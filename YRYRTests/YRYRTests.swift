//
//  YRYRTests.swift
//  YRYRTests
//
//  Created by Yuki MIZUNO on 5/29/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import XCTest

class YRYRTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testExample() {
		// This is an example of a functional test case.
		XCTAssert(true, "Pass")
	}

	func testChinachuPVRManager() {
		let scheduleExpectation = self.expectationWithDescription("Schedule test")
		let reservingExpectation = self.expectationWithDescription("Reserving test")
		let recordingExpectation = self.expectationWithDescription("Recording test")
		
		let manager = ChinachuPVRManager()
		manager.remoteHost = NSURL(string: "http://chinachu:10772")!

		manager.getSchedule(
			{program in
				scheduleExpectation.fulfill()
			}, failure: {error in
				XCTFail("\(error)")
				scheduleExpectation.fulfill()
		})
		
		manager.getReserving(
			{program in
				reservingExpectation.fulfill()
			}, failure: {error in
				XCTFail("\(error)")
				reservingExpectation.fulfill()
		})
		
		manager.getRecording(
			{program in
				recordingExpectation.fulfill()
			}, failure: {error in
				XCTFail("\(error)")
				recordingExpectation.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(60, handler: nil)
	}
	
	func testMusicStoreManager() {
		let musicSearchExpectation = self.expectationWithDescription("Music search test")
		
		let manager = MusicStoreManager()
		
		manager.getRelatedMusicTracks("ご注文はうさぎですか？",
			success: {tracks in
				musicSearchExpectation.fulfill()
			}, failure: {error in
				XCTFail("\(error)")
				musicSearchExpectation.fulfill()
		})
		
		
		self.waitForExpectationsWithTimeout(60, handler: nil)
	}
	
	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measureBlock() {
			// Put the code you want to measure the time of here.
		}
	}
	
}
