//
//  AppDelegate.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import LocalAuthentication
import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
	let file = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!).URLByAppendingPathComponent("schoolLoop").path ?? ""

	var window: UIWindow?
	var splashView: UIImageView!
	var securityView: UIView!

	var archived = true

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		if (UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
			application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
		}
		application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		if WCSession.isSupported() {
			let session = WCSession.defaultSession()
			session.delegate = self
			session.activateSession()
		}

		if archived {
			NSKeyedUnarchiver.unarchiveObjectWithFile(file)
			archived = false
		}

		let schoolLoop = SchoolLoop.sharedInstance
//		schoolLoop.schoolDelegate = self
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//			schoolLoop.getSchools()
//		}
		if schoolLoop.school != nil && schoolLoop.account != nil {
//			schoolLoop.loginDelegate = self

			schoolLoop.logIn(schoolLoop.school.name, username: schoolLoop.account.username, password: schoolLoop.account.password) { error in
				dispatch_async(dispatch_get_main_queue()) {
					if error == .NoError {
						let storybard = UIStoryboard(name: "Main", bundle: nil)
						let tabBarController = storybard.instantiateViewControllerWithIdentifier("tab")
						let oldView = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(false)
						tabBarController.view.addSubview(oldView)
						self.window?.rootViewController = tabBarController
						if UIApplication.sharedApplication().applicationState == .Active && NSUserDefaults.standardUserDefaults().boolForKey("password") {
							let view: UIView
							if let viewController = self.window?.rootViewController {
								if !UIAccessibilityIsReduceTransparencyEnabled() {
									let effect = UIBlurEffect(style: .Light)
									view = UIVisualEffectView(effect: effect)
									view.frame = viewController.view.bounds
								} else {
									view = UIView(frame: viewController.view.bounds)
									view.backgroundColor = UIColor.whiteColor()
								}
								view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
								viewController.view.addSubview(view)
								self.securityView = view
							}
							if NSUserDefaults.standardUserDefaults().boolForKey("touchID") {
								self.showAuthententication()
							} else {
								self.showPassword()
							}
						}
						UIView.animateWithDuration(0.25, animations: {
							oldView.alpha = 0
							}, completion: { _ in
							oldView.removeFromSuperview()
						})
					} else {
						let alertController = UIAlertController(title: "Authentication failed", message: "Please check your login credentials and try again.", preferredStyle: .Alert)
						let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
							dispatch_async(dispatch_get_main_queue()) {
								self.showLogin()
							}
						}
						alertController.addAction(okAction)
						UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
					}
				}
			}
		} else {
			showLogin()
		}

		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		if NSUserDefaults.standardUserDefaults().boolForKey("password") {
			if let tabBarController = self.window?.rootViewController as? UITabBarController {
				let view: UIView
				if !UIAccessibilityIsReduceTransparencyEnabled() {
					let effect = UIBlurEffect(style: .Light)
					view = UIVisualEffectView(effect: effect)
					view.frame = tabBarController.view.bounds
				} else {
					view = UIView(frame: tabBarController.view.bounds)
					view.backgroundColor = UIColor.whiteColor()
				}
				view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
				tabBarController.view.addSubview(view)
				securityView = view
			}
		}
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		if NSUserDefaults.standardUserDefaults().boolForKey("password") {
			if NSUserDefaults.standardUserDefaults().boolForKey("touchID") {
				self.showAuthententication()
			} else {
				self.showPassword()
			}
		}
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		application.applicationIconBadgeNumber = 0
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		guard NSKeyedArchiver.archiveRootObject(SchoolLoop.sharedInstance, toFile: file) else {
			Logger.log("Could not archive")
			return
		}
		do {
			try NSFileManager.defaultManager().setAttributes([NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication], ofItemAtPath: file)
		} catch let error {
			Logger.log("Could not secure, error: \(error)")
		}
//		guard (try? NSFileManager.defaultManager().setAttributes([NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication], ofItemAtPath: file)) != nil else {
//			Logger.log("Securing data failed")
//			return
//		}
	}

	func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		Logger.log("Started fetch")

		if archived {
			NSKeyedUnarchiver.unarchiveObjectWithFile(file)
			archived = false
		}
		let schoolLoop = SchoolLoop.sharedInstance
