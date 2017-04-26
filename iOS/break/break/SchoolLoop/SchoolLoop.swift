//
//  SchoolLoop.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import UIKit

/// The central class for managing SchoolLoop's API.
@objc(SchoolLoop)
public class SchoolLoop: NSObject, NSCoding {
	// MARK: - Static singletons

	/// A singleton for use throughout a project to manage a single account.
	public static var sharedInstance = SchoolLoop()

	/// A keychain for storing sensitive data.
	public let keychain = SchoolLoopKeychain.sharedInstance

	// MARK: - Instance variables

	/// The current school for this `SchoolLoop`'s account.
	public var school: SchoolLoopSchool!

	/// A list of all SchoolLoop schools.
	public var schools = [SchoolLoopSchool]()

	/// The current account managed by this `SchoolLoop`.
	public var account: SchoolLoopAccount!

	/// A list of courses for this `SchoolLoop`'s account.
	public var courses = [SchoolLoopCourse]()

	/// A list of computable courses for this `SchoolLoop`'s account.
	public var computableCourses = [SchoolLoopComputableCourse]()

	/// A list of assignments for this `SchoolLoop`'s account.
	public var assignments = [SchoolLoopAssignment]()

	/// A list of assignments for this `SchoolLoop`'s account, organized by due
	/// date. Each key in the `Dictionary` refers to a day, and its value is
	/// the assignments due on that day.
	public var assignmentsWithDueDates: [Date: [SchoolLoopAssignment]] {
		get {
			var awdd = [Date: [SchoolLoopAssignment]]()
			for assigment in assignments {
				var assignmentsForDate = awdd[assigment.dueDate] ?? []
				assignmentsForDate.append(assigment)
				awdd[assigment.dueDate] = assignmentsForDate
			}
			return awdd
		}
	}

	/// A list of LoopMail for this `SchoolLoop`'s account.
	public var loopMail = [SchoolLoopLoopMail]()

	/// A list of News for this `SchoolLoop`'s account.
	public var news = [SchoolLoopNews]()

	/// The top-level (i.e. "/") locker item for this `SchoolLoop`'s account.
	public var locker: SchoolLoopLockerItem!


	// MARK: - Private locker parsing instance variables

	/// A stack of the current tokens being parsed.
	fileprivate var currentTokens = [String]()

	/// The name for the current token being parsed.
	fileprivate var currentName = ""
	/// The path for the current token being parsed.
	fileprivate var currentPath = ""
	/// The locker item type for the current token being parsed.
	fileprivate var currentType = SchoolLoopLockerItemType.unknown

	// MARK: - Initializers

	/// Creates a new `SchoolLoop` with default values. Intended to reset
	/// everything (such as when logging out of an acccount).
	private override init() {
		super.init()
	}

	/// `NSCoding` initializer. You probably don't want to invoke this directly.
	public required init?(coder aDecoder: NSCoder) {
		let schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.school = aDecoder.decodeObject(forKey: "school") as? SchoolLoopSchool
		schoolLoop.schools = aDecoder.decodeObject(forKey: "schools") as? [SchoolLoopSchool] ?? []
		schoolLoop.account = aDecoder.decodeObject(forKey: "account") as? SchoolLoopAccount
		schoolLoop.courses = aDecoder.decodeObject(forKey: "courses") as? [SchoolLoopCourse] ?? []
		schoolLoop.assignments = aDecoder.decodeObject(forKey: "assignments") as? [SchoolLoopAssignment] ?? []
		schoolLoop.loopMail = aDecoder.decodeObject(forKey: "loopMail") as? [SchoolLoopLoopMail] ?? []
		schoolLoop.news = aDecoder.decodeObject(forKey: "news") as? [SchoolLoopNews] ?? []
		super.init()
	}

