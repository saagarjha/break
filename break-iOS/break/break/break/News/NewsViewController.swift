//
//  NewsViewController.swift
//  break
//
//  Created by Saagar Jha on 1/31/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SchoolLoopNewsDelegate {

	let cellIdentifier = "news"

	var schoolLoop: SchoolLoop!
	var news: [SchoolLoopNews] = []

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

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.hidesBarsOnSwipe = false
//    }

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.newsDelegate = self
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			self.schoolLoop.getNews()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func gotNews(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
		dispatch_async(dispatch_get_main_queue()) {
			if error == nil {
				self.news = schoolLoop.news
				self.newsTableView.reloadData()
			}
			self.refreshControl.performSelector(#selector(UIRefreshControl.endRefreshing), withObject: nil, afterDelay: 0)
		}
	}

	func refresh(sender: AnyObject) -> Bool {
		return schoolLoop.getNews()
	}

	@IBAction func openSettings(sender: AnyObject) {
		let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("settings")
		navigationController?.presentViewController(viewController, animated: true, completion: nil)
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return news.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? NewsTableViewCell else {
			assertionFailure("Could not deque NewsTableViewCell")
			return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
		}
		cell.titleLabel.text = news[indexPath.row].title
		cell.authorNameLabel.text = news[indexPath.row].authorName
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy"
		cell.createdDateLabel.text = dateFormatter.stringFromDate(news[indexPath.row].createdDate)
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let selectedNews = news[indexPath.row]
		destinationViewController.iD = selectedNews.iD
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - Navigation

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
