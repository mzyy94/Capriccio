//
//  VideoPlayViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/2/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoPlayViewController: UIViewController {
	@IBOutlet var mainVideoView: UIView!
	@IBOutlet weak var mediaProgressNavigationBar: UINavigationBar!
	@IBOutlet weak var mediaControlView: UIVisualEffectView!
	
	let mediaPlayer = VLCMediaPlayer()
	var program: PVRProgram!
	
	override func viewDidLoad() {
		let userDefault = NSUserDefaults()
		let manager = ChinachuPVRManager(remoteHost: NSURL(string: userDefault.stringForKey("pvrUrl")!)!)
		
		mediaPlayer.drawable = self.mainVideoView
		mediaPlayer.setMedia(VLCMedia(URL: manager.getStreamingUrl(program.id)))
		mediaPlayer.setDeinterlaceFilter("blend")
		mediaPlayer.play()
		
		UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
		UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
		UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
		mediaPlayer.stop()
	}

	@IBAction func doneButtonTapped(sender: UIBarButtonItem) {
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
