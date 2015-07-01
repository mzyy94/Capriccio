//
//  ProgramTableViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class ProgramTableViewController: UITableViewController {
	
	// MARK: - Instance fileds
	
	var programIds: [String] = []
	var programsById: [String: PVRProgram] = [:]
	let marginView = UIView()
	
	// MARK: - View initialization
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Cell registration
		let programCellNib = UINib(nibName: "ProgramInfoTableViewCell", bundle: nil)
		self.tableView.registerNib(programCellNib, forCellReuseIdentifier: "programCell")

		// Set table view style
		self.tableView.separatorStyle = .None
		self.tableView.backgroundColor = UIColor.paperColorBlueGray200()
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
		let cell = tableView.dequeueReusableCellWithIdentifier("programCell", forIndexPath: indexPath) as! ProgramInfoTableViewCell
		let program = programsById[programIds[indexPath.section]]!

		// Cell configuratoins
		NSNotificationCenter.defaultCenter().removeObserver(self, name: "accessoryButtonTapped", object: cell)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("accessoryButtonTapped:"), name: "accessoryButtonTapped", object: cell)
		cell.setCellEntities(program.title, subTitle: program.subTitle, genre: program.genre, channel: program.channel, episode: program.episode, startTime: program.startTime, duration: program.duration)

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
		let programDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProgramDetailView") as! ProgramDetailViewController
		
		programDetailViewController.program = programsById[programIds[indexPath.section]]
		
		self.navigationController?.pushViewController(programDetailViewController, animated: true)
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}

}
