//
//  SchoolLoopConstants.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import UIKit

struct SchoolLoopConstants {
	static let version = "2"
	static let devToken = UIDevice.currentDevice().identifierForVendor!.UUIDString
	static var devOS: String {
		get {
			var systemInfo = utsname()
			uname(&systemInfo)
			let machineMirror = Mirror(reflecting: systemInfo.machine)
			return machineMirror.children.reduce("") { identifier, element in
				guard let value = element.value as? Int8 where value != 0 else {
					return identifier
				}
				return identifier + String(UnicodeScalar(UInt8(value)))
			}
		}
	}
	static var year: String {
		get {
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "yyyy"
			return dateFormatter.stringFromDate(NSDate())
		}
	}
    static let max = "10000"

	static func schoolURL() -> NSURL {
		return NSURL(string: "https://lol.schoolloop.com/mapi/schools".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
	}

	static func logInURL(domainName: String) -> NSURL {
		return NSURL(string: "https://\(domainName)/mapi/login?version=\(version)&devToken=\(SchoolLoopConstants.devToken)&devOS=\(SchoolLoopConstants.devOS)&year=\(SchoolLoopConstants.year)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
	}

	static func courseURL(domainName: String, studentID: String) -> NSURL {
		return NSURL(string: "https://\(domainName)/mapi/report_card?studentID=\(studentID)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
	}

	static func gradeURL(domainName: String, studentID: String, periodID: String) -> NSURL {
		return NSURL(string: "https://\(domainName)/mapi/progress_report?studentID=\(studentID)&periodID=\(periodID)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
	}

	static func assignmentURL(domainName: String, studentID: String) -> NSURL {
		return NSURL(string: "https://\(domainName)/mapi/assignments?studentID=\(studentID)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
	}

	static func loopMailURL(domainName: String, studentID: String) -> NSURL {
		return NSURL(string: "https://\(domainName)/mapi/mail_messages?studentID=\(studentID)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
	}

	static func loopMailMessageURL(domainName: String, studentID: String, ID: String) -> NSURL {
		return NSURL(string: "https://\(domainName)/mapi/mail_messages?studentID=\(studentID)&ID=\(ID)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
	}

	static func newsURL(domainName: String, studentID: String) -> NSURL {
		return NSURL(string: "https://\(domainName)/mapi/news?studentID=\(studentID)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
	}

	static func lockerURL(path: String, domainName: String, username: String) -> NSURL {
		return NSURL(string: "https://webdav-\(domainName)/users/\(username)\(path)")!
	}
}
