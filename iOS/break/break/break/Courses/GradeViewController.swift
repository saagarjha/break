//
//  GradeViewController.swift
//  break
//
//  Created by Saagar Jha on 5/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class GradeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	let cellIdentifier = "gradeDetail"

	var periodID: String!
	var systemID: String!

	var schoolLoop: SchoolLoop!
	var grade: SchoolLoopGrade!

	@IBOutlet weak var gradeTableView: UITableView! {
		didSet {
			gradeTableView.sectionFooterHeight = UITableViewAutomaticDimension
			gradeTableView.estimatedSectionFooterHeight = 80
		}
	}
	var commentsView = UIView(frame: UIScreen.main.bounds)
	var commentsLabel = UILabel()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		grade = schoolLoop.course(forPeriodID: periodID)?.grade(forSystemID: systemID)
		commentsLabel.translatesAutoresizingMaskIntoConstraints = false
		commentsLabel.text = grade.comment
		commentsLabel.numberOfLines = 0
		commentsView.addSubview(commentsLabel)
		let constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[commentsLabel]-|", options: [], metrics: nil, views: ["commentsLabel": commentsLabel]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[commentsLabel]|", options: [], metrics: nil, views: ["commentsLabel": commentsLabel])
		NSLayoutConstraint.activate(constraints)
		commentsView.setNeedsLayout()
		commentsView.layoutIfNeeded()
		gradeTableView.beginUpdates()
		gradeTableView.endUpdates()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return commentsView
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return commentsView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return grade.comment.isEmpty ? 2 : 3
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/dd"
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Due Date"
			cell.detailTextLabel?.text = dateFormatter.string(from: grade.dueDate)
		case 1:
			cell.textLabel?.text = "Changed Date"
			cell.detailTextLabel?.text = dateFormatter.string(from: grade.changedDate)
		case 2:
			cell.textLabel?.text = "Comments:"
			cell.detailTextLabel?.text = ""
		default:
			break
		}
		return cell
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */

}
