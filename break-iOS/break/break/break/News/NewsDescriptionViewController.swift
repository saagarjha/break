//
//  NewsDescriptionViewController.swift
//  break
//
//  Created by Saagar Jha on 1/31/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class NewsDescriptionViewController: UIViewController, WKNavigationDelegate {

	var iD: String!

	var schoolLoop: SchoolLoop!
	var newsDescription: String = ""

	var descriptionWebView: WKWebView!

	override func loadView() {
		descriptionWebView = WKWebView()
		descriptionWebView.navigationDelegate = self
		descriptionWebView.allowsBackForwardNavigationGestures = true
		view = descriptionWebView
	}

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.hidesBarsOnSwipe = true
//    }

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		loadDescription()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func loadDescription() {
		guard let news = schoolLoop.newsForID(iD) else {
			assertionFailure("Could not get news for iD")
			return
		}
		newsDescription = "<meta name=\"viewport\" content=\"initial-scale=1.0\" /><style type=\"text/css\">body{font: -apple-system-body;}</style><h3>\(news.title)</h3>\(news.newsDescription)"
		if !news.links.isEmpty {
			newsDescription += "<hr><h3><span style=\"font-weight:normal\">Links:</span></h3>"
		}
		for link in news.links ?? [] {
			newsDescription += "<a href=\(link.URL)>\(link.title)</a><br>"
		}
		descriptionWebView.loadHTMLString(newsDescription, baseURL: nil)
	}

//    override func prefersStatusBarHidden() -> Bool {
//        return navigationController?.navigationBarHidden ?? false
//    }

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}
