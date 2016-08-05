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
		let startDate = trendScores.first?.dayID ?? Date()
		let endDate = trendScores.last?.dayID ?? Date()
		let dateDifference = endDate.timeIntervalSince(startDate)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d"
		let graphFrame = CGRect(x: leftInset, y: 0, width: layer.frame.width - leftInset, height: layer.frame.height - bottomInset)
		let path = UIBezierPath()
		path.move(to: graphFrame.topLeftCorner)
		path.addLine(to: graphFrame.bottomLeftCorner)
		path.addLine(to: graphFrame.bottomRightCorner)
		let shapeLayer = CAShapeLayer()
		shapeLayer.frame = self.layer.frame
		shapeLayer.path = path.cgPath
		shapeLayer.strokeColor = UIColor.black.cgColor
		shapeLayer.fillColor = nil
		shapeLayer.lineWidth = 1
		layer.addSublayer(shapeLayer)
		for i in 0..<dateLabels {
			let date = Date(timeInterval: endDate.timeIntervalSince(startDate ) * TimeInterval(i) / TimeInterval(dateLabels), since: startDate)
			let textLayer = CATextLayer()
			textLayer.contentsScale = UIScreen.main.scale
			textLayer.string = dateFormatter.string(from: date)
			textLayer.fontSize = 12
			textLayer.foregroundColor = UIColor.black.cgColor
			textLayer.alignmentMode = kCAAlignmentCenter
			let textFrame = textLayer.string?.boundingRect(with: textLayer.frame.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil) ?? CGRect.zero
			textLayer.frame = CGRect(x: leftInset + graphFrame.width * CGFloat(i) / CGFloat(dateLabels) - textFrame.width / 2, y: graphFrame.height + bottomInset / 2 - textFrame.height / 2, width: textFrame.width, height: textFrame.height)
			layer.addSublayer(textLayer)
		}
		for i in 0..<gradeLabels {
			let grade = minimum + (maximum - minimum) * Double(i) / Double(gradeLabels)
			let textLayer = CATextLayer()
			textLayer.contentsScale = UIScreen.main.scale
			textLayer.string = String(format: "%.2f%%", grade * 100)
			textLayer.fontSize = 12
			textLayer.foregroundColor = UIColor.black.cgColor
			let textFrame = textLayer.string?.boundingRect(with: textLayer.frame.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil) ?? CGRect.zero
			textLayer.frame = CGRect(x: leftInset / 2 - textFrame.width / 2, y: graphFrame.height - graphFrame.height * CGFloat(i) / CGFloat(gradeLabels) - textFrame.height / 2, width: textFrame.width, height: textFrame.height)
			layer.addSublayer(textLayer)
		}
		guard trendScores.count > 0 else {
			return
		}
		let trendLine = UIBezierPath()
		trendLine.move(to: graphFrame.bottomLeftCorner)
		for trendScore in trendScores {
			trendLine.addLine(to: CGPoint(x: leftInset + graphFrame.width * CGFloat(trendScore.dayID.timeIntervalSince(startDate) / dateDifference), y: graphFrame.height - graphFrame.height * CGFloat(((Double(trendScore.score) ?? 0) - minimum) / scoreDifference)))
		}
		let trendLineShapeLayer = CAShapeLayer()
		trendLineShapeLayer.frame = self.layer.frame
		trendLineShapeLayer.path = trendLine.cgPath
		trendLineShapeLayer.strokeColor = UIColor.black.cgColor
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
