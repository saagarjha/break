//
//  Preferences.swift
//  break
//
//  Created by Saagar Jha on 4/15/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import Foundation

enum Preferences {
	private static let userDefaults = UserDefaults.standard
	
	static var isPasswordSet: Bool {
		get {
			return userDefaults.bool(forKey: "isPasswordSet")
		}
		set {
			userDefaults.set(newValue, forKey: "isPasswordSet")
			userDefaults.synchronize()
		}
	}
	
	static var canUseTouchID: Bool {
		get {
			return userDefaults.bool(forKey: "canUseTouchID")
		}
		set {
			userDefaults.set(newValue, forKey: "canUseTouchID")
			userDefaults.synchronize()
		}
	}
	
	static var startupTabIndex: Int {
		get {
			return userDefaults.integer(forKey: "startupTabIndex")
		}
		set {
			userDefaults.set(newValue, forKey: "startupTabIndex")
			userDefaults.synchronize()
		}
	}
	
	static var areCoursesNotificationsAllowed: Bool {
		get {
			return userDefaults.bool(forKey: "areCoursesNotificationsAllowed")
		}
		set {
			userDefaults.set(newValue, forKey: "areCoursesNotificationsAllowed")
			userDefaults.synchronize()
		}
	}
	
	static var areAssignmentsNotificationsAllowed: Bool {
		get {
			return userDefaults.bool(forKey: "areAssignmentsNotificationsAllowed")
		}
		set {
			userDefaults.set(newValue, forKey: "areAssignmentsNotificationsAllowed")
			userDefaults.synchronize()
		}
	}
	
	static var areLoopMailNotificationsAllowed: Bool {
		get {
			return userDefaults.bool(forKey: "areLoopMailNotificationsAllowed")
		}
		set {
			userDefaults.set(newValue, forKey: "areLoopMailNotificationsAllowed")
			userDefaults.synchronize()
		}
	}
	
	static var areNewsNotificationsAllowed: Bool {
		get {
			return userDefaults.bool(forKey: "areNewsNotificationsAllowed")
		}
		set {
			userDefaults.set(newValue, forKey: "areNewsNotificationsAllowed")
			userDefaults.synchronize()
		}
	}
	
	static var hideGrades: Bool {
		get {
			return userDefaults.bool(forKey: "hideGrades")
		}
		set {
			userDefaults.set(newValue, forKey: "hideGrades")
			userDefaults.synchronize()
		}
	}
}
