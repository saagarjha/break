//
//  SchoolLoop.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import UIKit

class SchoolLoop: NSObject, NSCoding {
	static var sharedInstance = SchoolLoop()
	let keychain = SchoolLoopKeychain.sharedInstance

	weak var schoolDelegate: SchoolLoopSchoolDelegate?
	weak var loginDelegate: SchoolLoopLoginDelegate?
	weak var courseDelegate: SchoolLoopCourseDelegate?
	weak var gradeDelegate: SchoolLoopGradeDelegate?
	weak var assignmentDelegate: SchoolLoopAssignmentDelegate?
	weak var loopMailDelegate: SchoolLoopLoopMailDelegate?
	weak var loopMailMessageDelegate: SchoolLoopLoopMailMessageDelegate?
	weak var newsDelegate: SchoolLoopNewsDelegate?
	weak var lockerDelegate: SchoolLoopLockerDelegate?

	var username: String!
	var password: String!
	var fullName: String!
	var studentID: String!

	var school: SchoolLoopSchool!
	var schools: [SchoolLoopSchool] = []
	var account: SchoolLoopAccount!
	var courses: [SchoolLoopCourse] = []
	var assignments: [SchoolLoopAssignment] = []
	var assignmentsWithDueDates: [NSDate: [SchoolLoopAssignment]] {
		get {
			var awdd: [NSDate: [SchoolLoopAssignment]] = [:]
			for assigment in assignments {
				var assignmentsForDate = awdd[assigment.dueDate] ?? []
				assignmentsForDate.append(assigment)
				awdd[assigment.dueDate] = assignmentsForDate
			}
			return awdd
		}
	}
	var loopMail: [SchoolLoopLoopMail] = []
	var news: [SchoolLoopNews] = []
	var locker: SchoolLoopLockerItem!

	var currentTokens: [String] = []
	var currentName = ""
	var currentPath = ""
	var currentType = SchoolLoopLockerItemType.Unknown

	private override init() {
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		let schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.school = aDecoder.decodeObjectForKey("school") as? SchoolLoopSchool
		schoolLoop.schools = aDecoder.decodeObjectForKey("schools") as? [SchoolLoopSchool] ?? []
		account = aDecoder.decodeObjectForKey("account") as? SchoolLoopAccount
		schoolLoop.courses = aDecoder.decodeObjectForKey("courses") as? [SchoolLoopCourse] ?? []
		schoolLoop.assignments = aDecoder.decodeObjectForKey("assignments") as? [SchoolLoopAssignment] ?? []
		schoolLoop.loopMail = aDecoder.decodeObjectForKey("loopMail") as? [SchoolLoopLoopMail] ?? []
		schoolLoop.news = aDecoder.decodeObjectForKey("news") as? [SchoolLoopNews] ?? []
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(school, forKey: "school")
		aCoder.encodeObject(schools, forKey: "schools")
		aCoder.encodeObject(account, forKey: "account")
		aCoder.encodeObject(courses, forKey: "courses")
		aCoder.encodeObject(assignments, forKey: "assignments")
		aCoder.encodeObject(loopMail, forKey: "loopMail")
		aCoder.encodeObject(news, forKey: "news")
	}

	func getSchools() {
		let url = SchoolLoopConstants.schoolURL()
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "GET"
		let session = NSURLSession.sharedSession()
		session.synchronousDataTaskWithRequest(request) { (data, response, error) in
			guard let data = data,
				dataJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [AnyObject] else {
					self.schoolDelegate?.gotSchools(self, error: .ParseError)
					return
			}
			guard let schoolsJSON = dataJSON else {
				self.schoolDelegate?.gotSchools(self, error: .ParseError)
				return
			}
			for schoolJSON in schoolsJSON {
				guard let schoolJSON = schoolJSON as? [String: AnyObject] else {
					self.schoolDelegate?.gotSchools(self, error: .ParseError)
					return
				}
				guard let name = schoolJSON["name"] as? String,
					domainName = schoolJSON["domainName"] as? String else {
						self.schoolDelegate?.gotSchools(self, error: .ParseError)
						return
				}
				let school = SchoolLoopSchool(name: name, domainName: domainName)
				self.schools.append(school)
			}
			self.schoolDelegate?.gotSchools(self, error: nil)
		}
	}

