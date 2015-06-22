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
	
	var searchController: UISearchController! = nil
	var resultProgramTableView: ProgramTableViewController! = nil
	var progressView: GSIndeterminateProgressView! = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		
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
		
		let navigationBar = self.navigationController!.navigationBar
		
		self.progressView = GSIndeterminateProgressView(frame: CGRect(x: 0, y: navigationBar.frame.size.height, width: navigationBar.frame.size.width, height: 2))
		self.progressView.progressTintColor = navigationBar.superview!.tintColor
		self.progressView.backgroundColor = UIColor.clearColor()
		self.progressView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
		navigationBar.addSubview(self.progressView)
		
		updateRecordingPrograms()
		
		self.refreshControl!.addTarget(self, action: Selector("updateRecordingPrograms"), forControlEvents: .ValueChanged)
		
		self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		
		self.definesPresentationContext = true

	}
	
	
	func updateRecordingPrograms() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		self.progressView.startAnimating()
		let manager = ChinachuPVRManager.sharedInstance
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
						let programStore = PVRProgramStore.by("id", equalTo: programId).find().firstObject() as! PVRProgramStore
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
						programStore.setOriginalObject(program)
						programStore.save()
					}
				}
				
				self.tableView.reloadData()
				self.resultProgramTableView.programIds = self.programIds
				self.resultProgramTableView.programsById = self.programsById
				self.resultProgramTableView.tableView.reloadData()
				
			})
			}, failure: { error in
				self.refreshControl!.endRefreshing()
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		})
	}
	
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

	
	func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		updateSearchResult(searchByText: searchBar.text!, inScope: selectedScope)
	}

}
