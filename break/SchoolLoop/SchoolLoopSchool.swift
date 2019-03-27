//
//  SchoolLoopSchool.swift
//  break
//
//  Created by Saagar Jha on 1/28/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single school.
@objc(SchoolLoopSchool)
public class SchoolLoopSchool: NSObject, NSCoding {
	/// The name of this school.
	public var name: String

	/// The domain name for this school.
	public var domainName: String

	/// The district name of this school.
	public var districtName: String


	/// This class supports secure coding.
	public static var supportsSecureCoding = true


	/// Creates a new school with the specified values.
	///
	/// - Parameters:
	///   - name: The name of this school
	///   - domainName: The domain name for this school
	///   - districtName: The district name of this school
	public init(name: String, domainName: String, districtName: String) {
		self.name = name ?! ""
		self.domainName = domainName ?! ""
		self.districtName = districtName ?! ""
		super.init()
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		name = aDecoder.decodeObject(of: NSString.self, forKey: "name") as String? ?? ""
		domainName = aDecoder.decodeObject(of: NSString.self, forKey: "domainName") as String? ?? ""
		districtName = aDecoder.decodeObject(of: NSString.self, forKey: "districtName") as String? ?? ""
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(domainName, forKey: "domainName")
		aCoder.encode(districtName, forKey: "districtName")
	}
}

extension SchoolLoopSchool: Comparable { }

public func == (lhs: SchoolLoopSchool, rhs: SchoolLoopSchool) -> Bool {
	return lhs.name == rhs.name
}

public func < (lhs: SchoolLoopSchool, rhs: SchoolLoopSchool) -> Bool {
	return lhs.name < rhs.name
}
