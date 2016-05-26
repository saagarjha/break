//
//  SchoolLoopCutoff.swift
//  break
//
//  Created by Saagar Jha on 5/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopCutoff)
class SchoolLoopCutoff: NSObject, NSCoding {
	var Name: String
	var Start: String

	init(Name: String, Start: String) {
		self.Name = Name
		self.Start = Start
	}

	required init?(coder aDecoder: NSCoder) {
		self.Name = aDecoder.decodeObjectForKey("Name") as? String ?? ""
		self.Start = aDecoder.decodeObjectForKey("Start") as? String ?? ""
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(Name, forKey: "Name")
		aCoder.encodeObject(Start, forKey: "Start")
	}
}