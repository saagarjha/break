//
//  SchoolLoopContact.swift
//  break
//
//  Created by Saagar Jha on 11/14/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopContact)
class SchoolLoopContact: NSObject, NSCoding {
	var id: String
	var name: String
	var role: String
	var desc: String

	override var hashValue: Int {
		get {
			return id.hashValue
		}
	}

	init(id: String, name: String, role: String, desc: String) {
		self.id = id
		self.name = name
		self.role = role
		self.desc = desc
	}

	required init(coder aDecoder: NSCoder) {
		id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
		name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
		role = aDecoder.decodeObject(forKey: "role") as? String ?? ""
		desc = aDecoder.decodeObject(forKey: "desc") as? String ?? ""
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(id, forKey: "id")
		aCoder.encode(name, forKey: "name")
		aCoder.encode(role, forKey: "role")
		aCoder.encode(desc, forKey: "desc")
	}
}

func == (left: SchoolLoopContact, right: SchoolLoopContact) -> Bool {
	return left.id == right.id
}
