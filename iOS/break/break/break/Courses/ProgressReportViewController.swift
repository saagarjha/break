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
	static let normalFont = UIFont.preferredFont(forTextStyle: .title3)
	static let boldFont = UIFont(descriptor: normalFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: normalFont.pointSize)

	var periodID: String!

	var schoolLoop: SchoolLoop!
	var course: SchoolLoopCourse!
	var computableCourse: SchoolLoopComputableCourse!
	var categories: [SchoolLoopCategory] = []
	var grades: [SchoolLoopGrade] = []
	var filteredGrades: [SchoolLoopGrade] = []
	var trendScores: [SchoolLoopTrendScore] = []

	@IBOutlet weak var addGradeButtonItem: UIBarButtonItem! {
		didSet {
			addGradeButtonItem.isEnabled = false
		}
	}
	@IBOutlet weak var gradesTableView: UITableView! {
		didSet {
			gradesTableView.backgroundView = UIView()
			gradesTableView.backgroundView?.backgroundColor = .clear
			gradesTableView.rowHeight = UITableViewAutomaticDimension
			gradesTableView.estimatedRowHeight = 80.0
			gradesTableView.sectionHeaderHeight = UITableViewAutomaticDimension
			gradesTableView.estimatedSectionHeaderHeight = 200.0
		}
	}
	let searchController = UISearchController(searchResultsController: nil)
	var headerView = UIView()
	var titleLabel: UILabel!
	var titleSubtitleLabel: UILabel!
	var categoryNameLabels: [UILabel] = []
	var categorySubtitleLabels: [UILabel] = []
	var viewingState = ViewingState.weight

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
		schoolLoop = SchoolLoop.sharedInstance
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: gradesTableView)
		}
		NotificationCenter.default.addObserver(self, selector: #selector(ProgressReportViewController.deviceOrientationDidChange(notification:)), name: .UIDeviceOrientationDidChange, object: nil)
		schoolLoop.getGrades(withPeriodID: periodID) { error in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError || error == .trendScoreError {
					guard let course = self.schoolLoop.course(forPeriodID: self.periodID) else {
						assertionFailure("Could not get grades for periodID")
						return
					}
					self.course = course
					self.computableCourse = course.computableCourse
					self.changeViewingState(self)
					self.trendScores = self.course.trendScores
				}
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func addGrade(_ sender: Any) {
		let grade = SchoolLoopComputableGrade(title: "Assignment", categoryName: "Category", percentScore: "%", score: "0", maxPoints: "0", comment: "", systemID: "", dueDate: "", changedDate: "")
		grade.computableCourse = computableCourse
		computableCourse.computableGrades.insert(grade, at: 0)
		grades = computableCourse.computableGrades
		updateSearchResults(for: searchController)
		gradesTableView.reloadData()
		gradesTableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: true)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return section == 0 ? headerView : nil
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return section == 0 ? headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height : 0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 0 : filteredGrades.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GradeTableViewCell else {
			assertionFailure("Could not deque GradeTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		}
		let grade = filteredGrades[indexPath.row]
		cell.progressReportViewController = self
		cell.indexPath = indexPath
		cell.categories = ["¯\\_(ツ)_/¯"] + categories.map { $0.name }
		if viewingState == .original {
			cell.titleLabel.text = grade.title
			cell.titleLabel.isUserInteractionEnabled = false

			cell.scoreLabel.text = grade.score
			cell.scoreLabel.isUserInteractionEnabled = false

			cell.maxPointsLabel.text = grade.maxPoints
			cell.maxPointsLabel.isUserInteractionEnabled = false

			cell.categoryNameLabel.text = grade.categoryName
			cell.categoryNameLabel.isUserInteractionEnabled = false

			cell.percentScoreLabel.text = grade.percentScore
			cell.percentScoreLabel.isUserInteractionEnabled = false
		} else {
			guard let computableGrade = grade as? SchoolLoopComputableGrade else {
				assertionFailure("Could not convert SchoolLoopGrade to SchoolLoopComputableGrade")
				return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
			}

			if computableGrade.isUserCreated {
				cell.accessoryType = .none
				cell.selectionStyle = .none
			} else {
				cell.accessoryType = .disclosureIndicator
				cell.selectionStyle = .default
			}

			cell.titleLabel.text = computableGrade.title
			cell.titleLabel.isUserInteractionEnabled = true

			if let score = computableGrade.computedScore {
				cell.scoreLabel.text = "\(score)"
			} else {
				cell.scoreLabel.text = computableGrade.score
			}
			cell.scoreLabel.isUserInteractionEnabled = true

			if let maxPoints = computableGrade.computedMaxPoints {
				cell.maxPointsLabel.text = "\(maxPoints)"
			} else {
				cell.maxPointsLabel.text = computableGrade.maxPoints
			}
			cell.maxPointsLabel.isUserInteractionEnabled = true

			cell.categoryNameLabel.text = computableGrade.computedCategoryName?.name ?? computableGrade.categoryName
			cell.categoryNameLabel.isUserInteractionEnabled = true

			if let percentScore = computableGrade.computedPercentScore {
				cell.percentScoreLabel.text = String(format: "%.2f%%", percentScore * 100)
			} else {
				cell.percentScoreLabel.text = computableGrade.percentScore
			}
			cell.percentScoreLabel.isUserInteractionEnabled = true
		}
		return cell
	}

	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if viewingState == .original {
			return indexPath
		} else {
			return (grades[indexPath.row] as? SchoolLoopComputableGrade)?.isUserCreated ?? false ? nil : indexPath
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return viewingState != .original
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		computableCourse.computableGrades.remove(at: indexPath.row)
		grades = computableCourse.computableGrades
		updateSearchResults(for: searchController)
		tableView.deleteRows(at: [indexPath], with: .fade)
		redrawHeaderView(reloadTableView: false)
	}

	func updateSearchResults(for searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercased() ?? ""
		if filter != "" {
			filteredGrades.removeAll()
			filteredGrades = grades.filter { grade in
				return grade.title.lowercased().contains(filter) || grade.categoryName.lowercased().contains(filter)
			}
		} else {
			filteredGrades = grades
		}
		DispatchQueue.main.async {
			self.gradesTableView.reloadData()
		}
	}

	func changeViewingState(_ sender: AnyObject) {
		switch viewingState {
		case .calculated:
			viewingState = .original
			categories = computableCourse.computableCategories
			grades = course.grades
			addGradeButtonItem.isEnabled = false
			updateSearchResults(for: searchController)
		case .original:
			viewingState = .weight
			categories = computableCourse.computableCategories
			grades = computableCourse.computableGrades
			addGradeButtonItem.isEnabled = true
			updateSearchResults(for: searchController)
		case .weight:
			viewingState = .calculated
			categories = computableCourse.computableCategories
			grades = computableCourse.computableGrades
			addGradeButtonItem.isEnabled = true
			updateSearchResults(for: searchController)
		}
		redrawHeaderView(reloadTableView: true)
	}

	func redrawHeaderView(reloadTableView reload: Bool) {
		headerView = UIView(frame: UIScreen.main.bounds)
		headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProgressReportViewController.showCourse(_:))))
		updateTitleLabels()
		headerView.addSubview(self.titleLabel)
		headerView.addSubview(self.titleSubtitleLabel)
		let labels = updateCategoryLabels()
		for label in labels.values {
			headerView.addSubview(label)
		}
		headerView.setNeedsLayout()
		headerView.layoutIfNeeded()
		headerView.frame = CGRect(origin: headerView.frame.origin, size: headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize))
		layoutHeaderView(labels: labels)
		if reload {
			gradesTableView.reloadData()
		}
		UIView.setAnimationsEnabled(false)
		gradesTableView.beginUpdates()
		gradesTableView.endUpdates()
		UIView.setAnimationsEnabled(true)
		let layer = CALayer()
		layer.frame = CGRect(x: 0, y: headerView.frame.height - 1, width: gradesTableView.frame.width, height: 1 / UIScreen.main.scale)
		layer.backgroundColor = self.gradesTableView.separatorColor?.cgColor
		headerView.layer.addSublayer(layer)
	}

	func updateTitleLabels() {
		switch viewingState {
		case .calculated:
			titleLabel = createTitleLabel(withText: "Calculated")
			titleSubtitleLabel = createTitleLabel(withText: String(format: "%.2f%%", computableCourse.average * 100))
		case .original:
			titleLabel = createTitleLabel(withText: "Original")
			titleSubtitleLabel = createTitleLabel(withText: course.score)
		case .weight:
			titleLabel = createTitleLabel(withText: "Weight")
			titleSubtitleLabel = createTitleLabel(withText: " ")
		}
		titleSubtitleLabel.setContentCompressionResistancePriority(999, for: .horizontal)
	}

	func createTitleLabel(withText text: String) -> UILabel {
		let titleLabel = UILabel()
		titleLabel.text = text
		titleLabel.font = ProgressReportViewController.boldFont
		titleLabel.isUserInteractionEnabled = true
		titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProgressReportViewController.changeViewingState(_:))))
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		return titleLabel
	}

	func updateCategoryLabels() -> [String: UIView] {
		var labels: [String: UIView] = [:]
		categoryNameLabels = []
		categorySubtitleLabels = []
		for (index, category) in categories.enumerated() {
			let nameLabel = createNormalLabel(withText: category.name)
			labels["nameLabel\(index)"] = nameLabel
			self.categoryNameLabels.append(nameLabel)
			var text = ""
			switch viewingState {
			case .calculated:
				if let score = (category as? SchoolLoopComputableCategory)?.computedScore {
					text = String(format: "%.2f%%", score * 100)
				}
			case .weight:
				if let weight = (category as? SchoolLoopComputableCategory)?.computedWeight {
					text = String(format: "%.2f%%", weight * 100)
				}
			case .original:
				if let score = Double(category.score) {
					text = String(format: "%.2f%%", score * 100)
				} else {
					text = category.score
				}
			}
			let subtitleLabel = createNormalLabel(withText: text, selector: #selector(ProgressReportViewController.changeViewingState(_:)))
			subtitleLabel.setContentCompressionResistancePriority(999, for: .horizontal)
			labels["subtitleLabel\(index)"] = subtitleLabel
			self.categorySubtitleLabels.append(subtitleLabel)
		}
		return labels
	}

	func createNormalLabel(withText text: String, selector: Selector? = nil) -> UILabel {
		let label = UILabel()
		label.font = ProgressReportViewController.normalFont
		label.text = !text.isEmpty ? text : " "
		if let selector = selector {
			label.isUserInteractionEnabled = true
			label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
		}
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}

	func layoutHeaderView(labels: [String: UIView]) {
		var labels = labels
		var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-\(gradesTableView.layoutMargins.left)-[titleLabel]-(>=8)-[titleSubtitleLabel]-\(gradesTableView.layoutMargins.right)-|", options: [], metrics: nil, views: ["titleLabel": self.titleLabel, "titleSubtitleLabel": titleSubtitleLabel])
		for i in 0..<labels.count / 2 {
			constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-\(gradesTableView.layoutMargins.left)-[nameLabel\(i)]-(>=8)-[subtitleLabel\(i)]-\(gradesTableView.layoutMargins.right)-|", options: [], metrics: nil, views: labels)
		}
		labels["titleLabel"] = titleLabel
		labels["titleSubtitleLabel"] = titleSubtitleLabel
		for i in 0..<self.categoryNameLabels.count {
			constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[\(i == 0 ? "titleLabel" : "nameLabel\(i - 1)")]-[nameLabel\(i)]", options: [], metrics: nil, views: labels)
		}
		for i in 0..<self.categorySubtitleLabels.count {
			constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[\(i == 0 ? "titleSubtitleLabel" : "subtitleLabel\(i - 1)")]-[subtitleLabel\(i)]", options: [], metrics: nil, views: labels)
		}
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]", options: [], metrics: nil, views: labels)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[nameLabel\(categoryNameLabels.count - 1)]-|", options: [], metrics: nil, views: labels)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleSubtitleLabel]", options: [], metrics: nil, views: labels)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[subtitleLabel\(categoryNameLabels.count - 1)]-|", options: [], metrics: nil, views: labels)
		NSLayoutConstraint.activate(constraints)
	}

	func deviceOrientationDidChange(notification: NSNotification) {
		redrawHeaderView(reloadTableView: false)
	}

	func changedTitle(to title: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.title = title
		gradesTableView.reloadData()
	}

	func changedScore(to score: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.score = score
		redrawHeaderView(reloadTableView: true)
	}

	func changedMaxPoints(to maxPoints: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.maxPoints = maxPoints
		redrawHeaderView(reloadTableView: true)
	}

	func changedCategoryName(to categoryName: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.categoryName = categoryName
		redrawHeaderView(reloadTableView: true)
	}

	func changedPercentScore(to percentScore: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.percentScore = percentScore
		redrawHeaderView(reloadTableView: true)
	}

	// MARK: - Navigation

	func showCourse(_ sender: AnyObject) {
		guard let courseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "course") as? CourseViewController else {
			assertionFailure("Could not create CourseViewController")
			return
		}
		courseViewController.periodID = periodID
		navigationController?.pushViewController(courseViewController, animated: true)
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = gradesTableView.indexPathForRow(at: location),
			let cell = gradesTableView.cellForRow(at: indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "gradeDetail") as? GradeViewController else {
			return nil
		}
		let selectedGrade = grades[indexPath.row]
		if viewingState != .original {
			guard let selectedGrade = selectedGrade as? SchoolLoopComputableGrade, !selectedGrade.isUserCreated else {
				return nil
			}
		}
		destinationViewController.title = selectedGrade.title
		destinationViewController.periodID = periodID
		destinationViewController.systemID = selectedGrade.systemID
		destinationViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
		previewingContext.sourceRect = cell.frame
		return destinationViewController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		navigationController?.pushViewController(viewControllerToCommit, animated: true)
	}

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = segue.destination as? GradeViewController,
			let cell = sender as? GradeTableViewCell,
			let indexPath = gradesTableView.indexPath(for: cell) else {
				assertionFailure("Could not cast destinationViewController to GradeViewController")
				return
		}
		let selectedGrade = grades[indexPath.row]
		destinationViewController.title = selectedGrade.title
		destinationViewController.periodID = periodID
		destinationViewController.systemID = selectedGrade.systemID
	}

	enum ViewingState {
		case calculated
		case original
		case weight
	}
}
