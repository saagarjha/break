//
//  SchoolLoopContact.swift
//  break
//
//  Created by Saagar Jha on 11/14/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single contact.
@objc(SchoolLoopContact)
public class SchoolLoopContact: NSObject, NSCoding {
	/// The ID for this contact.
	public var id: String

	/// The name of this contact.
	public var name: String

	/// The role of this contact.
	public var role: String

	/// The description of this contact.
	public var desc: String


	/// The hash value of this contact.
	public override var hashValue: Int {
		get {
			return id.hashValue
		}
	}


	/// This class supports secure coding.
	public static var supportsSecureCoding = true


	/// Create a new contact with the specified values.
	///
	/// - Parameters:
	///   - id: The ID for this contact
	///   - name: The name of this contact
	///   - role: The role of this contact
	///   - desc: The description of this contact
	public init(id: String, name: String, role: String, desc: String) {
		self.id = id ?! ""
		self.name = name ?! ""
		self.role = role ?! ""
		self.desc = desc ?! ""
		super.init()
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init(coder aDecoder: NSCoder) {
		id = aDecoder.decodeObject(of: NSString.self, forKey: "id") as String? ?? ""
		name = aDecoder.decodeObject(of: NSString.self, forKey: "name") as String? ?? ""
		role = aDecoder.decodeObject(of: NSString.self, forKey: "role") as String? ?? ""
		desc = aDecoder.decodeObject(of: NSString.self, forKey: "desc") as String? ?? ""
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(id, forKey: "id")
		aCoder.encode(name, forKey: "name")
		aCoder.encode(role, forKey: "role")
		aCoder.encode(desc, forKey: "desc")
	}
}

public func == (left: SchoolLoopContact, right: SchoolLoopContact) -> Bool {
	return left.id == right.id
}
