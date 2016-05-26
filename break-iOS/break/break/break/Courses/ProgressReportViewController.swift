//
//  ProgressReportViewController.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class ProgressReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

	let cellIdentifier = "grade"

	var periodID: String!

	var schoolLoop: SchoolLoop!
	var categories: [SchoolLoopCategory] = []
	var grades: [SchoolLoopGrade] = []
	var filteredGrades: [SchoolLoopGrade] = []
	var trendScores: [SchoolLoopTrendScore] = []

	@IBOutlet weak var gradesTableView: UITableView! {
		didSet {
			gradesTableView.backgroundView = UIView()
			gradesTableView.backgroundView?.backgroundColor = UIColor.clearColor()
			gradesTableView.rowHeight = UITableViewAutomaticDimension
			gradesTableView.estimatedRowHeight = 80.0
			gradesTableView.sectionHeaderHeight = UITableViewAutomaticDimension
			gradesTableView.estimatedSectionHeaderHeight = 200.0
		}
	}
	let searchController = UISearchController(searchResultsController: nil)
	let categoryView = UIView(frame: UIScreen.mainScreen().bounds)
	var titleLabel = UILabel()
	var titleSubtitleLabel = UILabel()
	var categoryNameLabels: [UILabel] = []
	var categorySubtitleLabels: [UILabel] = []
	var showScore = true

	deinit {
		searchController.loadViewIfNeeded()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
		searchController.delegate = self
		searchController.dimsBackgroundDuringPresentation = false
		gradesTableView.tableHeaderView = searchController.searchBar
		categoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProgressReportViewController.showCourse(_:))))
		schoolLoop = SchoolLoop.sharedInstance
		if traitCollection.forceTouchCapability == .Available {
			registerForPreviewingWithDelegate(self, sourceView: view)
		}
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		schoolLoop.getGrades(periodID) { error in
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				if error == .NoError {
					guard let course = self.schoolLoop.courseForPeriodID(self.periodID) else {
						assertionFailure("Could not get grades for periodID")
						return
					}
					self.categories = course.categories
					let boldFont = UIFont(descriptor: self.titleLabel.font.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold), size: 20)
					let normalFont = UIFont.systemFontOfSize(20)
					self.titleLabel.text = "Total"
					self.titleLabel.font = boldFont
					self.titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProgressReportViewController.changeCategorySubtitle(_:))))
					self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
					self.categoryView.addSubview(self.titleLabel)
					self.titleSubtitleLabel.text = course.score
					self.titleSubtitleLabel.font = boldFont
					self.titleSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
					self.categoryView.addSubview(self.titleSubtitleLabel)
					var labels: [String: UIView] = [:]
					for (index, category) in course.categories.enumerate() {
						let nameLabel = UILabel()
						nameLabel.text = category.name
						nameLabel.font = normalFont
						labels["nameLabel\(index)"] = nameLabel
						self.categoryNameLabels.append(nameLabel)
						nameLabel.translatesAutoresizingMaskIntoConstraints = false
						self.categoryView.addSubview(nameLabel)
						let subtitleLabel = UILabel()
						subtitleLabel.setContentCompressionResistancePriority(999, forAxis: .Horizontal)
						var scoreText = category.score
						if let scoreValue = Double(scoreText) {
							scoreText = String(format: "%.2f%%", scoreValue * 100)
						}
						subtitleLabel.text = scoreText
						subtitleLabel.font = normalFont
						subtitleLabel.userInteractionEnabled = true
						subtitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProgressReportViewController.changeCategorySubtitle(_:))))
						labels["subtitleLabel\(index)"] = subtitleLabel
						self.categorySubtitleLabels.append(subtitleLabel)
						subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
						self.categoryView.addSubview(subtitleLabel)
					}
					var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-[titleLabel]-(>=0)-[titleSubtitleLabel]-|", options: [], metrics: nil, views: ["titleLabel": self.titleLabel, "titleSubtitleLabel": self.titleSubtitleLabel])
					for i in 0..<labels.count / 2 {
						constraints += NSLayoutConstraint.constraintsWithVisualFormat("|-[nameLabel\(i)]-(>=0)-[subtitleLabel\(i)]-|", options: [], metrics: nil, views: labels)
					}
					for i in 0..<self.categoryNameLabels.count {
						labels["titleLabel"] = self.titleLabel
						constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[\(i == 0 ? "titleLabel" : "nameLabel\(i - 1)")]-[nameLabel\(i)]", options: [], metrics: nil, views: labels)
					}
					for i in 0..<self.categorySubtitleLabels.count {
						labels["titleSubtitleLabel"] = self.titleSubtitleLabel
						constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[\(i == 0 ? "titleSubtitleLabel" : "subtitleLabel\(i - 1)")]-[subtitleLabel\(i)]", options: [], metrics: nil, views: labels)
					}
					constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]", options: [], metrics: nil, views: labels)
					constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[nameLabel\(self.categoryNameLabels.count - 1)]-|", options: [], metrics: nil, views: labels)
					constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleSubtitleLabel]", options: [], metrics: nil, views: labels)
					constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[subtitleLabel\(self.categoryNameLabels.count - 1)]-|", options: [], metrics: nil, views: labels)
					NSLayoutConstraint.activateConstraints(constraints)
					self.categoryView.setNeedsLayout()
					self.categoryView.layoutIfNeeded()
					self.categoryView.frame = CGRect(origin: self.categoryView.frame.origin, size: self.categoryView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize))
					let layer = CALayer()
					layer.frame = CGRect(x: 0, y: self.categoryView.frame.height - 1, width: self.gradesTableView.frame.width, height: 1)
					layer.backgroundColor = UIColor.blackColor().CGColor
					self.categoryView.layer.addSublayer(layer)
					self.grades = course.grades
					self.trendScores = course.trendScores
					self.gradesTableView.beginUpdates()
					self.gradesTableView.endUpdates()
					self.updateSearchResultsForSearchController(self.searchController)
				}
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}

	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return categoryView
		} else {
			return UIView(frame: CGRectZero)
		}
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return section == 0 ? categoryView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height : 0
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 0 : filteredGrades.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? GradeTableViewCell else {
			assertionFailure("Could not deque GradeTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		let grade = filteredGrades[indexPath.row]
		cell.titleLabel.text = grade.title
		cell.categoryNameLabel.text = grade.categoryName
		cell.percentScoreLabel.text = grade.percentScore
		cell.scoreLabel.text = "\(grade.score)/\(grade.maxPoints)"
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercaseString ?? ""
		if filter != "" {
			filteredGrades.removeAll()
			filteredGrades = grades.filter { grade in
				return grade.title.lowercaseString.containsString(filter) || grade.categoryName.lowercaseString.containsString(filter)
			}
		} else {
			filteredGrades = grades
		}
		dispatch_async(dispatch_get_main_queue()) {
			self.gradesTableView.reloadData()
		}
	}

	func changeCategorySubtitle(sender: AnyObject) {
		if !showScore {
			titleLabel.text = "Score"
		} else {
			titleLabel.text = "Weight"
		}
		for (index, label) in categorySubtitleLabels.enumerate() {
			var text = ""
			if !showScore {
				text = categories[index].score
			} else {
				text = categories[index].weight
			}
			if let value = Double(text) {
				text = NSString(format: "%.2f%%", value * 100) as String
			}
			label.text = text
		}
		showScore = !showScore
	}

	func showCourse(sender: AnyObject) {
		guard let courseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("course") as? CourseViewController else {
			assertionFailure("Could not create CourseViewController")
			return
		}
		courseViewController.periodID = periodID
		navigationController?.pushViewController(courseViewController, animated: true)
	}

	// MARK: - Navigation

	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = gradesTableView.indexPathForRowAtPoint(gradesTableView.convertPoint(location, toView: view)),
			cell = gradesTableView.cellForRowAtIndexPath(indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("gradeDetail") as? GradeViewController else {
			return nil
		}
		let selectedGrade = grades[indexPath.row]
		destinationViewController.title = selectedGrade.title
		destinationViewController.periodID = periodID
		destinationViewController.systemID = selectedGrade.systemID
		destinationViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
		previewingContext.sourceRect = cell.frame
		return destinationViewController
	}

	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		navigationController?.pushViewController(viewControllerToCommit, animated: true)
	}

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = segue.destinationViewController as? GradeViewController,
			cell = sender as? GradeTableViewCell,
			indexPath = gradesTableView.indexPathForCell(cell) else {
				assertionFailure("Could not cast destinationViewController to GradeViewController")
				return
		}
		let selectedGrade = grades[indexPath.row]
		destinationViewController.title = selectedGrade.title
		destinationViewController.periodID = periodID
		destinationViewController.systemID = selectedGrade.systemID
	}
}
