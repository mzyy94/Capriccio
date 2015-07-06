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

	// MARK: - Interface Builder outlets
	
	@IBOutlet weak var channelNumberLabel: UILabel!
	@IBOutlet weak var channelNameLabel: UILabel!
	@IBOutlet weak var programStartTimeLabel: UILabel!
	@IBOutlet weak var programTitleLabel: UILabel!
	
	
	// MARK: - View initialization
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}
	
}
