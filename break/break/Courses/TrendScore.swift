//
//  TrendScore.swift
//  break
//
//  Created by Saagar Jha on 5/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class TrendScore: UIView {

	static let dateLabels = 6
	static let gradeLabels = 5
	static let leftInset: CGFloat = 55
	static let bottomInset: CGFloat = 20
	static let font: UIFont = UIFont.preferredFont(forTextStyle: .caption1)

	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d"
		return dateFormatter
	}()

	var trendScores = [SchoolLoopTrendScore]() {
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

		let graphFrame = CGRect(x: TrendScore.leftInset, y: 0, width: layer.frame.width - TrendScore.leftInset, height: layer.frame.height - TrendScore.bottomInset)

		let axes = UIBezierPath()
		axes.move(to: graphFrame.topLeftCorner)
		axes.addLine(to: graphFrame.bottomLeftCorner)
		axes.addLine(to: graphFrame.bottomRightCorner)
		let axesShapeLayer = CAShapeLayer()
		axesShapeLayer.frame = layer.frame
		axesShapeLayer.path = axes.cgPath
		axesShapeLayer.strokeColor = UIColor.black.cgColor
		axesShapeLayer.fillColor = nil
		axesShapeLayer.lineWidth = 1
		layer.addSublayer(axesShapeLayer)

		for i in 0..<TrendScore.dateLabels {
			let date = Date(timeInterval: endDate.timeIntervalSince(startDate) * TimeInterval(i) / TimeInterval(TrendScore.dateLabels), since: startDate)
			let textLayer = CATextLayer()
			textLayer.contentsScale = UIScreen.main.scale
			textLayer.string = TrendScore.dateFormatter.string(from: date)
			textLayer.font = TrendScore.font
			textLayer.fontSize = TrendScore.font.pointSize
			textLayer.foregroundColor = UIColor.black.cgColor
			textLayer.alignmentMode = .center
			let textFrame = (textLayer.string as? NSString ?? "").boundingRect(with: textLayer.frame.size, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: TrendScore.font.pointSize)], context: nil)
			textLayer.frame = CGRect(x: graphFrame.minX + graphFrame.width * CGFloat(i) / CGFloat(TrendScore.dateLabels) - textFrame.width / 2, y: graphFrame.height + TrendScore.bottomInset / 2 - textFrame.height / 2, width: textFrame.width, height: textFrame.height)
			layer.addSublayer(textLayer)
		}

		for i in 0..<TrendScore.gradeLabels {
			let grade = minimum + (maximum - minimum) * Double(i) / Double(TrendScore.gradeLabels)
			let textLayer = CATextLayer()
			textLayer.contentsScale = UIScreen.main.scale
			textLayer.string = String(format: "%.2f%%", grade * 100)
			textLayer.font = TrendScore.font
			textLayer.fontSize = TrendScore.font.pointSize
			textLayer.foregroundColor = UIColor.black.cgColor
			let textFrame = (textLayer.string as? NSString ?? "").boundingRect(with: textLayer.frame.size, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: TrendScore.font.pointSize)], context: nil)
			textLayer.frame = CGRect(x: TrendScore.leftInset / 2 - textFrame.width / 2, y: graphFrame.height - graphFrame.height * CGFloat(i) / CGFloat(TrendScore.gradeLabels) - textFrame.height / 2, width: textFrame.width, height: textFrame.height)
			layer.addSublayer(textLayer)
		}

		guard trendScores.count > 0 else {
			return
		}
		let trendLine = UIBezierPath()
		trendLine.move(to: graphFrame.bottomLeftCorner)
		for trendScore in trendScores {
			trendLine.addLine(to: CGPoint(x: graphFrame.minX + graphFrame.width * CGFloat(trendScore.dayID.timeIntervalSince(startDate) / dateDifference), y: graphFrame.height - graphFrame.height * CGFloat(((Double(trendScore.score) ?? 0) - minimum) / scoreDifference)))
		}
		let trendLineShapeLayer = CAShapeLayer()
		trendLineShapeLayer.frame = layer.frame
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
		return CGPoint(x: minX, y: minY)
	}
	var topRightCorner: CGPoint {
		return CGPoint(x: maxX, y: minY)
	}
	var bottomLeftCorner: CGPoint {
		return CGPoint(x: minX, y: maxY)
	}
	var bottomRightCorner: CGPoint {
		return CGPoint(x: maxX, y: maxY)
	}
}
