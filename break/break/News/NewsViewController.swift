//
//  NewsViewController.swift
//  break
//
//  Created by Saagar Jha on 1/31/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController, Refreshable, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

	static let cellIdentifier = "news"

	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy"
		return dateFormatter
	}()

	var schoolLoop: SchoolLoop!
	var news = [SchoolLoopNews]()
	var filteredNews = [SchoolLoopNews]()

	var destinationViewController: NewsDescriptionViewController!

	let searchController = UISearchController(searchResultsController: nil)

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
		news = SchoolLoop.sharedInstance.news
		updateSearchResults(for: searchController)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc func refresh(_ sender: Any) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		schoolLoop.getNews() { (_, error) in
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else {
					return
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError {
					(UIApplication.shared.delegate as? AppDelegate)?.saveCache()
					`self`.news = self.schoolLoop.news
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
		return filteredNews.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsViewController.cellIdentifier, for: indexPath) as? NewsTableViewCell else {
			assertionFailure("Could not deque NewsTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: NewsViewController.cellIdentifier, for: indexPath)
		}
		let news = filteredNews[indexPath.row]
		cell.titleLabel.text = news.title
		cell.authorNameLabel.text = news.authorName
		cell.createdDateLabel.text = NewsViewController.dateFormatter.string(from: news.createdDate)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func updateSearchResults(for searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercased() ?? ""
		if !filter.isEmpty {
			filteredNews.removeAll()
			filteredNews = news.filter { news in
				return news.title.lowercased().contains(filter) || news.authorName.lowercased().contains(filter)
			}
		} else {
			filteredNews = news
		}
		self.tableView.reloadData()
	}

	// MARK: - Navigation

	func openNewsDescription(for news: SchoolLoopNews) {
		guard let newsDescriptionViewController = storyboard?.instantiateViewController(withIdentifier: "newsDescription") as? NewsDescriptionViewController else {
			assertionFailure("Could not create NewsDescriptionViewController")
			return
		}
		newsDescriptionViewController.iD = news.iD
		navigationController?.pushViewController(newsDescriptionViewController, animated: true)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		setupForceTouch(originatingFrom: tableView)
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = tableView.indexPathForRow(at: location),
			let cell = tableView.cellForRow(at: indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "newsDescription") as? NewsDescriptionViewController else {
			return nil
		}
		let selectedNews = filteredNews[indexPath.row]
		destinationViewController.iD = selectedNews.iD
		destinationViewController.preferredContentSize = .zero
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
		guard let destinationViewController = (segue.destination as? UINavigationController)?.topViewController as? NewsDescriptionViewController,
			let cell = sender as? NewsTableViewCell,
			let indexPath = tableView.indexPath(for: cell) else {
				assertionFailure("Could not cast destinationViewController to NewsDescriptionViewController")
				return
		}
		let selectedNews = filteredNews[indexPath.row]
		destinationViewController.iD = selectedNews.iD
		self.destinationViewController = destinationViewController
	}
}
