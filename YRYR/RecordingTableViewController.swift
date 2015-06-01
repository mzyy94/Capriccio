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

	var programs : [PVRProgram] = []
	var selectedIndex: NSIndexPath! = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let userDefault = NSUserDefaults()
		let programCellNib = UINib(nibName: "ProgramInfoTableViewCell", bundle: nil)
		self.tableView.registerNib(programCellNib, forCellReuseIdentifier: "programCell")

		MRProgressOverlayView.showOverlayAddedTo(self.parentViewController?.view, title: "Loading...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
		
		let manager = ChinachuPVRManager(remoteHost: NSURL(string: userDefault.stringForKey("pvrUrl")!)!)
		manager.getRecording(success: { program in
			self.programs = program.reverse()
			MRProgressOverlayView.dismissAllOverlaysForView(self.parentViewController?.view, animated: true)
			self.tableView.reloadData()
			}, failure: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

		self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
		return programs.count
    }

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCellWithIdentifier("programCell", forIndexPath: indexPath) as! ProgramInfoTableViewCell
		let program = programs[indexPath.row]
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
		self.performSegueWithIdentifier("showProgramDetail", sender: self)
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		
		let del = UITableViewRowAction(style: .Default, title: "Delete") {
			(action, indexPath) in
			let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this tv program?", preferredStyle: UIAlertControllerStyle.Alert)
			confirmAlertView.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {alertAction in
				let userDefault = NSUserDefaults()
				let manager = ChinachuPVRManager(remoteHost: NSURL(string: userDefault.stringForKey("pvrUrl")!)!)
				
				manager.deleteProgram(self.programs[indexPath.row].id, success: {
					self.programs.removeAtIndex(indexPath.row)
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
			programDetailVC.program = programs[selectedIndex.row]
		}
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

}
