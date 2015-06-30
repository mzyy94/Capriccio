//
//  RecordingTableViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/15/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import GSIndeterminateProgressBar


class RecordingTableViewController: ProgramTableViewController, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
	
	// MARK: - Instance fileds
	
	var searchController: UISearchController! = nil
	var resultProgramTableView: ProgramTableViewController! = nil
	var progressView: GSIndeterminateProgressView! = nil
	
	
	// MARK: - View initialization
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Search controller initialization
		resultProgramTableView = ProgramTableViewController()
		resultProgramTableView.tableView.delegate = self
		
		self.searchController = UISearchController(searchResultsController: (resultProgramTableView))
		self.searchController.searchResultsUpdater = self
		self.searchController.dimsBackgroundDuringPresentation = true
		self.searchController.delegate = self
		self.searchController.searchBar.delegate = self
		self.searchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44)
		self.searchController.searchBar.scopeButtonTitles = ["Title", "Description"]
		
		self.tableView.tableHeaderView = self.searchController.searchBar
		self.tableView.tableHeaderView!.sizeToFit()
		
		self.definesPresentationContext = true
		
		
		// Progress view initialization
		let navigationBar = self.navigationController!.navigationBar
		
		self.progressView = GSIndeterminateProgressView(frame: CGRect(x: 0, y: navigationBar.frame.size.height, width: navigationBar.frame.size.width, height: 2))
		self.progressView.progressTintColor = navigationBar.superview!.tintColor
		self.progressView.backgroundColor = UIColor.clearColor()
		self.progressView.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
		navigationBar.addSubview(self.progressView)
		
		// Set refresh control action
		self.refreshControl!.addTarget(self, action: Selector("updateRecordingPrograms"), forControlEvents: .ValueChanged)
		
		// Show edit button
		self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		// Refresh recording programs
		updateRecordingPrograms()

		// Load stored data in Core Data
		for storedProgram in PVRProgramStore.by("state", equalTo: "\(PVRProgramState.Recording.rawValue.integerValue)").sorted(by: "startTime", ascending: true).find() {
			let program = (storedProgram as! PVRProgramStore).originalObject
			programsById[program.id] = program
			programIds.append(program.id)
		}
		self.tableView.reloadData()

	}
	
	// MARK: - Refreshing recording data
	
	func updateRecordingPrograms() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		self.progressView.startAnimating()
		let manager = ChinachuPVRManager.sharedManager
		manager.getRecording(success: { programs in
			self.refreshControl!.endRefreshing()
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			self.progressView.stopAnimating()
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
				var upstreamProgramIds: [String: Bool] = [:]
				for programs in programs {
					upstreamProgramIds[programs.id] = true
				}
				
				// Remove unexist program
				let programCount = self.programsById.count
				for (index, programId) in enumerate(self.programIds.reverse()) {
					if upstreamProgramIds[programId] == nil {
						self.programsById.removeValueForKey(self.programIds.removeAtIndex(programCount - 1 - index) as String)
						dispatch_sync(dispatch_get_main_queue(), {
							self.tableView.deleteSections(NSIndexSet(index: programCount - 1 - index), withRowAnimation: .Fade)
						})
						let programStore = PVRProgramStore.by("state", equalTo: "\(PVRProgramState.Recording.rawValue.integerValue)").by("id", equalTo: programId).find().firstObject() as! PVRProgramStore
						programStore.beginWriting().delete().endWriting()
					}
				}
				
				// Append unexist program
				for (index, program) in enumerate(programs.reverse()) {
					if self.programsById[program.id] == nil {
						self.programIds.insert(program.id, atIndex: index)
						self.programsById[program.id] = program
						dispatch_sync(dispatch_get_main_queue(), {
							self.tableView.insertSections(NSIndexSet(index: index), withRowAnimation: .Fade)
						})
						let programStore = PVRProgramStore.create() as! PVRProgramStore
						programStore.originalObject = program
						programStore.save()
					}
				}
				
				self.tableView.reloadData()
				self.resultProgramTableView.programIds = self.programIds
				self.resultProgramTableView.programsById = self.programsById
				self.resultProgramTableView.tableView.reloadData()
				
			})
			}, failure: { error in
				self.progressView.stopAnimatingAndShowColor(UIColor.paperColorRed500())
				self.refreshControl!.endRefreshing()
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		})
	}
	
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		let storyBoard = UIStoryboard(name: "Main", bundle: nil)
		let programDetailViewController = storyBoard.instantiateViewControllerWithIdentifier("ProgramDetailView") as! ProgramDetailViewController
		
		programDetailViewController.program = tableView == self.tableView ?
			programsById[self.programIds[indexPath.section]] :
			programsById[resultProgramTableView.programIds[indexPath.section]]
		
		self.navigationController!.pushViewController(programDetailViewController, animated: true)
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let storyBoard = UIStoryboard(name: "Main", bundle: nil)
		let videoPlayViewController = storyBoard.instantiateViewControllerWithIdentifier("VideoPlayView") as! VideoPlayViewController
		videoPlayViewController.program = tableView == self.tableView ?
			programsById[self.programIds[indexPath.section]] :
			programsById[resultProgramTableView.programIds[indexPath.section]]
		
		self.presentViewController(videoPlayViewController, animated: true, completion: nil)
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		let del = UITableViewRowAction(style: .Default, title: "Delete") {
			(action, indexPath) in
			let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this tv program?", preferredStyle: .Alert)
			confirmAlertView.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: {alertAction in
				let manager = ChinachuPVRManager.sharedManager
				
				manager.deleteProgram(self.programsById[self.programIds[indexPath.section]]!.id, success: {
					let programStore = PVRProgramStore.by("state", equalTo: "\(PVRProgramState.Recording.rawValue.integerValue)").by("id", equalTo: self.programsById[self.programIds[indexPath.section]]!.id).find().firstObject() as! PVRProgramStore
					programStore.beginWriting().delete().endWriting()
					self.programsById.removeValueForKey(self.programIds.removeAtIndex(indexPath.section) as String)

					tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)

					}, failure: nil)
			}))
			confirmAlertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {alertAction in }))
			
			self.parentViewController?.presentViewController(confirmAlertView, animated: true, completion: nil)
			
		}
		
		del.backgroundColor = UIColor.paperColorRed500()
		
		return [del]
	}

	
	// MARK: - Search controller methods
	
	func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		updateSearchResult(searchByText: searchBar.text!, inScope: selectedScope)
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		self.updateSearchResult(searchByText: searchController.searchBar.text!, inScope: searchController.searchBar.selectedScopeButtonIndex)
	}
	
	func updateSearchResult(searchByText searchText: String = "", inScope scope: Int = 0) {
		resultProgramTableView.programIds = []
		if searchText != "" {
			if scope == 0 {
				for programId in programIds {
					if programsById[programId]!.title.rangeOfString(searchText, options: .WidthInsensitiveSearch | .DiacriticInsensitiveSearch | .CaseInsensitiveSearch) != nil {
						resultProgramTableView.programIds.append(programId)
					}
				}
			} else {
				for programId in programIds {
					if programsById[programId]!.detail.rangeOfString(searchText, options: .WidthInsensitiveSearch | .DiacriticInsensitiveSearch | .CaseInsensitiveSearch) != nil {
						resultProgramTableView.programIds.append(programId)
					}
				}
			}
		}
		resultProgramTableView.tableView.reloadData()
	}

}
