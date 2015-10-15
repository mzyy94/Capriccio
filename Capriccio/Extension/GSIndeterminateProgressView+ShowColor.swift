//
//  GSIndeterminateProgressView+ShowColor.swift
//  Capriccio
//
//  Created by Yuki MIZUNO on 6/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import GSIndeterminateProgressBar


extension GSIndeterminateProgressView {
	func stopAnimatingAndShowColor(color: UIColor) {
		let originalHidesWhenStopped = self.hidesWhenStopped
		
		self.hidesWhenStopped = false
		self.stopAnimating()
		self.hidesWhenStopped = originalHidesWhenStopped
		
		let coloredView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0))
		coloredView.backgroundColor = color
		
		self.addSubview(coloredView)
		
		UIView.animateWithDuration(0.4, animations: {
			coloredView.frame = CGRect(origin: CGPointZero, size: self.frame.size)
			}, completion: { finished in
				if finished {
					UIView.animateWithDuration(0.4, delay: 2.0, options: .TransitionNone, animations: {
						coloredView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0)
						}, completion: { finished in
							coloredView.removeFromSuperview()
							self.hidden = originalHidesWhenStopped
					})
				}
		})
	}
}
