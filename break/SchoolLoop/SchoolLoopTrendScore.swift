//
//  SchoolLoopTrendScore.swift
//  break
//
//  Created by Saagar Jha on 5/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

// Represents a single trend score.
@objc(SchoolLoopTrendScore)
public class SchoolLoopTrendScore: NSObject, NSCoding {
	/// The score of this trend score.
	public var score: String

	/// The day ID of this trend score.
	public var dayID: Date


	/// This class supports secure coding.
	public static var supportsSecureCoding = true


	/// Create a new trend score with the specified values.
	///
	/// - Parameters:
	///   - score: The score of this trend score
	///   - dayID: The day ID of this trend score
	public init(score: String, dayID: String) {
		self.score = score ?! ""
		self.dayID = Date(timeIntervalSince1970: (TimeInterval(dayID) ?? 0) / 1000)
		super.init()
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		score = aDecoder.decodeObject(of: NSString.self, forKey: "score") as String? ?? ""
		dayID = aDecoder.decodeObject(of: NSDate.self, forKey: "dayID") as Date? ?? Date.distantPast
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(score, forKey: "score")
		aCoder.encode(dayID, forKey: "dayID")
	}
}