	func logIn(schoolName: String, username: String, password: String) -> Bool {
//		loginDelegate?.loggedIn(self, error: nil)
//		return true
//		Logger.log("logIn called, background: \(UIApplication.sharedApplication().applicationState == .Background)")
//		school = schoolForName(schoolName)
		var loggedIn = false
		guard let school = schoolForName(schoolName) else {
			loginDelegate?.loggedIn(self, error: .AuthenticationError)
			return false
		}
		self.school = school
		self.username = username
		self.password = password
		let url = SchoolLoopConstants.logInURL(school.domainName)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.synchronousDataTaskWithRequest(request) { (data, response, error) in
			if let _ = error {
				self.loginDelegate?.loggedIn(self, error: .UnknownError)
				return
			}
			let httpResponse = response as? NSHTTPURLResponse
			if httpResponse?.statusCode != 200 {
				self.loginDelegate?.loggedIn(self, error: .UnknownError)
				return
			}
			guard let data = data,
				dataJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
					self.loginDelegate?.loggedIn(self, error: .ParseError)
					return
			}
			guard let loginJSON = dataJSON else {
				self.loginDelegate?.loggedIn(self, error: .ParseError)
				return
			}
			guard let fullName = loginJSON["fullName"] as? String,
				studentID = loginJSON["userID"] as? String else {
					self.loginDelegate?.loggedIn(self, error: .ParseError)
					return
			}
			NSUserDefaults.standardUserDefaults().setObject(schoolName, forKey: "schoolName")
			NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
			SchoolLoopKeychain.sharedInstance.save(username, password: password)
			self.fullName = fullName
			self.studentID = studentID
			self.account = SchoolLoopAccount(username: username, password: password, fullName: self.fullName, studentID: self.studentID)
			loggedIn = true
			self.loginDelegate?.loggedIn(self, error: nil)
			dispatch_async(dispatch_get_main_queue()) {
				var view: UIView?
				if let tabBarController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? UITabBarController,
					viewControllers = tabBarController.viewControllers?.map({ ($0 as? UINavigationController)?.viewControllers[0] }) {
						for viewController in viewControllers {
							if let coursesViewController = viewController as? CoursesViewController {
								view = coursesViewController.view
							}
							if let assignmentsViewController = viewController as? AssignmentsViewController {
								view = assignmentsViewController.view
							}
							if let loopMailViewController = viewController as? LoopMailViewController {
								view = loopMailViewController.view
							}
							if let newsViewController = viewController as? NewsViewController {
								view = newsViewController.view
							}
						}
				}
				if let _ = view as? AnyObject {
					return
				}
			}
//			Logger.log("logIn ended")
		}
		return loggedIn
	}

	func logOut() {
		keychain.removePassword(username)
		SchoolLoop.sharedInstance = SchoolLoop()
		(UIApplication.sharedApplication().delegate as? AppDelegate)?.showLogout()
	}

	func getCourses() -> Bool {
//		Logger.log("getCourses called, background: \(UIApplication.sharedApplication().applicationState == .Background)")
		var updated = false
		let url = SchoolLoopConstants.courseURL(school.domainName, studentID: studentID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.synchronousDataTaskWithRequest(request) { (data, response, error) in
			guard let data = data,
				dataJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [AnyObject] else {
					self.courseDelegate?.gotGrades(self, error: .ParseError)
					return
			}
			guard let coursesJSON = dataJSON else {
				self.courseDelegate?.gotGrades(self, error: .ParseError)
				return
			}
			for courseJSON in coursesJSON {
				guard let courseJSON = courseJSON as? [String: AnyObject] else {
					self.courseDelegate?.gotGrades(self, error: .ParseError)
					return
				}
				guard let courseName = courseJSON["courseName"] as? String,
					period = courseJSON["period"] as? String,
					teacherName = courseJSON["teacherName"] as? String,
					grade = courseJSON["grade"] as? String,
					score = courseJSON["score"] as? String,
					periodID = courseJSON["periodID"] as? String,
					lastUpdated = courseJSON["lastUpdated"] as? String else {
						self.courseDelegate?.gotGrades(self, error: .ParseError)
						return
				}
//				Logger.log("Course \(courseName), lastUpdated \(lastUpdated)")
				if let course = self.courseForPeriodID(periodID) {
//					Logger.log("lastUpdated new, updating")
					course.courseName = courseName
					course.period = period
					course.teacherName = teacherName
					course.grade = grade
					if course.setNewLastUpdated(lastUpdated) {
						updated = true
						if UIApplication.sharedApplication().applicationState != .Active {
							let notification = UILocalNotification()
							notification.fireDate = NSDate(timeIntervalSinceNow: 1)
							notification.alertBody = "Your grade in \(courseName) has changed"
							notification.applicationIconBadgeNumber = 1
							notification.soundName = UILocalNotificationDefaultSoundName
							UIApplication.sharedApplication().scheduleLocalNotification(notification)
						}
					}
				} else {
//					Logger.log("New course, adding")
					let course = SchoolLoopCourse(courseName: courseName, period: period, teacherName: teacherName, grade: grade, score: score, periodID: periodID)
					course.setNewLastUpdated(lastUpdated)
					self.courses.append(course)
				}
			}
			self.courseDelegate?.gotGrades(self, error: nil)
		}
//		Logger.log("getCourses ended")
		return updated
	}

	func getGrades(periodID: String) {
//		Logger.log("getGrades called, background: \(UIApplication.sharedApplication().applicationState == .Background)")
		let url = SchoolLoopConstants.gradeURL(school.domainName, studentID: studentID, periodID: periodID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.dataTaskWithRequest(request) { (data, response, error) in
			guard let course = self.courseForPeriodID(periodID) else {
				self.gradeDelegate?.gotGrades(self, error: .UnknownError)
				return
			}
			course.grades.removeAll()
			guard let data = data,
				dataJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [AnyObject] else {
					self.gradeDelegate?.gotGrades(self, error: .ParseError)
					return
			}
			guard let gradesJSON = (dataJSON?.first as? [String: AnyObject])?["grades"] as? [AnyObject] else {
				self.gradeDelegate?.gotGrades(self, error: .ParseError)
				return
			}
			for gradeJSON in gradesJSON {
				guard let gradeJSON = gradeJSON as? [String: AnyObject] else {
					self.gradeDelegate?.gotGrades(self, error: .ParseError)
					return
				}
				guard let percentScore = gradeJSON["percentScore"] as? String,
					score = gradeJSON["score"] as? String else {
						self.gradeDelegate?.gotGrades(self, error: .ParseError)
						return
				}
				guard let assignmentJSON = gradeJSON["assignment"] as? [String: AnyObject] else {
					self.gradeDelegate?.gotGrades(self, error: .ParseError)
					return
				}
				guard let title = assignmentJSON["title"] as? String,
					categoryName = assignmentJSON["categoryName"] as? String,
					maxPoints = assignmentJSON["maxPoints"] as? String else {
						self.gradeDelegate?.gotGrades(self, error: .ParseError)
						return
				}
				let grade = SchoolLoopGrade(title: title, categoryName: categoryName, percentScore: percentScore, score: score, maxPoints: maxPoints)
				course.grades.append(grade)
			}
			self.gradeDelegate?.gotGrades(self, error: nil)
//			Logger.log("getCourses ended")
		}.resume()
	}

	func getAssignments() -> Bool {
//		Logger.log("getAssignments called, background: \(UIApplication.sharedApplication().applicationState == .Background)")
		var updated = false
		let url = SchoolLoopConstants.assignmentURL(school.domainName, studentID: studentID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.synchronousDataTaskWithRequest(request) { (data, response, error) in
			guard let data = data,
				dataJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments
			) as? [AnyObject] else {
					self.assignmentDelegate?.gotAssignments(self, error: .ParseError)
					return
			}
			guard let assignmentsJSON = dataJSON else {
				self.assignmentDelegate?.gotAssignments(self, error: .ParseError)
				return
			}
			for assignmentJSON in assignmentsJSON {
				guard let assignmentJSON = assignmentJSON as? [String: AnyObject] else {
					self.assignmentDelegate?.gotAssignments(self, error: .ParseError)
					return
				}
				guard let title = assignmentJSON["title"] as? String,
					description = assignmentJSON["description"] as? String,
					courseName = assignmentJSON["courseName"] as? String,
					dueDate = assignmentJSON["dueDate"] as? String,
					iD = assignmentJSON["iD"] as? String else {
						self.assignmentDelegate?.gotAssignments(self, error: .ParseError)
						return
				}
				var links: [(title: String, URL: String)] = []
				if let linksJSON = assignmentJSON["links"] as? [AnyObject] {
					for linkJSON in linksJSON {
						guard let linkJSON = linkJSON as? [String: AnyObject] else {
							self.assignmentDelegate?.gotAssignments(self, error: .ParseError)
							return
						}
						guard let title = linkJSON["Title"] as? String,
							URL = linkJSON["URL"] as? String else {
								self.assignmentDelegate?.gotAssignments(self, error: .ParseError)
								return
						}
						links.append((title: title, URL: URL))
					}
				}
//				Logger.log("Assignment \(title)")
				if let assignment = self.assignmentForID(iD) {
//					Logger.log("Existing, updating")
					assignment.title = title
					assignment.courseName = courseName
					assignment.assignmentDescription = description
					assignment.setNewDueDate(dueDate)
				} else {
//					Logger.log("New assignment, adding")
					updated = true
					if UIApplication.sharedApplication().applicationState != .Active {
						let notification = UILocalNotification()
						notification.fireDate = NSDate(timeIntervalSinceNow: 1)
						notification.alertBody = "New assignment \(title) posted for \(courseName)"
						notification.applicationIconBadgeNumber = 1
						notification.soundName = UILocalNotificationDefaultSoundName
						UIApplication.sharedApplication().scheduleLocalNotification(notification)
					}
					let assignment = SchoolLoopAssignment(title: title, assignmentDescription: description, courseName: courseName, dueDate: dueDate, links: links, iD: iD)
					self.assignments.append(assignment)
				}
			}
			self.assignmentDelegate?.gotAssignments(self, error: nil)
		}
//		Logger.log("getAssignments ended")
		return updated
	}

	func getLoopMail() -> Bool {
//		Logger.log("getLoopMail called, background: \(UIApplication.sharedApplication().applicationState == .Background)")
		var updated = false
		let url = SchoolLoopConstants.loopMailURL(school.domainName, studentID: studentID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.synchronousDataTaskWithRequest(request) { (data, response, error) in
			guard let data = data,
				dataJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [AnyObject] else {
					self.loopMailDelegate?.gotLoopMail(self, error: .ParseError)
					return
			}
			guard let loopMailJSON = dataJSON else {
				self.loopMailDelegate?.gotLoopMail(self, error: .ParseError)
				return
			}
			for loopMailJSON in loopMailJSON {
				guard let loopMailJSON = loopMailJSON as? [String: AnyObject] else {
					self.loopMailDelegate?.gotLoopMail(self, error: .ParseError)
					return
				}
				guard let subject = loopMailJSON["subject"] as? String,
					date = loopMailJSON["date"] as? String,
					ID = loopMailJSON["ID"] as? String else {
						self.loopMailDelegate?.gotLoopMail(self, error: .ParseError)
						return
				}
				guard let senderJSON = loopMailJSON["sender"] as? [String: AnyObject] else {
					self.loopMailDelegate?.gotLoopMail(self, error: .ParseError)
					return
				}
				guard let sender = senderJSON["name"] as? String else {
					self.loopMailDelegate?.gotLoopMail(self, error: .ParseError)
					return
				}
//				Logger.log("LoopMail \(subject)")
				if let loopMail = self.loopMailForID(ID) {
//					Logger.log("Existing, updating")
					loopMail.subject = subject
					loopMail.sender = sender
					loopMail.setNewDate(date)
					loopMail.ID = ID
				} else {
//					Logger.log("New LoopMail, adding")
					updated = true
					if UIApplication.sharedApplication().applicationState != .Active {
						let notification = UILocalNotification()
						notification.fireDate = NSDate(timeIntervalSinceNow: 1)
						notification.alertBody = "From: \(sender)\n\(subject)\n"
						notification.applicationIconBadgeNumber = 1
						notification.soundName = UILocalNotificationDefaultSoundName
						UIApplication.sharedApplication().scheduleLocalNotification(notification)
					}
					let loopMail = SchoolLoopLoopMail(subject: subject, sender: sender, date: date, ID: ID)
					self.loopMail.append(loopMail)
				}
			}
			self.loopMailDelegate?.gotLoopMail(self, error: nil)
		}
//		Logger.log("getLoopMail ended")
		return updated
	}

	func getLoopMailMessage(ID: String) {
//		Logger.log("getLoopMailMessage called, background: \(UIApplication.sharedApplication().applicationState == .Background)")
		let url = SchoolLoopConstants.loopMailMessageURL(school.domainName, studentID: studentID, ID: ID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.dataTaskWithRequest(request) { (data, response, error) in
			guard let loopMail = self.loopMailForID(ID) else {
				self.loopMailMessageDelegate?.gotLoopMailMessage(self, error: .UnknownError)
				return
			}
			guard let data = data,
				dataJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
					self.loopMailMessageDelegate?.gotLoopMailMessage(self, error: .ParseError)
					return
			}
			guard let messageJSON = dataJSON else {
				self.loopMailMessageDelegate?.gotLoopMailMessage(self, error: .ParseError)
				return
			}
			guard let message = messageJSON["message"] as? String else {
				self.loopMailMessageDelegate?.gotLoopMailMessage(self, error: .ParseError)
				return
			}
			var links: [(title: String, URL: String)] = []
			if let linksJSON = messageJSON["links"] as? [AnyObject] {
				for linkJSON in linksJSON {
					guard let linkJSON = linkJSON as? [String: AnyObject] else {
						self.loopMailMessageDelegate?.gotLoopMailMessage(self, error: .ParseError)
						return
					}
					guard let title = linkJSON["Title"] as? String,
						URL = linkJSON["URL"] as? String else {
							self.loopMailMessageDelegate?.gotLoopMailMessage(self, error: .ParseError)
							return
					}
					links.append((title: title, URL: URL))
				}
			}
			loopMail.message = message
			loopMail.links = links
			self.loopMailMessageDelegate?.gotLoopMailMessage(self, error: nil)
//			Logger.log("getLoopMailMessage ended for loopMail: \(loopMail.subject)")
		}.resume()
	}

	func getNews() -> Bool {
//		Logger.log("getNews called, background: \(UIApplication.sharedApplication().applicationState == .Background)")
		var updated = false
		let url = SchoolLoopConstants.newsURL(school.domainName, studentID: studentID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.synchronousDataTaskWithRequest(request) { (data, response, error) in
			guard let data = data,
				dataJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [AnyObject] else {
					self.newsDelegate?.gotNews(self, error: .ParseError)
					return
			}
			guard let newsJSON = dataJSON else {
				self.newsDelegate?.gotNews(self, error: .ParseError)
				return
			}
			for newsJSON in newsJSON {
				guard let newsJSON = newsJSON as? [String: AnyObject] else {
					self.newsDelegate?.gotNews(self, error: .ParseError)
					return
				}
				guard let title = newsJSON["title"] as? String,
					authorName = newsJSON["authorName"] as? String,
					createdDate = newsJSON["createdDate"] as? String,
					description = newsJSON["description"] as? String,
					iD = newsJSON["iD"] as? String else {
						self.newsDelegate?.gotNews(self, error: .ParseError)
						return
				}
				var links: [(title: String, URL: String)] = []
				if let linksJSON = newsJSON["links"] as? [AnyObject] {
					for linkJSON in linksJSON {
						guard let linkJSON = linkJSON as? [String: AnyObject] else {
							self.newsDelegate?.gotNews(self, error: .ParseError)
							return
						}
						guard let title = linkJSON["Title"] as? String,
							URL = linkJSON["URL"] as? String else {
								self.newsDelegate?.gotNews(self, error: .ParseError)
								return
						}
						links.append((title: title, URL: URL))
					}
				}
//				Logger.log("News \(title)")
				if let news = self.newsForID(iD) {
//					Logger.log("Existing, updating")
					news.title = title
					news.authorName = authorName
					news.setNewCreatedDate(createdDate)
					news.newsDescription = description
					news.links = links
				} else {
//					Logger.log("New news, adding")
					updated = true
					if UIApplication.sharedApplication().applicationState != .Active {
						let notification = UILocalNotification()
						notification.fireDate = NSDate(timeIntervalSinceNow: 1)
						notification.alertBody = "\(title)\n\(authorName)"
						notification.applicationIconBadgeNumber = 1
						notification.soundName = UILocalNotificationDefaultSoundName
						UIApplication.sharedApplication().scheduleLocalNotification(notification)
					}
					let news = SchoolLoopNews(title: title, authorName: authorName, createdDate: createdDate, newsDescription: description, links: links, iD: iD)
					self.news.append(news)
				}
			}
			self.newsDelegate?.gotNews(self, error: nil)
		}
//		Logger.log("getNews ended")
		return updated
	}

	func getLocker(path: String) {
//		Logger.log("getLocker called, background: \(UIApplication.sharedApplication().applicationState == .Background)")
		let url = SchoolLoopConstants.lockerURL(path, domainName: school.domainName, username: username)
		let request = authenticatedRequest(url)
		request.HTTPMethod = "PROPFIND"
		let session = NSURLSession.sharedSession()
		session.synchronousDataTaskWithRequest(request) { (data, response, error) in
			guard let data = data else {
				self.lockerDelegate?.gotLocker(self, error: .ParseError)
				return
			}
			let parser = NSXMLParser(data: data)
			parser.delegate = self
			if !parser.parse() {
				self.lockerDelegate?.gotLocker(self, error: .ParseError)
				return
			} else {
				self.lockerDelegate?.gotLocker(self, error: nil)
			}
//			Logger.log("getLocker ended")
		}
	}

	func authenticatedRequest(url: NSURL) -> NSMutableURLRequest {
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "GET"

		let plainString = "\(username):\(password)"
		guard let base64Data = (plainString as NSString).dataUsingEncoding(NSUTF8StringEncoding) else {
			assertionFailure("Could not encode plainString")
			return request
		}
		let base64String = base64Data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
		request.addValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
		return request
	}

	func schoolForName(name: String) -> SchoolLoopSchool? {
		for school in schools {
			if school.name == name {
				return school
			}
		}
		return nil
	}

	func courseForPeriodID(periodID: String) -> SchoolLoopCourse? {
		for course in self.courses {
			if course.periodID == periodID {
				return course
			}
		}
		return nil
	}

	func assignmentForID(iD: String) -> SchoolLoopAssignment? {
		for assignment in assignments {
			if assignment.iD == iD {
				return assignment
			}
		}
		return nil
	}

	func loopMailForID(ID: String) -> SchoolLoopLoopMail? {
		for loopMail in self.loopMail {
			if loopMail.ID == ID {
				return loopMail
			}
		}
		return nil
	}

	func newsForID(iD: String) -> SchoolLoopNews? {
		for news in self.news {
			if news.iD == iD {
				return news
			}
		}
		return nil
	}

	func lockerItemParentForPath(path: String) -> SchoolLoopLockerItem? {
		let cleanPath = path.hasSuffix("/") ? path.substringToIndex((path.rangeOfString("/", options: .BackwardsSearch)?.startIndex)!) : path
		var currentLockerItem: SchoolLoopLockerItem? = locker
		var currentDirectoryContents: [SchoolLoopLockerItem] = locker?.lockerItems ?? []
		for (index, pathComponent) in cleanPath.componentsSeparatedByString("/").enumerate().dropFirst().dropLast() {
			for lockerItem in currentDirectoryContents {
				if lockerItem.path.componentsSeparatedByString("/").dropFirst()[index] == pathComponent {
					currentLockerItem = lockerItem
					currentDirectoryContents = lockerItem.lockerItems
					break
				}
				currentLockerItem = nil
			}
		}
		return currentLockerItem
	}

	func lockerItemForPath(path: String) -> SchoolLoopLockerItem? {
		guard let parent = lockerItemParentForPath(path) else {
			return nil
		}
		for lockerItem in parent.lockerItems {
			if lockerItem.path == path {
				return lockerItem
			}
		}
		return nil
	}

	func requestForLockerItemPath(path: String) -> NSURLRequest {
		return authenticatedRequest(SchoolLoopConstants.lockerURL(path, domainName: school.domainName, username: username))
	}
}

extension SchoolLoop: NSXMLParserDelegate {
	func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		currentTokens.append(elementName)
	}

	func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if currentTokens.last == "d:collection" {
			currentType = .Directory
		} else if currentTokens.last == "d:response" {
			let lockerItem = SchoolLoopLockerItem(name: currentName, path: currentPath, type: currentType)
			if let parent = lockerItemParentForPath(lockerItem.path) {
				if !parent.lockerItems.contains({ $0 == lockerItem }) {
					parent.lockerItems.append(lockerItem)
				}
			} else {
				locker = lockerItem
			}
			currentName = ""
			currentPath = ""
			currentType = .Unknown
		}
		currentTokens.popLast()
	}

	func parser(parser: NSXMLParser, foundCharacters string: String) {
		if currentTokens.last == "d:href" {
			currentPath = string.substringFromIndex(string.characters.indexOf("/")!.advancedBy(1))
			currentPath = currentPath.substringFromIndex(currentPath.characters.indexOf("/")!.advancedBy(1))
			currentPath = currentPath.substringFromIndex(currentPath.characters.indexOf("/")!)
		} else if currentTokens.last == "d:displayname" {
			currentName += string
		} else if currentTokens.last == "d:getcontenttype" {
			if currentType != .Directory {
				if string == "application/pdf" {
					currentType = .PDF
				} else {
					currentType = .Unknown
				}
			}
		}
	}
}

extension NSURLSession {
	func synchronousDataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
		var data: NSData?, response: NSURLResponse?, error: NSError?
		let semaphore = dispatch_semaphore_create(0)
		dataTaskWithRequest(request) {
			data = $0
			response = $1
			error = $2
			dispatch_semaphore_signal(semaphore)
		}.resume()
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		completionHandler(data, response, error)
	}
}
