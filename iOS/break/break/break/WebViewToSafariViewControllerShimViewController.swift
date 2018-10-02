//
//  WebViewToSafariViewControllerShimViewController.swift
//  break
//
//  Created by Saagar Jha on 4/29/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import SafariServices
import WebKit

// Since this delegate is expected to be exposed to Objective-C, we can't make
// this a protocol with a default implementation for UIViewControllers.
class WebViewToSafariViewControllerShimViewController: UIViewController, WKNavigationDelegate {

	var webView: WKWebView!

	override func loadView() {
		super.loadView()
		webView = WKWebView()
		webView.navigationDelegate = self
		webView.uiDelegate = self
		webView.allowsBackForwardNavigationGestures = true
		view = webView
	}

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		guard let url = navigationAction.request.url,
			let scheme = url.scheme,
			scheme.hasPrefix("http")
			else {
				decisionHandler(.allow)
				return
		}
		let safariViewController = breakSafariViewController(url: url, entersReaderIfAvailable: false)
		navigationController?.present(safariViewController, animated: true, completion: nil)
		decisionHandler(.cancel)
	}
}

@available(iOS 10.0, *)
extension WebViewToSafariViewControllerShimViewController: WKUIDelegate {
	func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
		return true
	}

	func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
		let safariViewController = breakSafariViewController(url: elementInfo.linkURL!, entersReaderIfAvailable: false)
		return safariViewController
	}

	func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
		navigationController?.present(previewingViewController, animated: true, completion: nil)
	}
}
