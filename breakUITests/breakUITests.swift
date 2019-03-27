//
//  breakUITests.swift
//  breakUITests
//
//  Created by Saagar Jha on 2/4/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import XCTest

class breakUITests: XCTestCase {

	let application = XCUIApplication()

	override func setUp() {
		super.setUp()

		continueAfterFailure = false
		application.launchEnvironment = ["testing": ""]
	}

	func testGenerateScreenshots() {
		application.launch()

		// Screenshot 1
		application.textFields["Full School Name"].tap()
		application.textFields["Full School Name"].typeText("Hogwarts School of Witchcraft and Wizardry")
		application.textFields["Username"].tap()
		application.textFields["Username"].typeText("hpotter")
		application.secureTextFields["Password"].tap()
		application.secureTextFields["Password"].typeText("thechosen1")
		application.buttons["Log in"].tap()
		XCTAssert(application.cells.element.waitForExistence(timeout: 2))
		XCTAssert(application.navigationBars["Courses"].exists)
		if UIDevice.current.userInterfaceIdiom == .pad {
			application.staticTexts["Potions"].tap()
			XCTAssert(application.navigationBars["Potions"].exists)
		}
		takeScreenshot(for: application, named: "01")

		// Screenshot 2
		if UIDevice.current.userInterfaceIdiom == .phone {
			application.staticTexts["Potions"].tap()
			XCTAssert(application.navigationBars["Potions"].exists)
		}

		// Work around an iOS bug and force a relayout of the table view
		application.staticTexts["Calculated"].tap()
		application.navigationBars.buttons["Potions"].tap()

		application.staticTexts["6.0"].firstMatch.tap()
		application.alerts.textFields.element.typeText("6")
		takeScreenshot(for: application, named: "02")

		// Screenshot 3
		application.alerts.buttons["Cancel"].tap()
		if UIDevice.current.userInterfaceIdiom == .phone {
			application.navigationBars.buttons["Courses"].tap()
		}
		XCTAssert(application.navigationBars["Courses"].exists)
		application.staticTexts["Defense Against the Dark Arts"].tap()
		XCTAssert(application.navigationBars["Defense Against the Dark Arts"].exists)
		application.staticTexts["Calculated"].tap()
		application.staticTexts["Essays"].swipeLeft()
		XCTAssert(application.buttons["Delete"].exists)
		takeScreenshot(for: application, named: "03")

		// Screenshot 4
		application.tabBars.buttons["Assignments"].tap()
		XCTAssert(application.navigationBars["Assignments"].exists)
		XCTAssert(application.cells.element.waitForExistence(timeout: 2))
		if UIDevice.current.userInterfaceIdiom == .pad {
			application.staticTexts["Dementor Essay"].tap()
			XCTAssert(application.staticTexts["I hope for your sakes they are better than the tripe I had to endure on resisting the Imperius Curse."].waitForExistence(timeout: 10))
		}
		takeScreenshot(for: application, named: "04")

		// Screenshot 5
		application.tabBars.buttons["LoopMail"].tap()
		XCTAssert(application.navigationBars["LoopMail"].exists)
		if UIDevice.current.userInterfaceIdiom == .phone {
			let semaphore = DispatchSemaphore(value: 0)
			application.staticTexts["Aragog's Dead"].forcePress(withForce: 1 / 3, duration: 10) {
				semaphore.signal()
			}
			XCTAssert(application.staticTexts["Dear Harry, Ron and Hermione,"].waitForExistence(timeout: 10))
			takeScreenshot(for: application, named: "05")
			semaphore.wait()
		} else {
			application.staticTexts["Aragog's Dead"].tap()
			XCTAssert(application.staticTexts["Dear Harry, Ron and Hermione,"].waitForExistence(timeout: 10))
			takeScreenshot(for: application, named: "05")
		}

		// Screenshot 6
		if UIDevice.current.userInterfaceIdiom == .phone {
			application.swipeUp()
		}
		application.staticTexts["Slug Club Dinner"].tap()
		application.navigationBars.buttons["Reply"].tap()
		XCTAssert(application.navigationBars["Compose"].waitForExistence(timeout: 1))
		XCTWaiter(delegate: nil).wait(for: [expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: application.scrollBars.element, handler: nil)], timeout: 1)
		takeScreenshot(for: application, named: "06")

