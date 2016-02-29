//
//  CoursesViewController.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class CoursesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SchoolLoopCourseDelegate {

	let cellIdentifier = "course"

	var schoolLoop: SchoolLoop!
	var courses: [SchoolLoopCourse] = []

	var destinationViewController: ProgressReportViewController!

	@IBOutlet weak var coursesTableView: UITableView! {
		didSet {
			coursesTableView.rowHeight = UITableViewAutomaticDimension
			coursesTableView.estimatedRowHeight = 80.0
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.courseDelegate = self
		schoolLoop.getCourses()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func gotGrades(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
		dispatch_async(dispatch_get_main_queue()) {
			if error == nil {
				self.courses = schoolLoop.courses
				self.coursesTableView.reloadData()
			}
		}
	}

	@IBAction func openSettings(sender: AnyObject) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("settings")
		navigationController?.presentViewController(viewController, animated: true, completion: nil)
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return courses.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? CourseTableViewCell else {
			assertionFailure("Could not deque CourseTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		cell.periodLabel.text = courses[indexPath.row].period
		cell.courseNameLabel.text = courses[indexPath.row].courseName
		cell.teacherNameLabel.text = courses[indexPath.row].teacherName
		cell.gradeLabel.text = courses[indexPath.row].grade
		cell.scoreLabel.text = courses[indexPath.row].score
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let selectedCourse = courses[indexPath.row]
		destinationViewController.title = selectedCourse.courseName
		destinationViewController.periodID = selectedCourse.periodID
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = segue.destinationViewController as? ProgressReportViewController else {
			assertionFailure("Could not cast destinationViewController to ProgressReportViewController")
			return
		}
		self.destinationViewController = destinationViewController
	}
}
