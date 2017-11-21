//
//  LoopMailViewController.swift
//  break
//
//  Created by Saagar Jha on 1/22/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class LoopMailViewController: UITableViewController, Refreshable, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

	static let cellIdentifier = "LoopMail"

	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	var schoolLoop: SchoolLoop!
	var loopMail = [SchoolLoopLoopMail]()
	var filteredLoopMail = [SchoolLoopLoopMail]()

	var destinationViewController: LoopMailMessageViewController!

	let searchController = UISearchController(searchResultsController: nil)
	
	var forceTouchSourceView: UIView! {
		return tableView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		setupRefreshControl()
		addSearchBar(from: searchController, to: tableView)
		setupSelfAsMasterViewController()

		schoolLoop = SchoolLoop.sharedInstance
		refresh(self)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loopMail = SchoolLoop.sharedInstance.loopMail
		updateSearchResults(for: searchController)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc func refresh(_ sender: Any) {
		schoolLoop.getLoopMail { (_, error) in
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else {
					return
				}
				if error == .noError {
					(UIApplication.shared.delegate as? AppDelegate)?.saveCache()
					`self`.loopMail = `self`.schoolLoop.loopMail
					`self`.updateSearchResults(for: self.searchController)
				}
				// Otherwise the refresh control dismiss animation doesn't work
				`self`.refreshControl?.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
			}
		}
	}

	@IBAction func openSettings(_ sender: Any) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "settings")
		navigationController?.present(viewController, animated: true, completion: nil)
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredLoopMail.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: LoopMailViewController.cellIdentifier, for: indexPath) as? LoopMailTableViewCell else {
			assertionFailure("Could not deque LoopMailTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: LoopMailViewController.cellIdentifier, for: indexPath)
		}
		let loopMail = filteredLoopMail[indexPath.row]
		cell.subjectLabel.text = loopMail.subject
		cell.senderLabel.text = loopMail.sender.name
		cell.dateLabel.text = LoopMailViewController.dateFormatter.string(from: loopMail.date)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let replyAction = UITableViewRowAction(style: .default, title: "Reply") { [weak self] _, indexPath in
			guard let `self` = self else {
				return
			}
			let selectedLoopMail = `self`.filteredLoopMail[indexPath.row]
			`self`.openLoopMailCompose(for: selectedLoopMail)
		}
		replyAction.backgroundColor = view.tintColor
		return [replyAction]
	}

	func updateSearchResults(for searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercased() ?? ""
		if filter != "" {
			filteredLoopMail.removeAll()
			filteredLoopMail = loopMail.filter { loopMail in
				return loopMail.subject.lowercased().contains(filter) || loopMail.sender.name.lowercased().contains(filter)
			}
		} else {
			filteredLoopMail = loopMail
		}
		DispatchQueue.main.async { [unowned self] in
			self.tableView.reloadData()
		}
	}

	// MARK: - Navigation

	func openLoopMailMessage(for loopMail: SchoolLoopLoopMail) {
		guard let loopMailMessageViewController = storyboard?.instantiateViewController(withIdentifier: "loopMailMessage") as? LoopMailMessageViewController else {
			assertionFailure("Could not create LoopMailMessageViewController")
			return
		}
		loopMailMessageViewController.ID = loopMail.ID
		navigationController?.pushViewController(loopMailMessageViewController, animated: true)
	}

	func openLoopMailCompose(for loopMail: SchoolLoopLoopMail) {
		guard let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "loopMailCompose") as? UINavigationController,
			let loopMailComposeViewController = navigationController.topViewController as? LoopMailComposeViewController
			else {
				assertionFailure("Could not create LoopMailComposeViewController")
				return
		}
		(schoolLoop ?? SchoolLoop.sharedInstance).getLoopMailMessage(withID: loopMail.ID) { [weak self] error in
			guard let `self` = self else {
				return
			}
			guard error == .noError else {
				return
			}
			guard let loopMail = self.schoolLoop.loopMail(forID: loopMail.ID) else {
				assertionFailure("Could not get LoopMail for ID")
				return
			}
			DispatchQueue.main.async {
				loopMailComposeViewController.loopMail = loopMail
				loopMailComposeViewController.composedLoopMail = SchoolLoopComposedLoopMail(subject: "\(loopMail.subject)", message: loopMail.message, to: [loopMail.sender], cc: [])
				`self`.present(navigationController, animated: true, completion: nil)
			}
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		setupForceTouch(originatingFrom: tableView)
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = tableView.indexPathForRow(at: location),
			let cell = tableView.cellForRow(at: indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "loopMailMessage") as? LoopMailMessageViewController else {
			return nil
		}
		let selectedLoopMail = filteredLoopMail[indexPath.row]
		destinationViewController.ID = selectedLoopMail.ID
		// Give it a placeholder LoopMail while it loads its own, for any
		// preview actions
		destinationViewController.loopMail = selectedLoopMail
		destinationViewController.parentLoopMailViewController = self
		destinationViewController.preferredContentSize = CGSize(width: 0, height: 0)
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
		guard let destinationViewController = (segue.destination as? UINavigationController)?.topViewController as? LoopMailMessageViewController,
			let cell = sender as? LoopMailTableViewCell,
			let indexPath = tableView.indexPath(for: cell) else {
				return
		}
		let selectedLoopMail = filteredLoopMail[indexPath.row]
		destinationViewController.ID = selectedLoopMail.ID
		// Give it a placeholder LoopMail while it loads its own, for any
		// preview actions
		destinationViewController.loopMail = selectedLoopMail
		self.destinationViewController = destinationViewController
		destinationViewController.parentLoopMailViewController = self
	}
}
