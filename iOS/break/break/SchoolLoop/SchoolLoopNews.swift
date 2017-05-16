//
//  SchoolLoopNews.swift
//  break
//
//  Created by Saagar Jha on 1/31/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

// Represents a single news item.
@objc(SchoolLoopNews)
public class SchoolLoopNews: NSObject, NSCoding {
	// The title of this news item.
	public var title: String
	
	/// The name of the author of this news item.
	public var authorName: String
	
	/// The creation date of this news item.
	public var createdDate: Date
	
	/// The description of this news item.
	public var newsDescription: String
	
	/// The links associated with this news item.
	public var links: [(title: String, URL: String)]
	
	/// The ID of this news item.
	public var iD: String


	/// This class supports secure coding.
	public static var supportsSecureCoding = true
	
	
	/// Create a new news item with the specified values.
	///
	/// - Parameters:
	///   - title: The title of this news item
	///   - authorName: The name of the author of this news item
	///   - createdDate: The creation date of this news item
	///   - newsDescription: The description of this news item
	///   - links: TThe links associated with this news item
	///   - iD: The ID of this news item
	public init(title: String, authorName: String, createdDate: String, newsDescription: String, links: [(title: String, URL: String)], iD: String) {
		self.title = title ?! ""
		self.authorName = authorName ?! ""
		self.createdDate = Date(timeIntervalSince1970: (TimeInterval(createdDate) ?? 0) / 1000)
		self.newsDescription = newsDescription ?! ""
		self.links = links
		self.iD = iD ?! ""
		super.init()
	}

	/// Sets a new creation date value for this news item.
	///
	/// - Parameters:
	///   - createdDate: The new creation date value
	func set(newCreatedDate createdDate: String) {
		self.createdDate = Date(timeIntervalSince1970: (TimeInterval(createdDate) ?? 0) / 1000)
	}
	
	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObject(of: NSString.self, forKey: "title") as String? ?? ""
		authorName = aDecoder.decodeObject(of: NSString.self, forKey: "authorName") as String? ?? ""
		createdDate = aDecoder.decodeObject(of: NSDate.self, forKey: "createdDate") as Date? ?? Date.distantPast
		newsDescription = aDecoder.decodeObject(of: NSString.self, forKey: "newsDescription") as String? ?? ""
		links = (aDecoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "links") as? [[String]])?.map { (title: $0[0], URL: $0[1]) } ?? []
		iD = aDecoder.decodeObject(of: NSString.self, forKey: "iD") as String? ?? ""
		super.init()
	}
	
	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(authorName, forKey: "authorName")
		aCoder.encode(createdDate, forKey: "createdDate")
		aCoder.encode(newsDescription, forKey: "newsDescription")
		aCoder.encode(links.map { [$0.title, $0.URL] }, forKey: "links")
		aCoder.encode(iD, forKey: "iD")
	}
}
