//
//  LoopMailMessageViewController.swift
//  break
//
//  Created by Saagar Jha on 1/23/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit
import WebKit

class LoopMailMessageViewController: WebViewToSafariViewControllerShimViewController {

	var ID: String!

	var schoolLoop: SchoolLoop!
	var message: String = ""
	var loopMail: SchoolLoopLoopMail?

	var parentLoopMailViewController: LoopMailViewController?
	override var previewActionItems: [UIPreviewActionItem] {
		return [loopMail.map { loopMail in
			{ [weak self] _, _ in
				guard let `self` = self else {
					return
				}
				`self`.parentLoopMailViewController?.openLoopMailCompose(for: loopMail)
			}
		}].flatMap {
			$0
		}.map {
			UIPreviewAction(title: "Reply", style: .default, handler: $0)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		setupSelfAsDetailViewController()

		schoolLoop = SchoolLoop.sharedInstance
		guard let ID = ID else {
			return
		}
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		schoolLoop.getLoopMailMessage(withID: ID) { error in
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else {
					return
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if error == .noError {
					guard let loopMail = `self`.schoolLoop.loopMail(forID: self.ID) else {
						assertionFailure("Could not get LoopMail for ID")
						return
					}
					`self`.loopMail = loopMail
					`self`.message = "\(breakConstants.webViewDefaultStyle)<h4><span style=\"font-weight:normal\">From: \(loopMail.sender.name)</span></h4><h3>\(loopMail.subject)</h3><hr>\(loopMail.message)"
					if !loopMail.links.isEmpty {
						`self`.message += "<hr><h3><span style=\"font-weight:normal\">Links:</span></h3>"
					}
					for link in loopMail.links {
						`self`.message += "<a href=\(link.URL)>\(link.title)</a><br>"
					}
					`self`.webView.loadHTMLString(`self`.message, baseURL: nil)
				}
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard let loopMailComposeViewController = (segue.destination as? UINavigationController)?.topViewController as? LoopMailComposeViewController,
			let loopMail = loopMail else {
				return
		}
		loopMailComposeViewController.loopMail = loopMail
		loopMailComposeViewController.composedLoopMail = SchoolLoopComposedLoopMail(subject: "\(loopMail.subject)", message: loopMail.message, to: [loopMail.sender], cc: [])
	}
}
