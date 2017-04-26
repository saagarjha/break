//
//  SchoolLoopAssignment.swift
//  break
//
//  Created by Saagar Jha on 1/20/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single assignment.
@objc(SchoolLoopAssignment)
public class SchoolLoopAssignment: NSObject, NSCoding {
	/// The title of this assignment.
	public var title: String
	
	/// The description of this assignment.
	public var assignmentDescription: String
	
	/// The course name associated with this assignment.
	public var courseName: String
	
	/// The due date of this assignment.
	public var dueDate: Date
	
	/// The links associated with this assignment.
	public var links: [(title: String, URL: String)]
	
	/// The ID of this assignment.
	public var iD: String

	
	/// A Boolean that designates whether this assignment is completed.
	public var isCompleted: Bool
	

	/// Create a new assignment with the specified values.
	///
	/// - Parameters:
	///   - title: The title of this assignment
	///   - assignmentDescription: The description of this assignment
	///   - courseName: The course name associated with this assignment
	///   - dueDate: The due date of this assignment
	///   - links: The links associated with this assignment
	///   - iD: The ID of this assignment
	public init(title: String, assignmentDescription: String, courseName: String, dueDate: String, links: [(title: String, URL: String)], iD: String) {
		self.title = title ?! ""
		self.assignmentDescription = assignmentDescription ?! ""
		self.courseName = courseName ?! ""
		self.dueDate = Date(timeIntervalSince1970: (TimeInterval(dueDate) ?? 0) / 1000)
		self.links = links
		self.iD = iD ?! ""
		isCompleted = false
		super.init()
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
		assignmentDescription = aDecoder.decodeObject(forKey: "assignmentDescription") as? String ?? ""
		courseName = aDecoder.decodeObject(forKey: "courseName") as? String ?? ""
		dueDate = aDecoder.decodeObject(forKey: "dueDate") as? Date ?? Date.distantPast
		links = (aDecoder.decodeObject(forKey: "links") as? [[String]])?.map { (title: $0[0], URL: $0[1]) } ?? []
		iD = aDecoder.decodeObject(forKey: "iD") as? String ?? ""
		isCompleted = aDecoder.decodeObject(forKey: "isCompleted") as? Bool ?? false
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(description, forKey: "assignmentDescription")
		aCoder.encode(courseName, forKey: "courseName")
		aCoder.encode(dueDate, forKey: "dueDate")
		aCoder.encode(links.map { [$0.title, $0.URL] }, forKey: "links")
		aCoder.encode(iD, forKey: "iD")
		aCoder.encode(isCompleted as Any, forKey: "isCompleted")
	}
}