//		if let schoolName = NSUserDefaults.standardUserDefaults().stringForKey("schoolName"), username = NSUserDefaults.standardUserDefaults().stringForKey("username"), password = schoolLoop.keychain.getPasswordForUsername(username) {
//			schoolLoop.loginDelegate = self
		var updated = UIBackgroundFetchResult.Failed
		schoolLoop.logIn(schoolLoop.school.name, username: schoolLoop.account.username, password: schoolLoop.account.password) { error in
			if error == .NoError {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
					let group = dispatch_group_create()
					let completion: (Bool, SchoolLoopError) -> Void = {
						if $0.1 == .NoError {
							updated = updated == .Failed ? .NoData : updated
							updated = $0.0 ? .NewData : updated
						}
						dispatch_group_leave(group)
					}
					dispatch_group_enter(group)
					schoolLoop.getCourses(completion)
					dispatch_group_enter(group)
					schoolLoop.getAssignments(completion)
					dispatch_group_enter(group)
					schoolLoop.getLoopMail(completion)
					dispatch_group_enter(group)
					schoolLoop.getNews(completion)
					dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, Int64(30 * NSEC_PER_SEC)))
					Logger.log("Ended fetch, updated: \(updated == .NoData ? "NoData" : updated == .Failed ? "Failed" : "NewData")")
					completionHandler(updated)
				}
			} else {
				completionHandler(.Failed)
			}
		}
//		} else {
//			return completionHandler(.Failed)
//		}
		// if let tabBarController = window?.rootViewController as? UITabBarController,
		// viewControllers = tabBarController.viewControllers?.map({ ($0 as? UINavigationController)?.viewControllers[0] }) {
		// for viewController in viewControllers {
		// Logger.log("Started courses fetch")
		// if let coursesViewController = viewController as? CoursesViewController {
		// schoolLoop.courseDelegate = coursesViewController
		// coursesViewController.schoolLoop = schoolLoop
		// updated ||= coursesViewController.refresh(self)
		// }
		// Logger.log("Ended courses fetch")
		// Logger.log("Started assignments fetch")
		// if let assignmentsViewController = viewController as? AssignmentsViewController {
		// schoolLoop.assignmentDelegate = assignmentsViewController
		// assignmentsViewController.schoolLoop = schoolLoop
		// updated ||= assignmentsViewController.refresh(self)
		// }
		// Logger.log("Ended assignments fetch")
		// Logger.log("Started LoopMail fetch")
		// if let loopMailViewController = viewController as? LoopMailViewController {
		// schoolLoop.loopMailDelegate = loopMailViewController
		// loopMailViewController.schoolLoop = schoolLoop
		// updated ||= loopMailViewController.refresh(self)
		// }
		// Logger.log("Ended LoopMail fetch")
		// Logger.log("Started News fetch")
		// if let newsViewController = viewController as? NewsViewController {
		// schoolLoop.newsDelegate = newsViewController
		// newsViewController.schoolLoop = schoolLoop
		// updated ||= newsViewController.refresh(self)
		// }
		// Logger.log("Ended news fetch")
		// }
		// }
		// if schoolLoop.account == nil {
		// schoolLoop.getSchools()
		// if let schoolName = NSUserDefaults.standardUserDefaults().stringForKey("schoolName"), username = NSUserDefaults.standardUserDefaults().stringForKey("username"), password = schoolLoop.keychain.getPassword(username) {
		// schoolLoop.loginDelegate = self
		//
		// schoolLoop.logIn(schoolName, username: username, password: password)
		// } else {
		// return false
		// }
		// }
//		updated = schoolLoop.getCourses() | schoolLoop.getAssignments() | schoolLoop.getLoopMail() | schoolLoop.getNews()
	}

//	func gotSchools(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
//		if error == nil {
//			if let schoolName = NSUserDefaults.standardUserDefaults().stringForKey("schoolName"), username = NSUserDefaults.standardUserDefaults().stringForKey("username"), password = schoolLoop.keychain.getPassword(username) {
//				schoolLoop.loginDelegate = self
//
//				schoolLoop.logIn(schoolName, username: username, password: password)
//			} else {
//				showLogin()
//			}
//		}
//	}

//	func loggedIn(error: SchoolLoopError?) {
//		if error == .NoError {
//			let storybard = UIStoryboard(name: "Main", bundle: nil)
//			let tabViewController = storybard.instantiateViewControllerWithIdentifier("tab")
//			dispatch_async(dispatch_get_main_queue()) {
//				self.window?.rootViewController = tabViewController
//			}
//		} else {
//			dispatch_async(dispatch_get_main_queue()) {
//				let alertController = UIAlertController(title: "Authentication failed", message: "Please check your login credentials and try again.", preferredStyle: .Alert)
//				let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
//					dispatch_async(dispatch_get_main_queue()) {
//						self.showLogin()
//					}
//				}
//				alertController.addAction(okAction)
//				UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
//			}
//		}
//	}

	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
		completionHandler(true)
	}

	func showLogin() {
		dispatch_async(dispatch_get_main_queue()) {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let loginViewController = storyboard.instantiateViewControllerWithIdentifier("login")
			self.window?.makeKeyAndVisible()
			self.window?.rootViewController?.presentViewController(loginViewController, animated: false, completion: nil)
		}
	}

	func showLogout() {
		UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let loginViewController = storyboard.instantiateViewControllerWithIdentifier("login")
		window?.rootViewController = loginViewController
	}

	func saveCache() {
		NSKeyedArchiver.archiveRootObject(SchoolLoop.sharedInstance, toFile: file)
	}

	func clearCache() {
		do {
			try NSFileManager.defaultManager().removeItemAtPath(file)
		} catch let error {
			Logger.log("Could not remove file, error: \(error)")
		}
	}

	func showAuthententication() {
//		if let tabBarController = self.window?.rootViewController as? UITabBarController {
		LAContext().evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "You'll need to unlock break to continue.") { (success, error) in
			if success {
				dispatch_async(dispatch_get_main_queue()) {
					UIView.animateWithDuration(0.25, animations: {
						if let view = self.securityView as? UIVisualEffectView {
							view.effect = nil
						} else {
							self.securityView.alpha = 0
						}
						}, completion: { _ in
						self.securityView.removeFromSuperview()
					})
				}
			} else {
				self.showPassword()
			}

		}
