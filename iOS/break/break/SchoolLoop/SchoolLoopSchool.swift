//
//  SchoolLoopSchool.swift
//  break
//
//  Created by Saagar Jha on 1/28/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopSchool)
class SchoolLoopSchool: NSObject, NSCoding {
	var name: String
	var domainName: String
	var districtName: String

	init(name: String, domainName: String, districtName: String) {
		self.name = name ?! ""
		self.domainName = domainName ?! ""
		self.districtName = districtName ?! ""
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
		domainName = aDecoder.decodeObject(forKey: "domainName") as? String ?? ""
		districtName = aDecoder.decodeObject(forKey: "districtName") as? String ?? ""
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(domainName, forKey: "domainName")
		aCoder.encode(districtName, forKey: "districtName")
	}
}

extension SchoolLoopSchool: Comparable { }

func == (lhs: SchoolLoopSchool, rhs: SchoolLoopSchool) -> Bool {
	return lhs.name == rhs.name
}

func < (lhs: SchoolLoopSchool, rhs: SchoolLoopSchool) -> Bool {
	return lhs.name < rhs.name
}
