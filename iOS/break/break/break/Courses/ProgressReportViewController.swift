//
//  ProgressReportViewController.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class ProgressReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate, UIPopoverPresentationControllerDelegate {

	let cellIdentifier = "grade"
	static let normalFont = UIFont.preferredFont(forTextStyle: .title3)
	static let boldFont = UIFont(descriptor: normalFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: normalFont.pointSize)

	var periodID: String!

	var schoolLoop: SchoolLoop!
	var course: SchoolLoopCourse!
	var computableCourse: SchoolLoopComputableCourse!
	var categories = [SchoolLoopCategory]()
	var grades = [SchoolLoopGrade]()
	var filteredGrades = [SchoolLoopGrade]()
	var trendScores = [SchoolLoopTrendScore]()

	var viewMode = ViewMode.calculated {
		didSet {
			let title = viewMode.description
			switch viewMode {
			case .calculated:
				categories = computableCourse.computableCategories
				grades = computableCourse.computableGrades
				addGradeButtonItem.isEnabled = true

				header.title = (title: title, subtitle: String(format: "%.2f%%", computableCourse.computedScore * 100), comparisonResult: computableCourse.comparisonResult)
				header.headers = categories.flatMap {
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
				header.headers = categories.flatMap {
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
				header.headers = categories.flatMap {
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
				if scoreDifferenceString == "-0.00%" {
					scoreDifferenceString = "+0.00%"
				}
				header.title = (title: title, subtitle: scoreDifferenceString, comparisonResult: computableCourse.comparisonResult)
				header.headers = categories.flatMap {
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
			default:
				assertionFailure("ViewMode set to invalid value")
			}
			UIView.setAnimationsEnabled(false)
			gradesTableView.beginUpdates()
			gradesTableView.endUpdates()
			UIView.setAnimationsEnabled(true)
			updateSearchResults(for: searchController)
		}
	}

	@IBOutlet weak var titleButton: UIButton! {
		didSet {
			titleButton.isEnabled = false
		}
	}
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
	var header: ProgressReportHeader!

	var viewModesViewController: ViewModesViewController!

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
		header = ProgressReportHeader()
		header.headerTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProgressReportViewController.showCourse(_:))))
		schoolLoop = SchoolLoop.sharedInstance
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: gradesTableView)
		}
		schoolLoop.getGrades(withPeriodID: periodID) { error in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError || error == .trendScoreError {
					(UIApplication.shared.delegate as? AppDelegate)?.saveCache()
					guard let course = self.schoolLoop.course(forPeriodID: self.periodID) else {
						assertionFailure("Could not get grades for periodID")
						return
					}
					self.course = course
					self.computableCourse = course.computableCourse
					self.categories = self.computableCourse.computableCategories
					self.grades = self.computableCourse.computableGrades
					self.viewMode = .calculated
					self.updateSearchResults(for: self.searchController)
					self.trendScores = self.course.trendScores
					self.titleButton.isEnabled = true
				}
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if course != nil {
			viewMode = { viewMode }()
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
		gradesTableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: true)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return section == 0 ? header?.headerTableView : nil
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		header.headerTableView.layoutIfNeeded()
		return section == 0 && header != nil ? header.headerTableView.contentSize.height : 0
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
		if viewMode == .original {
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
		if viewMode == .original {
			return indexPath
		} else {
			return (grades[indexPath.row] as? SchoolLoopComputableGrade)?.isUserCreated ?? false ? nil : indexPath
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return viewMode != .original
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		computableCourse.computableGrades.remove(at: indexPath.row)
		grades = computableCourse.computableGrades
		updateSearchResults(for: searchController)
		tableView.deleteRows(at: [indexPath], with: .fade)
		viewMode = { viewMode }()
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

	func changedTitle(to title: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.title = title
		viewMode = { viewMode }()
	}

	func changedScore(to score: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.score = score
		viewMode = { viewMode }()
	}

	func changedMaxPoints(to maxPoints: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.maxPoints = maxPoints
		viewMode = { viewMode }()
	}

	func changedCategoryName(to categoryName: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.categoryName = categoryName
		viewMode = { viewMode }()
	}

	func changedPercentScore(to percentScore: String, forIndexPath indexPath: IndexPath) {
		guard let grade = grades[indexPath.row] as? SchoolLoopComputableGrade else {
			assertionFailure("Could not cast SchoolLoopGrade to SchoolLoopComputableGrade")
			return
		}
		grade.percentScore = percentScore
		viewMode = { viewMode }()
	}

	// MARK: - Navigation

	func showCourse(_ sender: AnyObject) {
		guard let courseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "course") as? CourseViewController else {
			assertionFailure("Could not create CourseViewController")
			return
		}
		courseViewController.course = computableCourse
		navigationController?.pushViewController(courseViewController, animated: true)
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = gradesTableView.indexPathForRow(at: location),
			let cell = gradesTableView.cellForRow(at: indexPath) else {
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
			guard let selectedGrade = selectedGrade as? SchoolLoopComputableGrade, !selectedGrade.isUserCreated else {
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
		popoverPresentationController.sourceRect = titleButton.bounds
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
			let indexPath = gradesTableView.indexPath(for: cell) else {
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
