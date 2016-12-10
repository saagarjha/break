//
//  ExtensionDelegate.swift
//  break-watchOS Extension
//
//  Created by Saagar Jha on 4/24/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import WatchConnectivity
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
	var session: WCSession?

	func applicationDidFinishLaunching() {
		// Perform any final initialization of your application.
	}

	func applicationDidBecomeActive() {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		if WCSession.isSupported() {
			session = WCSession.default()
			session?.delegate = self
			session?.activate()
		}
	}

	func applicationWillResignActive() {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, etc.
	}

	func sendMessage(_ message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void, errorHandler: @escaping (Error) -> Void) {
		if let session = session {
			session.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
		} else {
			errorHandler(NSError(domain: WCErrorDomain, code: WCError.Code.genericError.rawValue, userInfo: nil))
		}
	}

	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

	}
}
