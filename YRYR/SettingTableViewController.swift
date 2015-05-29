//
//  SettingTableViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

	@IBOutlet weak var pvrAddressTextField: UITextField!
	@IBOutlet weak var pvrUserTextField: UITextField!
	@IBOutlet weak var pvrPasswordTextField: UITextField!
	
	override func viewDidLoad() {
		
		func createLabel(text: String) -> UILabel {
			let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
			
			label.text = text
			label.textAlignment = .Left
			label.textColor = .blackColor()
			label.backgroundColor = .clearColor()
			
			return label
		}
		
        super.viewDidLoad()
		
		let userDefaults = NSUserDefaults()

		pvrAddressTextField.leftView = createLabel("Address")
		pvrAddressTextField.text = userDefaults.stringForKey("pvrUrl")
		pvrAddressTextField.leftViewMode = .Always
		
		pvrUserTextField.leftView = createLabel("Username")
		pvrUserTextField.text = userDefaults.stringForKey("pvrUser")
		pvrUserTextField.leftViewMode = .Always
		
		pvrPasswordTextField.leftView = createLabel("Password")
		pvrPasswordTextField.text = userDefaults.stringForKey("pvrPassword")
		pvrPasswordTextField.leftViewMode = .Always

    }

	@IBAction func saveButtonTapped(sender: AnyObject) {

		let userDefaults = NSUserDefaults()
		
		userDefaults.setObject(pvrAddressTextField.text, forKey: "pvrUrl")
		userDefaults.setObject(pvrUserTextField.text, forKey: "pvrUser")
		userDefaults.setObject(pvrPasswordTextField.text, forKey: "pvrPassword")

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
        return 3
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
