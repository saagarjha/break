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
	let file = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent("schoolLoop").path

	var window: UIWindow?

	var splashView: UIImageView!
	lazy var securityView: UIView = {
		let securityView: UIView
		if !UIAccessibilityIsReduceTransparencyEnabled() {
			let effect = UIBlurEffect(style: .light)
			securityView = UIVisualEffectView(effect: effect)
			securityView.frame = UIScreen.main.bounds
		} else {
			securityView = UIView(frame: UIScreen.main.bounds)
			securityView.backgroundColor = .white
		}
		securityView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return securityView
	}()
	weak var securityAlertController: UIAlertController?

	var archived = true
	var launchIndex = 0
	var launchNotification: UILocalNotification?
	var completionHandler: (() -> Void)?
	var loginTries = 0

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
		// Override point for customization after application launch.

		application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

		if WCSession.isSupported() {
			let session = WCSession.default
			session.delegate = self
			session.activate()
		}
		
		SchoolLoop.sharedInstance = DemoableSchoolLoop()

		if archived {
			NSKeyedUnarchiver.unarchiveObject(withFile: file)
			archived = false
		}

		launchIndex = AppDelegate.index(forType: (launchOptions?[.shortcutItem] as? UIApplicationShortcutItem)?.type.components(separatedBy: ".").last ?? "") ?? Preferences.startupTabIndex
		launchNotification = launchOptions?[.localNotification] as? UILocalNotification

		loginOnLaunch()

		setupAppearance()

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		if Preferences.isPasswordSet {
			if let tabBarController = self.window?.rootViewController as? UITabBarController,
				tabBarController.view.window != nil
				{
				tabBarController.view.addSubview(securityView)
			}
		}
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

		// Remove any previous alerts, if any
		securityAlertController?.dismiss(animated: true, completion: nil)

		if Preferences.isPasswordSet {
			if Preferences.canUseTouchID {
				showAuthententication()
			} else {
				showPassword()
			}
		}
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		application.applicationIconBadgeNumber = 0
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		saveCache()
	}

	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		Logger.log("Starting background fetch")
		if archived {
			NSKeyedUnarchiver.unarchiveObject(withFile: file)
			archived = false
		}
		let schoolLoop = SchoolLoop.sharedInstance
		var updated = UIBackgroundFetchResult.failed
		if schoolLoop.school != nil && schoolLoop.account != nil && !schoolLoop.account.password.isEmpty {
			schoolLoop.logIn(withSchoolName: schoolLoop.school.name, username: schoolLoop.account.username, password: schoolLoop.account.password) { error in
				if error == .noError {
					DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
						let group = DispatchGroup()

						func completion<T>(updatedItems: [T], error: SchoolLoopError) where T: UpdatableItem {
							defer {
								group.leave()
							}

							guard error == .noError else {
								return
							}

							self.saveCache()

							updated = updated == .failed ? .noData : updated
							updated = updatedItems.isEmpty ? .newData : updated

							for item in updatedItems {
								item.postNotification()
							}
						}

						group.enter()
						schoolLoop.getCourses(with: completion)
						group.enter()
						schoolLoop.getAssignments(with: completion)
						group.enter()
						schoolLoop.getLoopMail(with: completion)
						group.enter()
						schoolLoop.getNews(with: completion)

						// Be conservative since we're only allowed 30 seconds
						_ = group.wait(timeout: .now() + 25)
						completionHandler(updated)
					}
				} else {
					completionHandler(.failed)
				}
			}
		} else {
			Logger.log("Background fetch School: \(String(describing: schoolLoop.school))")
			Logger.log("Background fetch Account: \(String(describing: schoolLoop.account?.username))")
			Logger.log("Background fetch Password: \(String(describing: schoolLoop.account?.password.isEmpty))")
			completionHandler(.failed)
		}
	}

	func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
		guard launchNotification == nil else {
			return
		}
		openContext(for: notification)
	}

	func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
		notification.userInfo?["identifier"] = identifier
		guard launchNotification == nil else {
			return
		}
		DispatchQueue.main.async { [unowned self] in
			self.launchNotification = notification
			self.completionHandler = completionHandler
			if self.openContext(for: notification) {
				self.launchNotification = nil
				self.completionHandler = nil
			}
		}
	}


	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		let launchIndex = AppDelegate.index(forType: shortcutItem.type) ?? -1
		if launchIndex > 0 {
			if let tabBarController = window?.rootViewController as? UITabBarController {
				tabBarController.selectedIndex = launchIndex
			}
		}
		completionHandler(true)
	}

	func loginOnLaunch() {
		Logger.log("Logging in at launch")
		let schoolLoop = SchoolLoop.sharedInstance
		if schoolLoop.school != nil && schoolLoop.account != nil && !schoolLoop.account.password.isEmpty {
			schoolLoop.logIn(withSchoolName: schoolLoop.school.name, username: schoolLoop.account.username, password: schoolLoop.account.password) { error in
				DispatchQueue.main.async { [unowned self] in
					Logger.log("Login completed with error \(error)")
					if error == .noError {
						// Initialize tab bar controller
						let storybard = UIStoryboard(name: "Main", bundle: nil)
						let tabBarController = storybard.instantiateViewController(withIdentifier: "tab")
						(tabBarController as? UITabBarController)?.selectedIndex = self.launchIndex

						// Take a snapshot to perform an animation on
						let oldView = UIScreen.main.snapshotView(afterScreenUpdates: false)
						tabBarController.view.addSubview(oldView)

						self.window?.rootViewController = tabBarController

						// Handle notification contexts
						if let notification = self.launchNotification {
							self.openContext(for: notification)
							self.launchNotification = nil
						}
						self.completionHandler?()

						// Show security view
						if UIApplication.shared.applicationState == .active && Preferences.isPasswordSet {
							tabBarController.view.addSubview(self.securityView)
							if Preferences.canUseTouchID {
								self.showAuthententication()
							} else {
								self.showPassword()
							}
						}

						// Remove the old view with an animation
						UIView.animate(withDuration: 0.25, animations: {
							oldView.alpha = 0
						}, completion: { _ in
							oldView.removeFromSuperview()
						})

						self.loginTries = 0
					} else if error == .authenticationError {
						let alertController = UIAlertController(title: "Authentication failed", message: "Please check your login credentials and try again.", preferredStyle: .alert)

						let okAction = UIAlertAction(title: "OK", style: .default) { _ in
							DispatchQueue.main.async { [unowned self] in
								self.showLogin()
							}
						}
						alertController.addAction(okAction)

						self.securityAlertController = alertController
						UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
						self.loginTries = 0
					} else {
						// Third time's the charm
						if self.loginTries < 3 {
							self.loginOnLaunch()
						}
						self.loginTries += 1
					}
				}
			}
		} else {
			Logger.log("School: \(String(describing: schoolLoop.school))")
			Logger.log("Account: \(String(describing: schoolLoop.account?.username))")
			Logger.log("Password: \(String(describing: schoolLoop.account?.password.isEmpty))")
			showLogin()
		}
	}

	func setupAppearance() {
		window?.tintColor = UIColor.break
		let appearance = UINavigationBar.appearance()
		appearance.barStyle = .black
		appearance.tintColor = .white
		appearance.barTintColor = UIColor.break
	}

	func showLogin() {
		DispatchQueue.main.async { [unowned self] in
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
			self.window?.makeKeyAndVisible()
			self.window?.rootViewController?.present(loginViewController, animated: false, completion: nil)
		}
	}

	func showLogout() {
		UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
		window?.rootViewController = loginViewController
	}

	func saveCache() {
		guard NSKeyedArchiver.archiveRootObject(SchoolLoop.sharedInstance, toFile: file) else {
			Logger.log("Could not save cache")
			return
		}
		do {
			try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: file)
		} catch _ {
			Logger.log("Error saving cache")
		}
	}

	func clearCache() {
		do {
			try FileManager.default.removeItem(atPath: file)
		} catch _ {
			Logger.log("Could not clear cache")
		}
	}

	static func index(forType type: String) -> Int? {
		switch type {
		case breakTabIndices.courses.description:
			return breakTabIndices.courses.rawValue
		case breakTabIndices.assignments.description:
			return breakTabIndices.assignments.rawValue
		case breakTabIndices.loopMail.description:
			return breakTabIndices.loopMail.rawValue
		case breakTabIndices.news.description:
			return breakTabIndices.news.rawValue
		case breakTabIndices.locker.description:
			return breakTabIndices.locker.rawValue
		default:
			return nil
		}
	}

	func showAuthententication() {
		LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "You'll need to unlock break to continue.") { [unowned self] (success, error) in
			if success {
				self.removeSecurityView()
			} else {
				self.showPassword()
			}

		}
	}

	func showPassword() {
		if let tabBarController = self.window?.rootViewController as? UITabBarController {
			let alertController = UIAlertController(title: "Enter your password", message: "You'll need to enter your password to continue. If you've forgotten it, just press \"Forgot\" and log in with your School Loop account.", preferredStyle: .alert)
			let forgotAction = UIAlertAction(title: "Forgot", style: .cancel) { [unowned self] _ in
				Preferences.isPasswordSet = false
				Preferences.canUseTouchID = false
				SchoolLoop.sharedInstance.logOut()
				self.removeSecurityView()
			}
			let okAction = UIAlertAction(title: "OK", style: .default) { _ in
				let schoolLoop = SchoolLoop.sharedInstance

				if alertController.textFields?.first?.text == schoolLoop.keychain.getPassword(forUsername: "\(schoolLoop.account.username)appPassword") {
					self.removeSecurityView()
				} else {
					let alertController = UIAlertController(title: "Incorrect password", message: "The password you entered was incorrect.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default) { _ in
						DispatchQueue.main.async { [unowned self] in
							self.showPassword()
						}
					}
					alertController.addAction(okAction)
					DispatchQueue.main.async {
						tabBarController.present(alertController, animated: true, completion: nil)
					}
				}

			}

			alertController.addAction(forgotAction)
			alertController.addAction(okAction)

			alertController.addTextField { textField in
				textField.placeholder = "Password"
				textField.isSecureTextEntry = true
				let schoolLoop = SchoolLoop.sharedInstance

				// If the password is numeric show the number pad
				if (schoolLoop.keychain.getPassword(forUsername: "\(schoolLoop.account.username)appPassword") ?? "").rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
					textField.keyboardType = .numberPad
				}
			}

			DispatchQueue.main.async { [unowned self] in
				self.securityAlertController = alertController
				tabBarController.present(alertController, animated: true, completion: nil)
			}
		}
	}

	func removeSecurityView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.25, animations: { [unowned self] in
				if let securityView = self.securityView as? UIVisualEffectView {
					securityView.effect = nil
				} else {
					self.securityView.alpha = 0
				}
			}, completion: { [unowned self] _ in
				self.securityView.removeFromSuperview()

				// Reset the security view for the next use
				if let securityView = self.securityView as? UIVisualEffectView {
					securityView.effect = UIBlurEffect(style: .light)
				} else {
					self.securityView.alpha = 1
				}
			})
		}
	}

	@discardableResult func openContext(for notification: UILocalNotification) -> Bool {
		defer {
			completionHandler?()
		}

		guard let data = notification.userInfo?["updatedItem"] as? Data else {
			assertionFailure("Could not retrieve updated item")
			return false
		}
		guard let tabBarController = window?.rootViewController as? UITabBarController else {
			return false
		}

		switch NSKeyedUnarchiver.unarchiveObject(with: data) {
		case let course as SchoolLoopCourse:
			tabBarController.selectedIndex = breakTabIndices.courses.rawValue
			tabBarController.viewControllerOfType(CoursesViewController.self)?.openProgressReport(for: course)
		case let assignment as SchoolLoopAssignment:
			tabBarController.selectedIndex = breakTabIndices.assignments.rawValue
			tabBarController.viewControllerOfType(AssignmentsViewController.self)?.openAssignmentDescription(for: assignment)
		case let loopMail as SchoolLoopLoopMail:
			tabBarController.selectedIndex = breakTabIndices.loopMail.rawValue
			if notification.userInfo?["identifier"] as? String != "Reply" {
				tabBarController.viewControllerOfType(LoopMailViewController.self)?.openLoopMailMessage(for: loopMail)
			} else {
				tabBarController.viewControllerOfType(LoopMailViewController.self)?.openLoopMailCompose(for: loopMail)
			}
		case let news as SchoolLoopNews:
			tabBarController.selectedIndex = breakTabIndices.news.rawValue
			tabBarController.viewControllerOfType(NewsViewController.self)?.openNewsDescription(for: news)
		default:
			assertionFailure("Unrecognized updated item")
		}
		return true
	}

	func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
		if archived {
			NSKeyedUnarchiver.unarchiveObject(withFile: file)
			archived = false
		}
		let schoolLoop = SchoolLoop.sharedInstance
		schoolLoop.logIn(withSchoolName: schoolLoop.school.name, username: schoolLoop.account.username, password: schoolLoop.account.password) { error in
			if error == .noError {
				if message["courses"] != nil {
					schoolLoop.getCourses { _,_ in
						replyHandler(["courses": NSKeyedArchiver.archivedData(withRootObject: schoolLoop.courses)])
					}
				} else if let periodID = message["grades"] as? String {
					if let course = schoolLoop.course(forPeriodID: periodID) {
						schoolLoop.getGrades(withPeriodID: periodID) { _ in
							replyHandler(["grades": NSKeyedArchiver.archivedData(withRootObject: course.grades)])
						}
					}
				} else if message["assignments"] != nil {
					schoolLoop.getAssignments { _,_ in
						replyHandler(["assignments": NSKeyedArchiver.archivedData(withRootObject: schoolLoop.assignmentsWithDueDates)])
					}
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

	@available(iOS 9.3, *)
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

	}

	func sessionDidBecomeInactive(_ session: WCSession) {

	}

	func sessionDidDeactivate(_ session: WCSession) {

	}
}

extension UITabBarController {
	func viewControllerOfType<T>(_: T.Type) -> T? where T: UIViewController {
		return (viewControllers ?? []).flatMap {
			return $0 as? T ?? ($0 as? UINavigationController)?.viewControllers.first as? T
		}.first
	}
}

protocol UpdatableItem {
	func postNotification()
}

extension SchoolLoopCourse: UpdatableItem {
	func postNotification() {
		if UIApplication.shared.applicationState != .active,
			Preferences.areCoursesNotificationsAllowed {
			let notification = UILocalNotification()
			notification.userInfo = ["updatedItem": NSKeyedArchiver.archivedData(withRootObject: self)]
			notification.alertBody = "Your grade in \(courseName) has changed"
			notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
			notification.soundName = UILocalNotificationDefaultSoundName
			UIApplication.shared.scheduleLocalNotification(notification)
			// rdar://problem/31790032
			usleep(100_000)
		}
	}
}

extension SchoolLoopAssignment: UpdatableItem {
	func postNotification() {
		if UIApplication.shared.applicationState != .active,
			Preferences.areAssignmentsNotificationsAllowed {
			let notification = UILocalNotification()
			notification.userInfo = ["updatedItem": NSKeyedArchiver.archivedData(withRootObject: self)]
			notification.alertBody = "New assignment \(title) posted for \(courseName)"
			notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
			notification.soundName = UILocalNotificationDefaultSoundName
			UIApplication.shared.scheduleLocalNotification(notification)
			// rdar://problem/31790032
			usleep(100_000)
		}
	}
}

extension SchoolLoopLoopMail: UpdatableItem {
	func postNotification() {
		if UIApplication.shared.applicationState != .active,
			Preferences.areLoopMailNotificationsAllowed {
			let notification = UILocalNotification()
			notification.category = "ReplyCategory"
			notification.userInfo = ["updatedItem": NSKeyedArchiver.archivedData(withRootObject: self)]
			notification.alertBody = "From: \(self.sender.name)\n\(self.subject)"
			notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
			notification.soundName = UILocalNotificationDefaultSoundName
			UIApplication.shared.scheduleLocalNotification(notification)
			// rdar://problem/31790032
			usleep(100_000)
		}
	}
}

extension SchoolLoopNews: UpdatableItem {
	func postNotification() {
		if UIApplication.shared.applicationState != .active,
			Preferences.areNewsNotificationsAllowed {
			let notification = UILocalNotification()
			notification.userInfo = ["updatedItem": NSKeyedArchiver.archivedData(withRootObject: self)]
			notification.alertBody = "\(title)\n\(authorName)"
			notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
			notification.soundName = UILocalNotificationDefaultSoundName
			UIApplication.shared.scheduleLocalNotification(notification)
			// rdar://problem/31790032
			usleep(100_000)
		}
	}
}
