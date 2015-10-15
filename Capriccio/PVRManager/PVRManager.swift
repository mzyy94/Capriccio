//
//  PVRManager.swift
//  Capriccio
//
//  Created by Yuki MIZUNO on 5/29/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class PVRManager: NSObject {
	
	// MARK: - Instance fileds
	
	var remoteHost: NSURL!
	
	
	// MARK: - Initialization
	
	override init() {
		super.init()
	}
	
	
	// MARK: - Abstract methods
	
	func getReserving(success: (([PVRProgram]) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		fatalError("must be overridden")
	}
		
	func getRecording(success: (([PVRProgram]) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		fatalError("must be overridden")
	}
}
