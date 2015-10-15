//
//  CircularAudioProgressView.swift
//  Capriccio
//
//  Created by Yuki MIZUNO on 6/30/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import FFCircularProgressView

internal class CircularAudioProgressView: FFCircularProgressView {
	var iconLayer: CAShapeLayer!
	
	
	// MARK: - Instance initialization

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupIconLayer()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		self.setupIconLayer()
	}
	
	private func setupIconLayer() {
		let lineWidth = max(self.frame.size.width * 0.025, CGFloat(1))
		self.iconLayer = CAShapeLayer()
		iconLayer.contentsScale = UIScreen.mainScreen().scale
		iconLayer.strokeColor = self.tintColor.CGColor
		iconLayer.fillColor = nil
		iconLayer.lineCap = kCALineCapButt
		iconLayer.lineWidth = lineWidth
		iconLayer.fillRule = kCAFillRuleNonZero
		self.layer.addSublayer(iconLayer)
	}
	
	
	// MARK: - Draw square path
	
	private func drawStop() {
		let radius: CGFloat = self.bounds.size.width / 2
		let ratio: CGFloat = 0.3
		let sideSize = self.bounds.size.width * ratio
		
		let stopPath = UIBezierPath()
		stopPath.moveToPoint(CGPointMake(0, 0))
		stopPath.addLineToPoint(CGPointMake(sideSize, 0.0))
		stopPath.addLineToPoint(CGPointMake(sideSize, sideSize))
		stopPath.addLineToPoint(CGPointMake(0.0, sideSize))
		stopPath.closePath()
		
		stopPath.applyTransform(CGAffineTransformMakeTranslation(radius * (1-ratio), radius * (1-ratio)))
		
		self.iconLayer.path = stopPath.CGPath
		self.iconLayer.strokeColor = self.tintColor.CGColor
		self.iconLayer.fillColor = self.tintColor.CGColor
	}
	
	
	// MARK: - Overridden private method
	
	func drawArrow() {
		self.drawStop()
	}
	
	func drawTick() {
		self.drawStop()
	}
}
