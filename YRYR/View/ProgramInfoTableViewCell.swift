//
//  ProgramInfoTableViewCell.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 5/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class ProgramInfoTableViewCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subTitleLabel: UILabel!
	@IBOutlet weak var genreLabel: UILabel!
	@IBOutlet weak var episodeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	var borderLayer: CALayer! = nil
	let borderHeight: CGFloat = 2
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

		borderLayer = CALayer()
		borderLayer.backgroundColor = UIColor.lightGrayColor().CGColor
		borderLayer.frame = CGRect(x: 0, y: self.frame.size.height - borderHeight, width: self.frame.size.width, height: borderHeight)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	override func layoutSubviews() {
		self.layer.addSublayer(borderLayer)
		
		super.layoutSubviews()
	}
	
	override func layoutSublayersOfLayer(layer: CALayer!) {
		borderLayer.frame = CGRect(x: 0, y: self.frame.size.height - borderHeight, width: self.frame.size.width, height: borderHeight)
		
		super.layoutSublayersOfLayer(layer)
	}

	
	override var frame: CGRect {
		get {
			return super.frame
		}
		set (newFrame) {
			var frame = newFrame
			let inset: CGFloat = 16

			frame.origin.x += inset
			
			if let superview = self.superview {
				frame.size.width = superview.frame.width
			}
			frame.size.width -= 2 * inset

			super.frame = frame
		}
	}
	
}
