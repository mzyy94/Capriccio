//
//  MusicStoreManager.swift
//  Capriccio
//
//  Created by Yuki MIZUNO on 6/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import StoreKit

class MusicStoreManager: NSObject, SKStoreProductViewControllerDelegate {
	
	// MARK: - Instance fileds

	var token: NSString = "1l3v4mQ"
	
	
	// MARK: - Class fileds
	
	static let sharedManager = MusicStoreManager()
	
	
	// MARK: - Get music tracks
	
	func getRelatedMusicTracks(keyword: String, success: (([MusicTrackInformation]) -> Void)! = nil, failure: ((NSError) -> Void)! = nil) {
		Alamofire.request(.GET, "https://itunes.apple.com/search?term=\(keyword.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!)&country=JP&lang=ja_jp&media=music")
            .responseJSON { response in
                switch response.result {
                case .Success:
                    let data = response.result.value
                    let json = JSON(data!)
                    var tracks: [MusicTrackInformation] = []
                    for value in json["results"].arrayValue {
                        let track = MusicTrackInformation(fromDictionary: value.dictionaryObject!)
                        tracks.append(track)
                    }
                    
                    success?(tracks)
                case .Failure(let error):
                    failure?(error)
                }
		}
	}
	
	
	// MARK: - Open iTunes Store
	
	func openStoreView(trackId: NSNumber, inViewController viewController: AnyObject) {
		let target = viewController as! UIViewController
		let store = SKStoreProductViewController()
		store.delegate = self

	
		target.presentViewController(store, animated: true, completion: {
			let params: [String: AnyObject] = [SKStoreProductParameterITunesItemIdentifier: trackId,
				SKStoreProductParameterAffiliateToken: self.token]
			store.loadProductWithParameters(params, completionBlock: {(completed, error) in
				if error != nil {
					let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
					// TODO: Show error message
					dispatch_after(popTime, dispatch_get_main_queue(), {
						store.dismissViewControllerAnimated(true, completion: nil)
					})
				}
			})
		})
	}
	
	func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
		viewController.dismissViewControllerAnimated(true, completion: nil)
	}
	
}
