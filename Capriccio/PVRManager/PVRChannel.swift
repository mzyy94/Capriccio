//
//  PVRChannel.swift
//  Capriccio
//
//  Created by Yuki MIZUNO on 5/29/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class PVRChannel: NSObject {
	
	// MARK: - Instance fileds
	
	let id: String
	let channel: Int
	let name: String
	let number: Int
	let sid: Int
	let type: String
	let userData: AnyObject?
	
	
	// MARK: - Initialization

	init(id: String, channel: Int, name: String, number: Int, sid: Int, type: String, userData: NSObject?) {
		self.id = id
		self.channel = channel
		self.name = name
		self.number = number
		self.sid = sid
		self.type = type
		self.userData = userData
	}
	
	init(fromDictionary dict: NSDictionary) {
		self.id = dict["id"] as! String
		self.channel = dict["channel"] as! Int
		self.name = dict["name"] as! String
		self.number = dict["number"] as! Int
		self.sid = dict["sid"] as! Int
		self.type = dict["type"] as! String
		self.userData = dict["userData"] as? NSObject
	}
	
}
