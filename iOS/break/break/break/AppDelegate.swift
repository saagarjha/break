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
	var securityView: UIView!

	var archived = true
	var launchIndex = 0
	var launchNotification: UILocalNotification?
	var completionHandler: (() -> Void)?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
		// Override point for customization after application launch.
		let replyNotificationAction = UIMutableUserNotificationAction()
		replyNotificationAction.identifier = "Reply"
		replyNotificationAction.title = "Reply"
		replyNotificationAction.activationMode = .foreground

		let replyNotificationCategory = UIMutableUserNotificationCategory()
		replyNotificationCategory.identifier = "ReplyCategory"
		replyNotificationCategory.setActions([replyNotificationAction], for: .default)
		replyNotificationCategory.setActions([replyNotificationAction], for: .minimal)

		application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: [replyNotificationCategory]))
		application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		if WCSession.isSupported() {
			let session = WCSession.default()
			session.delegate = self
			session.activate()
		}

		if archived {
			NSKeyedUnarchiver.unarchiveObject(withFile: file)
			archived = false
		}

		launchIndex = index(forType: (launchOptions?[.shortcutItem] as? UIApplicationShortcutItem)?.type.components(separatedBy: ".").last ?? "") ?? UserDefaults.standard.integer(forKey: "startup")
		launchNotification = launchOptions?[.localNotification] as? UILocalNotification

		loginOnLaunch()

		let color = UIColor(red: 26 / 256, green: 188 / 256, blue: 156 / 256, alpha: 1)
		window?.tintColor = color
		let appearance = UINavigationBar.appearance()
		appearance.barStyle = .black
		appearance.tintColor = .white
		appearance.barTintColor = color
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		if UserDefaults.standard.bool(forKey: "password") {
			if let tabBarController = self.window?.rootViewController as? UITabBarController {
				let view: UIView
				if !UIAccessibilityIsReduceTransparencyEnabled() {
					let effect = UIBlurEffect(style: .light)
					view = UIVisualEffectView(effect: effect)
					view.frame = tabBarController.view.bounds
				} else {
					view = UIView(frame: tabBarController.view.bounds)
					view.backgroundColor = .white
				}
				view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
				tabBarController.view.addSubview(view)
				securityView = view
			}
		}
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		if UserDefaults.standard.bool(forKey: "password") {
			if UserDefaults.standard.bool(forKey: "touchID") {
				self.showAuthententication()
			} else {
				self.showPassword()
			}
		}
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		application.applicationIconBadgeNumber = 0
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		guard NSKeyedArchiver.archiveRootObject(SchoolLoop.sharedInstance, toFile: file) else {
			return
		}
		do {
			try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: file)
		} catch _ {
		}
		guard (try? FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: file)) != nil else {
			return
		}
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
					DispatchQueue.global(qos: .userInitiated).async {
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
						schoolLoop.getCourses(withCompletionHandler: completion)
						group.enter()
						schoolLoop.getAssignments(withCompletionHandler: completion)
						group.enter()
						schoolLoop.getLoopMail(withCompletionHandler: completion)
						group.enter()
						schoolLoop.getNews(withCompletionHandler: completion)
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
		openContextForNotification(notification)
	}

	func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
		guard launchNotification == nil else {
			return
		}
		DispatchQueue.main.async {
			self.launchNotification = notification
			self.completionHandler = completionHandler
		}
	}


	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		let launchIndex = self.index(forType: shortcutItem.type) ?? -1
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
				DispatchQueue.main.async {
					Logger.log("Login completed with error \(error)")
					if error == .noError {
						let storybard = UIStoryboard(name: "Main", bundle: nil)
						let tabBarController = storybard.instantiateViewController(withIdentifier: "tab")
						(tabBarController as? UITabBarController)?.selectedIndex = self.launchIndex
						let oldView = UIScreen.main.snapshotView(afterScreenUpdates: false)
						tabBarController.view.addSubview(oldView)
						self.window?.rootViewController = tabBarController
						if let notification = self.launchNotification {
							self.openContextForNotification(notification)
						}
						self.completionHandler?()
						if UIApplication.shared.applicationState == .active && UserDefaults.standard.bool(forKey: "password") {
							let view: UIView
							if let viewController = self.window?.rootViewController {
								if !UIAccessibilityIsReduceTransparencyEnabled() {
									let effect = UIBlurEffect(style: .light)
									view = UIVisualEffectView(effect: effect)
									view.frame = viewController.view.bounds
								} else {
									view = UIView(frame: viewController.view.bounds)
									view.backgroundColor = .white
								}
								view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
								viewController.view.addSubview(view)
								self.securityView = view
							}
							if UserDefaults.standard.bool(forKey: "touchID") {
								self.showAuthententication()
							} else {
								self.showPassword()
							}
						}
						UIView.animate(withDuration: 0.25, animations: {
							oldView.alpha = 0
						}, completion: { _ in
							oldView.removeFromSuperview()
						})
					} else if error == .authenticationError {
						let alertController = UIAlertController(title: "Authentication failed", message: "Please check your login credentials and try again.", preferredStyle: .alert)
						let okAction = UIAlertAction(title: "OK", style: .default) { _ in
							DispatchQueue.main.async {
								self.showLogin()
							}
						}
						alertController.addAction(okAction)
						UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
					} else {
						self.loginOnLaunch()
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

	func showLogin() {
		DispatchQueue.main.async {
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
		if !NSKeyedArchiver.archiveRootObject(SchoolLoop.sharedInstance, toFile: file) {
			Logger.log("Could not save cache")
		}
	}

	func clearCache() {
		do {
			try FileManager.default.removeItem(atPath: file)
		} catch _ {
			Logger.log("Could not clear cache")
		}
	}

	func index(forType type: String) -> Int? {
		switch type {
		case "Course":
			return 0
		case "Assignments":
			return 1
		case "LoopMail":
			return 2
		case "News":
			return 3
		case "Locker":
			return 4
		default:
			return nil
		}
	}

	func showAuthententication() {
		LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "You'll need to unlock break to continue.") { (success, error) in
			if success {
				DispatchQueue.main.async {
					UIView.animate(withDuration: 0.25, animations: {
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
	}

	func showPassword() {
		if let tabBarController = self.window?.rootViewController as? UITabBarController {
			let alertController = UIAlertController(title: "Enter your password", message: "You'll need to enter your password to continue. If you've forgotten it, just press \"Forgot\" and log in with your SchoolLoop account.", preferredStyle: .alert)
			let forgotAction = UIAlertAction(title: "Forgot", style: .default) { _ in
				UserDefaults.standard.set(false, forKey: "password")
				UserDefaults.standard.set(false, forKey: "touchID")
				UserDefaults.standard.synchronize()
				SchoolLoop.sharedInstance.logOut()
				DispatchQueue.main.async {
					UIView.animate(withDuration: 0.25, animations: {
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
			let okAction = UIAlertAction(title: "OK", style: .default) { _ in
				let schoolLoop = SchoolLoop.sharedInstance
				if alertController.textFields![0].text == schoolLoop.keychain.getPassword(forUsername: "\(schoolLoop.account.username)appPassword") {
					DispatchQueue.main.async {
						UIView.animate(withDuration: 0.25, animations: {
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
					let alertController = UIAlertController(title: "Incorrect password", message: "The password you entered was incorrect.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default) { _ in
						DispatchQueue.main.async {
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
				if Int(schoolLoop.keychain.getPassword(forUsername: "\(schoolLoop.account.username)appPassword") ?? "") != nil {
					textField.keyboardType = .numberPad
				}
			}
			DispatchQueue.main.async {
				tabBarController.present(alertController, animated: true, completion: nil)
			}
		}
	}

	func openContextForNotification(_ notification: UILocalNotification) {
		guard let data = notification.userInfo?["updatedItem"] as? Data,
			let tabBarController = window?.rootViewController as? UITabBarController else {
				assertionFailure("Could not retrieve updated item")
				return
		}
		switch NSKeyedUnarchiver.unarchiveObject(with: data) {
		case let course as SchoolLoopCourse:
			tabBarController.selectedIndex = 0
			tabBarController.viewControllerOfType(CoursesViewController.self)?.openProgressReport(for: course)
		case let assignment as SchoolLoopAssignment:
			tabBarController.selectedIndex = 1
			tabBarController.viewControllerOfType(AssignmentsViewController.self)?.openAssignmentDescription(for: assignment)
		case let loopMail as SchoolLoopLoopMail:
			tabBarController.selectedIndex = 2
			if notification.category != "ReplyCategory" {
				tabBarController.viewControllerOfType(LoopMailViewController.self)?.openLoopMailMessage(for: loopMail)
			} else {
				tabBarController.viewControllerOfType(LoopMailViewController.self)?.openLoopMailCompose(for: loopMail)
			}
		case let news as SchoolLoopNews:
			tabBarController.selectedIndex = 3
			tabBarController.viewControllerOfType(NewsViewController.self)?.openNewsDescription(for: news)
		default:
			assertionFailure("Unrecognized updated item")
		}
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
					schoolLoop.getCourses { _ in
						replyHandler(["courses": NSKeyedArchiver.archivedData(withRootObject: schoolLoop.courses)])
					}
				} else if let periodID = message["grades"] as? String {
					if let course = schoolLoop.course(forPeriodID: periodID) {
						schoolLoop.getGrades(withPeriodID: periodID) { _ in
							replyHandler(["grades": NSKeyedArchiver.archivedData(withRootObject: course.grades)])
						}
					}
				} else if message["assignments"] != nil {
					schoolLoop.getAssignments { _ in
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

	static func color(for string: String) -> UIColor {
		let hashValue = UInt(bitPattern: string.hashValue)
		let channelSize = UInt(MemoryLayout<Int>.size * 8 / 3)
		let mask = 1 << channelSize - 1
		let red = CGFloat(hashValue & mask) / CGFloat(mask + 1)
		let green = CGFloat(hashValue >> channelSize & mask) / CGFloat(mask + 1)
		let blue = CGFloat(hashValue >> (channelSize * 2) & mask) / CGFloat(mask + 1)
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
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
		if UIApplication.shared.applicationState != .active {
			let notification = UILocalNotification()
			notification.userInfo = ["updatedItem": NSKeyedArchiver.archivedData(withRootObject: self)]
			notification.fireDate = Date(timeIntervalSinceNow: 1)
			notification.alertBody = "Your grade in \(courseName) has changed"
			notification.applicationIconBadgeNumber = 1
			notification.soundName = UILocalNotificationDefaultSoundName
			UIApplication.shared.scheduleLocalNotification(notification)
		}
	}
}

extension SchoolLoopAssignment: UpdatableItem {
	func postNotification() {
		if UIApplication.shared.applicationState != .active {
			let notification = UILocalNotification()
			notification.userInfo = ["updatedItem": NSKeyedArchiver.archivedData(withRootObject: self)]
			notification.fireDate = Date(timeIntervalSinceNow: 1)
			notification.alertBody = "New assignment \(title) posted for \(courseName)"
			notification.applicationIconBadgeNumber = 1
			notification.soundName = UILocalNotificationDefaultSoundName
			UIApplication.shared.scheduleLocalNotification(notification)
		}
	}
}

extension SchoolLoopLoopMail: UpdatableItem {
	func postNotification() {
		if UIApplication.shared.applicationState != .active {
			let notification = UILocalNotification()
			notification.category = "ReplyCategory"
			notification.userInfo = ["updatedItem": NSKeyedArchiver.archivedData(withRootObject: self)]
			notification.fireDate = Date(timeIntervalSinceNow: 1)
			notification.alertBody = "From: \(sender.name)\n\(subject)\n"
			notification.applicationIconBadgeNumber = 1
			notification.soundName = UILocalNotificationDefaultSoundName
			UIApplication.shared.scheduleLocalNotification(notification)
		}
	}
}

extension SchoolLoopNews: UpdatableItem {
	func postNotification() {
		if UIApplication.shared.applicationState != .active {
			let notification = UILocalNotification()
			notification.userInfo = ["updatedItem": NSKeyedArchiver.archivedData(withRootObject: self)]
			notification.fireDate = Date(timeIntervalSinceNow: 1)
			notification.alertBody = "\(title)\n\(authorName)"
			notification.applicationIconBadgeNumber = 1
			notification.soundName = UILocalNotificationDefaultSoundName
			UIApplication.shared.scheduleLocalNotification(notification)
		}
	}
}
