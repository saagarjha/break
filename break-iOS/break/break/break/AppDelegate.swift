//
//  AppDelegate.swift
//  break
//
//  Created by Saagar Jha on 1/18/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SchoolLoopSchoolDelegate, SchoolLoopLoginDelegate {

	var window: UIWindow?
	var splashView: UIImageView!

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		if (UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
			application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
		}
		application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		application.applicationIconBadgeNumber = 0

		let schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.schoolDelegate = self
		schoolLoop.getSchools()
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		completionHandler(fetch() ? .NewData : .NoData)
	}

	func fetch() -> Bool {
		var updated = false
		if let tabBarController = window?.rootViewController as? UITabBarController,
			viewControllers = tabBarController.viewControllers?.map({ ($0 as? UINavigationController)?.viewControllers[0] }) {
				for viewController in viewControllers {
					if let coursesViewController = viewController as? CoursesViewController {
						coursesViewController.schoolLoop = SchoolLoop.sharedInstance
						updated ||= coursesViewController.refresh(self)
					}
					if let assignmentsViewController = viewController as? AssignmentsViewController {
						assignmentsViewController.schoolLoop = SchoolLoop.sharedInstance
						updated ||= assignmentsViewController.refresh(self)
					}
					if let loopMailViewController = viewController as? LoopMailViewController {
						loopMailViewController.schoolLoop = SchoolLoop.sharedInstance
						updated ||= loopMailViewController.refresh(self)
					}
					if let newsViewController = viewController as? NewsViewController {
						newsViewController.schoolLoop = SchoolLoop.sharedInstance
						updated ||= newsViewController.refresh(self)
					}
				}
		}
		return updated
	}

	func gotSchools(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
		if error == nil {
			if let schoolName = NSUserDefaults.standardUserDefaults().stringForKey("schoolName"), username = NSUserDefaults.standardUserDefaults().stringForKey("username"), password = schoolLoop.keychain.getPassword(username) {
				schoolLoop.loginDelegate = self

				schoolLoop.logIn(schoolName, username: username, password: password)
			} else {
				showLogin()
			}
		}
	}

	func loggedIn(schoolLoop: SchoolLoop, error: SchoolLoopError?) {
		if error == nil {
			let storybard = UIStoryboard(name: "Main", bundle: nil)
			let tabViewController = storybard.instantiateViewControllerWithIdentifier("tab")
			dispatch_async(dispatch_get_main_queue()) {
				self.window?.rootViewController = tabViewController
			}
		} else {
			dispatch_async(dispatch_get_main_queue()) {
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

	func showLogin() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let loginViewController = storyboard.instantiateViewControllerWithIdentifier("login")
		window?.makeKeyAndVisible()
		window?.rootViewController?.presentViewController(loginViewController, animated: true, completion: nil)
	}

	func showLogout() {
		UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let loginViewController = storyboard.instantiateViewControllerWithIdentifier("login")
		window?.rootViewController = loginViewController
	}
}

infix operator ||= { associativity left precedence 90 }

func ||= (inout lhs: Bool, rhs: Bool) {
	lhs = lhs || rhs
}
