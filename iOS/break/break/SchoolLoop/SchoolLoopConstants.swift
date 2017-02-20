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
	static let version = "3"
	#if os(iOS)
		static let devToken = UIDevice.current.identifierForVendor?.uuidString ?? ""
	#else
		static let devToken = ""
	#endif
	static var devOS: String {
		get {
			var systemInfo = utsname()
			uname(&systemInfo)
			let machineMirror = Mirror(reflecting: systemInfo.machine)
			return machineMirror.children.reduce("") { identifier, element in
				guard let value = element.value as? Int8, value != 0 else {
					return identifier
				}
				return identifier + String(UnicodeScalar(UInt8(value)))
			}
		}
	}
	static var year: String {
		get {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "y"
			return dateFormatter.string(from: Date())
		}
	}
	static let max = "25"
	static let forgotURL = URL(string: "https://montavista.schoolloop.com/portal/forgot_password")!

	static func schoolURL() -> URL {
		return URL(string: "https://lol.schoolloop.com/mapi/schools".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func logInURL(withDomainName domainName: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/login?version=\(version)&devToken=\(SchoolLoopConstants.devToken)&devOS=\(SchoolLoopConstants.devOS)&year=\(SchoolLoopConstants.year)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func courseURL(withDomainName domainName: String, studentID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/report_card?studentID=\(studentID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func gradeURL(withDomainName domainName: String, studentID: String, periodID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/progress_report?studentID=\(studentID)&periodID=\(periodID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func assignmentURL(withDomainName domainName: String, studentID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/assignments?studentID=\(studentID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func loopMailURL(withDomainName domainName: String, studentID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/mail_messages?studentID=\(studentID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func loopMailMessageURL(withDomainName domainName: String, studentID: String, ID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/mail_messages?studentID=\(studentID)&ID=\(ID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func loopMailContactsURL(withDomainName domainName: String, studentID: String, query: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/contacts?studentID=\(studentID)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func loopMailSendURL(withDomainName domainName: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/mail_messages".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func newsURL(withDomainName domainName: String, studentID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/news?studentID=\(studentID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	static func lockerURL(withPath path: String, domainName: String, username: String) -> URL {
		return URL(string: "https://webdav-\(domainName)/users/\(username)\(path)")!
	}
}
