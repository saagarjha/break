//
//  LoopMailMessageViewController.swift
//  break
//
//  Created by Saagar Jha on 1/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class LoopMailMessageViewController: UIViewController, WKNavigationDelegate, SchoolLoopLoopMailMessageDelegate {

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

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		schoolLoop = SchoolLoop.sharedInstance
		 schoolLoop.loopMailMessageDelegate = self
		 schoolLoop.getLoopMailMessage(ID)
	}
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func gotLoopMailMessage(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
		dispatch_async(dispatch_get_main_queue()) {
			if error == nil {
                guard let loopMail = schoolLoop.loopMailForID(self.ID) else {
                    print("Could not get LoopMail for ID")
                    return
                }
				self.message = "<meta name=\"viewport\" content=\"initial-scale=1.0\" /><style type=\"text/css\">body{font: -apple-system-body;}</style><h3><span style=\"font-weight:normal\">From: \(loopMail.sender)</span></h3><h2>\(loopMail.subject)</h2><hr>\(loopMail.message)"
				self.messageWebView.loadHTMLString(self.message, baseURL: nil)
			}
		}
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
