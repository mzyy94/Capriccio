//
//  VideoPlayViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/2/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoPlayViewController: UIViewController, VLCMediaPlayerDelegate {
	@IBOutlet var mainVideoView: UIView!
	@IBOutlet weak var mediaProgressNavigationBar: UINavigationBar!
	@IBOutlet weak var mediaControlView: UIVisualEffectView!
	@IBOutlet weak var videoProgressSlider: UISlider!
	@IBOutlet weak var videoTimeLabel: UILabel!
	
	let mediaPlayer = VLCMediaPlayer()
	var program: PVRProgram!
	
	override func viewDidLoad() {
		let userDefault = NSUserDefaults()
		let manager = ChinachuPVRManager(remoteHost: NSURL(string: userDefault.stringForKey("pvrUrl")!)!)
		
		mediaPlayer.drawable = self.mainVideoView
		mediaPlayer.setMedia(VLCMedia(URL: manager.getStreamingUrl(program.id)))
		mediaPlayer.setDeinterlaceFilter("blend")
		mediaPlayer.setDelegate(self)
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
		
		videoProgressSlider.setThumbImage(thumbImage, forState: UIControlState.Normal)
		
		UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
		UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		mediaPlayer.setDelegate(nil)

		UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
		UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
		mediaPlayer.stop()
	}
	
	func mediaPlayerTimeChanged(aNotification: NSNotification!) {
		// Only when slider is not under control
		if !videoProgressSlider.touchInside {
			let mediaPlayer = aNotification.object as! VLCMediaPlayer
			let time = Int(NSTimeInterval(mediaPlayer.position()) * program.duration)
			videoProgressSlider.value = mediaPlayer.position()
			videoTimeLabel.text = NSString(format: "%02d:%02d", time / 60, time % 60) as String
		}
	}

	@IBAction func doneButtonTapped(sender: UIBarButtonItem) {
		mediaPlayer.setDelegate(nil)
		mediaPlayer.stop()
		UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
		UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)

		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func playPauseButtonTapped(sender: UIButton) {
		if mediaPlayer.isPlaying() {
			mediaPlayer.pause()
			sender.setTitle("Play", forState: UIControlState.Normal)
		} else {
			mediaPlayer.play()
			sender.setTitle("Pause", forState: UIControlState.Normal)
		}
	}
	
	@IBAction func videoProgressSliderChanged(sender: UISlider) {
		let time = Int(NSTimeInterval(sender.value) * program.duration)
		videoTimeLabel.text = NSString(format: "%02d:%02d", time / 60, time % 60) as String
	}
	
	@IBAction func videoProgressSliderTouchedUp(sender: UISlider) {
		mediaPlayer.setPosition(sender.value)
	}
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		super.touchesEnded(touches, withEvent: event)
		
		for touch: AnyObject in touches {
			let t = touch as! UITouch
			
			if NSStringFromClass(t.view.classForCoder) == "VLCOpenGLES2VideoView" {
				
				if self.mediaControlView.hidden || self.mediaProgressNavigationBar.hidden {
					
					self.mediaControlView.hidden = false
					self.mediaProgressNavigationBar.hidden = false
					UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
					
					UIView.animateWithDuration(0.4, animations: {
						self.mediaControlView.alpha = 1.0
						self.mediaProgressNavigationBar.alpha = 1.0
					})
				} else {
					
					UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
					
					UIView.animateWithDuration(0.4, animations: {
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

}
