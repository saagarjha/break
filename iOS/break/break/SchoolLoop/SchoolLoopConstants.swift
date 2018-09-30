//
//  SchoolLoopConstants.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import UIKit

/// A set of constants for the School Loop API.
enum SchoolLoopConstants {
	/// The application verion. It appears that School Loop accepts anything
	/// greater than 2.
	private static let version = "3"
	
	#if os(iOS)
		/// The UUID of the current device.
		static let devToken = UIDevice.current.identifierForVendor?.uuidString ?? ""
	#else
		/// The UUID of the current device. watchOS does not support this API.
		static let devToken = ""
	#endif
	
	/// A string describing the device, in this case the model identifier.
	public static var devOS: String {
		get {
			var systemInfo = utsname()
			uname(&systemInfo)
			return withUnsafePointer(to: systemInfo.machine) {
				$0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
					String(cString: $0)
				}
			}
		}
	}
	
	/// The current year.
	private static var year: String {
		get {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "y"
			return dateFormatter.string(from: Date())
		}
	}
	
	/// The max number of items to fetch for rate-limited APIs.
	private static let max = "25"
	
	
	/// A URL to the School Loop "forgot password" page.
	static let forgotURL = URL(string: "https://lol.schoolloop.com/portal/forgot_password")!

	/// Creates a link to the School Loop school API endpoint.
	///
	/// - Returns: The link to the schools API endpoint
	static func schoolURL() -> URL {
		return URL(string: "https://lol.schoolloop.com/mapi/schools".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	/// Creates a URL to the School Loop login endpoint with the specified
	/// domain name.
	///
	/// - Parameters:
	///     - domainName: The domain name used for the creation of the URL
	/// - Returns: A URL to the School Loop login endpoint with the specified
	///   domain name
	static func loginURL(domainName: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/login?version=\(version)&devToken=\(SchoolLoopConstants.devToken)&devOS=\(SchoolLoopConstants.devOS)&year=\(SchoolLoopConstants.year)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	/// Creates a URL to the School Loop course endpoint with the specified
	/// domain name and student ID.
	///
	/// - Parameters:
	///   - domainName: The domain name used for the creation of the URL
	///   - studentID: The student ID used for the creation of the URL
	/// - Returns: A URL to the SchoolLoop course endpoint with the specified
	///   domain name and student ID
	static func courseURL(domainName: String, studentID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/report_card?studentID=\(studentID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	/// Creates a URL to the School Loop course endpoint with the specified
	/// domain name, student ID, and period ID.
	///
	/// - Parameters:
	///   - domainName: The domain name used for the creation of the URL
	///   - studentID: The student ID used for the creation of the URL
	///   - periodID: The period ID used for the creation of the URL
	/// - Returns: A URL to the School Loop course endpoint with the specified
	///   domain name, student ID, and period ID
	static func gradeURL(domainName: String, studentID: String, periodID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/progress_report?studentID=\(studentID)&periodID=\(periodID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}
	
	/// Creates a URL to the School Loop assignment endpoint with the specified
	/// domain name and student ID.
	///
	/// - Parameters:
	///   - domainName: The domain name used for the creation of the URL
	///   - studentID: The student ID used for the creation of the URL
	/// - Returns: A URL to the School Loop assignment endpoint with the
	///   specified domain name and student ID
	static func assignmentURL(domainName: String, studentID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/assignments?studentID=\(studentID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	/// Creates a URL to the School Loop LoopMail endpoint with the specified
	/// domain name and student ID.
	///
	/// - Parameters:
	///   - domainName: The domain name used for the creation of the URL
	///   - studentID: The student ID used for the creation of the URL
	/// - Returns: A URL to the School Loop LoopMail endpoint with the specified
	///   domain name and student ID
	static func loopMailURL(domainName: String, studentID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/mail_messages?studentID=\(studentID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	/// Creates a URL to the School Loop LoopMail message endpoint with the
	/// specified domain name, student ID, and ID.
	///
	/// - Parameters:
	///   - domainName: The domain name used for the creation of the URL
	///   - studentID: The student ID used for the creation of the URL
	///   - ID: The ID used for the creation of the URL
	/// - Returns: A URL to the School Loop LoopMail message endpoint with the
	///   specified domain name, student ID, and ID
	static func loopMailMessageURL(domainName: String, studentID: String, ID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/mail_messages?studentID=\(studentID)&ID=\(ID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	/// Creates a URL to the School Loop LoopMail contacts endpoint with the
	/// specified domain name, student ID, and query.
	///
	/// - Parameters:
	///   - domainName: The domain name used for the creation of the URL
	///   - studentID: The student ID used for the creation of the URL
	///   - query: The query used for the creation of the URL
	/// - Returns: A URL to the School Loop LoopMail contacts endpoint with the
	///   specified domain name, student ID, and query
	static func loopMailContactsURL(domainName: String, studentID: String, query: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/contacts?studentID=\(studentID)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	/// Creates a URL to the School Loop LoopMail send endpoint with the
	/// specified domain name.
	///
	/// - Parameters:
	///     - domainName: The domain name used for the creation of the URL
	/// - Returns: A URL to the School Loop LoopMail send endpoint with the
	///   specified domain name
	static func loopMailSendURL(domainName: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/mail_messages".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}
	
	/// Creates a URL to the School Loop news endpoint with the specified domain
	/// name and student ID.
	///
	/// - Parameters:
	///   - domainName: The domain name used for the creation of the URL
	///   - studentID: The student ID used for the creation of the URL
	/// - Returns: A URL to the School Loop news endpoint with the specified
	///   domain name and student ID
	static func newsURL(domainName: String, studentID: String) -> URL {
		return URL(string: "https://\(domainName)/mapi/news?studentID=\(studentID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
	}

	/// Creates a URL to the School Loop locker endpoint with the specified
	/// path, domain name, and username.
	///
	/// - Parameters:
	///   - path: The path used for the creation of the URL
	///   - domainName: The domain name used for the creation of the URL
	///   - username: The username used for the creation of the URL
	/// - Returns: A URL to the School Loop locker endpoint with the specified
	///   domain name and student ID
	static func lockerURL(path: String, domainName: String, username: String) -> URL {
		return URL(string: "https://webdav-\(domainName)/users/\(username)\(path)")!
	}
}
