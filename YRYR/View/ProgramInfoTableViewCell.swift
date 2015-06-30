//
//  ProgramInfoTableViewCell.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import BFPaperTableViewCell

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
	
	
	// MARK: - Interface Builder outlets
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subTitleLabel: UILabel!
	@IBOutlet weak var genreLabel: UILabel!
	@IBOutlet weak var episodeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
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
		
		self.tintColor = UIColor.paperColorTeal100()
	}

	
	// MARK: - View action
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
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
