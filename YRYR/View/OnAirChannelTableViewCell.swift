//
//  OnAirChannelTableViewCell.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 7/6/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import BFPaperTableViewCell

class OnAirChannelTableViewCell: BFPaperTableViewCell {

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

	// MARK: - Interface Builder outlets
	
	@IBOutlet weak var channelNumberLabel: UILabel!
	@IBOutlet weak var channelNameLabel: UILabel!
	@IBOutlet weak var programStartTimeLabel: UILabel!
    @IBOutlet weak var programDurationLabel: UILabel!
	@IBOutlet weak var programTitleLabel: UILabel!
    @IBOutlet weak var programDetailLabel: UILabel!
	
	
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
		
		// Rounded corner
		self.layer.masksToBounds = false
		self.layer.cornerRadius = cornerRadius
		self.backgroundColor = UIColor.clearColor()
		
		self.tintColor = UIColor.paperColorTeal100()
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	// MARK: - Subview layout
	
	override func layoutSubviews() {
		shadowLayer?.frame = self.bounds
		shadowLayer?.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).CGPath
		super.layoutSubviews()
	}
	
}
