//
//  PVRProgramStore.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/2/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import Foundation
import CoreData

class PVRProgramStore: NSManagedObject {
	
	// MARK: - Managed instance fileds
	
	@NSManaged var attributes: String
	@NSManaged var detail: String
	@NSManaged var duration: NSNumber
	@NSManaged var endTime: NSDate
	@NSManaged var episode: NSNumber
	@NSManaged var fullTitle: String
	@NSManaged var genre: String
	@NSManaged var id: String
	@NSManaged var startTime: NSDate
	@NSManaged var state: NSNumber
	@NSManaged var subTitle: String
	@NSManaged var title: String
	@NSManaged var channel: PVRChannelStore
	
	
	// MARK: - Unmanaged instance fileds
	
	var originalObject: PVRProgram {
		get {
			return PVRProgram(id: id, title: title, fullTitle: fullTitle, subTitle: subTitle,
				detail: detail, attributes: split(attributes) { contains(",", $0) }, genre: genre,
				channel: channel.originalObject, episode: Int(episode), startTime: startTime,
				endTime: endTime, duration: NSTimeInterval(duration), state: PVRProgramState(rawValue: state)! ,userData: nil)
		}
		set (object) {
			self.attributes = join(",", object.attributes)
			self.detail = object.detail
			self.duration = object.duration
			self.endTime = object.endTime
			self.episode = object.episode!
			self.fullTitle = object.fullTitle
			self.genre = object.genre
			self.id = object.id
			self.startTime = object.startTime
			self.state = object.state.rawValue
			self.subTitle = object.subTitle
			self.title = object.title
			if let channel = PVRChannelStore.by("id", equalTo: object.channel.id).find(inContext: self.context()).firstObject() as? PVRChannelStore {
				self.channel = channel
			} else {
				let channel = PVRChannelStore.create(inContext: self.context()) as! PVRChannelStore
				channel.originalObject = object.channel
				channel.save()
				self.channel = channel
			}
		}
	}
	
}