	/// `NSCoding` encoding. You probably don't want to invoke this directly.
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(school, forKey: "school")
		aCoder.encode(schools, forKey: "schools")
		aCoder.encode(account, forKey: "account")
		aCoder.encode(courses, forKey: "courses")
		aCoder.encode(assignments, forKey: "assignments")
		aCoder.encode(loopMail, forKey: "loopMail")
		aCoder.encode(news, forKey: "news")
	}

	// MARK: - SchoolLoop core API

	/// Fetch a list of schools asynchronously and update `schools`.
	///
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `schools` in `completion`.
	///
	/// - Parameters:
	///   - completion: Called upon completion of the fetch, and contains any
	///     errors that occurred during the fetch
	public func getSchools(with completion: ((_ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.schoolURL()
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			var newSchools = [SchoolLoopSchool]()
			guard error == nil else {
				completion?(.networkError)
				return
			}
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyObject] else {
					completion?(.parseError)
					return
			}
			guard let schoolsJSON = dataJSON else {
				completion?(.parseError)
				return
			}
			for schoolJSON in schoolsJSON {
				guard let schoolJSON = schoolJSON as? [String: AnyObject] else {
					completion?(.parseError)
					return
				}
				let name = schoolJSON["name"] as? String ?? ""
				let domainName = schoolJSON["domainName"] as? String ?? ""
				let districtName = schoolJSON["districtName"] as? String ?? ""
				let school = SchoolLoopSchool(name: name, domainName: domainName, districtName: districtName)
				newSchools.append(school)
			}
			self.schools = newSchools
			completion?(.noError)
		}.resume()
	}


	/// Log in asynchronously and update `school` as well as `account`.
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `account` or `school` in `completion`.
	///
	/// - Parameters:
	///   - schoolName: The school name to use when logging in. This must be a
	///     "full" school name in that it is the one that SchoolLoop uses.
	///   - username: The username to use to log in
	///   - password: The password to use to log in
	///   - completion: Called upon completion of the log in, and contains any
	///     errors that occurred during the log in
	public func logIn(withSchoolName schoolName: String, username: String, password: String, completion: ((_ error: SchoolLoopError) -> Void)?) {
		guard let school = school(forName: schoolName) else {
			completion?(.doesNotExistError)
			return
		}
		self.school = school
		self.account = SchoolLoopAccount(username: username, password: password, fullName: account?.fullName ?? "", studentID: account?.studentID ?? "", hashedPassword: account?.hashedPassword ?? "", email: "")
		let url = SchoolLoopConstants.loginURL(domainName: school.domainName)
		let request = authenticatedRequest(url: url)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				completion?(.networkError)
				return
			}
			let httpResponse = response as? HTTPURLResponse
			if httpResponse?.statusCode != 200 {
				#if os(iOS)
					Logger.log("Login failed with status code \(String(describing: httpResponse?.statusCode)))")
					Logger.log("Login username: \(username)")
					Logger.log("Login password size: \(password.characters.count)")
				#endif
				completion?(.unknownError)
				return
			}
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
					completion?(.parseError)
					return
			}
			guard let loginJSON = dataJSON else {
				completion?(.parseError)
				return
			}
			let fullName = loginJSON["fullName"] as? String ?? ""
			let studentID = loginJSON["userID"] as? String ?? ""
			let hashedPassword = loginJSON["hashedPassword"] as? String ?? ""
			let email = loginJSON["email"] as? String ?? ""
			self.account = SchoolLoopAccount(username: username, password: password, fullName: fullName, studentID: studentID, hashedPassword: hashedPassword, email: email)
			self.account.isLoggedIn = true
			completion?(.noError)
		}.resume()
	}

	/// Log out of the current account. This resets and removes any saved data for
	/// the current account.
	public func logOut() {
		_ = keychain.removePassword(forUsername: account.username)
		SchoolLoop.sharedInstance = SchoolLoop()
	}

	/// Fetch a list of courses for the current account asynchronously and
	/// update `courses`.
	///
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `courses` in `completion`.
	///
	/// - Parameters:
	///   - completion: Called upon completion of the fetch, and contains
	///     "updated" courses as well as any errors that occurred during the
	///     fetch
	public func getCourses(with completion: ((_ updatedCourses: [SchoolLoopCourse], _ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.courseURL(domainName: school.domainName, studentID: account.studentID)
		let request = authenticatedRequest(url: url)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			var newCourses = [SchoolLoopCourse]()
			var updatedCourses = [SchoolLoopCourse]()
			guard error == nil else {
				completion?(updatedCourses, .networkError)
				return
			}
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyObject] else {
					completion?(updatedCourses, .parseError)
					return
			}
			guard let coursesJSON = dataJSON else {
				completion?(updatedCourses, .parseError)
				return
			}
			for courseJSON in coursesJSON {
				guard let courseJSON = courseJSON as? [String: AnyObject] else {
					completion?(updatedCourses, .parseError)
					return
				}
				let courseName = courseJSON["courseName"] as? String ?? ""
				let period = courseJSON["period"] as? String ?? ""
				let teacherName = courseJSON["teacherName"] as? String ?? ""
				let grade = courseJSON["grade"] as? String ?? ""
				let score = courseJSON["score"] as? String ?? ""
				let periodID = courseJSON["periodID"] as? String ?? ""
				let lastUpdated = courseJSON["lastUpdated"] as? String ?? ""
				let course = SchoolLoopCourse(courseName: courseName, period: period, teacherName: teacherName, grade: grade, score: score, periodID: periodID)
				_ = course.set(newLastUpdated: lastUpdated)
				if let oldCourse = self.course(forPeriodID: periodID) {
					if oldCourse.set(newLastUpdated: lastUpdated) {
						updatedCourses.append(course)
					}
				} else {
					updatedCourses.append(course)
				}
				_ = course.set(newLastUpdated: lastUpdated)
				newCourses.append(course)
			}
			self.courses = newCourses
			completion?(updatedCourses, .noError)
		}.resume()
	}

	/// Fetch a list of grades for the course with the specified period ID
	/// asynchronously and update its `grades`.
	///
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `grades` in `completion`.
	///
	/// - Parameters:
	///   - periodID: The period ID of the course to fetch grades for.
	///   - completion: Called upon completion of the fetch, and contains
	///     any errors that occurred during the fetch.
	public func getGrades(withPeriodID periodID: String, completion: ((_ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.gradeURL(domainName: school.domainName, studentID: account.studentID, periodID: periodID)
		let request = authenticatedRequest(url: url)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				completion?(.networkError)
				return
			}
			guard let course = self.course(forPeriodID: periodID) else {
				completion?(.doesNotExistError)
				return
			}
			course.categories.removeAll()
			course.grades.removeAll()
			course.trendScores.removeAll()
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyObject] else {
					completion?(.parseError)
					return
			}
			guard let categoriesJSON = (dataJSON?.first as? [String: AnyObject])?["categories"] as? [AnyObject] else {
				completion?(.parseError)
				return
			}
			for categoryJSON in categoriesJSON {
				guard let categoryJSON = categoryJSON as? [String: AnyObject] else {
					completion?(.parseError)
					return
				}
				let name = categoryJSON["name"] as? String ?? ""
				let score = categoryJSON["score"] as? String ?? ""
				let weight = categoryJSON["weight"] as? String ?? ""
				let category = SchoolLoopCategory(name: name, score: score, weight: weight)
				course.categories.append(category)

			}
			guard let GradingScaleJSON = (dataJSON?.first as? [String: AnyObject])?["GradingScale"] as? [String: AnyObject], let CutoffsJSON = GradingScaleJSON["Cutoffs"] as? [AnyObject] else {
				completion?(.parseError)
				return
			}
			for CutoffJSON in CutoffsJSON {
				guard let CutoffJSON = CutoffJSON as? [String: AnyObject] else {
					completion?(.parseError)
					return
				}
				let Name = CutoffJSON["Name"] as? String ?? ""
				let Start = CutoffJSON["Start"] as? String ?? ""
				let cutoff = SchoolLoopCutoff(Name: Name, Start: Start)
				course.cutoffs.append(cutoff)

			}
			guard let gradesJSON = (dataJSON?.first as? [String: AnyObject])?["grades"] as? [AnyObject] else {
				completion?(.parseError)
				return
			}
			for gradeJSON in gradesJSON {
				guard let gradeJSON = gradeJSON as? [String: AnyObject] else {
					completion?(.parseError)
					return
				}
				let percentScore = gradeJSON["percentScore"] as? String ?? ""
				let score = gradeJSON["score"] as? String ?? ""
				let comment = gradeJSON["comment"] as? String ?? ""
				let changedDate = gradeJSON["changedDate"] as? String ?? ""
				guard let assignmentJSON = gradeJSON["assignment"] as? [String: AnyObject] else {
					completion?(.parseError)
					return
				}
				let title = assignmentJSON["title"] as? String ?? ""
				let categoryName = assignmentJSON["categoryName"] as? String ?? ""
				let maxPoints = assignmentJSON["maxPoints"] as? String ?? ""
				let systemID = assignmentJSON["systemID"] as? String ?? ""
				let dueDate = assignmentJSON["dueDate"] as? String ?? ""
				let grade = SchoolLoopGrade(title: title, categoryName: categoryName, percentScore: percentScore, score: score, maxPoints: maxPoints, comment: comment, systemID: systemID, dueDate: dueDate, changedDate: changedDate)
				course.grades.append(grade)
			}
			guard let trendScoresJSON = (dataJSON?.first as? [String: AnyObject])?["trendScores"] as? [AnyObject] else {
				completion?(.trendScoreError)
				return
			}
			for trendScoreJSON in trendScoresJSON {
				guard let trendScoreJSON = trendScoreJSON as? [String: AnyObject] else {
					completion?(.parseError)
					return
				}
				let score = trendScoreJSON["score"] as? String ?? ""
				let dayID = trendScoreJSON["dayID"] as? String ?? ""
				let trendScore = SchoolLoopTrendScore(score: score, dayID: dayID)
				course.trendScores.append(trendScore)
			}
			completion?(.noError)
		}.resume()
	}

	/// Fetch a list of assignments for the current account asynchronously and
	/// update `assignments`.
	///
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `assignments` in `completion`.
	///
	/// - Parameters:
	///   - completion: Called upon completion of the fetch, and contains
	///     "updated" assignments as well as any errors that occurred during the
	///     fetch
	public func getAssignments(with completion: ((_ updatedAssignments: [SchoolLoopAssignment], _ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.assignmentURL(domainName: school.domainName, studentID: account.studentID)
		let request = authenticatedRequest(url: url)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			var newAssignments = [SchoolLoopAssignment]()
			var updatedAssignments = [SchoolLoopAssignment]()
			guard error == nil else {
				completion?(updatedAssignments, .networkError)
				return
			}
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments
				) as? [AnyObject] else {
					completion?(updatedAssignments, .parseError)
					return
			}
			guard let assignmentsJSON = dataJSON else {
				completion?(updatedAssignments, .parseError)
				return
			}
			for assignmentJSON in assignmentsJSON {
				guard let assignmentJSON = assignmentJSON as? [String: AnyObject] else {
					completion?(updatedAssignments, .parseError)
					return
				}
				let title = assignmentJSON["title"] as? String ?? ""
				let description = assignmentJSON["description"] as? String ?? ""
				let courseName = assignmentJSON["courseName"] as? String ?? ""
				let dueDate = assignmentJSON["dueDate"] as? String ?? ""
				let iD = assignmentJSON["iD"] as? String ?? ""
				var links = [(title: String, URL: String)]()
				if let linksJSON = assignmentJSON["links"] as? [AnyObject] {
					for linkJSON in linksJSON {
						guard let linkJSON = linkJSON as? [String: AnyObject] else {
							completion?(updatedAssignments, .parseError)
							return
						}
						let title = linkJSON["Title"] as? String ?? ""
						let URL = linkJSON["URL"] as? String ?? ""
						links.append((title: title, URL: URL))
					}
				}
				let assignment = SchoolLoopAssignment(title: title, assignmentDescription: description, courseName: courseName, dueDate: dueDate, links: links, iD: iD)
				if let oldAssignment = self.assignment(foriD: iD) {
					assignment.isCompleted = oldAssignment.isCompleted
				} else {
					updatedAssignments.append(assignment)
				}
				newAssignments.append(assignment)
			}
			self.assignments = newAssignments
			completion?(updatedAssignments, .noError)
		}.resume()
	}

	/// Fetch a list of LoopMail for the current account asynchronously and
	/// update `loopMail`.
	///
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `loopMail` in `completion`.
	///
	/// - Parameters:
	///   - completion: Called upon completion of the fetch, and contains
	///     "updated" LoopMail as well as any errors that occurred during the
	///     fetch
	public func getLoopMail(with completion: ((_ updatedLoopMail: [SchoolLoopLoopMail], _ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.loopMailURL(domainName: school.domainName, studentID: account.studentID)
		let request = authenticatedRequest(url: url)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			var newLoopMail = [SchoolLoopLoopMail]()
			var updatedLoopMail = [SchoolLoopLoopMail]()
			guard error == nil else {
				completion?(updatedLoopMail, .networkError)
				return
			}
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyObject] else {
					completion?(updatedLoopMail, .parseError)
					return
			}
			guard let loopMailJSON = dataJSON else {
				completion?(updatedLoopMail, .parseError)
				return
			}
			for loopMailJSON in loopMailJSON {
				guard let loopMailJSON = loopMailJSON as? [String: AnyObject] else {
					completion?(updatedLoopMail, .parseError)
					return
				}
				let subject = loopMailJSON["subject"] as? String ?? ""
				let date = loopMailJSON["date"] as? String ?? ""
				let ID = loopMailJSON["ID"] as? String ?? ""
				guard let senderJSON = loopMailJSON["sender"] as? [String: AnyObject] else {
					completion?(updatedLoopMail, .parseError)
					return
				}
				let name = senderJSON["name"] as? String ?? ""
				let id = senderJSON["userID"] as? String ?? ""
				let sender = SchoolLoopContact(id: id, name: name, role: "", desc: "")
				let loopMail = SchoolLoopLoopMail(subject: subject, sender: sender, date: date, ID: ID)
				if self.loopMail(forID: ID) == nil {
					updatedLoopMail.append(loopMail)
				}
				newLoopMail.append(loopMail)
			}
			self.loopMail = newLoopMail
			completion?(updatedLoopMail, .noError)
		}.resume()
	}

	/// Fetch the message content for the LoopMail with the specified ID
	/// asynchronously and update its `message` and `links`.
	///
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `message` or `links` in `completion`.
	///
	/// - Parameters:
	///   - ID: The period ID of the course to fetch grades for
	///   - completion: Called upon completion of the fetch, and contains
	///     any errors that occurred during the fetch
	public func getLoopMailMessage(withID ID: String, completion: ((_ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.loopMailMessageURL(domainName: school.domainName, studentID: account.studentID, ID: ID)
		let request = authenticatedRequest(url: url)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				completion?(.networkError)
				return
			}
			guard let loopMail = self.loopMail(forID: ID) else {
				completion?(.doesNotExistError)
				return
			}
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
					completion?(.parseError)
					return
			}
			guard let messageJSON = dataJSON else {
				completion?(.parseError)
				return
			}
			let message = messageJSON["message"] as? String ?? ""
			var links = [(title: String, URL: String)]()
			if let linksJSON = messageJSON["links"] as? [AnyObject] {
				for linkJSON in linksJSON {
					guard let linkJSON = linkJSON as? [String: AnyObject] else {
						completion?(.parseError)
						return
					}
					let title = linkJSON["Title"] as? String ?? ""
					let URL = linkJSON["URL"] as? String ?? ""
					links.append((title: title, URL: URL))
				}
			}
			loopMail.message = message
			loopMail.links = links
			completion?(.noError)
		}.resume()
	}

	/// Fetch a list of contacts that match the specified query.
	///
	/// - Parameters:
	///   - query: The query to use when searching for contacts
	///   - completion: Called upon completion of the fetch, and contains
	///     the contacts matching this query as well as any errors that occurred
	///     during the fetch
	public func getLoopMailContacts(withQuery query: String, completion: ((_ contacts: [SchoolLoopContact], _ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.loopMailContactsURL(domainName: school.domainName, studentID: account.studentID, query: query)
		let request = authenticatedRequest(url: url)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			var contacts = [SchoolLoopContact]()
			guard error == nil else {
				completion?(contacts, .networkError)
				return
			}
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyObject] else {
					completion?(contacts, .parseError)
					return
			}
			guard let contactsJSON = dataJSON else {
				completion?(contacts, .parseError)
				return
			}
			for contactJSON in contactsJSON {
				guard let contactJSON = contactJSON as? [String: AnyObject] else {
					completion?(contacts, .parseError)
					return
				}
				let id = contactJSON["id"] as? String ?? ""
				let name = contactJSON["name"] as? String ?? ""
				let role = contactJSON["role"] as? String ?? ""
				let desc = contactJSON["desc"] as? String ?? ""
				let contact = SchoolLoopContact(id: id, name: name, role: role, desc: desc)
				contacts.append(contact)
			}
			completion?(contacts, .noError)
		}.resume()
	}

	/// Sends the specified composed LoopMail asynchronously.
	///
	/// - Parameters:
	///   - composedLoopMail: The composed LoopMail to send.
	///   - completion: Called upon completion of the send, and contains
	///     any errors that occurred during the send.
	public func sendLoopMail(with composedLoopMail: SchoolLoopComposedLoopMail, completion: ((_ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.loopMailSendURL(domainName: school.domainName)
		var request = hashedAuthenticatedRequest(url: url)
		modify(&request, forSendingUsing: composedLoopMail)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				completion?(.networkError)
				return
			}
			completion?(.noError)
		}.resume()
	}

	/// Fetch a list of news for the current account asynchronously and
	/// update `news`.
	///
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `news` in `completion`.
	///
	/// - Parameters:
	///   - completion: Called upon completion of the fetch, and contains
	///     "updated" news as well as any errors that occurred during the
	///     fetch
	public func getNews(with completion: ((_ updatedNews: [SchoolLoopNews], _ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.newsURL(domainName: school.domainName, studentID: account.studentID)
		let request = authenticatedRequest(url: url)
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			var newNews = [SchoolLoopNews]()
			var updatedNews = [SchoolLoopNews]()
			guard error == nil else {
				completion?(updatedNews, .networkError)
				return
			}
			guard let data = data,
				let dataJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyObject] else {
					completion?(updatedNews, .parseError)
					return
			}
			guard let newsJSON = dataJSON else {
				completion?(updatedNews, .parseError)
				return
			}
			for newsJSON in newsJSON {
				guard let newsJSON = newsJSON as? [String: AnyObject] else {
					completion?(updatedNews, .parseError)
					return
				}
				let title = newsJSON["title"] as? String ?? ""
				let authorName = newsJSON["authorName"] as? String ?? ""
				let createdDate = newsJSON["createdDate"] as? String ?? ""
				let description = newsJSON["description"] as? String ?? ""
				let iD = newsJSON["iD"] as? String ?? ""
				var links = [(title: String, URL: String)]()
				if let linksJSON = newsJSON["links"] as? [AnyObject] {
					for linkJSON in linksJSON {
						guard let linkJSON = linkJSON as? [String: AnyObject] else {
							completion?(updatedNews, .parseError)
							return
						}
						let title = linkJSON["Title"] as? String ?? ""
						let URL = linkJSON["URL"] as? String ?? ""
						links.append((title: title, URL: URL))
					}
				}
				let news = SchoolLoopNews(title: title, authorName: authorName, createdDate: createdDate, newsDescription: description, links: links, iD: iD)
				if self.news(foriD: iD) == nil {
					updatedNews.append(news)
				}
				newNews.append(news)
			}
			self.news = newNews
			completion?(updatedNews, .noError)
		}.resume()
	}

	/// Fetch a list of grades for the locker item with the specified path
	/// asynchronously and update its `lockerItems`.
	///
	/// - Important: This method is asynchronous, so put any logic that depends
	///   on an updated value of `lockerItems` in `completion`.
	///
	/// - Note: It appears that SchoolLoop does not specify the depth of the
	///   directory tree that it returns for a given path. Thus, while this
	///   method often is able to populate a significant portion of the tree,
	///   you cannot guarantee that it is complete (i.e. you must call this
	///   method for every locker item to be safe).
	///
	/// - Bug: This method fails for some users with a 401 Unauthorized; in this
	///   case it will call the `completion` with `.authenticationError`. This
	///   has already been reported to SchoolLoop, but the underlying reason is
	///   still unknown.
	///
	/// - Parameters:
	///   - path: The path of the locker item to fetch locker items for
	///   - completion: Called upon completion of the fetch, and contains
	///     any errors that occurred during the fetch
	public func getLocker(withPath path: String, completion: ((_ error: SchoolLoopError) -> Void)?) {
		let url = SchoolLoopConstants.lockerURL(path: path, domainName: school.domainName, username: account.username)
		let request = authenticatedRequest(url: url, httpMethod: "PROPFIND")
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			let httpResponse = response as? HTTPURLResponse
			guard httpResponse?.statusCode != 401 else {
				completion?(.authenticationError)
				return
			}
			guard let data = data else {
				completion?(.parseError)
				return
			}
			let parser = XMLParser(data: data)
			parser.delegate = self
			if !parser.parse() {
				completion?(.parseError)
				return
			} else {
				completion?(.noError)
			}
		}.resume()
	}

	// MARK: - Request factory methods

	/// Creates an authenticated request with the current user's credentials,
	/// suitable for most interaction with SchoolLoop's API.
	///
	/// - Parameters:
	///   - url: The URL to used for creation of the request
	///   - httpMethod: The HTTP method used for the creation of the request
	/// - Returns: An authenticated request with the current user's credentials
	private func authenticatedRequest(url: URL, httpMethod: String = "GET") -> URLRequest {
		let request = NSMutableURLRequest(url: url)
		request.httpMethod = httpMethod
		authenticate(request)
		return request as URLRequest
	}

	/// Creates an hashed, authenticated request with the current user's
	/// credentials, suitable for interaction with SchoolLoop's POST API.
	///
	/// - Parameters:
	///   - url: The URL to used for creation of the request
	///   - httpMethod: The HTTP method used for the creation of the request
	/// - Returns: An hashed, authenticated request with the current user's
	///   credentials
	private func hashedAuthenticatedRequest(url: URL, httpMethod: String = "POST") -> URLRequest {
		let request = NSMutableURLRequest(url: url)
		request.httpMethod = httpMethod
		authenticate(request)
		request.addValue("true", forHTTPHeaderField: "SL-HASH")
		request.addValue(SchoolLoopConstants.devToken, forHTTPHeaderField: "SL-UUID")
		return request as URLRequest
	}

	/// Adds authentication to a request based on the current user's
	/// credentials. In particular, it sets the request's Authorization HTTP
	/// header field.
	///
	/// - Parameters:
	///   - request: The request to add authentication to
	private func authenticate(_ request: NSMutableURLRequest) {
		let plainString = "\(account.username):\(account.password)"
		guard let base64Data = plainString.data(using: .utf8) else {
			assertionFailure("Could not encode plainString")
			return
		}
		let base64String = base64Data.base64EncodedString()
		request.addValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
	}

	/// Modifies a request for sending based on the specified composed LoopMail.
	/// In particular, it sets the request's Content-Type HTTP header field and
	/// its HTTP body.
	///
	/// - Parameters:
	///   - request: The request to modify for sending
	///   - composedLoopMail: The composed LoopMail to use to modify the request
	private func modify(_ request: inout URLRequest, forSendingUsing composedLoopMail: SchoolLoopComposedLoopMail) {
		request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: ["to": composedLoopMail.to.map({ $0.id }).joined(separator: " "), "cc": composedLoopMail.cc.map({ $0.id }).joined(separator: " "), "subject": composedLoopMail.subject, "message": composedLoopMail.message])
	}

	/// Creates a request with the specified locker item path, suitable for
	/// downloading the file.
	///
	/// - Parameters:
	///   - path: The path of the locker item to use for the creation of the
	///     request
	/// - Returns: A request for the specified locker item
	private func request(lockerItemPath path: String) -> URLRequest {
		return authenticatedRequest(url: SchoolLoopConstants.lockerURL(path: path, domainName: school.domainName, username: account.username))
	}

	// MARK: - Lookup methods

	/// Returns the school matching the specified name.
	///
	/// - Parameters:
	///   - name: The name of the school to search for
	/// - Returns: The school matching the specified name, if any
	public func school(forName name: String) -> SchoolLoopSchool? {
		return schools.first { $0.name == name }
	}

	/// Returns the course with the specified period ID.
	///
	/// - Parameters:
	///   - periodID: The period ID of the course to search for
	/// - Returns: The course matching the specified period ID, if any
	public func course(forPeriodID periodID: String) -> SchoolLoopCourse? {
		return courses.first { $0.periodID == periodID }
	}

	/// Returns the assignment with the specified iD.
	///
	/// - Parameters:
	///   - iD: The iD of the assignment to search for
	/// - Returns: The assignment matching the specified iD, if any
	public func assignment(foriD iD: String) -> SchoolLoopAssignment? {
		return assignments.first { $0.iD == iD }
	}

	/// Returns the LoopMail with the specified ID.
	///
	/// - Parameters:
	///   - ID: The ID of the LoopMail to search for
	/// - Returns: The LoopMail matching the specified ID, if any
	public func loopMail(forID ID: String) -> SchoolLoopLoopMail? {
		return loopMail.first { $0.ID == ID }
	}

	/// Returns the news with the specified iD.
	///
	/// - Parameters:
	///   - iD: The iD of the news to search for
	/// - Returns: The news matching the specified iD, if any
	public func news(foriD iD: String) -> SchoolLoopNews? {
		return news.first { $0.iD == iD }
	}

	/// Returns the locker item with the specified path.
	///
	/// - Parameters:
	///   - path: The path of the locker item to search for
	/// - Returns: The locker item with the specified path, if any
	public func lockerItem(forPath path: String) -> SchoolLoopLockerItem? {
		guard let parent = lockerItemParent(forPath: path) else {
			return nil
		}
		return parent.lockerItems.first { $0.path == path }
	}

	// MARK: - Locker file retrieval

	/// Downloads the specified locker item and returns the location of the
	/// downloaded file.
	///
	/// - Parameters:
	///   - lockerItem: The locker item to download
	/// - Returns: The location of the downloaded file
	public func file(for lockerItem: SchoolLoopLockerItem) -> URL {
		let session = URLSession.shared
		let file = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(lockerItem.name)
		session.synchronousDataTask(with: request(lockerItemPath: lockerItem.path)) { (data, response, error) in
			try? data?.write(to: file)
		}
		return file
	}

	// MARK: - Locker helper methods

	/// Returns the locker item that would be the parent of a locker item at the
	/// specified path.
	///
	/// - Parameters:
	///   - path: The path for the child locker item
	/// - Returns: The parent for the locker item at the specified path, if any
	fileprivate func lockerItemParent(forPath path: String) -> SchoolLoopLockerItem? {
		// The path without a trailing "/"
		let cleanPath = path.hasSuffix("/") ? path.substring(to: (path.range(of: "/", options: .backwards)?.lowerBound)!) : path
		var currentLockerItem: SchoolLoopLockerItem? = locker
		var currentDirectoryContents: [SchoolLoopLockerItem] = locker?.lockerItems ?? []
		for (index, pathComponent) in cleanPath.components(separatedBy: "/").enumerated().dropFirst().dropLast() {
			for lockerItem in currentDirectoryContents {
				if lockerItem.path.components(separatedBy: "/").dropFirst()[index] == pathComponent {
					currentLockerItem = lockerItem
					currentDirectoryContents = lockerItem.lockerItems
					break
				}
				currentLockerItem = nil
			}
		}
		return currentLockerItem
	}
}

