//
//  DemoableSchoolLoop.swift
//  break
//
//  Created by Saagar Jha on 5/17/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import Foundation

@objc(DemoableSchoolLoop)
class DemoableSchoolLoop: SchoolLoop {
	static let schoolName = "Hogwarts School of Witchcraft and Wizardry"
	static let username = "hpotter"
	static let password = "thechosen1"

	var isInDemo = false

	override var school: SchoolLoopSchool! {
		get {
			guard isInDemo else {
				return super.school
			}
			return SchoolLoopSchool(name: DemoableSchoolLoop.schoolName, domainName: "hogwarts.schoolloop.com", districtName: "Educational Office")
		}
		set {
			super.school = newValue
		}
	}

	override var schools: [SchoolLoopSchool] {
		get {
			// This is used for autocomplete, so merge the demo schools with
			// the actual results
			return super.schools + [
				SchoolLoopSchool(name: DemoableSchoolLoop.schoolName, domainName: "hogwarts.schoolloop.com", districtName: "Educational Office"),
				SchoolLoopSchool(name: "Beauxbatons Academy of Magic", domainName: "", districtName: ""),
				SchoolLoopSchool(name: "Durmstrang Institute", domainName: "", districtName: ""),
			]
		}
		set {
			super.schools = newValue
		}
	}

	override var account: SchoolLoopAccount! {
		get {
			guard isInDemo else {
				return super.account
			}
			return SchoolLoopAccount(username: DemoableSchoolLoop.username, password: DemoableSchoolLoop.password, fullName: "Potter, Harry J.", studentID: "", hashedPassword: "", email: "hpotter@hogwarts.ac.uk")
		}
		set {
			super.account = newValue
		}
	}

