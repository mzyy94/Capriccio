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
	
	static let sharedInstance = ChinachuPVRManager()

	override init() {
		super.init()
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
		
	func getMediaUrl(programId: String, isRecording: Bool = false) -> NSURL {
		if NSFileManager.defaultManager().fileExistsAtPath(getDownloadedFileUrl(programId).relativePath!) {
			return getDownloadedFileUrl(programId)
		} else {
			return NSURL(string: remoteHost.absoluteString! + "/api/" + (isRecording ? "recording/" : "recorded/") + programId + "/watch.m2ts?ext=m2ts&c:v=copy&c:a=copy")!
		}
	}

	func getDownloadedFileUrl(programId: String) -> NSURL {
		var err: NSError? = nil
		
		let documentURL = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: &err)
		let programDir = documentURL!.URLByAppendingPathComponent(programId)
		let downloadPath = programDir.URLByAppendingPathComponent("file.m2ts")
		
		return downloadPath
	}
	
	func startDownloadVideo(programId: String, inProgress progress: (Float) -> Void, onComplete complete: (Void) -> Void) -> Request {
		var err: NSError? = nil
		
		let documentURL = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: &err)
		let programDir = documentURL!.URLByAppendingPathComponent(programId)
		if !NSFileManager.defaultManager().fileExistsAtPath(programDir.absoluteString!) {
			NSFileManager.defaultManager().createDirectoryAtURL(programDir, withIntermediateDirectories: false, attributes: nil, error: &err)
		}
		
		let downloadPath = programDir.URLByAppendingPathComponent("file.m2ts")
		
		let downloadRequest = Alamofire.download(.GET, remoteHost.absoluteString! + "/api/recorded/" + programId + "/file.m2ts", { (temporaryURL, response) in
			return downloadPath
			})
			.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
				progress(Float(totalBytesRead) / Float(totalBytesExpectedToRead))
			}
			.response { (request, response, _, error) in
				if error == nil {
					complete()
				}
		}
		
		return downloadRequest
	}
	
	func cancelDownloadVideo(request: AnyObject?) {
		if request == nil {
			return
		}
		
		let downloadRequest = request as! Request
		downloadRequest.cancel()
	}
	
	func setDownloadVideoHandler(request: AnyObject?, inProgress progress:(Float) -> Void, onComplete complete:(Void) -> Void) {
		if request == nil {
			return
		}
		
		let downloadRequest = request as! Request
		downloadRequest.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
			progress(Float(totalBytesRead) / Float(totalBytesExpectedToRead))
			}
			.response { (request, response, _, error) in
				if error == nil {
					complete()
				}
		}
	}
	
	func fileDownloaded(programId: String) -> Bool {
		return NSFileManager.defaultManager().fileExistsAtPath(getDownloadedFileUrl(programId).relativePath!)
	}
	
	func removeDownloadedFile(programId: String, onComplete complete:(Void) -> Void) {
		var error: NSError?
		
		NSFileManager.defaultManager().removeItemAtURL(getDownloadedFileUrl(programId), error: &error)
		
		if error == nil {
			complete()
		}
		
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
