//
//  CoursesInterfaceController.swift
//  break
//
//  Created by Saagar Jha on 4/24/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

class CoursesInterfaceController: WKInterfaceController, WCSessionDelegate {

	let rowType = "course"

	var courses: [SchoolLoopCourse] = []

	@IBOutlet var coursesTable: WKInterfaceTable!

	override func awakeWithContext(context: AnyObject?) {
		super.awakeWithContext(context)

		// Configure interface objects here.
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		if WCSession.isSupported() {
			let session = WCSession.defaultSession()
			session.delegate = self
			session.activateSession()
			print("\(session.reachable)")
			session.sendMessage(["courses": ""], replyHandler: { response in
				if let data = response["courses"] as? NSData,
					let courses = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [SchoolLoopCourse] {
						self.courses = courses
						self.coursesTable.setNumberOfRows(courses.count, withRowType: self.rowType)
						for (index, course) in courses.enumerate() {
							if let controller = self.coursesTable.rowControllerAtIndex(index) as? CourseRowController {
								controller.courseNameLabel.setText(course.courseName)
								controller.teacherNameLabel.setText(course.teacherName)
								controller.gradeLabel.setText(course.grade)
								controller.scoreLabel.setText(course.score)
							}
						}
				}
				}, errorHandler: { error in
				print(error)
			})

		}
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}

	override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
		return courses[rowIndex]
	}
}
