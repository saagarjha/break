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
		self.Name = Name ?! ""
		self.Start = Start ?! ""
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		self.Name = aDecoder.decodeObject(forKey: "Name") as? String ?? ""
		self.Start = aDecoder.decodeObject(forKey: "Start") as? String ?? ""
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(Name, forKey: "Name")
		aCoder.encode(Start, forKey: "Start")
	}
}
