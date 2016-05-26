//
//  TrendScore.swift
//  break
//
//  Created by Saagar Jha on 5/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class TrendScore: UIView {

	let dateLabels = 6
	let gradeLabels = 5
	let leftInset: CGFloat = 55
	let bottomInset: CGFloat = 20

	var trendScores: [SchoolLoopTrendScore] = [] {
		didSet {
			drawTrendLine()
		}
	}

	func drawTrendLine() {
		layer.sublayers = nil
		let minimum = trendScores.reduce(1) {
			return Double(min($0, Double($1.score) ?? 1))
		}
		let maximum = trendScores.reduce(0) {
			return Double(max($0, Double($1.score) ?? 0))
		}
		let scoreDifference = maximum - minimum
		let startDate = trendScores.first?.dayID ?? NSDate()
		let endDate = trendScores.last?.dayID ?? NSDate()
		let dateDifference = endDate.timeIntervalSinceDate(startDate)
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d"
		let graphFrame = CGRect(x: leftInset, y: 0, width: layer.frame.width - leftInset, height: layer.frame.height - bottomInset)
		let path = UIBezierPath()
		path.moveToPoint(graphFrame.topLeftCorner)
		path.addLineToPoint(graphFrame.bottomLeftCorner)
		path.addLineToPoint(graphFrame.bottomRightCorner)
		let shapeLayer = CAShapeLayer()
		shapeLayer.frame = self.layer.frame
		shapeLayer.path = path.CGPath
		shapeLayer.strokeColor = UIColor.blackColor().CGColor
		shapeLayer.fillColor = nil
		shapeLayer.lineWidth = 1
		layer.addSublayer(shapeLayer)
		for i in 0..<dateLabels {
			let date = NSDate(timeInterval: endDate.timeIntervalSinceDate(startDate) * NSTimeInterval(i) / NSTimeInterval(dateLabels), sinceDate: startDate)
			let textLayer = CATextLayer()
			textLayer.contentsScale = UIScreen.mainScreen().scale
			textLayer.string = dateFormatter.stringFromDate(date)
			textLayer.fontSize = 12
			textLayer.foregroundColor = UIColor.blackColor().CGColor
			textLayer.alignmentMode = kCAAlignmentCenter
			let textFrame = textLayer.string?.boundingRectWithSize(textLayer.frame.size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)], context: nil) ?? CGRectZero
			textLayer.frame = CGRect(x: leftInset + graphFrame.width * CGFloat(i) / CGFloat(dateLabels) - textFrame.width / 2, y: graphFrame.height + bottomInset / 2 - textFrame.height / 2, width: textFrame.width, height: textFrame.height)
			layer.addSublayer(textLayer)
		}
		for i in 0..<gradeLabels {
			let grade = minimum + (maximum - minimum) * Double(i) / Double(gradeLabels)
			let textLayer = CATextLayer()
			textLayer.contentsScale = UIScreen.mainScreen().scale
			textLayer.string = String(format: "%.2f%%", grade * 100)
			textLayer.fontSize = 12
			textLayer.foregroundColor = UIColor.blackColor().CGColor
			let textFrame = textLayer.string?.boundingRectWithSize(textLayer.frame.size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)], context: nil) ?? CGRectZero
			textLayer.frame = CGRect(x: leftInset / 2 - textFrame.width / 2, y: graphFrame.height - graphFrame.height * CGFloat(i) / CGFloat(gradeLabels) - textFrame.height / 2, width: textFrame.width, height: textFrame.height)
			layer.addSublayer(textLayer)
		}
		guard trendScores.count > 0 else {
			return
		}
		let trendLine = UIBezierPath()
		trendLine.moveToPoint(graphFrame.bottomLeftCorner)
		for trendScore in trendScores {
			trendLine.addLineToPoint(CGPoint(x: leftInset + graphFrame.width * CGFloat(trendScore.dayID.timeIntervalSinceDate(startDate) / dateDifference), y: graphFrame.height - graphFrame.height * CGFloat(((Double(trendScore.score) ?? 0) - minimum) / scoreDifference)))
		}
		let trendLineShapeLayer = CAShapeLayer()
		trendLineShapeLayer.frame = self.layer.frame
		trendLineShapeLayer.path = trendLine.CGPath
		trendLineShapeLayer.strokeColor = UIColor.blackColor().CGColor
		trendLineShapeLayer.fillColor = nil
		trendLineShapeLayer.lineWidth = 1
		layer.addSublayer(trendLineShapeLayer)
	}

	/*
	 // Only override drawRect: if you perform custom drawing.
	 // An empty implementation adversely affects performance during animation.
	 override func drawRect(rect: CGRect) {
	 // Drawing code
	 }
	 */
}

extension CGRect {
	var topLeftCorner: CGPoint {
		get {
			return CGPoint(x: minX, y: minY)
		}
	}
	var topRightCorner: CGPoint {
		get {
			return CGPoint(x: maxX, y: minY)
		}
	}
	var bottomLeftCorner: CGPoint {
		get {
			return CGPoint(x: minX, y: maxY)
		}
	}
	var bottomRightCorner: CGPoint {
		get {
			return CGPoint(x: maxX, y: maxY)
		}
	}
}
