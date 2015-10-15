//
//  SettingTableViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import KeychainAccess

class SettingTableViewController: UITableViewController, UITextFieldDelegate {

	// MARK: - Interface Builder outlets
	
	@IBOutlet weak var pvrAddressTextField: UITextField!
	@IBOutlet weak var pvrPortTextField: UITextField!
	@IBOutlet weak var pvrUserTextField: UITextField!
	@IBOutlet weak var pvrPasswordTextField: UITextField!
	
	
	// MARK: - Interface Builder actions
	
	@IBAction func saveButtonTapped(sender: AnyObject) {

		let userDefaults = NSUserDefaults()
		
		// Get value from text field
		let pvrUrl = pvrAddressTextField.text!
		let pvrPort = Int(pvrPortTextField.text!)!
		let pvrUser = pvrUserTextField.text!
		
		
		// TODO: check whether the authentication succeeded or not
		
		// Save values
		userDefaults.setObject(pvrUrl, forKey: "pvrUrl")
		userDefaults.setInteger(pvrPort, forKey: "pvrPort")
		userDefaults.setObject(pvrUser, forKey: "pvrUser")
		
		// Save confidential value
		let keychain = Keychain(server: "\(pvrUrl):\(pvrPort)", protocolType: pvrUrl.rangeOfString("^https://", options: .RegularExpressionSearch) != nil ? .HTTPS : .HTTP, authenticationType: .HTTPBasic)
		let pvrPass = pvrPasswordTextField.text
		
		keychain[pvrUser] = pvrPass
		keychain.setSharedPassword(pvrPass!, account: pvrUser)
		
		// Set new url to PVRManager
		ChinachuPVRManager.sharedManager.remoteHost = NSURL(string: "\(pvrUrl):\(pvrPort)")!

		closeKeyboard(sender)
	}
	
	@IBAction func cancelButtonTapped(sender: AnyObject) {
		closeKeyboard(sender)
	}
	
	
	// MARK: - View initialization
	
	override func viewDidLoad() {
		// Local function for label generation
		func createLabel(text: String) -> UILabel {
			let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
			
			label.text = text
			label.textAlignment = .Left
			label.textColor = .blackColor()
			label.backgroundColor = .clearColor()
			
			return label
		}
		
		super.viewDidLoad()

		// Keyboard toolbar setup
		let toolBar = UIToolbar()
		
		let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
		let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("closeKeyboard:"))

		toolBar.items = [spacer, done]
		toolBar.sizeToFit()
		
		
		// TextField setup
		let userDefaults = NSUserDefaults()

		let pvrUrl = userDefaults.stringForKey("pvrUrl")!
		let pvrPort = userDefaults.integerForKey("pvrPort")
		let pvrUser = userDefaults.stringForKey("pvrUser")!
		
		pvrAddressTextField.leftView = createLabel("Address")
		pvrAddressTextField.text = pvrUrl
		pvrAddressTextField.leftViewMode = .Always
		pvrAddressTextField.delegate = self
		pvrAddressTextField.inputAccessoryView = toolBar
		
		pvrPortTextField.leftView = createLabel("Port")
		pvrPortTextField.text = String(pvrPort)
		pvrPortTextField.leftViewMode = .Always
		pvrPortTextField.delegate = self
		pvrPortTextField.inputAccessoryView = toolBar
		
		pvrUserTextField.leftView = createLabel("Username")
		pvrUserTextField.text = pvrUser
		pvrUserTextField.leftViewMode = .Always
		pvrUserTextField.delegate = self
		pvrUserTextField.inputAccessoryView = toolBar
		
		pvrPasswordTextField.leftView = createLabel("Password")
		pvrPasswordTextField.leftViewMode = .Always
		pvrPasswordTextField.delegate = self
		pvrPasswordTextField.inputAccessoryView = toolBar
		
		
		// Get saved password from Keychain service
		let keychain = Keychain(server: "\(pvrUrl):\(pvrPort)",
			protocolType: pvrUrl.rangeOfString("^https://",
			options: .RegularExpressionSearch) != nil ? .HTTPS : .HTTP,
			authenticationType: .HTTPBasic)
		
		if let password = try? keychain.get(pvrUser) {
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
	
	
	// MARK: - Memory/resource management
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	// MARK: - Keyboard show/hide methods

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		switch textField {
		case pvrAddressTextField:
			pvrPortTextField.becomeFirstResponder()
		case pvrPortTextField:
			pvrUserTextField.becomeFirstResponder()
		case pvrUserTextField:
			pvrPasswordTextField.becomeFirstResponder()
		default:
			textField.resignFirstResponder()
		}
		
		return true
	}
	
	func closeKeyboard(sender: AnyObject) {
		pvrAddressTextField.resignFirstResponder()
		pvrPortTextField.resignFirstResponder()
		pvrUserTextField.resignFirstResponder()
		pvrPasswordTextField.resignFirstResponder()
	}
	
	// MARK: - Table view data source

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Return number of settings
		return 4
	}
	
}
