//
//  SchoolLoopLoopMail.swift
//  break
//
//  Created by Saagar Jha on 1/22/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopLoopMail: NSObject, NSCoding {
	var subject: String
	var sender: String
	var date: NSDate
	var ID: String

	var message: String = ""
    var links: [(title: String, URL: String)] = []

	init(subject: String, sender: String, date: String, ID: String) {
		self.subject = subject
		self.sender = sender
		self.date = NSDate(timeIntervalSince1970: NSTimeInterval(date)! / 1000)
		self.ID = ID
        super.init()
	}
    
    func setNewDate(date: String) {
        self.date = NSDate(timeIntervalSince1970: NSTimeInterval(date)! / 1000)
    }
    
    required init?(coder aDecoder: NSCoder) {
        subject = aDecoder.decodeObjectForKey("subject")  as? String ?? ""
        sender = aDecoder.decodeObjectForKey("sender") as? String ?? ""
        date = aDecoder.decodeObjectForKey("date") as? NSDate ?? NSDate.distantPast()
        ID = aDecoder.decodeObjectForKey("ID") as? String ?? ""
        message = aDecoder.decodeObjectForKey("message") as? String ?? ""
        links = aDecoder.decodeObjectForKey("links")  as? [(title: String, URL: String)] ?? []
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(subject, forKey: "subject")
        aCoder.encodeObject(sender, forKey: "sender")
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeObject(ID, forKey: "ID")
        aCoder.encodeObject(message, forKey: "message")
        aCoder.encodeObject(links as? AnyObject, forKey: "links")
    }
}
