//
//  ReservingTableViewController.swift
//  Capriccio
//
//  Created by Yuki MIZUNO on 6/22/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import GSIndeterminateProgressBar


class ReservingTableViewController: ProgramTableViewController, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
	
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
		self.progressView = GSIndeterminateProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 2))
		self.progressView.progressTintColor = UIColor.paperColorBlue400()
		self.progressView.backgroundColor = UIColor.clearColor()
		self.progressView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
		self.navigationController?.view.addSubview(self.progressView)
		
		// Set refresh control action
		self.refreshControl!.addTarget(self, action: Selector("updateReservingPrograms"), forControlEvents: .ValueChanged)
		
		// Show edit button
		self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		// Load stored data in Core Data
		for storedProgram in PVRProgramStore.by("state >= 2").sorted(by: "startTime", ascending: false).find() {
			let program = (storedProgram as! PVRProgramStore).originalObject
			programsById[program.id] = program
			programIds.append(program.id)
		}
		
		self.tableView.reloadData()

		// Refresh reserving programs
		updateReservingPrograms()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	// MARK: - Refreshing reserving data
	
	func updateReservingPrograms() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		self.progressView.startAnimating()
		let manager = ChinachuPVRManager.sharedManager
		manager.getReserving({ programs in
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
				for (index, programId) in self.programIds.reverse().enumerate() {
					if upstreamProgramIds[programId] == nil {
						self.programsById.removeValueForKey(self.programIds.removeAtIndex(programCount - 1 - index) as String)
						dispatch_sync(dispatch_get_main_queue(), {
							self.tableView.deleteSections(NSIndexSet(index: programCount - 1 - index), withRowAnimation: .Fade)
						})
						let programStore = PVRProgramStore.by("state >= 2").by("id", equalTo: programId).find().firstObject() as! PVRProgramStore
						programStore.beginWriting().delete().endWriting()
					}
				}
				
				// Append unexist program
				for (index, program) in programs.enumerate() {
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
				self.refreshControl!.endRefreshing()
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		})
	}
	

	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
		cell.accessoryView = nil
		return cell
	}

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		switch programsById[programIds[indexPath.section]]!.state {
		case .AutomaticReserving:
			let skip = UITableViewRowAction(style: .Default, title: "Skip") {
				(action, indexPath) in
				let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to skip this reservation?", preferredStyle: .Alert)
				confirmAlertView.addAction(UIAlertAction(title: "Skip", style: .Destructive, handler: {alertAction in
					let manager = ChinachuPVRManager.sharedManager
					
					manager.skipReserving(self.programsById[self.programIds[indexPath.section]]!.id, success: {
						let programStore = PVRProgramStore.by("state >= 2").by("id", equalTo: self.programsById[self.programIds[indexPath.section]]!.id).find().firstObject() as! PVRProgramStore
						programStore.beginWriting()
						programStore.state = PVRProgramState.SkippedReserving.rawValue.integerValue
						programStore.endWriting()
						self.programsById[self.programIds[indexPath.section]]!.state = .SkippedReserving
						}, failure: nil)
				}))
				confirmAlertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {alertAction in }))
				
				self.parentViewController?.presentViewController(confirmAlertView, animated: true, completion: nil)
				
			}
			
			skip.backgroundColor = UIColor.clearColor()
			
			return [skip]
		case .ManualReserving:
			let remove = UITableViewRowAction(style: .Default, title: "Remove") {
				(action, indexPath) in
				let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to remove this reservation?", preferredStyle: .Alert)
				confirmAlertView.addAction(UIAlertAction(title: "Remove", style: .Destructive, handler: {alertAction in
					let manager = ChinachuPVRManager.sharedManager
					
					manager.cancelReserving(self.programsById[self.programIds[indexPath.section]]!.id, success: {
						let programStore = PVRProgramStore.by("state >= 2").by("id", equalTo: self.programsById[self.programIds[indexPath.section]]!.id).find().firstObject() as! PVRProgramStore
						programStore.beginWriting().delete().endWriting()
						self.programsById.removeValueForKey(self.programIds.removeAtIndex(indexPath.section) as String)
						
						tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
						
						}, failure: nil)
				}))
				confirmAlertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {alertAction in }))
				
				self.parentViewController?.presentViewController(confirmAlertView, animated: true, completion: nil)
				
			}
			
			remove.backgroundColor = UIColor.clearColor()
			
			return [remove]
		case .SkippedReserving:
			let unskip = UITableViewRowAction(style: .Default, title: "Unskip") {
				(action, indexPath) in
				let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to unskip this reservation?", preferredStyle: .Alert)
				confirmAlertView.addAction(UIAlertAction(title: "Unskip", style: .Destructive, handler: {alertAction in
					let manager = ChinachuPVRManager.sharedManager
					
					manager.unskipReserving(self.programsById[self.programIds[indexPath.section]]!.id, success: {
						let programStore = PVRProgramStore.by("state >= 2").by("id", equalTo: self.programsById[self.programIds[indexPath.section]]!.id).find().firstObject() as! PVRProgramStore
						programStore.beginWriting()
						programStore.state = PVRProgramState.AutomaticReserving.rawValue.integerValue
						programStore.endWriting()
						self.programsById[self.programIds[indexPath.section]]!.state = .AutomaticReserving
						}, failure: nil)
				}))
				confirmAlertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {alertAction in }))
				
				self.parentViewController?.presentViewController(confirmAlertView, animated: true, completion: nil)
			}
			
			unskip.backgroundColor = UIColor.clearColor()
			
			return [unskip]
		default:
			return []
		}
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
					if programsById[programId]!.title.rangeOfString(searchText, options: [.WidthInsensitiveSearch, .DiacriticInsensitiveSearch, .CaseInsensitiveSearch]) != nil {
						resultProgramTableView.programIds.append(programId)
					}
				}
			} else {
				for programId in programIds {
					if programsById[programId]!.detail.rangeOfString(searchText, options: [.WidthInsensitiveSearch, .DiacriticInsensitiveSearch, .CaseInsensitiveSearch]) != nil {
						resultProgramTableView.programIds.append(programId)
					}
				}
			}
		}
		resultProgramTableView.tableView.reloadData()
	}

}
