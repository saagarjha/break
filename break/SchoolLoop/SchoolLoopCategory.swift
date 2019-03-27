//
//  SchoolLoopCategory.swift
//  break
//
//  Created by Saagar Jha on 5/20/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

// Represents a single category.
@objc(SchoolLoopCategory)
public class SchoolLoopCategory: NSObject, NSSecureCoding {
	/// The name of this category.
	public var name: String

	/// The score for this category.
	public var score: String

	/// The weight of this category.
	public var weight: String


	/// This class supports secure coding.
	public static var supportsSecureCoding = true


	/// Create a new category with the specified values.
	///
	/// - Parameters:
	///   - name: The name of this category
	///   - score: The score for this category
	///   - weight: The weight of this category
	public init(name: String, score: String, weight: String) {
		self.name = name ?! ""
		self.score = score ?! ""
		self.weight = weight ?! ""
		super.init()
	}


	/// Copy constructor.
	///
	/// - Parameter category: The category to copy
	convenience init(category: SchoolLoopCategory) {
		self.init(name: category.name, score: category.score, weight: category.weight)
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init(coder aDecoder: NSCoder) {
		name = aDecoder.decodeObject(of: NSString.self, forKey: "name") as String? ?? ""
		score = aDecoder.decodeObject(of: NSString.self, forKey: "score") as String? ?? ""
		weight = aDecoder.decodeObject(of: NSString.self, forKey: "weight") as String? ?? ""
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(score, forKey: "score")
		aCoder.encode(weight, forKey: "weight")
	}
}
