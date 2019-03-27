//
//  SchoolLoopLockerItem.swift
//  break
//
//  Created by Saagar Jha on 2/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

/// Represents a single locker item.
public class SchoolLoopLockerItem {
	/// The name of this locker item.
	public var name: String

	/// The path of this locker item.
	public var path: String

	/// The type of this locker item.
	public var type: SchoolLoopLockerItemType


	/// The locker items for this locker item.
	public var lockerItems = [SchoolLoopLockerItem]()

	/// Create a new locker item with the specified values.
	///
	/// - Parameters:
	///   - name: The name of this locker item
	///   - path: The path of this locker item
	///   - type: The type of this locker item
	public init(name: String, path: String, type: SchoolLoopLockerItemType) {
		self.name = name ?! ""
		self.path = path ?! ""
		self.type = type
	}
}

extension SchoolLoopLockerItem: Equatable, Comparable {
}

public func == (lhs: SchoolLoopLockerItem, rhs: SchoolLoopLockerItem) -> Bool {
	return lhs.name == rhs.name && lhs.path == rhs.path && lhs.type == rhs.type
}

public func < (lhs: SchoolLoopLockerItem, rhs: SchoolLoopLockerItem) -> Bool {
	return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