	override var courses: [SchoolLoopCourse] {
		get {
			guard isInDemo else {
				return super.courses
			}
			return [
				SchoolLoopCourse(courseName: "Charms", period: "1", teacherName: "Flitwick, Filius", grade: "E", score: "85.31%", periodID: "1"),
				{
					let course = SchoolLoopCourse(courseName: "Defense Against the Dark Arts", period: "2", teacherName: "Snape, Severus", grade: "E", score: "83.75%", periodID: "2")
					_ = course.set(newLastUpdated: "6/21/1997 9:00 AM")
					course.cutoffs = [
						SchoolLoopCutoff(Name: "O", Start: "90"),
						SchoolLoopCutoff(Name: "E", Start: "80"),
						SchoolLoopCutoff(Name: "A", Start: "70"),
						SchoolLoopCutoff(Name: "P", Start: "60"),
						SchoolLoopCutoff(Name: "D", Start: "50"),
						SchoolLoopCutoff(Name: "T", Start: "0"),
					]
					course.categories = [
						SchoolLoopCategory(name: "Practicals", score: "0.95", weight: "0.35"),
						SchoolLoopCategory(name: "Essays", score: "0.575", weight: "0.15"),
					]
					course.grades = [
						SchoolLoopGrade(title: "Essay 7", categoryName: "Essays", percentScore: "50%", score: "5", maxPoints: "10", comment: "", systemID: "12", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 6", categoryName: "Essays", percentScore: "70%", score: "7", maxPoints: "10", comment: "", systemID: "11", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Practical 4", categoryName: "Practicals", percentScore: "100%", score: "10", maxPoints: "10", comment: "", systemID: "10", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 5", categoryName: "Essays", percentScore: "40%", score: "4", maxPoints: "10", comment: "Disagreed with me on the best way to tackle dementors", systemID: "9", dueDate: "858589200000", changedDate: "858621600000"),
						SchoolLoopGrade(title: "Essay 4", categoryName: "Essays", percentScore: "60%", score: "6", maxPoints: "10", comment: "", systemID: "8", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Practical 3", categoryName: "Practicals", percentScore: "90%", score: "9", maxPoints: "10", comment: "", systemID: "7", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 4", categoryName: "Essays", percentScore: "80%", score: "8", maxPoints: "10", comment: "", systemID: "6", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 3", categoryName: "Essays", percentScore: "40%", score: "4", maxPoints: "10", comment: "", systemID: "5", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 2", categoryName: "Essays", percentScore: "70%", score: "7", maxPoints: "10", comment: "", systemID: "4", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Practical 2", categoryName: "Practicals", percentScore: "100%", score: "10", maxPoints: "10", comment: "", systemID: "3", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 1", categoryName: "Essays", percentScore: "50%", score: "5", maxPoints: "10", comment: "", systemID: "2", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Practical 1", categoryName: "Practicals", percentScore: "100%", score: "9", maxPoints: "10", comment: "", systemID: "1", dueDate: "", changedDate: ""),
					]
					course.trendScores = [
						SchoolLoopTrendScore(score: "0.9", dayID: "841654800000"),
						SchoolLoopTrendScore(score: "0.78", dayID: "843791236364"),
						SchoolLoopTrendScore(score: "0.815", dayID: "845927672727"),
						SchoolLoopTrendScore(score: "0.845", dayID: "848064109091"),
						SchoolLoopTrendScore(score: "0.825", dayID: "850200545455"),
						SchoolLoopTrendScore(score: "0.845", dayID: "852336981818"),
						SchoolLoopTrendScore(score: "0.8333", dayID: "854473418182"),
						SchoolLoopTrendScore(score: "0.8333", dayID: "856609854545"),
						SchoolLoopTrendScore(score: "0.8233", dayID: "858746290909"),
						SchoolLoopTrendScore(score: "0.835", dayID: "860882727273"),
						SchoolLoopTrendScore(score: "0.8407", dayID: "863019163636"),
						SchoolLoopTrendScore(score: "0.8375", dayID: "865155600000"),
					]
					return course
				}(),
				SchoolLoopCourse(courseName: "Herbology", period: "3", teacherName: "Sprout, Pomona", grade: "E", score: "84.69%", periodID: "3"),
				{
					let course = SchoolLoopCourse(courseName: "Potions", period: "5", teacherName: "Slughorn, Horace", grade: "O", score: "96.67%", periodID: "4")
					course.categories = [
						SchoolLoopCategory(name: "Potions", score: "1.0333", weight: ".5"),
						SchoolLoopCategory(name: "Essays", score: "0.8", weight: ".3"),
						SchoolLoopCategory(name: "Attendance", score: "1", weight: ".1"),
						SchoolLoopCategory(name: "Participation", score: "1.1", weight: ".1"),
					]
					course.grades = [
						SchoolLoopGrade(title: "Potion 3", categoryName: "Potions", percentScore: "60%", score: "6", maxPoints: "10", comment: "", systemID: "8", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 3", categoryName: "Essays", percentScore: "70%", score: "7", maxPoints: "10", comment: "", systemID: "7", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Potion 2", categoryName: "Potions", percentScore: "100%", score: "10", maxPoints: "10", comment: "", systemID: "6", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "First Semester Participation", categoryName: "Participation", percentScore: "110%", score: "11", maxPoints: "10", comment: "", systemID: "5", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "First Semester Attendance", categoryName: "Attendance", percentScore: "100%", score: "10", maxPoints: "10", comment: "", systemID: "4", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 2", categoryName: "Essays", percentScore: "80%", score: "8", maxPoints: "10", comment: "", systemID: "3", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Essay 1", categoryName: "Essays", percentScore: "90%", score: "9", maxPoints: "10", comment: "", systemID: "2", dueDate: "", changedDate: ""),
						SchoolLoopGrade(title: "Potion 1", categoryName: "Potions", percentScore: "150%", score: "15", maxPoints: "10", comment: "", systemID: "1", dueDate: "", changedDate: ""),
					]
					return course
				}(),
				SchoolLoopCourse(courseName: "Transfiguration", period: "6", teacherName: "McGonagall, Minerva", grade: "E", score: "83.73%", periodID: "5"),
			]
		}
		set {
			super.courses = newValue
		}
	}

	override var assignments: [SchoolLoopAssignment] {
		get {
			guard isInDemo else {
				return super.assignments
			}
			return [
				SchoolLoopAssignment(title: "Principles of Rematerialization Essay", assignmentDescription: "", courseName: "Transfiguration", dueDate: "842270400000", links: [], iD: "1"),
				SchoolLoopAssignment(title: "Essay", assignmentDescription: "", courseName: "Herbology", dueDate: "858081600000", links: [], iD: "2"),
				SchoolLoopAssignment(title: "Dementor Essay", assignmentDescription: "I hope for your sakes they are better than the tripe I had to endure on resisting the Imperius Curse.", courseName: "Defense Against the Dark Arts", dueDate: "858600000000", links: [], iD: "3"),
				SchoolLoopAssignment(title: "Practice Turning Vinegar into Wine", assignmentDescription: "", courseName: "Charms", dueDate: "861796800000", links: [], iD: "4"),
			]
		}
		set {
			super.assignments = newValue
		}
	}

	override var loopMail: [SchoolLoopLoopMail] {
		get {
			guard isInDemo else {
				return super.loopMail
			}
			return [
				SchoolLoopLoopMail(subject: "Please Come Immediately", sender: SchoolLoopContact(id: "", name: "Dumbledore, Albus", role: "", desc: ""), date: "867520800000", ID: "10"),
				{
					let loopMail = SchoolLoopLoopMail(subject: "Aragog's Dead", sender: SchoolLoopContact(id: "", name: "Hagrid, Reubeus", role: "", desc: ""), date: "861624000000", ID: "9")
					loopMail.message = "Dear Harry, Ron and Hermione,<br><br>Aragog died last night. Harry and Ron, you met him and you know how special he was. Hermione, I know you’d have liked him. It would mean a lot to me if you’d nip down for the burial later this evening. I’m planning on doing it round dusk, that was his favorite time of day. I know you’re not supposed to be out that late, but you can use the cloak. Wouldn’t ask, but I can’t face it alone.<br><br>Hagrid"
					return loopMail
				}(),
				SchoolLoopLoopMail(subject: "Re: Lessons", sender: SchoolLoopContact(id: "", name: "Dumbledore, Albus", role: "", desc: ""), date: "857984400000", ID: "8"),
				SchoolLoopLoopMail(subject: "Replacement Keeper", sender: SchoolLoopContact(id: "", name: "McLaggen, Cormac", role: "", desc: ""), date: "857253600000", ID: "7"),
				SchoolLoopLoopMail(subject: "Re: Lessons", sender: SchoolLoopContact(id: "", name: "Dumbledore, Albus", role: "", desc: ""), date: "852483600000", ID: "6"),
				SchoolLoopLoopMail(subject: "Re: Lessons", sender: SchoolLoopContact(id: "", name: "Dumbledore, Albus", role: "", desc: ""), date: "845110800000", ID: "5"),
				SchoolLoopLoopMail(subject: "Re: Slug Club Dinner", sender: SchoolLoopContact(id: "", name: "Severus, Snape", role: "", desc: ""), date: "842731200000", ID: "4"),
				{
					let loopMail = SchoolLoopLoopMail(subject: "Slug Club Dinner", sender: SchoolLoopContact(id: "", name: "Slughorn, Horace", role: "", desc: ""), date: "842727600000", ID: "3")
					loopMail.message = "Harry,<br><br>What do you say to a spot of supper tonight in my rooms instead? We’re having a little party, just a few rising stars, I’ve got McLaggen coming and Zabini, the charming Melinda Bobbin — I don’t know whether you know her? Her family owns a large chain of apothecaries — and, of course, I hope very much that Miss Granger will favor me by coming too.<br><br>-Horace"
					return loopMail
				}(),
				SchoolLoopLoopMail(subject: "Lessons", sender: SchoolLoopContact(id: "", name: "Dumbledore, Albus", role: "", desc: ""), date: "841694400000", ID: "2"),
				SchoolLoopLoopMail(subject: "Quidditch Tryouts Names", sender: SchoolLoopContact(id: "", name: "McGonagall, Minerva", role: "", desc: ""), date: "841658400000", ID: "1"),
			]
		}
		set {
			super.loopMail = newValue
		}
	}

	override var news: [SchoolLoopNews] {
		get {
			guard isInDemo else {
				return super.news
			}
			return [
				SchoolLoopNews(title: "Gryffindor House wins House Cup", authorName: "Dumbledore, Albus", createdDate: "863294400000", newsDescription: "", links: [], iD: "9"),
				SchoolLoopNews(title: "Last Quidditch Match!", authorName: "Hooch, Rolanda", createdDate: "862646400000", newsDescription: "", links: [], iD: "8"),
				SchoolLoopNews(title: "Apparition Testing", authorName: "Twycross, Wilkie", createdDate: "861004800000", newsDescription: "", links: [], iD: "7"),
				SchoolLoopNews(title: "Hufflepuff-Gryffindor Quidditch Match", authorName: "Hooch, Rolanda", createdDate: "857203200000", newsDescription: "", links: [], iD: "6"),
				SchoolLoopNews(title: "Hogmeade Trip Cancelled", authorName: "McGonagall, Minerva", createdDate: "857116800000", newsDescription: "", links: [], iD: "5"),
				SchoolLoopNews(title: "Apparition Lessons", authorName: "Twycross, Wilkie", createdDate: "852537600000", newsDescription: "If you are seventeen years of age, or will turn seventeen on or before the 31st August next, you are eligible for a twelve-week course of Apparition Lessons from a Ministry of Magic Apparition instructor. Please sign below if you would like to participate. Cost: 12 Galleons.", links: [(title: "Signup form", URL: "")], iD: "4"),
				SchoolLoopNews(title: "First Quidditch Match of the Year!", authorName: "Hooch, Rolanda", createdDate: "846316800000", newsDescription: "", links: [], iD: "3"),
				SchoolLoopNews(title: "Gryffindor Quidditch Team Tryouts", authorName: "Potter, Harry J.", createdDate: "842169600000", newsDescription: "Hello, fellow Gryffindor students!<br><br>The Gryffindor Quidditch Team will be holding tryouts next Saturday. We're looking for qualified Chasers, Beaters, and a Keeper, so come out to the Quidditch pitch if you're interested!<br><br>- Harry", links: [], iD: "2"),
				SchoolLoopNews(title: "Blanket ban on any items from Weasleys' Wizard Wheezes", authorName: "Filch, Argus", createdDate: "841608000000", newsDescription: "", links: [], iD: "1")
			]
		}
		set {
			super.news = newValue
		}
	}

	override var locker: SchoolLoopLockerItem! {
		get {
			guard isInDemo else {
				return super.locker
			}
			return {
				let lockerItem = SchoolLoopLockerItem(name: "", path: "/", type: .directory)
				lockerItem.lockerItems = [
					{
						let lockerItem = SchoolLoopLockerItem(name: "", path: "/My%20Courses/", type: .directory)
						lockerItem.lockerItems = [
							SchoolLoopLockerItem(name: "Charms", path: "/My%20Courses/Charms", type: .directory),
							SchoolLoopLockerItem(name: "Defense Against the Dark Arts", path: "/My%20Courses/Defense Against the Dark Arts", type: .directory),
							SchoolLoopLockerItem(name: "Herbology", path: "/My%20Courses/Herbology", type: .directory),
							SchoolLoopLockerItem(name: "Potions", path: "/My%20Courses/Potions", type: .directory),
							{
								let lockerItem = SchoolLoopLockerItem(name: "Transfiguration", path: "/My%20Courses/Transfiguration", type: .directory)
								lockerItem.lockerItems = [
									SchoolLoopLockerItem(name: "Avis Technique.pdf", path: "/My%20Courses/Transfiguration/Avis%20Technique.pdf", type: .pdf),
									SchoolLoopLockerItem(name: "Greensheet.pages", path: "/My%20Courses/Transfiguration/Greensheet.pages", type: .pages),
									SchoolLoopLockerItem(name: "Human Transfiguration", path: "/My%20Courses/Transfiguration/Human%20Transfiguration", type: .directory),
									SchoolLoopLockerItem(name: "List of Nonverbal Spells.docx", path: "/My%20Courses/Transfiguration/List%20of%20Nonverbal%20Spells.docx", type: .doc),
									SchoolLoopLockerItem(name: "NEWT Statistics.numbers", path: "/My%20Courses/Transfiguration/Newt%20Statistics.numbers", type: .numbers),
								]
								return lockerItem
							}(),
						]
						return lockerItem
					}(),
					SchoolLoopLockerItem(name: "My Locker", path: "/My%20Locker/", type: .directory)
				]
				return lockerItem
			}()
		}
		set {
			super.locker = newValue
		}
	}

	override func getSchools(with completion: ((SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getSchools(with: completion)
			return
		}
		completion?(.noError)
	}

	override func logIn(withSchoolName schoolName: String, username: String, password: String, completion: ((SchoolLoopError) -> Void)?) {
		guard schoolName != DemoableSchoolLoop.schoolName ||
			username != DemoableSchoolLoop.username ||
			password != DemoableSchoolLoop.password else {
				isInDemo = true
				completion?(.noError)
				return
		}
		super.logIn(withSchoolName: schoolName, username: username, password: password, completion: completion)
	}

	override func logOut() {
		super.logOut()
		SchoolLoop.sharedInstance = DemoableSchoolLoop()
	}

	override func getCourses(with completion: (([SchoolLoopCourse], SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getCourses(with: completion)
			return
		}
		completion?([], .noError)
	}

	override func getGrades(withPeriodID periodID: String, completion: ((SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getGrades(withPeriodID: periodID, completion: completion)
			return
		}
		completion?(.noError)
	}

	override func getAssignments(with completion: (([SchoolLoopAssignment], SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getAssignments(with: completion)
			return
		}
		completion?([], .noError)
	}

	override func getLoopMail(with completion: (([SchoolLoopLoopMail], SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getLoopMail(with: completion)
			return
		}
		completion?([], .noError)
	}

	override func getLoopMailMessage(withID ID: String, completion: ((SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getLoopMailMessage(withID: ID, completion: completion)
			return
		}
		completion?(.noError)
	}

	override func getLoopMailContacts(withQuery query: String, completion: (([SchoolLoopContact], SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getLoopMailContacts(withQuery: query, completion: completion)
			return
		}
		completion?([], .noError)
	}

	override func sendLoopMail(with composedLoopMail: SchoolLoopComposedLoopMail, completion: ((SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.sendLoopMail(with: composedLoopMail, completion: completion)
			return
		}
		completion?(.noError)
	}

	override func getNews(with completion: (([SchoolLoopNews], SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getNews(with: completion)
			return
		}
		completion?([], .noError)
	}

	override func getLocker(withPath path: String, completion: ((SchoolLoopError) -> Void)?) {
		guard isInDemo else {
			super.getLocker(withPath: path, completion: completion)
			return
		}
		completion?(.noError)
	}
}
