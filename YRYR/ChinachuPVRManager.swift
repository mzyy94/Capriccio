//
//  ChinachuPVRManager.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/29/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum ChinachuPVRDeleteMode {
	case File
	case Information
	case All
}

class ChinachuPVRManager: PVRManager {
	
	override init(remoteHost: NSURL) {
		super.init(remoteHost: remoteHost)
	}
	
	override func getReserving(success: (([PVRProgram]) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		Alamofire.request(.GET, remoteHost.absoluteString! + "/api/reserves.json")
			.responseJSON { (request, response, data, error) in
				if error != nil {
					failure(error!)
				} else {
					let json = JSON(data!)
					var programs: [PVRProgram] = []
					for prog in json.arrayValue {
						let ch = prog["channel"]
						let channel = PVRChannel(id: ch["id"].stringValue, channel: ch["channel"].intValue,
							name: ch["name"].stringValue, number: ch["n"].intValue, sid: ch["sid"].intValue,
							type: ch["type"].stringValue, userData: nil)
						
						var attrs: [String] = []
						for attr in prog["flags"].arrayValue {
							attrs.append(attr.stringValue)
						}
						let program = PVRProgram(id: prog["id"].stringValue, title: prog["title"].stringValue,
							fullTitle: prog["fullTitle"].stringValue, subTitle: prog["subTitle"].stringValue,
							detail: prog["detail"].stringValue, attributes: attrs, genre: prog["category"].stringValue,
							channel: channel, episode: prog["episode"].intValue,
							startTime: NSDate(timeIntervalSince1970: NSTimeInterval(prog["start"].intValue / 1000)),
							endTime: NSDate(timeIntervalSince1970: NSTimeInterval(prog["end"].intValue / 1000)),
							duration: NSTimeInterval(prog["seconds"].intValue), userData: nil)
						
						programs.append(program)
					}
					success(programs)
				}
		}
	}
	
	func getPreviewImage(programId: String, isRecording: Bool = false, time: Int = 50, success: ((NSData) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		Alamofire.request(.GET, remoteHost.absoluteString! + "/api/recorded/" + programId + "/preview.jpg?pos=\(time)")
			.response { (request, response, data, error) in
				if error != nil {
					failure(error!)
				} else {
					success(data as! NSData)
				}
		}
	}

	func getPreviewImageUrl(programId: String, isRecording: Bool = false, time: Int = 50) -> NSURL {
		return NSURL(string: remoteHost.absoluteString! + "/api/" + (isRecording ? "recording/" : "recorded/") + programId + "/preview.jpg?pos=\(time)")!
	}
		
	func getStreamingUrl(programId: String, isRecording: Bool = false) -> NSURL {
		return NSURL(string: remoteHost.absoluteString! + "/api/" + (isRecording ? "recording/" : "recorded/") + programId + "/watch.m2ts?ext=m2ts&c:v=copy&c:a=copy")!
	}

	
	override func getRecording(success: (([PVRProgram]) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		Alamofire.request(.GET, remoteHost.absoluteString! + "/api/recorded.json")
			.responseJSON { (request, response, data, error) in
				if error != nil {
					failure(error!)
				} else {
					let json = JSON(data!)
					var programs: [PVRProgram] = []
					for prog in json.arrayValue {
						let ch = prog["channel"]
						let channel = PVRChannel(id: ch["id"].stringValue, channel: ch["channel"].intValue,
							name: ch["name"].stringValue, number: ch["n"].intValue, sid: ch["sid"].intValue,
							type: ch["type"].stringValue, userData: nil)
						
						var attrs: [String] = []
						for attr in prog["flags"].arrayValue {
							attrs.append(attr.stringValue)
						}
						let program = PVRProgram(id: prog["id"].stringValue, title: prog["title"].stringValue,
							fullTitle: prog["fullTitle"].stringValue, subTitle: prog["subTitle"].stringValue,
							detail: prog["detail"].stringValue, attributes: attrs, genre: prog["category"].stringValue,
							channel: channel, episode: prog["episode"].intValue,
							startTime: NSDate(timeIntervalSince1970: NSTimeInterval(prog["start"].intValue / 1000)),
							endTime: NSDate(timeIntervalSince1970: NSTimeInterval(prog["end"].intValue / 1000)),
							duration: NSTimeInterval(prog["seconds"].intValue), userData: nil)
						
						programs.append(program)
					}
					success(programs)
				}
		}
	}
	
	func deleteProgram(programId: String, mode: ChinachuPVRDeleteMode = .All, success: ((Void) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		switch mode {
		case .Information:
			Alamofire.request(.DELETE, self.remoteHost.absoluteString! + "/api/recorded/" + programId + ".json")
				.response { (request, response, data, error) in
					if error != nil {
						failure(error!)
					} else {
						success()
					}
			}
		case .File:
			Alamofire.request(.DELETE, self.remoteHost.absoluteString! + "/api/recorded/" + programId + "/file.json")
				.response { (request, response, data, error) in
					if error != nil {
						failure(error!)
					} else {
						success()
					}
			}
		case .All:
			Alamofire.request(.DELETE, self.remoteHost.absoluteString! + "/api/recorded/" + programId + ".json")
				.response { (request, response, data, error) in
					if error != nil {
						failure(error!)
					} else {
						Alamofire.request(.DELETE, self.remoteHost.absoluteString! + "/api/recorded/" + programId + "/file.json")
							.response { (request, response, data, error) in
								if error != nil {
									failure(error!)
								} else {
									success()
								}
						}
					}
			}
		}
	}

}
