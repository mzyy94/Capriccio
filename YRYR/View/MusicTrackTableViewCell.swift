//
//  MusicTrackTableViewCell.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import AVFoundation
import FFCircularProgressView

class MusicTrackTableViewCell: UITableViewCell {
	
	// MARK: - Instance fileds
	
	var audioItem: AVPlayerItem!
	var audioPlayer: AVPlayer!
	var previewUrl: NSURL!
	var trackId: Int!
	var circularProgressView: CircularAudioProgressView!
	var nowPreviewTrackPlaying: Bool = false
	
	
	// MARK: - Interface Builder outlets
	
	@IBOutlet weak var artworkImage: UIImageView!
	@IBOutlet weak var trackNameLabel: UILabel!
	@IBOutlet weak var trackInfoLabel: UILabel!
	@IBOutlet weak var buyMusicButton: UIButton!
	
	
	// MARK: - View initialization
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		// Set button style
		buyMusicButton.layer.cornerRadius = 5
		buyMusicButton.layer.borderWidth = 1
		buyMusicButton.layer.borderColor = self.tintColor.CGColor
		buyMusicButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		
		// Set tap gesture event
		let artworkImageTapGesture = UITapGestureRecognizer(target: self, action: Selector("playPreviewTrack:"))
		artworkImage.addGestureRecognizer(artworkImageTapGesture)
		let cellTapGesture = UITapGestureRecognizer(target: self, action: Selector("buyMusicButtonPressed:"))
		self.addGestureRecognizer(cellTapGesture)
		
	}


	// MARK: - Interface Builder actions
	
	@IBAction func buyMusicButtonPressed(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName("openStoreView", object: nil, userInfo: ["trackId": trackId])
	}
	
	
	// MARK: - Play preview track
	
	func playPreviewTrack(sender: UITapGestureRecognizer) {
		NSNotificationCenter.defaultCenter().postNotificationName("startPreviewTrackPlaying", object: self)
		nowPreviewTrackPlaying = true
		
		// Set preview track notifications and play
		audioItem = AVPlayerItem(URL: previewUrl)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioTrackDidFinished:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: audioItem)
		audioItem.addObserver(self, forKeyPath: "status", options: .Old, context: nil)
		audioPlayer = AVPlayer(playerItem: audioItem)
		audioPlayer.play()
		
		// Remove current gesture recognizer and set new one
		artworkImage.removeGestureRecognizer(artworkImage.gestureRecognizers![0])
		let stopPreviewTrack = UITapGestureRecognizer(target: self, action: Selector("audioTrackDidFinished:"))
		artworkImage.addGestureRecognizer(stopPreviewTrack)

		// Begin flip animation and show audio progress
		UIView.beginAnimations(nil, context: nil)
		UIView.setAnimationDuration(0.4)
		UIView.setAnimationCurve(.Linear)
		UIView.setAnimationTransition(.FlipFromLeft, forView: self.artworkImage, cache: true)
		circularProgressView = CircularAudioProgressView(frame: artworkImage.bounds)
		artworkImage.addSubview(circularProgressView)
		circularProgressView.backgroundColor = UIColor.whiteColor()
		circularProgressView.startSpinProgressBackgroundLayer()
		UIView.commitAnimations()
	}
	
	
	// MARK: - Preview audio track events
	
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == "status" {
			circularProgressView.stopSpinProgressBackgroundLayer()
			NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("changeAudioTrackPlayingProgress:"), userInfo: nil, repeats: true)
		}
	}
	
	func changeAudioTrackPlayingProgress(timer: NSTimer) {
		if !nowPreviewTrackPlaying {
			// Finish this loop
			timer.invalidate()
			return
		}
		// Change audio progress
		circularProgressView.progress = CGFloat(CMTimeGetSeconds(audioPlayer.currentTime()) / CMTimeGetSeconds(audioPlayer.currentItem!.asset.duration))
		if circularProgressView.progress == 1 {
			// Finish this loop
			timer.invalidate()
		}
	}
	
	func audioTrackDidFinished(sender: AnyObject?) {
		// Check whether preview track is playing
		if !nowPreviewTrackPlaying {
			return
		}
		nowPreviewTrackPlaying = false
		
		// Remove notifications
		NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: audioItem)
		audioItem.removeObserver(self, forKeyPath: "status")
		
		// Stop preview track
		audioPlayer.pause()
		
		// Clear fields
		audioItem = nil
		audioPlayer = nil
		
		
		// Remove current gesture recognizer and set new one
		artworkImage.removeGestureRecognizer(artworkImage.gestureRecognizers![0])
		let artworkImageTapGesture = UITapGestureRecognizer(target: self, action: Selector("playPreviewTrack:"))
		artworkImage.addGestureRecognizer(artworkImageTapGesture)

		// Begin flip animation and hide audio progress
		UIView.beginAnimations(nil, context: nil)
		UIView.setAnimationDuration(0.4)
		UIView.setAnimationCurve(.Linear)
		UIView.setAnimationTransition(.FlipFromRight, forView: self.artworkImage, cache: true)
		circularProgressView.removeFromSuperview()
		UIView.commitAnimations()
	}
}
