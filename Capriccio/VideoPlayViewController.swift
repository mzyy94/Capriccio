//
//  VideoPlayViewController.swift
//  Capriccio
//
//  Created by Yuki MIZUNO on 6/2/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoPlayViewController: UIViewController, VLCMediaPlayerDelegate {
	
	// MARK: - Instance fileds
	
	let mediaPlayer = VLCMediaPlayer()
	var program: PVRProgram!
	
	var externalWindow: UIWindow! = nil
	var savedViewConstraints: [NSLayoutConstraint] = []
	
	
	// MARK: - Interface Builder outlets
	
	@IBOutlet var mainVideoView: UIView!
	@IBOutlet weak var mediaProgressNavigationBar: UINavigationBar!
	@IBOutlet weak var mediaControlView: UIVisualEffectView!
	@IBOutlet weak var videoProgressSlider: UISlider!
	@IBOutlet weak var videoTimeLabel: UILabel!
	@IBOutlet weak var volumeSliderPlaceView: MPVolumeView!
	@IBOutlet weak var playPauseButton: UIButton!
	
	
	// MARK: - Interface Builder actions
	
	@IBAction func doneButtonTapped(sender: UIBarButtonItem) {
		mediaPlayer.delegate = nil
		mediaPlayer.stop()

		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func playPauseButtonTapped(sender: UIButton) {
		if mediaPlayer.playing {
			mediaPlayer.pause()
			sender.setImage(UIImage(named: "play_arrow_white"), forState: .Normal)
		} else {
			mediaPlayer.play()
			sender.setImage(UIImage(named: "pause_white"), forState: .Normal)
		}
	}
	
	@IBAction func backwardButtonTapped() {
		let second: Float = 30
		let step: Float = second / Float(program.duration)
		if mediaPlayer.position - step > 0 {
			mediaPlayer.position = mediaPlayer.position - step
			videoProgressSlider.value = mediaPlayer.position
			
			let time = Int(NSTimeInterval(videoProgressSlider.value) * program.duration)
			videoTimeLabel.text = NSString(format: "%02d:%02d", time / 60, time % 60) as String
		}
	}
	
	@IBAction func forwardButtonTapped() {
		let second: Float = 30
		let step: Float = second / Float(program.duration)
		if mediaPlayer.position + step < 1 {
			mediaPlayer.position = mediaPlayer.position + step
			videoProgressSlider.value = mediaPlayer.position
			
			let time = Int(NSTimeInterval(videoProgressSlider.value) * program.duration)
			videoTimeLabel.text = NSString(format: "%02d:%02d", time / 60, time % 60) as String
		}
	}
	
	@IBAction func videoProgressSliderChanged(sender: UISlider) {
		let time = Int(NSTimeInterval(sender.value) * program.duration)
		videoTimeLabel.text = NSString(format: "%02d:%02d", time / 60, time % 60) as String
	}
	
	@IBAction func videoProgressSliderTouchedUp(sender: UISlider) {
		mediaPlayer.position = sender.value
	}
	
	
	// MARK: - View initialization
	
	override func viewDidLoad() {
		let manager = ChinachuPVRManager.sharedManager
		
		// Media player settings
		let media = VLCMedia(URL: manager.getMediaUrl(program))
		media.addOptions(["network-caching": 3333])
		mediaPlayer.drawable = self.mainVideoView
		mediaPlayer.media = media
		mediaPlayer.setDeinterlaceFilter("blend")
		mediaPlayer.delegate = self
		mediaPlayer.play()
		
		// Generate slider thumb image
		let thumbRadius: CGFloat = 6
		
		let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: thumbRadius * 2,
			height: thumbRadius * 2), cornerRadius: thumbRadius)
		UIGraphicsBeginImageContextWithOptions(path.bounds.size, false, 0)
		UIColor.whiteColor().setFill()
		path.fill()
		let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		
		// Set slider thumb image
		videoProgressSlider.setThumbImage(thumbImage, forState: .Normal)
		
		for subview:AnyObject in volumeSliderPlaceView.subviews {
			if NSStringFromClass(subview.classForCoder) == "MPVolumeSlider" {
				let volumeSlider = subview as! UISlider
				volumeSlider.setThumbImage(thumbImage, forState: .Normal)
				break
			}
		}

	}
	
	override func viewWillAppear(animated: Bool) {
		// Initialize navigation bar background
		let emptyImage = UIImage()
		self.navigationController?.navigationBar.translucent = true
		self.navigationController?.navigationBar.shadowImage = emptyImage
		self.navigationController?.navigationBar.setBackgroundImage(emptyImage, forBarMetrics: .Default)
		self.navigationController?.navigationBar.setBackgroundImage(emptyImage, forBarMetrics: .Compact)

	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Save current constraints
		savedViewConstraints = self.view.constraints
		
		// Set external display events
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("screenDidConnect:"), name: UIScreenDidConnectNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("screenDidDisconnect:"), name: UIScreenDidDisconnectNotification, object: nil)
		
		// Start remote control events
		UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
		self.becomeFirstResponder()
	}
	

	// MARK: - View deinitialization
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		// Media player settings
		mediaPlayer.delegate = nil
		mediaPlayer.stop()
		
		// Unset external display events
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIScreenDidConnectNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIScreenDidDisconnectNotification, object: nil)
		
		// End remote control events
		UIApplication.sharedApplication().endReceivingRemoteControlEvents()
		self.resignFirstResponder()
	}


	// MARK: - Device orientation configurations
	
	override func shouldAutorotate() -> Bool {
		return externalWindow == nil
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.All
	}

	
	// MARK: - First responder configuration
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	
	// MARK: - Memory/resource management
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	// MARK: - Remote control
	
	override func remoteControlReceivedWithEvent(event: UIEvent?) {
		if event!.type == .RemoteControl {
			switch event!.subtype {
			case .RemoteControlPlay, .RemoteControlPause, .RemoteControlTogglePlayPause:
				self.playPauseButtonTapped(playPauseButton)
				break
			default:
				break
			}
		}
	}
	
	
	// MARK: - Media player delegate methods
	
	var onceToken : dispatch_once_t = 0
	func mediaPlayerTimeChanged(aNotification: NSNotification!) {
		// Only when slider is not under control
		if !videoProgressSlider.touchInside {
			let mediaPlayer = aNotification.object as! VLCMediaPlayer
			let time = Int(NSTimeInterval(mediaPlayer.position) * program.duration)
			videoProgressSlider.value = mediaPlayer.position
			videoTimeLabel.text = NSString(format: "%02d:%02d", time / 60, time % 60) as String
		}
		
		// First time of video playback
		dispatch_once(&onceToken) {
			let notification = NSNotification(name: UIScreenDidConnectNotification, object: nil)
			self.screenDidConnect(notification)
		}
	}
	
	func mediaPlayerStateChanged(aNotification: NSNotification!) {
		updateMetadata()
	}
	
	
	// MARK: - Media metadata settings
	
	func updateMetadata() {
		let time = Int(NSTimeInterval(mediaPlayer.position) * program.duration)
		let videoInfo = [MPMediaItemPropertyTitle: program.title,
			MPMediaItemPropertyMediaType: MPMediaType.TVShow.rawValue,
			MPMediaItemPropertyPlaybackDuration: program.duration,
			MPNowPlayingInfoPropertyElapsedPlaybackTime: time,
			MPNowPlayingInfoPropertyPlaybackRate: mediaPlayer.rate
		]
//		MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = videoInfo as? [String : AnyObject]
	}
	

	// MARK: - Touch events
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
		
		for touch: AnyObject in touches {
			let t = touch as! UITouch
			
			if NSStringFromClass(t.view!.classForCoder) == "VLCOpenGLES2VideoView" {
				if self.mediaControlView.hidden || self.mediaProgressNavigationBar.hidden {
					self.mediaControlView.hidden = false
					self.mediaProgressNavigationBar.hidden = false
					self.statusBarHidden = false
					
					UIView.animateWithDuration(0.4, animations: {
						self.setNeedsStatusBarAppearanceUpdate()
						self.mediaControlView.alpha = 1.0
						self.mediaProgressNavigationBar.alpha = 1.0
					})
				} else {
					self.statusBarHidden = true
					
					UIView.animateWithDuration(0.4, animations: {
						self.setNeedsStatusBarAppearanceUpdate()
						self.mediaControlView.alpha = 0.0
						self.mediaProgressNavigationBar.alpha = 0.0
						},  completion: { finished in
							self.mediaControlView.hidden = true
							self.mediaProgressNavigationBar.hidden = true
					})
				}
			}
		}
	}
	
	
	// MARK: - Status bar
	
	var statusBarHidden: Bool = false
	override func prefersStatusBarHidden() -> Bool {
		return statusBarHidden
	}
	
	
	override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
		return .Fade
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
	
	// MARK: - External display
	
	func screenDidConnect(aNotification: NSNotification) {
		let screens = UIScreen.screens()
		if screens.count > 1 {
			let externalScreen = screens[1] 
			let availableModes = externalScreen.availableModes
			
			// Set up external screen
			externalScreen.currentMode = availableModes.last
            externalScreen.overscanCompensation = .InsetApplicationFrame
			
			// Change device orientation to portrait
			let portraitOrientation = UIInterfaceOrientation.Portrait.rawValue
			UIDevice.currentDevice().setValue(portraitOrientation, forKey: "orientation")

			if self.externalWindow == nil {
				self.externalWindow = UIWindow(frame: externalScreen.bounds)
			}
			
			// Set up external window
			self.externalWindow.screen = externalScreen
			self.externalWindow.hidden = false
			self.externalWindow.layer.contentsGravity = kCAGravityResizeAspect
			
			// Move mainVideoView to external window
			mainVideoView.removeFromSuperview()
			let externalViewController = UIViewController()
			externalViewController.view = mainVideoView
			self.externalWindow.rootViewController = externalViewController
			
			// Show media controls
			self.mediaControlView.hidden = false
			self.mediaProgressNavigationBar.hidden = false
			
			UIView.animateWithDuration(0.4, animations: {
				self.mediaControlView.alpha = 1.0
				self.mediaProgressNavigationBar.alpha = 1.0
			})

		}
	}
	
	func screenDidDisconnect(aNotification: NSNotification) {
		if self.externalWindow != nil {
			// Restore mainVideoView
			mainVideoView.removeFromSuperview()
			self.view.addSubview(mainVideoView)
			self.view.sendSubviewToBack(mainVideoView)

			// Restore view constraints
			self.view.removeConstraints(self.view.constraints)
			self.view.addConstraints(savedViewConstraints)

			self.externalWindow = nil
		}
	}

}
