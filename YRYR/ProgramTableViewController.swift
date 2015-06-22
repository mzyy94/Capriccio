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
	
	
	// MARK: - View initialization
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Cell registration
		let programCellNib = UINib(nibName: "ProgramInfoTableViewCell", bundle: nil)
		self.tableView.registerNib(programCellNib, forCellReuseIdentifier: "programCell")

		// Set table view style
		self.tableView.separatorStyle = .None
		
		// Load stored data in Core Data
		for storedProgram in PVRProgramStore.all().sorted(by: "startTime", ascending: true).find() {
			let program = (storedProgram as! PVRProgramStore).originalObject
			programsById[program.id] = program
			programIds.append(program.id)
		}
		
		self.tableView.reloadData()
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

		// Date formation
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy/MM/dd HH:mm-"
		
		// Cell configuratoins
		cell.accessoryType = .DetailButton
		cell.titleLabel.text = program.title
		cell.subTitleLabel.text = program.subTitle
		cell.genreLabel.text = program.genre
		cell.episodeLabel.text = program.episode != nil && program.episode > 0 ? "#\(program.episode!) " : ""
		cell.durationLabel.text = "\(Int(program.duration / 60)) min."
		cell.dateLabel.text = dateFormatter.stringFromDate(program.startTime)

		return cell
	}

	override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		let programDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProgramDetailView") as! ProgramDetailViewController
		
		programDetailViewController.program = programsById[programIds[indexPath.section]]
		
		self.navigationController?.pushViewController(programDetailViewController, animated: true)
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 58
	}
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 10
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView()
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
