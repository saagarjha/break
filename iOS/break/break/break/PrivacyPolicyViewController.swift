//
//  PrivacyPolicyViewController.swift
//  break
//
//  Created by Saagar Jha on 5/12/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let privacyPolicy = "<p>break values your privacy. break stores certain data on your phone, including:</p>\n\n<ul>\n<li>Your login credentials.</li>\n<li>A cache of your SchoolLoop data.</li>\n</ul>\n\n<p>break takes precautions, such as the iOS keychain and Data Protection, in order to ensure that this data remains secure. Implementation details are available <a href=\"https://github.com/saagarjha/break\">here</a>.</p>\n\n<p>break also communicates with SchoolLoop in order to access data; this data is governed under SchoolLoop's privacy policy <a href=\"http://www.schoolloop.com/about-us/privacy-policy/\">here</a>.</p>"
		let privacyPolicyWebView = WKWebView()
		privacyPolicyWebView.allowsBackForwardNavigationGestures = true
		privacyPolicyWebView.loadHTMLString("<meta name=\"viewport\" content=\"initial-scale=1.0\" /><style type=\"text/css\">body{font: -apple-system-body;}</style>\(privacyPolicy)", baseURL: nil)
		view = privacyPolicyWebView
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func done(_ sender: AnyObject) {
		dismiss(animated: true, completion: nil)
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
