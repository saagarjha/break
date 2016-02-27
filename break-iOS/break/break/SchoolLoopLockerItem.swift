//
//  SchoolLoopLockerItem.swift
//  break
//
//  Created by Saagar Jha on 2/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopLockerItem {
	var name: String
	var path: String
	var type: SchoolLoopLockerItemType

	var lockerItems: [SchoolLoopLockerItem] = []

	init(name: String, path: String, type: SchoolLoopLockerItemType) {
		self.name = name
		self.path = path
		self.type = type
	}
}

func == (lhs: SchoolLoopLockerItem, rhs: SchoolLoopLockerItem) -> Bool {
	return lhs.name == rhs.name && lhs.path == rhs.path && lhs.type == rhs.type
}