//
//  ProgramInfoTableViewCell.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import BFPaperTableViewCell
import BFPaperButton

class ProgramInfoTableViewCell: BFPaperTableViewCell {
	
	// MARK: - Instance fileds
	var borderLayer: CALayer! = nil
	let borderHeight: CGFloat = 2
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
		// Initialization code

		borderLayer = CALayer()
		borderLayer.backgroundColor = UIColor.paperColorBlueGray400().CGColor
		borderLayer.frame = CGRect(x: 0, y: self.frame.size.height - borderHeight, width: self.frame.size.width, height: borderHeight)
		
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

		self.tintColor = UIColor.paperColorTeal100()
	}
	
	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		
		// Title underline
		let frame = self.titleLabel.frame
		let unerlineInset = 0.5 / UIScreen.mainScreen().scale
		let context = UIGraphicsGetCurrentContext()
		CGContextSaveGState(context)
		CGContextSetLineWidth(context, unerlineInset)
		CGContextSetStrokeColorWithColor(context, UIColor.paperColorBlueGray800().CGColor)
		CGContextMoveToPoint(context, frame.origin.x, frame.origin.y + frame.height)
		CGContextAddLineToPoint(context, self.titleLabel.frame.width, frame.origin.y + frame.height)
		CGContextStrokePath(context)
		CGContextRestoreGState(context)
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
		self.layer.addSublayer(borderLayer)
		
		super.layoutSubviews()
	}
	
	override func layoutSublayersOfLayer(layer: CALayer!) {
		borderLayer.frame = CGRect(x: 0, y: self.frame.size.height - borderHeight, width: self.frame.size.width, height: borderHeight)
		
		super.layoutSublayersOfLayer(layer)
	}
	
}
