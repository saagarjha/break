//
//  LoopMailMessageViewController.swift
//  break
//
//  Created by Saagar Jha on 1/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class LoopMailMessageViewController: UIViewController, WKNavigationDelegate {

	var ID: String!

	var schoolLoop: SchoolLoop!
	var message: String = ""

	var messageWebView: WKWebView!

	override func loadView() {
		messageWebView = WKWebView()
		messageWebView.navigationDelegate = self
		messageWebView.allowsBackForwardNavigationGestures = true
		view = messageWebView
	}

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.hidesBarsOnSwipe = true
//    }

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
//		schoolLoop.loopMailMessageDelegate = self
		schoolLoop.getLoopMailMessage(ID) { error in
			dispatch_async(dispatch_get_main_queue()) {
				if error == .NoError {
					guard let loopMail = self.schoolLoop.loopMailForID(self.ID) else {
						assertionFailure("Could not get LoopMail for ID")
						return
					}
					self.message = "<meta name=\"viewport\" content=\"initial-scale=1.0\" /><style type=\"text/css\">body{font: -apple-system-body;}</style><h4><span style=\"font-weight:normal\">From: \(loopMail.sender)</span></h4><h3>\(loopMail.subject)</h3><hr>\(loopMail.message)"
					if !loopMail.links.isEmpty {
						self.message += "<hr><h3><span style=\"font-weight:normal\">Links:</span></h3>"
					}
					for link in loopMail.links ?? [] {
						self.message += "<a href=\(link.URL)>\(link.title)</a><br>"
					}
					self.messageWebView.loadHTMLString(self.message, baseURL: nil)
				}
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

//	func gotLoopMailMessage(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
//		dispatch_async(dispatch_get_main_queue()) {
//			if error == nil {
//				guard let loopMail = schoolLoop.loopMailForID(self.ID) else {
//					print("Could not get LoopMail for ID")
//					return
//				}
//				self.message = "<meta name=\"viewport\" content=\"initial-scale=1.0\" /><style type=\"text/css\">body{font: -apple-system-body;}</style><h4><span style=\"font-weight:normal\">From: \(loopMail.sender)</span></h4><h3>\(loopMail.subject)</h3><hr>\(loopMail.message)"
//				if !loopMail.links.isEmpty {
//					self.message += "<hr><h3><span style=\"font-weight:normal\">Links:</span></h3>"
//				}
//				for link in loopMail.links ?? [] {
//					self.message += "<a href=\(link.URL)>\(link.title)</a><br>"
//				}
//				self.messageWebView.loadHTMLString(self.message, baseURL: nil)
//			}
//		}
//	}

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
