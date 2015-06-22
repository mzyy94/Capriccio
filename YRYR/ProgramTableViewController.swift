//
//  ProgramTableViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class ProgramTableViewController: UITableViewController {

	var programIds: [String] = []
	var programsById: [String: PVRProgram] = [:]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let programCellNib = UINib(nibName: "ProgramInfoTableViewCell", bundle: nil)
		self.tableView.registerNib(programCellNib, forCellReuseIdentifier: "programCell")

		for storedProgram in PVRProgramStore.all().sorted(by: "startTime", ascending: true).find() {
			let program = (storedProgram as! PVRProgramStore).getOriginalObject()
			programsById[program.id] = program
			programIds.append(program.id)
		}
		
		self.tableView.separatorStyle = .None
		
		self.tableView.reloadData()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return programIds.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
		return 1
    }

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCellWithIdentifier("programCell", forIndexPath: indexPath) as! ProgramInfoTableViewCell
		let program = programsById[programIds[indexPath.section]]!
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
		let programDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProgramDetailView") as! ProgramDetailViewController
		
		programDetailViewController.program = programsById[programIds[indexPath.section]]
		
		self.navigationController?.pushViewController(programDetailViewController, animated: true)
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		
		let del = UITableViewRowAction(style: .Default, title: "Delete") {
			(action, indexPath) in
			let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this tv program?", preferredStyle: UIAlertControllerStyle.Alert)
			confirmAlertView.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {alertAction in
				let manager = ChinachuPVRManager.sharedInstance
				
				manager.deleteProgram(self.programsById[self.programIds[indexPath.section]]!.id, success: {
					let programStore = PVRProgramStore.by("id", equalTo: self.programsById[self.programIds[indexPath.section]]!.id).find().firstObject() as! PVRProgramStore
					programStore.beginWriting().delete().endWriting()
					self.programsById.removeValueForKey(self.programIds.removeAtIndex(indexPath.section) as String)

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

}