// MARK: - Locker XML parsing

extension SchoolLoop: XMLParserDelegate {
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		currentTokens.append(elementName)
	}

	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if currentTokens.last == "d:collection" {
			currentType = .directory
		} else if currentTokens.last == "d:response" {
			if currentType == .unknown {
				currentType = SchoolLoopLockerItemType(filename: currentName)
			}
			let lockerItem = SchoolLoopLockerItem(name: currentName, path: currentPath, type: currentType)
			if let parent = lockerItemParent(forPath: lockerItem.path) {
				if !parent.lockerItems.contains(lockerItem) {
					parent.lockerItems.append(lockerItem)
				}
			} else {
				locker = lockerItem
			}
			currentName = ""
			currentPath = ""
			currentType = .unknown
		}
		_ = currentTokens.popLast()
	}

	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		if currentTokens.last == "d:href" {
			// Drop the leading "/users/[username]"
			currentPath = string.substring(from: string.index(after: string.characters.index(of: "/")!))
			currentPath = currentPath.substring(from: currentPath.index(after: currentPath.characters.index(of: "/")!))
			currentPath = currentPath.substring(from: currentPath.characters.index(of: "/")!)
		} else if currentTokens.last == "d:displayname" {
			currentName += string
		} else if currentTokens.last == "d:getcontenttype" {
			if currentType != .directory {
				switch string {
				case "application/pdf":
					currentType = .pdf
				case "text/plain":
					currentType = .txt
				case "application/msword":
					currentType = .doc
				case "application/mspowerpoint":
					currentType = .ppt
				case "application/vndms-excel":
					currentType = .xls
				default:
					currentType = SchoolLoopLockerItemType(filename: currentName)
				}
			}
		}
	}
}

