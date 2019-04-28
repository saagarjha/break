//
//  ProgressReportViewController.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class ProgressReportViewController: UITableViewController, UISearchResultsUpdating, UIViewControllerPreviewingDelegate, UIPopoverPresentationControllerDelegate {

	static let cellIdentifier = "grade"

	static let normalFont = UIFont.preferredFont(forTextStyle: .title3)
	static let boldFont = UIFont(descriptor: normalFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: normalFont.pointSize)
	static let triangleImageWidth: CGFloat = 8
	static let triangleImageHeight: CGFloat = 8
	static let triangeImageSpacing: CGFloat = 4
	static let triangleImage: UIImage? = {
		let width = ProgressReportViewController.triangleImageWidth
		let height = ProgressReportViewController.triangleImageHeight
		let spacing = ProgressReportViewController.triangeImageSpacing

		let trianglePath = UIBezierPath()
		trianglePath.move(to: CGPoint(x: spacing, y: height / 4))
		trianglePath.addLine(to: CGPoint(x: width + spacing, y: height / 4))
		trianglePath.addLine(to: CGPoint(x: width / 2 + spacing, y: 3 * height / 4))
		trianglePath.close()
		UIGraphicsBeginImageContextWithOptions(CGSize(width: width + spacing, height: height), false, UIScreen.main.scale)
		defer {
			UIGraphicsEndImageContext()
		}
		trianglePath.fill()
		return UIGraphicsGetImageFromCurrentImageContext()
	}()

	var periodID: String!

	var schoolLoop: SchoolLoop!
	var course: SchoolLoopCourse!
	var computableCourse: SchoolLoopComputableCourse!
	var categories = [SchoolLoopCategory]()
	var grades = [SchoolLoopGrade]()
	var filteredGrades = [SchoolLoopGrade]()
	var trendScores = [SchoolLoopTrendScore]()
	var categoryColors = [String: UIColor]()

	var viewMode = ViewMode.calculated {
		didSet {
			let title = viewMode.description
			switch viewMode {
			case .calculated:
				categories = computableCourse.computableCategories
				grades = computableCourse.computableGrades
				addGradeButtonItem.isEnabled = true

				header.title = (title: title, subtitle: String(format: "%.2f%%", computableCourse.computedScore * 100), comparisonResult: computableCourse.comparisonResult)
				header.headers = categories.compactMap {
					$0 as? SchoolLoopComputableCategory
				}.map { category in
					guard let score = category.computedScore else {
						return (title: category.name, subtitle: "", comparisonResult: category.comparisonResult)
					}
					return (title: category.name, subtitle: String(format: "%.2f%%", score * 100), comparisonResult: category.comparisonResult)
				}
			case .original:
				categories = course.categories
				grades = course.grades
				addGradeButtonItem.isEnabled = false

				header.title = (title: title, subtitle: course.score, comparisonResult: ComparisonResult.orderedSame)
				header.headers = categories.map { category in
					guard let score = Double(category.score) else {
						return (category.name, subtitle: category.score, comparisonResult: ComparisonResult.orderedSame)
					}
					return (title: category.name, subtitle: String(format: "%.2f%%", score * 100), comparisonResult: ComparisonResult.orderedSame)
				}
			case .weights:
				categories = computableCourse.computableCategories
				grades = computableCourse.computableGrades
				addGradeButtonItem.isEnabled = true

				header.title = (title: title, subtitle: "", comparisonResult: computableCourse.comparisonResult)
				header.headers = categories.compactMap {
					$0 as? SchoolLoopComputableCategory
				}.map { category in
					guard let weight = category.computedWeight else {
						return (title: category.name, subtitle: "", comparisonResult: category.comparisonResult)
					}
					return (title: category.name, subtitle: String(format: "%.2f%%", weight * 100), comparisonResult: category.comparisonResult)
				}
			case .totals:
				categories = computableCourse.computableCategories
				grades = computableCourse.computableGrades
				addGradeButtonItem.isEnabled = true

				header.title = (title: title, subtitle: "", comparisonResult: computableCourse.comparisonResult)
				header.headers = categories.compactMap {
					$0 as? SchoolLoopComputableCategory
				}.map { category in
					let (score, maxPoints) = category.computedTotals
					return (title: category.name, subtitle: String(format: "%.1f/%.1f", score, maxPoints), comparisonResult: category.comparisonResult)
				}
			case .differences:
				categories = computableCourse.computableCategories
				grades = computableCourse.computableGrades
				addGradeButtonItem.isEnabled = true

				var scoreDifferenceString = String(format: "%+.2f%%", computableCourse.computedScoreDifference * 100)
				// Convert "negative 0" to "positive 0"
				if scoreDifferenceString == "-0.00%" {
					scoreDifferenceString = "+0.00%"
				}
				header.title = (title: title, subtitle: scoreDifferenceString, comparisonResult: computableCourse.comparisonResult)
				header.headers = categories.compactMap {
					$0 as? SchoolLoopComputableCategory
				}.map { category in
					guard let scoreDifference = category.computedScoreDifference else {
						return (title: category.name, subtitle: "", comparisonResult: category.comparisonResult)
					}
					var scoreDifferenceString = String(format: "%+.2f%%", scoreDifference * 100)
					if scoreDifferenceString == "-0.00%" {
						scoreDifferenceString = "+0.00%"
					}
					return (title: category.name, subtitle: scoreDifferenceString, comparisonResult: category.comparisonResult)
				}
			}
			categoryColors = Dictionary(header.headers.map {
				$0.title
			}.enumerated().map { index, category in
					(category, UIColor(index: index, offset: .categoryOffset))
				}) { first, second in
				first
			}
			UIView.setAnimationsEnabled(false)
			tableView.beginUpdates()
			tableView.endUpdates()
			UIView.setAnimationsEnabled(true)
			updateSearchResults(for: searchController)
		}
	}

	@IBOutlet weak var titleButton: UIButton! {
		didSet {
			titleButton.isEnabled = false
			titleButton.setImage(ProgressReportViewController.triangleImage, for: .normal)
			// Make the image show up on the right
			titleButton.semanticContentAttribute = .forceRightToLeft
			// Don't mess with the title view in iOS 11, since its animation is
			// somewhat different and breaks this method
			if #available(iOS 11.0, *) {
			} else {
				// Center the title label
				titleButton.contentEdgeInsets.left = ProgressReportViewController.triangleImageWidth + ProgressReportViewController.triangeImageSpacing
			}
		}
	}
	@IBOutlet weak var addGradeButtonItem: UIBarButtonItem! {
		didSet {
			addGradeButtonItem.isEnabled = false
		}
	}
	let searchController = UISearchController(searchResultsController: nil)
	var header: ProgressReportHeader!

	var viewModesViewController: ViewModesViewController!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		addSearchBar(from: searchController, to: tableView)
		setupSelfAsDetailViewController()

		header = ProgressReportHeader()
		header.headerTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCourse)))

		schoolLoop = SchoolLoop.sharedInstance
		guard let periodID = periodID else {
			return
		}
		schoolLoop.getGrades(withPeriodID: periodID) { error in
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else {
					return
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError || error == .trendScoreError {
					(UIApplication.shared.delegate as? AppDelegate)?.saveCache()
					guard let course = `self`.schoolLoop.course(forPeriodID: `self`.periodID) else {
						assertionFailure("Could not get grades for periodID")
						return
					}
					`self`.course = course
					`self`.computableCourse = course.computableCourse
					`self`.trendScores = course.trendScores
					`self`.viewMode = .calculated
					`self`.titleButton.isEnabled = true
				}
			}
		}

		// Workaround for rdar://problem/35436877
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
			guard let `self` = self else {
				return
			}
			`self`.tableView.estimatedRowHeight = 80
			`self`.updateSearchResults(for: self.searchController)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if course != nil {
			// Call didSet
			viewMode = { viewMode }()
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		// This only works on iOS 10 or below
		if #available(iOS 11.0, *) {
		} else {
			// Collapse the left content inset if there's not enough space for it
			titleButton.contentEdgeInsets.left = max(titleButton.contentEdgeInsets.left - (titleButton.frame.midX - view.frame.midX), 0)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func changeView(_ sender: Any) {
		viewModesViewController = ViewModesViewController()
		viewModesViewController.viewMode = viewMode
		viewModesViewController.viewModeDelegate = self

		viewModesViewController.modalPresentationStyle = .popover
		viewModesViewController.popoverPresentationController?.delegate = self
		present(viewModesViewController, animated: true, completion: nil)
	}

	@IBAction func addGrade(_ sender: Any) {
		let grade = SchoolLoopComputableGrade(title: "Assignment", categoryName: "Category", percentScore: "%", score: "0", maxPoints: "0", comment: "", systemID: "", dueDate: "", changedDate: "")
		grade.computableCourse = computableCourse
		computableCourse.computableGrades.insert(grade, at: 0)
		grades = computableCourse.computableGrades
		updateSearchResults(for: searchController)
		if computableCourse.computableGrades.count >= 1 {
			DispatchQueue.main.async {
				self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .none, animated: true)
			}
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return section == 0 ? header?.headerTableView : nil
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		header?.headerTableView.layoutIfNeeded()
		return section == 0 && header != nil ? header.headerTableView.contentSize.height : 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 0 : filteredGrades.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgressReportViewController.cellIdentifier, for: indexPath) as? GradeTableViewCell else {
			assertionFailure("Could not deque GradeTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: ProgressReportViewController.cellIdentifier, for: indexPath)
		}
		let grade = filteredGrades[indexPath.row]
		cell.progressReportViewController = self
		cell.indexPath = indexPath
		cell.categories = ["¯\\_(ツ)_/¯"] + categories.map { $0.name }
		if viewMode == .original {
			cell.categoryDiscriminatorView.backgroundColor = categoryColors[grade.categoryName]

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
				return tableView.dequeueReusableCell(withIdentifier: ProgressReportViewController.cellIdentifier, for: indexPath)
			}

			if computableGrade.isUserCreated {
				cell.accessoryType = .none
				cell.selectionStyle = .none
			} else {
				cell.accessoryType = .disclosureIndicator
				cell.selectionStyle = .default
			}

			cell.categoryDiscriminatorView.backgroundColor = categoryColors[computableGrade.computedCategoryName?.name ?? ""]

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

	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		// Only enable selection for "original" grades
		if viewMode == .original {
			return indexPath
		} else {
			return (grades[indexPath.row] as? SchoolLoopComputableGrade)?.isUserCreated ?? false ? nil : indexPath
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return viewMode != .original
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		computableCourse.computableGrades.remove(at: indexPath.row)
		grades = computableCourse.computableGrades
		updateSearchResults(for: searchController)
		tableView.deleteRows(at: [indexPath], with: .fade)
		// Call didSet
		viewMode = { viewMode }()
	}

	func updateSearchResults(for searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercased() ?? ""
		if !filter.isEmpty {
			filteredGrades.removeAll()
			filteredGrades = grades.filter { grade in
				return grade.title.lowercased().contains(filter) || grade.categoryName.lowercased().contains(filter)
			}
		} else {
			filteredGrades = grades
		}
		DispatchQueue.main.async {
			self.tableView.reloadData()
			// Workaround for rdar://problem/35436877
			UIView.setAnimationsEnabled(false)
			self.tableView.beginUpdates()
			self.tableView.endUpdates()
			UIView.setAnimationsEnabled(true)
		}
	}

	func changedTitle(to title: String, forIndexPath indexPath: IndexPath) {
		guard let grade = filteredGrades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.title = title
		// Call didSet
		viewMode = { viewMode }()
	}

	func changedScore(to score: String, forIndexPath indexPath: IndexPath) {
		guard let grade = filteredGrades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.score = score
		// Call didSet
		viewMode = { viewMode }()
	}

	func changedMaxPoints(to maxPoints: String, forIndexPath indexPath: IndexPath) {
		guard let grade = filteredGrades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.maxPoints = maxPoints
		// Call didSet
		viewMode = { viewMode }()
	}

	func changedCategoryName(to categoryName: String, forIndexPath indexPath: IndexPath) {
		guard let grade = filteredGrades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.categoryName = categoryName
		// Call didSet
		viewMode = { viewMode }()
	}

	func changedPercentScore(to percentScore: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.percentScore = percentScore
		// Call didSet
		viewMode = { viewMode }()
	}

	// MARK: - Navigation

	@objc func showCourse(_ sender: Any) {
		guard let courseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "course") as? CourseViewController else {
			assertionFailure("Could not create CourseViewController")
			return
		}
		courseViewController.course = computableCourse
		navigationController?.pushViewController(courseViewController, animated: true)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		setupForceTouch(originatingFrom: tableView)
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = tableView.indexPathForRow(at: location),
			let cell = tableView.cellForRow(at: indexPath) else {
				guard header.headerTableView.frame.contains(location),
					let courseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "course") as? CourseViewController else {
						return nil
				}
				courseViewController.course = computableCourse
				courseViewController.preferredContentSize = .zero
				previewingContext.sourceRect = header.headerTableView.frame
				return courseViewController
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "gradeDetail") as? GradeViewController else {
			return nil
		}
		let selectedGrade = grades[indexPath.row]
		if viewMode != .original {
			guard let selectedGrade = selectedGrade as? SchoolLoopComputableGrade,
				!selectedGrade.isUserCreated else {
					return nil
			}
		}
		destinationViewController.title = selectedGrade.title
		destinationViewController.periodID = periodID
		destinationViewController.systemID = selectedGrade.systemID
		destinationViewController.preferredContentSize = .zero
		previewingContext.sourceRect = cell.frame
		return destinationViewController
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		navigationController?.pushViewController(viewControllerToCommit, animated: true)
	}

	func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
		viewModesViewController.viewModesTableView.layoutIfNeeded()
		viewModesViewController.preferredContentSize = viewModesViewController.viewModesTableView.contentSize
		popoverPresentationController.permittedArrowDirections = .up
		popoverPresentationController.sourceView = titleButton
		// Make the popover appear to originate from the center of the button's
		// title label, not the center of the button (which includes the image)
		titleButton.titleLabel.flatMap {
			popoverPresentationController.sourceRect = CGRect(x: $0.frame.minX, y: titleButton.bounds.minY, width: $0.frame.width, height: titleButton.frame.height)
		}
	}

	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let destinationViewController = segue.destination as? GradeViewController,
			let cell = sender as? GradeTableViewCell,
			let indexPath = tableView.indexPath(for: cell) else {
				assertionFailure("Could not cast destinationViewController to GradeViewController")
				return
		}
		let selectedGrade = grades[indexPath.row]
		destinationViewController.title = selectedGrade.title
		destinationViewController.periodID = periodID
		destinationViewController.systemID = selectedGrade.systemID
	}
}

protocol ViewModeDelegate {
	func changedMode(to mode: ViewMode)
}

extension ProgressReportViewController: ViewModeDelegate {
	func changedMode(to mode: ViewMode) {
		viewMode = mode
	}
}
