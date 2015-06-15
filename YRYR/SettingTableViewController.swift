//
//  SettingTableViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import KeychainAccess

class SettingTableViewController: UITableViewController {

	@IBOutlet weak var pvrAddressTextField: UITextField!
	@IBOutlet weak var pvrPortTextField: UITextField!
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

		let pvrUrl = userDefaults.stringForKey("pvrUrl")!
		let pvrPort = userDefaults.integerForKey("pvrPort")
		let pvrUser = userDefaults.stringForKey("pvrUser")!
		
		pvrAddressTextField.leftView = createLabel("Address")
		pvrAddressTextField.text = pvrUrl
		pvrAddressTextField.leftViewMode = .Always
		
		pvrPortTextField.leftView = createLabel("Port")
		pvrPortTextField.text = String(pvrPort)
		pvrPortTextField.leftViewMode = .Always
		
		pvrUserTextField.leftView = createLabel("Username")
		pvrUserTextField.text = pvrUser
		pvrUserTextField.leftViewMode = .Always
		
		pvrPasswordTextField.leftView = createLabel("Password")
		pvrPasswordTextField.leftViewMode = .Always
		
		let keychain = Keychain(server: "\(pvrUrl):\(pvrPort)",
			protocolType: pvrUrl.rangeOfString("^https://",
			options: .RegularExpressionSearch) != nil ? .HTTPS : .HTTP,
			authenticationType: .HTTPBasic)
		
		if let password = keychain.get(pvrUser) {
			pvrPasswordTextField.text = password
		} else {
			keychain.getSharedPassword(pvrUser) { (password, error) -> () in
				if password != nil {
					self.pvrPasswordTextField.text = password
					
					keychain[pvrUser] = password
				} else {
					self.pvrPasswordTextField.text = ""
				}
			}
		}

    }

	@IBAction func saveButtonTapped(sender: AnyObject) {

		let userDefaults = NSUserDefaults()
		
		let pvrUrl = pvrAddressTextField.text!
		let pvrPort = pvrPortTextField.text.toInt()!
		let pvrUser = pvrUserTextField.text!
		
		
		// TODO: check whether the authentication succeeded or not
		
		userDefaults.setObject(pvrUrl, forKey: "pvrUrl")
		userDefaults.setInteger(pvrPort, forKey: "pvrPort")
		userDefaults.setObject(pvrUser, forKey: "pvrUser")
		
		let keychain = Keychain(server: "\(pvrUrl):\(pvrPort)", protocolType: pvrUrl.rangeOfString("^https://", options: .RegularExpressionSearch) != nil ? .HTTPS : .HTTP, authenticationType: .HTTPBasic)
		
		
		let pvrPass = pvrPasswordTextField.text
		
		keychain[pvrUser] = pvrPass
		keychain.setSharedPassword(pvrPass, account: pvrUser)
		
		ChinachuPVRManager.sharedInstance.remoteHost = NSURL(string: "\(pvrUrl):\(pvrPort)")!

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
        return 4
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
