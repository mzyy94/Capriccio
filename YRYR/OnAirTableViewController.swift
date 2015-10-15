//
//  OnAirTableViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 7/6/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import GSIndeterminateProgressBar
import SugarRecord

class OnAirTableViewController: UITableViewController {
	
	// MARK: - Instance fileds
	
	var programIds: [String] = []
	var programsById: [String: PVRProgram] = [:]
	let marginView = UIView()
	var progressView: GSIndeterminateProgressView! = nil

	
	// MARK: - View initialization
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.clearsSelectionOnViewWillAppear = false

		// Cell registration
		let onAirCellNib = UINib(nibName: "OnAirChannelTableViewCell", bundle: nil)
		self.tableView.registerNib(onAirCellNib, forCellReuseIdentifier: "OnAirCell")
		
		// Set table view style
		self.tableView.separatorStyle = .None
		self.tableView.backgroundColor = UIColor.paperColorGray50()
		
		// Clear Back button
		self.navigationItem.backBarButtonItem?.title = ""
		
		// Progress view initialization
		self.progressView = GSIndeterminateProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 2))
		self.progressView.progressTintColor = UIColor.paperColorBlue400()
		self.progressView.backgroundColor = UIColor.clearColor()
		self.progressView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
		self.navigationController?.view.addSubview(self.progressView)
		
		// Set refresh control action
		self.refreshControl!.addTarget(self, action: Selector("updateSchedule"), forControlEvents: .ValueChanged)
		
		// Refresh schedule
		updateSchedule()
		
		// Load stored data in Core Data
		for storedProgram in PVRProgramStore.by("state", equalTo: "\(PVRProgramState.None.rawValue.integerValue)").sorted(by: "startTime", ascending: true).find() {
			let program = (storedProgram as! PVRProgramStore).originalObject
			if program.isOnAir() {
				programsById[program.id] = program
				programIds.append(program.id)
			}
		}
		self.tableView.reloadData()
		
	}
	
	// MARK: - Refreshing schedule
	
	func updateSchedule() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		self.progressView.startAnimating()
		let manager = ChinachuPVRManager.sharedManager
		manager.getSchedule({ programs in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
				// Refresh stored schedule
				SugarRecord.operation(inBackground: true, stackType: .SugarRecordEngineCoreData, closure: { context in
					let programStore = PVRProgramStore.by("state", equalTo: "\(PVRProgramState.None.rawValue.integerValue)").find(inContext: context)
					context.beginWriting()
					for pStore in programStore {
						(pStore as! PVRProgramStore).delete()
					}
					for program: PVRProgram in programs {
						let programStore = PVRProgramStore.create(inContext: context) as! PVRProgramStore
						programStore.originalObject = program
						context.insertObject(programStore)
						if program.isOnAir() {
							self.programsById[program.id] = program
							self.programIds.append(program.id)
						}
					}
					context.endWriting()
					
					dispatch_sync(dispatch_get_main_queue(), {
						self.refreshControl!.endRefreshing()
						self.progressView.stopAnimating()
						self.tableView.reloadData()
					})
				})
			})
			}, failure: { error in
				self.progressView.stopAnimatingAndShowColor(UIColor.paperColorRed500())
				self.refreshControl!.endRefreshing()
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		})
	}
	
	
	// MARK: - Memory/resource management
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Return the number of programs
		return programIds.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Return 1, because each section has only 1 program
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("OnAirCell", forIndexPath: indexPath) as! OnAirChannelTableViewCell
		let program = programsById[programIds[indexPath.section]]!
		
		// Cell configuratoins
		cell.channelNameLabel.text = program.channel.name
		cell.programTitleLabel.text = program.title
        cell.programDetailLabel.text = program.detail
        cell.programDurationLabel.text = "\(Int(program.duration / 60))min"

        // Date formation
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm-"
        cell.programStartTimeLabel.text = dateFormatter.stringFromDate(program.startTime)

        cell.channelNumberLabel.text = "\(program.channel.channel)"
		
		return cell
	}
	
	func accessoryButtonTapped(notification: NSNotification) {
		let touch = notification.userInfo!["touch"] as! UITouch
		let touchPoint = touch.locationInView(self.tableView)
		let indexPath = self.tableView.indexPathForRowAtPoint(touchPoint)!
		let videoPlayViewController = self.storyboard!.instantiateViewControllerWithIdentifier("VideoPlayView") as! VideoPlayViewController
		videoPlayViewController.program = programsById[programIds[indexPath.section]]
		
		self.presentViewController(videoPlayViewController, animated: true, completion: nil)
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 84
	}
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 10
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return marginView
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let videoPlayViewController = self.storyboard!.instantiateViewControllerWithIdentifier("VideoPlayView") as! VideoPlayViewController
        videoPlayViewController.program = programsById[programIds[indexPath.section]]
        
        self.presentViewController(videoPlayViewController, animated: true, completion: nil)
    }
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}


}
