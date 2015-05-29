//
//  PVRProgram.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/29/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class PVRProgram: NSObject {
	
	let id: String
	
	let title: String
	let fullTitle: String
	let subTitle: String
	let detail: String
	let attributes: [String]
	
	let genre: String
	let channel: PVRChannel
	let episode: Int?
	
	let startTime: NSDate
	let endTime: NSDate
	let duration: NSTimeInterval
	
	let userData: AnyObject?
	
	init(id: String, title: String, fullTitle: String, subTitle: String, detail: String,
		attributes: [String], genre: String, channel: PVRChannel, episode: Int?,
		startTime: NSDate, endTime: NSDate, duration: NSTimeInterval, userData: NSObject?) {
			
			self.id = id
			self.title = title
			self.fullTitle = fullTitle
			self.subTitle = subTitle
			self.detail = detail
			self.attributes = attributes
			self.genre = genre
			self.channel = channel
			self.episode = episode
			self.startTime = startTime
			self.endTime = endTime
			self.duration = duration
			self.userData = userData
			
	}
	
	init(fromDictionary dict: NSDictionary) {
		
		self.id = dict["id"] as! String
		self.title = dict["title"] as! String
		self.fullTitle = dict["fullTitle"] as! String
		self.subTitle = dict["subTitle"] as! String
		self.detail = dict["detail"] as! String
		self.attributes = dict["attributes"] as! [String]
		self.genre = dict["genre"] as! String
		self.channel = dict["channel"] as! PVRChannel
		self.episode = dict["episode"] as? Int
		self.startTime = dict["startTime"] as! NSDate
		self.endTime = dict["endTime"] as! NSDate
		self.duration = dict["duration"] as! NSTimeInterval
		self.userData = dict["userData"] as? NSObject
		
	}
	
	func isOnAir() -> Bool {
		let now = NSDate.new()
		let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
		
		
		return .OrderedDescending == calendar.compareDate(now, toDate: startTime, toUnitGranularity: .SecondCalendarUnit) &&
			.OrderedAscending == calendar.compareDate(now, toDate: endTime, toUnitGranularity: .SecondCalendarUnit)
	}

}