		// Screenshot 7
		application.navigationBars.buttons["Cancel"].tap()
		application.tabBars.buttons["News"].tap()
		XCTAssert(application.navigationBars["News"].exists)
		XCTAssert(application.cells.element.waitForExistence(timeout: 2))
		if UIDevice.current.userInterfaceIdiom == .pad {
			application.staticTexts["Apparition Lessons"].tap()
			XCTAssert(application.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "If you are seventeen years of age")).waitForExistence(timeout: 10))
		}
		takeScreenshot(for: application, named: "07")

		// Screenshot 8
		application.tabBars.buttons["Locker"].tap()
		XCTAssert(application.navigationBars["Locker"].exists)
		application.staticTexts["Transfiguration"].tap()
		XCTAssert(application.navigationBars["Transfiguration"].exists)
		XCTAssert(application.cells.element.waitForExistence(timeout: 2))
		takeScreenshot(for: application, named: "08")

		// Screenshot 9
		application.navigationBars.buttons["My Courses"].tap()
		XCTAssert(application.navigationBars["Locker"].exists)
		application.navigationBars.buttons.firstMatch.tap()
		XCTAssert(application.navigationBars["Settings"].exists)
		application.staticTexts["Notifications"].tap()
		application.staticTexts["Courses"].tap()
		application.staticTexts["Assignments"].tap()
		application.staticTexts["LoopMail"].tap()
		application.staticTexts["News"].tap()
		takeScreenshot(for: application, named: "09")

		// Screenshot 10
		if UIDevice.current.userInterfaceIdiom == .phone {
			application.navigationBars.buttons["Settings"].tap()
		}
		XCTAssert(application.navigationBars["Settings"].exists)
		application.staticTexts["Security"].tap()
		XCTAssert(application.navigationBars["Security"].exists)
		application.switches["Use a password"].tap()
		application.alerts.secureTextFields.element.typeText("")
		application.alerts.buttons["Done"].tap()
		application.switches["Use biometric authentication"].tap()
		if UIDevice.current.userInterfaceIdiom == .phone {
			application.navigationBars.buttons["Settings"].tap()
		}
		XCTAssert(application.navigationBars["Settings"].exists)
		application.navigationBars.buttons["Done"].tap()
		application.tabBars.buttons["Courses"].tap()
		application.navigationBars.buttons["Defense Against the Dark Arts"].tap()
		XCTAssert(application.navigationBars["Defense Against the Dark Arts"].exists)
		if UIDevice.current.userInterfaceIdiom == .phone {
			application.navigationBars.buttons["Courses"].tap()
		}
		XCTAssert(application.navigationBars["Courses"].exists)
		XCUIDevice.shared.press(.home)
		application.activate()
		XCTAssert(application.navigationBars["Courses"].waitForExistence(timeout: 1))
		takeScreenshot(for: application, named: "10")
	}

	func takeScreenshot(for application: XCUIApplication, named name: String) {
		let attachment = XCTAttachment(image: application.screenshot().image)
		attachment.lifetime = .keepAlways
		attachment.name = name
		add(attachment)
	}
}

extension XCUIElement {
	func forcePress(withForce force: Double, duration: TimeInterval, completion: (() -> Void)? = nil) {
		let eventPath = XCPointerEventPath.init(forTouchAtPoint: coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).screenPoint, offset: 0)
		eventPath.pressDownWithPressure(force, atOffset: 0)
		eventPath.liftUpAtOffset(duration)
		let eventRecord = XCSynthesizedEventRecord.init(withName: "force touch", interfaceOrientation: (self as AnyObject).interfaceOrientation) // Fall back to Objective-C runtime for method resolution
		eventRecord.addPointerEventPath(eventPath)
		XCTRunnerDaemonSession.sharedSession.synthesizeEvent(eventRecord) { error in
			XCTAssertNil(error)
			completion?()
		}
	}
}

@objc protocol XCPointerEventPathProtocol {
	init(forTouchAtPoint: CGPoint, offset: TimeInterval)
	func pressDownWithPressure(_ presure: Double, atOffset: TimeInterval)
	func liftUpAtOffset(_ offset: TimeInterval)
}

let XCPointerEventPath = unsafeBitCast(NSClassFromString("XCPointerEventPath"), to: XCPointerEventPathProtocol.Type.self)

@objc protocol XCSynthesizedEventRecordProtocol {
	init(withName: String, interfaceOrientation: UIInterfaceOrientation)
	func addPointerEventPath(_ pointerEventPath: XCPointerEventPathProtocol)
}

let XCSynthesizedEventRecord = unsafeBitCast(NSClassFromString("XCSynthesizedEventRecord"), to: XCSynthesizedEventRecordProtocol.Type.self)

@objc protocol XCTRunnerDaemonSessionProtocol {
	static var sharedSession: XCTRunnerDaemonSessionProtocol { get }
	func synthesizeEvent(_ event: XCSynthesizedEventRecordProtocol, completion: @escaping (NSError?) -> Void)
}

let XCTRunnerDaemonSession = unsafeBitCast(NSClassFromString("XCTRunnerDaemonSession"), to: XCTRunnerDaemonSessionProtocol.Type.self)

@objc protocol XCUIElementProtocol {
	// Introduce "interfaceOrientation" as a selector
	var interfaceOrientation: UIInterfaceOrientation { get }
}
