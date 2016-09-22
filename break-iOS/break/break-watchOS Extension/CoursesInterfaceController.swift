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

	override func awake(withContext context: Any?) {
		super.awake(withContext: context)

		// Configure interface objects here.
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		(WKExtension.shared().delegate as? ExtensionDelegate)?.sendMessage(["courses": ""], replyHandler: { response in
			if let data = response["courses"] as? Data,
				let courses = NSKeyedUnarchiver.unarchiveObject(with: data) as? [SchoolLoopCourse] {
					self.courses = courses
					self.coursesTable.setNumberOfRows(courses.count, withRowType: self.rowType)
					for (index, course) in courses.enumerated() {
						if let controller = self.coursesTable.rowController(at: index) as? CourseRowController {
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

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}

	override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
		return courses[rowIndex]
	}
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		
	}
}
