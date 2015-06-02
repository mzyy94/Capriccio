//
//  RecordingTableViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import MRProgress

class RecordingTableViewController: UITableViewController {

	var programIds: [String] = []
	var programsById: [String: PVRProgram] = [:]
	var selectedIndex: NSIndexPath! = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let programCellNib = UINib(nibName: "ProgramInfoTableViewCell", bundle: nil)
		self.tableView.registerNib(programCellNib, forCellReuseIdentifier: "programCell")

		updateRecordingPrograms()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		for storedProgram in PVRProgramStore.all().sorted(by: "startTime", ascending: true).find() {
			let program = (storedProgram as! PVRProgramStore).getOriginalObject()
			programsById[program.id] = program
			programIds.append(program.id)
		}
		
		tableView.reloadData()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func updateRecordingPrograms() {
		let userDefault = NSUserDefaults()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let manager = ChinachuPVRManager(remoteHost: NSURL(string: userDefault.stringForKey("pvrUrl")!)!)
		manager.getRecording(success: { programs in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false

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
							self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: programCount - 1 - index, inSection: 0)], withRowAnimation: .Fade)
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
							self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
						})
						let programStore = PVRProgramStore.create() as! PVRProgramStore
						programStore.setOriginalObject(program)
						programStore.save()
					}
				}
				
				self.tableView.reloadData()
			})
			}, failure: { error in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		})
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
		return programsById.count
    }

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCellWithIdentifier("programCell", forIndexPath: indexPath) as! ProgramInfoTableViewCell
		let program = programsById[programIds[indexPath.row]]!
		let dateFormatter = NSDateFormatter()
		
		dateFormatter.dateFormat = "yyyy/MM/dd HH:mm-"
		
		cell.accessoryType = UITableViewCellAccessoryType.DetailButton
		cell.tintColor = .grayColor()
		cell.titleLabel.text = program.title
		cell.subTitleLabel.text = program.subTitle
		cell.genreLabel.text = program.genre
		cell.episodeLabel.text = program.episode != nil && program.episode > 0 ? "#\(program.episode!) " : ""
		cell.durationLabel.text = "\(Int(program.duration / 60)) min."
		cell.dateLabel.text = dateFormatter.stringFromDate(program.startTime)
		

        return cell
    }
	

	override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		selectedIndex = indexPath
		PVRProgramStore.all().find()
		self.performSegueWithIdentifier("showProgramDetail", sender: self)
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		
		let del = UITableViewRowAction(style: .Default, title: "Delete") {
			(action, indexPath) in
			let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this tv program?", preferredStyle: UIAlertControllerStyle.Alert)
			confirmAlertView.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {alertAction in
				let userDefault = NSUserDefaults()
				let manager = ChinachuPVRManager(remoteHost: NSURL(string: userDefault.stringForKey("pvrUrl")!)!)
				
				manager.deleteProgram(self.programsById[self.programIds[indexPath.row]]!.id, success: {
					let programStore = PVRProgramStore.by("id", equalTo: self.programsById[self.programIds[indexPath.row]]!.id).find().firstObject() as! PVRProgramStore
					programStore.beginWriting().delete().endWriting()
					self.programsById.removeValueForKey(self.programIds.removeAtIndex(indexPath.row) as String)

					tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

					}, failure: nil)
			}))
			confirmAlertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {alertAction in }))
			
			self.parentViewController?.presentViewController(confirmAlertView, animated: true, completion: nil)
			
		}
		
		del.backgroundColor = UIColor.redColor()
		
		return [del]
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		selectedIndex = indexPath
		self.performSegueWithIdentifier("playVideo", sender: self)
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showProgramDetail" {
			let programDetailVC = segue.destinationViewController as! ProgramDetailViewController
			programDetailVC.program = programsById[programIds[selectedIndex.row]]
		} else if segue.identifier == "playVideo" {
			let videoPlayVC = segue.destinationViewController as! VideoPlayViewController
			videoPlayVC.program = programsById[programIds[selectedIndex.row]]
		}
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

}
