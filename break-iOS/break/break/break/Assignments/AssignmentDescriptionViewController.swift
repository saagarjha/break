//
//  AssignmentDescriptionViewController.swift
//  break
//
//  Created by Saagar Jha on 1/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class AssignmentDescriptionViewController: UIViewController, WKNavigationDelegate {

	var iD: String!

	var schoolLoop: SchoolLoop!
	var assignmentDescription: String = ""

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
		let assignment = schoolLoop.assignmentForID(iD)!
		assignmentDescription = "<meta name=\"viewport\" content=\"initial-scale=1.0\" /><style type=\"text/css\">body{font: -apple-system-body;}</style><h3>\(assignment.title)</h3>\(assignment.assignmentDescription)"
		if !assignment.links.isEmpty {
			assignmentDescription += "<hr><h3><span style=\"font-weight:normal\">Links:</span></h3>"
		}
		for link in assignment.links {
			assignmentDescription += "<a href=\(link.URL)>\(link.title)</a><br>"
		}
		descriptionWebView.loadHTMLString(assignmentDescription, baseURL: nil)
	}

//	override func prefersStatusBarHidden() -> Bool {
//		return navigationController?.navigationBarHidden ?? false
//	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}
