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
	var grades = [SchoolLoopGrade]()

	@IBOutlet var gradesTable: WKInterfaceTable!
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)

		// Configure interface objects here.
		guard let course = context as? SchoolLoopCourse else {
			return
		}
		self.periodID = course.periodID
		setTitle(course.courseName)
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		(WKExtension.shared().delegate as? ExtensionDelegate)?.sendMessage(["grades": periodID], replyHandler: { response in
				if let data = response["grades"] as? Data,
					let grades = NSKeyedUnarchiver.unarchiveObject(with: data) as? [SchoolLoopGrade] {
					self.grades = grades
					self.gradesTable.setNumberOfRows(grades.count, withRowType: self.rowType)
					for (index, grade) in grades.enumerated() {
						if let controller = self.gradesTable.rowController(at: index) as? GradeRowController {
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

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}

	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

	}
}
