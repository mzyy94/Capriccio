//
//  MusicTrackInformation.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class MusicTrackInformation: NSObject {
	
	// MARK: - Instance fileds
	
	var trackId: Int
	var trackName: String
	var artistName: String
	var collectionName: String?
	var collectionArtistName: String?
	var trackPrice: Float
	var currency: String
	var artworkUrl: NSURL?
	var previewUrl: NSURL?
	var trackViewUrl: NSURL
	
	
	// MARK: - Initialization
	
	init(fromDictionary dict: NSDictionary) {
		self.trackId = dict["trackId"]!.integerValue
		self.trackName = dict["trackName"] as! String
		self.artistName = dict["artistName"] as! String
		self.collectionName = dict["collectionName"] as? String
		self.collectionArtistName = dict["collectionArtistName"] as? String
		self.trackPrice = dict["trackPrice"]!.floatValue
		self.currency = dict["currency"] as! String
		self.artworkUrl = NSURL(string: dict["artworkUrl100"] as! String)
		self.previewUrl = NSURL(string: dict["previewUrl"] as! String)
		self.trackViewUrl = NSURL(string: dict["trackViewUrl"] as! String)!
	}
	
}
