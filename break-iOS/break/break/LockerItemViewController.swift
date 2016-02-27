//
//  LockerItemViewController.swift
//  break
//
//  Created by Saagar Jha on 2/26/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class LockerItemViewController: UIViewController, WKNavigationDelegate {

	var path: String!

	var schoolLoop: SchoolLoop!
	var request: NSURLRequest!

	var lockerItemWebView: WKWebView!

	override func loadView() {
		lockerItemWebView = WKWebView()
		lockerItemWebView.navigationDelegate = self
		lockerItemWebView.allowsBackForwardNavigationGestures = true
		view = lockerItemWebView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		navigationController?.hidesBarsOnSwipe = true

		schoolLoop = SchoolLoop.sharedInstance
		loadLockerItem()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func loadLockerItem() {
		request = schoolLoop.urlForLockerItemPath(path)
		lockerItemWebView.loadRequest(request)
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}
