//
//  NewsViewController.swift
//  break
//
//  Created by Saagar Jha on 1/31/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

	let cellIdentifier = "news"

	var schoolLoop: SchoolLoop!
	var news: [SchoolLoopNews] = []
	var filteredNews: [SchoolLoopNews] = []

	var destinationViewController: NewsDescriptionViewController!

	@IBOutlet weak var newsTableView: UITableView! {
		didSet {
            newsTableView.backgroundView = UIView()
            newsTableView.backgroundView?.backgroundColor = .clear
			newsTableView.rowHeight = UITableViewAutomaticDimension
			newsTableView.estimatedRowHeight = 80.0
			refreshControl.addTarget(self, action: #selector(NewsViewController.refresh(_:)), for: .valueChanged)
			newsTableView.addSubview(refreshControl)
		}
	}
	let refreshControl = UIRefreshControl()
	let searchController = UISearchController(searchResultsController: nil)

	deinit {
		searchController.loadViewIfNeeded()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		news = SchoolLoop.sharedInstance.news
		updateSearchResults(for: searchController)
//        navigationController?.hidesBarsOnSwipe = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
		searchController.delegate = self
		searchController.dimsBackgroundDuringPresentation = false
		newsTableView.tableHeaderView = searchController.searchBar
		schoolLoop = SchoolLoop.sharedInstance
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: newsTableView)
		}
		refresh(self)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func refresh(_ sender: AnyObject) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		schoolLoop.getNews() { (_, error) in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError {
					self.news = self.schoolLoop.news
					self.updateSearchResults(for: self.searchController)
				}
				self.refreshControl.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
			}
		}
	}

	@IBAction func openSettings(_ sender: AnyObject) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "settings")
		navigationController?.present(viewController, animated: true, completion: nil)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredNews.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? NewsTableViewCell else {
			assertionFailure("Could not deque NewsTableViewCell")
			return tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
		}
		let news = filteredNews[indexPath.row]
		cell.titleLabel.text = news.title
		cell.authorNameLabel.text = news.authorName
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy"
		cell.createdDateLabel.text = dateFormatter.string(from: news.createdDate)
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func updateSearchResults(for searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercased() ?? ""
		if filter != "" {
			filteredNews.removeAll()
			filteredNews = news.filter { news in
				return news.title.lowercased().contains(filter) || news.authorName.lowercased().contains(filter)
			}
		} else {
			filteredNews = news
		}
		DispatchQueue.main.async {
			self.newsTableView.reloadData()
		}
	}

	// MARK: - Navigation

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = newsTableView.indexPathForRow(at: location),
			let cell = newsTableView.cellForRow(at: indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "newsDescription") as? NewsDescriptionViewController else {
			return nil
		}
		let selectedNews = filteredNews[indexPath.row]
		destinationViewController.iD = selectedNews.iD
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
		guard let destinationViewController = segue.destination as? NewsDescriptionViewController,
			let cell = sender as? NewsTableViewCell,
			let indexPath = newsTableView.indexPath(for: cell) else {
				assertionFailure("Could not cast destinationViewController to NewsDescriptionViewController")
				return
		}
		let selectedNews = filteredNews[indexPath.row]
		destinationViewController.iD = selectedNews.iD
		self.destinationViewController = destinationViewController
	}
}
