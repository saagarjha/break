//
//  SchoolLoop.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import UIKit

class SchoolLoop {

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

	func getSchools() {
		let url = SchoolLoopConstants.schoolURL()
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "GET"
		let session = NSURLSession.sharedSession()
		session.dataTaskWithRequest(request) { (data, response, error) in
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
		}.resume()
	}

	func logIn(schoolName: String, username: String, password: String) {
		school = schoolForName(schoolName)
		if school == nil {
			loginDelegate?.loggedIn(self, error: .AuthenticationError)
		}
		self.username = username
		self.password = password
		let url = SchoolLoopConstants.logInURL(school.domainName)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.dataTaskWithRequest(request) { (data, response, error) in
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
			self.loginDelegate?.loggedIn(self, error: nil)
		}.resume()
	}

	func logOut() {
		keychain.removePassword(username)
		SchoolLoop.sharedInstance = SchoolLoop()
		(UIApplication.sharedApplication().delegate as? AppDelegate)?.showLogout()
	}

	func getCourses() {
		let url = SchoolLoopConstants.courseURL(school.domainName, studentID: studentID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.dataTaskWithRequest(request) { (data, response, error) in
			self.courses.removeAll()
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
					periodID = courseJSON["periodID"] as? String else {
					self.courseDelegate?.gotGrades(self, error: .ParseError)
					return
				}
				let course = SchoolLoopCourse(courseName: courseName, period: period, teacherName: teacherName, grade: grade, score: score, periodID: periodID)
				self.courses.append(course)
			}
			self.courseDelegate?.gotGrades(self, error: nil)
		}.resume()
	}

	func getGrades(periodID: String) {
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
		}.resume()
	}

	func getAssignments() {
		let url = SchoolLoopConstants.assignmentURL(school.domainName, studentID: studentID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.dataTaskWithRequest(request) { (data, response, error) in
			self.assignments.removeAll()
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
				let assignment = SchoolLoopAssignment(title: title, description: description, courseName: courseName, dueDate: dueDate, links: links, iD: iD)
				self.assignments.append(assignment)
			}
			self.assignmentDelegate?.gotAssignments(self, error: nil)
		}.resume()
	}

	func getLoopMail() {
		let url = SchoolLoopConstants.loopMailURL(school.domainName, studentID: studentID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.dataTaskWithRequest(request) { (data, response, error) in
			self.loopMail.removeAll()
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
				let loopMail = SchoolLoopLoopMail(subject: subject, sender: sender, date: date, ID: ID)
				self.loopMail.append(loopMail)
			}
			self.loopMailDelegate?.gotLoopMail(self, error: nil)
		}.resume()
	}

	func getLoopMailMessage(ID: String) {
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
			loopMail.message = message
			self.loopMailMessageDelegate?.gotLoopMailMessage(self, error: nil)
		}.resume()
	}

	func getNews() {
		let url = SchoolLoopConstants.newsURL(school.domainName, studentID: studentID)
		let request = authenticatedRequest(url)
		let session = NSURLSession.sharedSession()
		session.dataTaskWithRequest(request) { (data, response, error) in
			self.news.removeAll()
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
				let news = SchoolLoopNews(title: title, authorName: authorName, createdDate: createdDate, description: description, links: links, iD: iD)
				self.news.append(news)
			}
			self.newsDelegate?.gotNews(self, error: nil)
		}.resume()
	}

	func authenticatedRequest(url: NSURL) -> NSURLRequest {
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
		for mail in loopMail {
			if mail.ID == ID {
				return mail
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
}