//		}
	}

	func showPassword() {
		if let tabBarController = self.window?.rootViewController as? UITabBarController {
			let alertController = UIAlertController(title: "Enter your password", message: "You'll need to enter your password to continue. If you've forgotten it, just press \"Forgot\" and log in with your SchoolLoop account.", preferredStyle: .Alert)
			let forgotAction = UIAlertAction(title: "Forgot", style: .Default) { _ in
				SchoolLoop.sharedInstance.logOut()
				dispatch_async(dispatch_get_main_queue()) {
					UIView.animateWithDuration(0.25, animations: {
						if let view = self.securityView as? UIVisualEffectView {
							view.effect = nil
						} else {
							self.securityView.alpha = 0
						}
						}, completion: { _ in
						self.securityView.removeFromSuperview()
					})
				}
			}
			let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
				let schoolLoop = SchoolLoop.sharedInstance
				if alertController.textFields![0].text == schoolLoop.keychain.getPasswordForUsername("\(schoolLoop.account.username)appPassword") {
					dispatch_async(dispatch_get_main_queue()) {
						UIView.animateWithDuration(0.25, animations: {
							if let view = self.securityView as? UIVisualEffectView {
								view.effect = nil
							} else {
								self.securityView.alpha = 0
							}
							}, completion: { _ in
							self.securityView.removeFromSuperview()
						})
					}
				} else {
					let alertController = UIAlertController(title: "Incorrect password", message: "The password you entered was incorrect.", preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
						dispatch_async(dispatch_get_main_queue()) {
							self.showPassword()
						}
					}
					alertController.addAction(okAction)
					dispatch_async(dispatch_get_main_queue()) {
						tabBarController.presentViewController(alertController, animated: true, completion: nil)
					}
				}

			}
			alertController.addAction(forgotAction)
			alertController.addAction(okAction)
			alertController.addTextFieldWithConfigurationHandler({ textField in
				textField.placeholder = "Password"
				textField.secureTextEntry = true
			})
			dispatch_async(dispatch_get_main_queue()) {
				tabBarController.presentViewController(alertController, animated: true, completion: nil)
			}
		}
	}

	func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: ([String: AnyObject]) -> Void) {
		if archived {
			NSKeyedUnarchiver.unarchiveObjectWithFile(file)
			archived = false
		}
		let schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.logIn(schoolLoop.school.name, username: schoolLoop.account.username, password: schoolLoop.account.password) { error in
			if error == .NoError {
				if message["courses"] != nil {
					schoolLoop.getCourses() { _ in
						replyHandler(["courses": NSKeyedArchiver.archivedDataWithRootObject(schoolLoop.courses)])
					}
				} else if let periodID = message["grades"] as? String {
					if let course = schoolLoop.courseForPeriodID(periodID) {
						schoolLoop.getGrades(periodID) { _ in
							replyHandler(["grades": NSKeyedArchiver.archivedDataWithRootObject(course.grades)])
						}
					}
				} else if message["assignments"] != nil {
					schoolLoop.getAssignments({ _ in
						replyHandler(["assignments": NSKeyedArchiver.archivedDataWithRootObject(schoolLoop.assignmentsWithDueDates)])
					})
				} else {
					print("Failure")
					replyHandler(["error": ""])
				}
			} else {
				print("Failure")
				replyHandler(["error": ""])
			}
		}
	}
}

infix operator ||= { associativity left precedence 90 }

//func ||= (inout lhs: UIBackgroundFetchResult, rhs: UIBackgroundFetchResult) {
//    if lhs == .NoData && rhs == .NewData {
//        lhs = .NewData
//    } else if lhs == .Failed {
//        lhs = rhs
//    }
//}

func | (lhs: Bool, rhs: Bool) -> Bool {
	return lhs || rhs
}
