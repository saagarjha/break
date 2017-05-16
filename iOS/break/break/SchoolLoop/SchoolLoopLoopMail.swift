//
//  SchoolLoopLoopMail.swift
//  break
//
//  Created by Saagar Jha on 1/22/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single LoopMail.
@objc(SchoolLoopLoopMail)
public class SchoolLoopLoopMail: NSObject, NSCoding {
	/// The subject of this LoopMail.
	public var subject: String
	
	/// The sender of this LoopMail.
	public var sender: SchoolLoopContact
	
	/// The date of this LoopMail.
	public var date: Date
	
	/// The ID of this LoopMail.
	public var ID: String
	

	/// The message of this LoopMail.
	public var message: String = ""
	
	/// This links associated with this LoopMail.
	public var links = [(title: String, URL: String)]()

	
	/// This class supports secure coding.
	public static var supportsSecureCoding = true
	
	
	/// Creates a new LoopMail with the specified values.
	///
	/// - Parameters:
	///   - subject: The subject of this LoopMail
	///   - sender: The sender of this LoopMail
	///   - date: The date of this LoopMail
	///   - ID: The ID of this LoopMail
	public init(subject: String, sender: SchoolLoopContact, date: String, ID: String) {
		self.subject = subject ?! ""
		self.sender = sender
		self.date = Date(timeIntervalSince1970: (TimeInterval(date) ?? 0) / 1000)
		self.ID = ID ?! ""
		super.init()
	}

	/// Sets a new date value for this LoopMail.
	///
	/// - Parameters:
	///   - date: The new date value
	func set(newDate date: String) {
		self.date = Date(timeIntervalSince1970: (TimeInterval(date) ?? 0) / 1000)
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		subject = aDecoder.decodeObject(of: NSString.self, forKey: "subject") as String? ?? ""
		sender = aDecoder.decodeObject(of: SchoolLoopContact.self, forKey: "sender") ?? SchoolLoopContact(id: "", name: "", role: "", desc: "")
		date = aDecoder.decodeObject(of: NSDate.self, forKey: "date") as Date? ?? Date.distantPast
		ID = aDecoder.decodeObject(of: NSString.self, forKey: "ID") as String? ?? ""
		message = aDecoder.decodeObject(of: NSString.self, forKey: "message") as String? ?? ""
		links = (aDecoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "links") as? [[String]])?.map { (title: $0[0], URL: $0[1]) } ?? []
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(subject, forKey: "subject")
		aCoder.encode(sender, forKey: "sender")
		aCoder.encode(date, forKey: "date")
		aCoder.encode(ID, forKey: "ID")
		aCoder.encode(message, forKey: "message")
		aCoder.encode(links.map { [$0.title, $0.URL] }, forKey: "links")
	}
}