// MARK: - URLSession extension

extension URLSession {
	/// Creates a task that synchronously retrieves the contents of a URL based
	/// on the specified URL request object, and calls a handler upon
	/// completion. The task bypasses calls to delegate methods for response and
	/// data delivery, and instead provides any resulting `Data`, `URLResponse`,
	/// and `Error` objects inside the completion handler.
	///
	/// - Parameters:
	///   - request: An `URLRequest` object that provides the URL, cache policy,
	///     request type, body data or body stream, and so on.
	///   - completionHandler: The completion handler to call when the load
	///     request is complete.
	///
	///     If you pass `nil`, only the session delegate methods are called when
	///     the task completes, making this method equivalent to the
	///     `dataTask(with:)` method.
	///
	///     This completion handler takes the following parameters:
	///   - data: The data returned by the server.
	///   - response: An object that provides response metadata, such as HTTP
	///     headers and status code. If you are making an HTTP or HTTPS request,
	///     the returned object is actually an `HTTPURLResponse` object.
	///   - error: An error object that indicates why the request failed, or
	///     `nil` if the request was successful.
	func synchronousDataTask(with request: URLRequest, completionHandler: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
		var data: Data?, response: URLResponse?, error: Error?
		let semaphore = DispatchSemaphore(value: 0)
		dataTask(with: request) {
			(data, response, error) = $0
			semaphore.signal()
		}.resume()
		_ = semaphore.wait(timeout: DispatchTime.distantFuture)
		completionHandler(data, response, error)
	}
}

infix operator ?!: NilCoalescingPrecedence
extension String {
	/// The "'null' coalescing" operator. This operator is similar to the nil
	/// coalescing operator except that it picks the right hand size if the left
	/// hand side is `"null"`.
	///
	/// - Parameters:
	///   - lhs: The string to test
	///   - rhs: The fallback value
	/// - Returns: The original value, or the fallback if the original value is
	///   `"null"`
	public static func ?!(lhs: String, rhs: String) -> String {
		return lhs == "null" ? rhs : lhs
	}
}
