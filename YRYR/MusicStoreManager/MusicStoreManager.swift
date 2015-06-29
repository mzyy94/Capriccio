//
//  MusicStoreManager.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MusicStoreManager: NSObject {
	
	// MARK: - Instance fileds

	var token: String = ""
	
	
	// MARK: - Class fileds
	
	static let sharedManager = MusicStoreManager()
	
	
	// MARK: - Get music tracks
	
	func getRelatedMusicTracks(keyword: String, success: (([MusicTrackInformation]) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		Alamofire.request(.GET, "https://itunes.apple.com/search?term=\(keyword.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)&country=JP&lang=ja_jp&media=music")
			.responseJSON { (request, response, data, error) in
				if error != nil {
					failure?(error!)
				} else {
					let json = JSON(data!)
					var tracks: [MusicTrackInformation] = []
					for value in json["results"].arrayValue {
						let track = MusicTrackInformation(fromDictionary: value.dictionaryObject!)
						tracks.append(track)
					}

					success?(tracks)
				}
		}
	}
	
}
