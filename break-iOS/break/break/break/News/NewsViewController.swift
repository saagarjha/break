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
			newsTableView.rowHeight = UITableViewAutomaticDimension
			newsTableView.estimatedRowHeight = 80.0
			refreshControl.addTarget(self, action: #selector(NewsViewController.refresh(_:)), forControlEvents: .ValueChanged)
			newsTableView.addSubview(refreshControl)
		}
	}
	let refreshControl = UIRefreshControl()
	let searchController = UISearchController(searchResultsController: nil)
    
    deinit {
        searchController.loadViewIfNeeded()
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		news = SchoolLoop.sharedInstance.news
		updateSearchResultsForSearchController(searchController)
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
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		schoolLoop.getNews() { (_, error) in
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				if error == .NoError {
					self.news = self.schoolLoop.news
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
		return filteredNews.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? NewsTableViewCell else {
			assertionFailure("Could not deque NewsTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		let news = filteredNews[indexPath.row]
		cell.titleLabel.text = news.title
		cell.authorNameLabel.text = news.authorName
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy"
		cell.createdDateLabel.text = dateFormatter.stringFromDate(news.createdDate)
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let selectedNews = filteredNews[indexPath.row]
		destinationViewController.iD = selectedNews.iD
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		let filter = searchController.searchBar.text?.lowercaseString ?? ""
		if filter != "" {
			filteredNews.removeAll()
			filteredNews = news.filter { news in
				return news.title.lowercaseString.containsString(filter) || news.authorName.lowercaseString.containsString(filter)
			}
		} else {
			filteredNews = news
		}
		dispatch_async(dispatch_get_main_queue()) {
			self.newsTableView.reloadData()
		}
	}

	// MARK: - Navigation

	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = newsTableView.indexPathForRowAtPoint(location),
			cell = newsTableView.cellForRowAtIndexPath(indexPath) else {
				return nil
		}
		guard let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("newsDescription") as? NewsDescriptionViewController else {
			return nil
		}
		let selectedNews = filteredNews[indexPath.row]
		destinationViewController.iD = selectedNews.iD
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
		guard let destinationViewController = segue.destinationViewController as? NewsDescriptionViewController else {
			assertionFailure("Could not cast destinationViewController to NewsDescriptionViewController")
			return
		}
		self.destinationViewController = destinationViewController
	}
}
