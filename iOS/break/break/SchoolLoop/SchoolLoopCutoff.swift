//
//  SchoolLoopCutoff.swift
//  break
//
//  Created by Saagar Jha on 5/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single cutoff.
@objc(SchoolLoopCutoff)
public class SchoolLoopCutoff: NSObject, NSCoding {
	/// The name of this cutoff.
	public var Name: String
	
	// The start of this cutoff.
	public var Start: String
	
	
	/// This class supports secure coding.
	public static var supportsSecureCoding = true

	
	/// Create a new cutoff with the specified values.
	///
	/// - Parameters:
	///   - Name: The name of this cutoff
	///   - Start: The start of this cutoff
	public init(Name: String, Start: String) {
		self.Name = Name ?! ""
		self.Start = Start ?! ""
		super.init()
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		self.Name = aDecoder.decodeObject(of: NSString.self, forKey: "Name") as String? ?? ""
		self.Start = aDecoder.decodeObject(of: NSString.self, forKey: "Start") as String? ?? ""
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(Name, forKey: "Name")
		aCoder.encode(Start, forKey: "Start")
	}
}
