//
//  ProgressReportInterfaceController.swift
//  break
//
//  Created by Saagar Jha on 4/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

class ProgressReportInterfaceController: WKInterfaceController, WCSessionDelegate {

	let rowType = "grade"

	var periodID: String!
	var grades: [SchoolLoopGrade] = []

	@IBOutlet var gradesTable: WKInterfaceTable!
	override func awakeWithContext(context: AnyObject?) {
		super.awakeWithContext(context)

		// Configure interface objects here.
		let course = context as? SchoolLoopCourse
		self.periodID = course?.periodID
		setTitle(course?.courseName)
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		if WCSession.isSupported() {
			let session = WCSession.defaultSession()
			session.delegate = self
			session.activateSession()
			print("\(session.reachable)")
			session.sendMessage(["grades": periodID], replyHandler: { response in
				if let data = response["grades"] as? NSData,
					let grades = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [SchoolLoopGrade] {
						self.grades = grades
						self.gradesTable.setNumberOfRows(grades.count, withRowType: self.rowType)
						for (index, grade) in grades.enumerate() {
							if let controller = self.gradesTable.rowControllerAtIndex(index) as? GradeRowController {
								controller.titleLabel.setText(grade.title)
								controller.categoryName.setText(grade.categoryName)
								controller.scoreLabel.setText("\(grade.score)/\(grade.maxPoints)")
								controller.percentScoreLabel.setText(grade.percentScore)
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

}
