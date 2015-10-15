//
//  ProgramInfoTableViewCell.swift
//  Capriccio
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import BFPaperTableViewCell
import BFPaperButton

class ProgramInfoTableViewCell: BFPaperTableViewCell {
	
	// MARK: - Instance fileds
	var shadowLayer: CALayer! = nil
	let cornerRadius: CGFloat = 2
	override var frame: CGRect {
		get {
			return super.frame
		}
		set (newFrame) {
			var frame = newFrame
			let inset: CGFloat = 16

			// Set left inset
			frame.origin.x += inset
			
			if let superview = self.superview {
				frame.size.width = superview.frame.width
			}
			// Set right inset
			frame.size.width -= 2 * inset
			
			super.frame = frame
		}
	}
	let genreColor: [String: UIColor] = [
		"anime": UIColor.paperColorPink100(),
		"information": UIColor.paperColorTeal100(),
		"news": UIColor.paperColorLightGreen100(),
		"sports": UIColor.paperColorCyan100(),
		"variety": UIColor.paperColorYellow100(),
		"drama": UIColor.paperColorOrange100(),
		"music": UIColor.paperColorIndigo100(),
		"cinema": UIColor.paperColorDeepPurple100(),
		"etc": UIColor.paperColorGray100()
	]
	
	
	// MARK: - Interface Builder outlets
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	
	// MARK: - View initialization

	override func awakeFromNib() {
		super.awakeFromNib()

		// Shadow layer
		shadowLayer = CALayer()
		shadowLayer.backgroundColor = UIColor.whiteColor().CGColor
		shadowLayer.shouldRasterize = true
		shadowLayer.rasterizationScale = UIScreen.mainScreen().scale
		shadowLayer.shadowColor = UIColor.blackColor().CGColor
		shadowLayer.shadowRadius = 2.4
		shadowLayer.shadowOpacity = 0.6
		shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
		shadowLayer.cornerRadius = cornerRadius
		self.layer.insertSublayer(shadowLayer, atIndex: 0)
		
		// BFPaperTableViewCell settings
		self.usesSmartColor = true
		self.tapDelay = 0
		self.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterSmall
		self.alwaysCompleteFullAnimation = false
		
		// Replace AccessoryView
		let playButton = BFPaperButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 40, height: 40)), raised: false)
		playButton.cornerRadius = playButton.frame.size.width / 2
		playButton.backgroundColor = UIColor.paperColorLightBlue600()
		playButton.setImage(UIImage(named: "play_arrow_white"), forState: .Normal)
		playButton.addTarget(self, action: Selector("accessoryButtonTapped:event:"), forControlEvents: .TouchUpInside)
		self.accessoryView = playButton
		
		// Rounded corner
		self.layer.masksToBounds = false
		self.layer.cornerRadius = cornerRadius
		self.backgroundColor = UIColor.clearColor()

		self.tintColor = UIColor.paperColorTeal100()
	}
	
	
	// MARK: - Entity setter
	
	func setCellEntities(title: String, subTitle: String, genre: String, channel: PVRChannel, episode: Int!, startTime: NSDate, duration: NSTimeInterval) {
		let titleAttributedText = NSMutableAttributedString(string: title)
		titleAttributedText.appendAttributedString(NSAttributedString(string: " \(subTitle)"))
		self.titleLabel.attributedText = titleAttributedText
		
		// Date formation
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
		self.dateLabel.text = dateFormatter.stringFromDate(startTime) + " (\(Int(duration / 60)) min.)"
		
		
		let genreBackgroundColor: UIColor
		if let color = genreColor[genre] {
			genreBackgroundColor = color
		} else {
			genreBackgroundColor = UIColor.paperColorBrown100()
		}
		
		let infoAttributedText = NSMutableAttributedString(string: genre, attributes: [NSBackgroundColorAttributeName: genreBackgroundColor])
		
		infoAttributedText.appendAttributedString(NSAttributedString(string: " \(channel.name)", attributes: [NSForegroundColorAttributeName: UIColor.paperColorBlueGray500()]))
		
		if episode > 0 {
			infoAttributedText.appendAttributedString(NSAttributedString(string: " #\(episode)", attributes: [NSForegroundColorAttributeName: UIColor.paperColorDeepOrange500()]))
		}
		
		self.infoLabel.attributedText = infoAttributedText
	}

	
	// MARK: - View action
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	func accessoryButtonTapped(sender: UIButton!, event: UIEvent) {
		let touches = event.allTouches()
		let touch: AnyObject = touches!.first as! AnyObject
		NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "accessoryButtonTapped", object: self, userInfo: ["touch": touch]))
	}
	
	// MARK: - Subview layout
	
	override func layoutSubviews() {
		shadowLayer?.frame = self.bounds
		shadowLayer?.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).CGPath
		super.layoutSubviews()
	}
	
}
