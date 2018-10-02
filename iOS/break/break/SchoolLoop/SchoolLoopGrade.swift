//
//  SchoolLoopGrade.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single grade.
@objc(SchoolLoopGrade)
public class SchoolLoopGrade: NSObject, NSCoding {
	/// A shared date formatter for parsing the due date and last changed date.
	private static var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		return dateFormatter
	}()


	/// The title of this grade.
	public var title: String

	/// The category name of this grade.
	public var categoryName: String

	/// The percent score for this grade.
	public var percentScore: String

	/// The score for this grade.
	public var score: String

	/// The max points for this grade.
	public var maxPoints: String

	/// The comment for this grade.
	public var comment: String

	/// The system ID of this grade.
	public var systemID: String

	/// The due date of this grade.
	public var dueDate: Date

	/// The changed date of this grade.
	public var changedDate: Date


	/// This class supports secure coding.
	public static var supportsSecureCoding = true


	/// Creates a new grade with the specified values.
	///
	/// - Parameters:
	///   - title: The title of this grade
	///   - categoryName: The category name of this grade
	///   - percentScore: The percent score for this grade
	///   - score: The score for this grade
	///   - maxPoints: The max points for this grade
	///   - comment: The comment for this grade
	///   - systemID: The system ID of this grade
	///   - dueDate: the due date of this grade
	///   - changedDate: The changed date of this grade
	public init(title: String, categoryName: String, percentScore: String, score: String, maxPoints: String, comment: String, systemID: String, dueDate: String, changedDate: String) {
		self.title = title ?! ""
		self.categoryName = categoryName ?! ""
		self.percentScore = percentScore ?! ""
		self.score = score ?! ""
		self.maxPoints = maxPoints ?! ""
		self.comment = comment ?! ""
		self.systemID = systemID ?! ""
		self.dueDate = SchoolLoopGrade.dateFormatter.date(from: dueDate) ?? Date.distantPast
		self.changedDate = SchoolLoopGrade.dateFormatter.date(from: changedDate) ?? Date.distantPast
		super.init()
	}

	/// Copy constructor.
	///
	/// - Parameter grade: The grade to copy
	convenience init(grade: SchoolLoopGrade) {
		self.init(title: grade.title, categoryName: grade.categoryName, percentScore: grade.percentScore, score: grade.score, maxPoints: grade.maxPoints, comment: grade.comment, systemID: grade.systemID, dueDate: SchoolLoopGrade.dateFormatter.string(from: grade.dueDate), changedDate: SchoolLoopGrade.dateFormatter.string(from: grade.dueDate))
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObject(of: NSString.self, forKey: "title") as String? ?? ""
		categoryName = aDecoder.decodeObject(of: NSString.self, forKey: "categoryName") as String? ?? ""
		percentScore = aDecoder.decodeObject(of: NSString.self, forKey: "percentScore") as String? ?? ""
		score = aDecoder.decodeObject(of: NSString.self, forKey: "score") as String? ?? ""
		maxPoints = aDecoder.decodeObject(of: NSString.self, forKey: "maxPoints") as String? ?? ""
		comment = aDecoder.decodeObject(of: NSString.self, forKey: "comment") as String? ?? ""
		systemID = aDecoder.decodeObject(of: NSString.self, forKey: "systemID") as String? ?? ""
		dueDate = aDecoder.decodeObject(of: NSDate.self, forKey: "dueDate") as Date? ?? Date.distantPast
		changedDate = aDecoder.decodeObject(of: NSDate.self, forKey: "changedDate") as Date? ?? Date.distantPast
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(categoryName, forKey: "categoryName")
		aCoder.encode(percentScore, forKey: "percentScore")
		aCoder.encode(score, forKey: "score")
		aCoder.encode(maxPoints, forKey: "maxPoints")
		aCoder.encode(comment, forKey: "comment")
		aCoder.encode(systemID, forKey: "systemID")
		aCoder.encode(dueDate, forKey: "dueDate")
		aCoder.encode(changedDate, forKey: "changedDate")
	}
}
