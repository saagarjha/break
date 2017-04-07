//
//  SchoolLoopLoopMail.swift
//  break
//
//  Created by Saagar Jha on 1/22/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopLoopMail)
class SchoolLoopLoopMail: NSObject, NSCoding {
	var subject: String
	var sender: SchoolLoopContact
	var date: Date
	var ID: String

	var message: String = ""
	var links = [(title: String, URL: String)]()

	init(subject: String, sender: SchoolLoopContact, date: String, ID: String) {
		self.subject = subject ?! ""
		self.sender = sender
		self.date = Date(timeIntervalSince1970: TimeInterval(date)! / 1000)
		self.ID = ID ?! ""
		super.init()
	}

	func set(newDate date: String) {
		self.date = Date(timeIntervalSince1970: TimeInterval(date)! / 1000)
	}

	required init?(coder aDecoder: NSCoder) {
		subject = aDecoder.decodeObject(forKey: "subject") as? String ?? ""
		sender = aDecoder.decodeObject(forKey: "sender") as? SchoolLoopContact ?? SchoolLoopContact(id: "", name: "", role: "", desc: "")
		date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date.distantPast
		ID = aDecoder.decodeObject(forKey: "ID") as? String ?? ""
		message = aDecoder.decodeObject(forKey: "message") as? String ?? ""
		links = (aDecoder.decodeObject(forKey: "links") as? [[String]])?.map { (title: $0[0], URL: $0[1]) } ?? []
		super.init()
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(subject, forKey: "subject")
		aCoder.encode(sender, forKey: "sender")
		aCoder.encode(date, forKey: "date")
		aCoder.encode(ID, forKey: "ID")
		aCoder.encode(message, forKey: "message")
		aCoder.encode(links.map { [$0.title, $0.URL] }, forKey: "links")
	}
}
