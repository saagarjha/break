//
//  SchoolLoopComposedLoopMail.swift
//  break
//
//  Created by Saagar Jha on 11/14/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

/// Represents a single, "composed" LoopMail.
@objc (SchoolLoopComposedLoopMail)
public class SchoolLoopComposedLoopMail: NSObject {
	/// The subject of this LoopMail.
	public var subject: String

	/// The message of this LoopMail.
	public var message: String

	/// The recipients of this LoopMail.
	public var to: [SchoolLoopContact]

	/// The carbon copy recipients of this LoopMail.
	public var cc: [SchoolLoopContact]


	/// Creates a new "composed" LoopMail with the specified values.
	///
	/// - Parameters:
	///   - subject: The subject of this LoopMail
	///   - message: The message of this LoopMail
	///   - to: The recipients of this LoopMail
	///   - cc: The carbon copy recipients of this LoopMail
	public init(subject: String, message: String, to: [SchoolLoopContact], cc: [SchoolLoopContact]) {
		self.subject = subject ?! ""
		self.message = message ?! ""
		self.to = to
		self.cc = cc
		super.init()
	}
}
