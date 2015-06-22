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
import KeychainAccess

enum ChinachuPVRDeleteMode {
	case File
	case Information
	case All
}

class ChinachuPVRManager: PVRManager {
	
	// MARK: - Class fileds
	
	static let sharedManager = ChinachuPVRManager()

	
	// MARK: - Class initialization
	
	override init() {
		super.init()
	}
	
	
	// MARK: - Private method
	
	private func getAccount() -> (String, String) {
		let userDefaults = NSUserDefaults()

		let username = userDefaults.stringForKey("pvrUser")!
		let password: String
		if let storedPassword = Keychain(server: remoteHost.absoluteString!,
			protocolType: remoteHost.scheme! == "https" ? .HTTPS : .HTTP,
			authenticationType: .HTTPBasic).get(username) {
				
			password = storedPassword
		} else {
			password = ""
		}
		
		return (username, password)
	}
	
	
	// MARK: - Reserving program
	
	override func getReserving(success: (([PVRProgram]) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		let (username, password) = getAccount()
		Alamofire.request(.GET, remoteHost.absoluteString! + "/api/reserves.json")
			.authenticate(user: username, password: password)
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

	
	// MARK: - Recording program
	
	override func getRecording(success: (([PVRProgram]) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		let (username, password) = getAccount()
		
		Alamofire.request(.GET, remoteHost.absoluteString! + "/api/recorded.json")
			.authenticate(user: username, password: password)
			.responseJSON { (request, response, data, error) in
				if error != nil {
					failure(error!)
				} else {
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
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
						
						dispatch_sync(dispatch_get_main_queue(), {
							success(programs)
						})
					})
				}
		}
	}
	
	func deleteProgram(programId: String, mode: ChinachuPVRDeleteMode = .All, success: ((Void) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		let (username, password) = getAccount()
		
		switch mode {
		case .Information:
			Alamofire.request(.DELETE, self.remoteHost.absoluteString! + "/api/recorded/" + programId + ".json")
				.authenticate(user: username, password: password)
				.response { (request, response, data, error) in
					if error != nil {
						failure(error!)
					} else {
						success()
					}
			}
		case .File:
			Alamofire.request(.DELETE, self.remoteHost.absoluteString! + "/api/recorded/" + programId + "/file.json")
				.authenticate(user: username, password: password)
				.response { (request, response, data, error) in
					if error != nil {
						failure(error!)
					} else {
						success()
					}
			}
		case .All:
			Alamofire.request(.DELETE, self.remoteHost.absoluteString! + "/api/recorded/" + programId + ".json")
				.authenticate(user: username, password: password)
				.response { (request, response, data, error) in
					if error != nil {
						failure(error!)
					} else {
						Alamofire.request(.DELETE, self.remoteHost.absoluteString! + "/api/recorded/" + programId + "/file.json")
							.authenticate(user: username, password: password)
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
	
	
	// MARK: - Thumbnail of the video
	
	func getPreviewImage(programId: String, isRecording: Bool = false, time: Int = 50, success: ((NSData) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		let (username, password) = getAccount()
		Alamofire.request(.GET, remoteHost.absoluteString! + "/api/recorded/" + programId + "/preview.jpg?pos=\(time)")
			.authenticate(user: username, password: password)
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
	
	
	// MARK: - Remote/local media
	
	func getMediaUrl(programId: String, isRecording: Bool = false) -> NSURL {
		if NSFileManager.defaultManager().fileExistsAtPath(getDownloadedFileUrl(programId).relativePath!) {
			return getDownloadedFileUrl(programId)
		} else {
			let (username, password) = getAccount()

			return NSURL(scheme: remoteHost.scheme!, host: "\(username):\(password)@\(remoteHost.host!):\(remoteHost.port!)", path: "/api/" + (isRecording ? "recording/" : "recorded/") + programId + "/watch.m2ts?ext=m2ts&c:v=copy&c:a=copy")!
		}
	}

	func getDownloadedFileUrl(programId: String) -> NSURL {
		var err: NSError? = nil
		
		let documentURL = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: &err)
		let programDir = documentURL!.URLByAppendingPathComponent(programId)
		let downloadPath = programDir.URLByAppendingPathComponent("file.m2ts")
		
		return downloadPath
	}
	
	
	// MARK: - Download video
	
	func startDownloadVideo(programId: String, inProgress progress: (Float) -> Void, onComplete complete: (Void) -> Void) -> Request {
		var err: NSError? = nil
		
		let documentURL = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: &err)
		let programDir = documentURL!.URLByAppendingPathComponent(programId)
		if !NSFileManager.defaultManager().fileExistsAtPath(programDir.absoluteString!) {
			NSFileManager.defaultManager().createDirectoryAtURL(programDir, withIntermediateDirectories: false, attributes: nil, error: &err)
		}
		
		let downloadPath = programDir.URLByAppendingPathComponent("file.m2ts")
		
		let (username, password) = getAccount()

		let downloadRequest = Alamofire.download(.GET, remoteHost.absoluteString! + "/api/recorded/" + programId + "/file.m2ts", { (temporaryURL, response) in
			return downloadPath
			})
			.authenticate(user: username, password: password)
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
		if let downloadRequest: Request = request as? Request {
			downloadRequest.cancel()
		}
	}
	
	func setDownloadVideoHandler(request: AnyObject?, inProgress progress:(Float) -> Void, onComplete complete:(Void) -> Void) {
		if let downloadRequest: Request = request as? Request {
			downloadRequest.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
				progress(Float(totalBytesRead) / Float(totalBytesExpectedToRead))
				}
				.response { (request, response, _, error) in
					if error == nil {
						complete()
					}
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

}
