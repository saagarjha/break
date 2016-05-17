//
//  LoopMailViewController.swift
//  break
//
//  Created by Saagar Jha on 1/22/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoopMailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

	let cellIdentifier = "LoopMail"

	var schoolLoop: SchoolLoop!
	var loopMail: [SchoolLoopLoopMail] = []
	var filteredLoopMail: [SchoolLoopLoopMail] = []

	var destinationViewController: LoopMailMessageViewController!

	@IBOutlet weak var loopMailTableView: UITableView! {
		didSet {
			loopMailTableView.rowHeight = UITableViewAutomaticDimension
			loopMailTableView.estimatedRowHeight = 80.0
			refreshControl.addTarget(self, action: #selector(LoopMailViewController.refresh(_:)), forControlEvents: .ValueChanged)
			loopMailTableView.addSubview(refreshControl)
		}
	}
	let refreshControl = UIRefreshControl()
	let searchController = UISearchController(searchResultsController: nil)

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		loopMail = SchoolLoop.sharedInstance.loopMail
		updateSearchResultsForSearchController(searchController)
//        navigationController?.hidesBarsOnSwipe = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		searchController.searchResultsUpdater = self
		searchController.delegate = self
		loopMailTableView.tableHeaderView = searchController.searchBar
		schoolLoop = SchoolLoop.sharedInstance
		if traitCollection.forceTouchCapability == .Available {
			registerForPreviewingWithDelegate(self, sourceView: view)
		}
		refresh(self)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func refresh(sender: AnyObject) {
		schoolLoop.getLoopMail() { (_, error) in
			dispatch_async(dispatch_get_main_queue()) {
				if error == .NoError {
					self.loopMail = self.schoolLoop.loopMail
					self.updateSearchResultsForSearchController(self.searchController)
				}
				self.refreshControl.performSelector(#selector(UIRefreshControl.endRefreshing), withObject: nil, afterDelay: 0)
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
		return filteredLoopMail.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LoopMailTableViewCell else {
			assertionFailure("Could not deque LoopMailTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		let loopMail = filteredLoopMail[indexPath.row]
		cell.subjectLabel.text = loopMail.subject
		cell.senderLabel.text = loopMail.sender
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		dateFormatter.timeStyle = .ShortStyle
		cell.dateLabel.text = dateFormatter.stringFromDate(loopMail.date)
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let selectedLoopMail = filteredLoopMail[indexPath.row]
		destinationViewController.ID = selectedLoopMail.ID
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercaseString ?? ""
		if filter != "" {
			filteredLoopMail.removeAll()
			filteredLoopMail = loopMail.filter() { loopMail in
				return loopMail.subject.lowercaseString.containsString(filter) || loopMail.sender.lowercaseString.containsString(filter)
			}
		} else {
			filteredLoopMail = loopMail
		}
		dispatch_async(dispatch_get_main_queue()) {
			self.loopMailTableView.reloadData()
		}
	}

	// MARK: - Navigation
	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = loopMailTableView.indexPathForRowAtPoint(location),
			cell = loopMailTableView.cellForRowAtIndexPath(indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("loopMailMessage") as? LoopMailMessageViewController else {
			return nil
		}
		let selectedLoopMail = filteredLoopMail[indexPath.row]
		destinationViewController.ID = selectedLoopMail.ID
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
		guard let destinationViewController = segue.destinationViewController as? LoopMailMessageViewController else {
			assertionFailure("Could not cast destinationViewController to LoopMailMessageViewController")
			return
		}
		self.destinationViewController = destinationViewController
	}
}
