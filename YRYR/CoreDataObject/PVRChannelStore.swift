//
//  PVRChannelStore.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/2/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import Foundation
import CoreData

class PVRChannelStore: NSManagedObject {

    @NSManaged var channel: NSNumber
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var number: NSNumber
    @NSManaged var sid: NSNumber
    @NSManaged var type: String
	
	func getOriginalObject() -> PVRChannel {
		return PVRChannel(id: id, channel: Int(channel), name: name, number: Int(number), sid: Int(sid), type: type, userData: nil)
	}
	
	func setOriginalObject(object: PVRChannel) {
		self.channel = object.channel
		self.id = object.id
		self.name = object.name
		self.number = object.number
		self.sid = object.sid
		self.type = object.type
	}

}
