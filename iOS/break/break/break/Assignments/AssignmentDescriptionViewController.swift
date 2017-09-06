//
//  AssignmentDescriptionViewController.swift
//  break
//
//  Created by Saagar Jha on 1/25/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class AssignmentDescriptionViewController: WebViewToSafariViewControllerShimViewController {

	var iD: String!

	var schoolLoop: SchoolLoop!
	var assignmentDescription: String = ""

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		setupSelfAsDetailViewController()
		
		schoolLoop = SchoolLoop.sharedInstance
		loadDescription()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func loadDescription() {
		guard let iD = iD else {
			return
		}
		guard let assignment = schoolLoop.assignment(foriD: iD) else {
			assertionFailure("Could not get assignment for iD")
			return
		}
		assignmentDescription = breakConstants.webViewDefaultStyle
		assignmentDescription += "<h3>\(assignment.title)</h3>\(assignment.assignmentDescription)"
		if !assignment.links.isEmpty {
			assignmentDescription += "<hr><h3><span style=\"font-weight:normal\">Links:</span></h3>"
		}
		for link in assignment.links {
			assignmentDescription += "<a href=\(link.URL)>\(link.title)</a><br>"
		}
		webView.loadHTMLString(assignmentDescription, baseURL: nil)
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}
