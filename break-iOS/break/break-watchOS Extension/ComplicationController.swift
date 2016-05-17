//
//  ComplicationController.swift
//  break-watchOS Extension
//
//  Created by Saagar Jha on 4/30/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {

	var assignments: [NSDate: [SchoolLoopAssignment]]?

	override init() {
		super.init()
		(WKExtension.sharedExtension().delegate as? ExtensionDelegate)?.sendMessage(["assignments": ""], replyHandler: { reply in
			if let data = reply["assignments"] as? NSData {
				if let assignments = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDate: [SchoolLoopAssignment]] {
					self.assignments = assignments
					let server = CLKComplicationServer.sharedInstance()
					for complication in server.activeComplications! {
						server.reloadTimelineForComplication(complication)
					}
				}
			}
			}, errorHandler: { error in
			print(error)
		})
	}

	// MARK: - Timeline Configuration

	func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
		handler([.Forward])
	}

	func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
		handler(NSDate())
	}

	func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
		handler(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7))
	}

	func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
		handler(.ShowOnLockScreen)
	}

	// MARK: - Timeline Population

	func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
		// Call the handler with the current timeline entry
		guard let assignments = assignments else {
			handler(nil)
			return
		}
		let today = NSDate()
		let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
		var dateComponents = NSDateComponents()
		dateComponents.day = 1
		let tomorrow = calendar?.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions(rawValue: 0))
		dateComponents = (calendar?.components([.Year, .Month, .Day], fromDate: tomorrow!))!
		dateComponents.hour = 0
		dateComponents.minute = 0
		let tomorrowMidnight = (calendar?.dateFromComponents(dateComponents))!
		let dueTomorrow = assignments[tomorrowMidnight] ?? []
		if complication.family == .CircularSmall {
			let template = CLKComplicationTemplateCircularSmallSimpleText()
			template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count)")
			handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template))
		} else if complication.family == .ModularLarge {
			let template = CLKComplicationTemplateModularLargeTable()
			template.headerTextProvider = CLKSimpleTextProvider(text: "Nothing due")
			if dueTomorrow.count > 0 {
				template.headerTextProvider = CLKSimpleTextProvider(text: "Due tomorrow", shortText: "Due")
				template.row1Column1TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow[0].courseName.characters.last!)")
				template.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow[0].title)")
			}
			if dueTomorrow.count > 1 {
				template.row2Column1TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow[1].courseName.characters.last!)")
				template.row2Column2TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow[1].title)")
			}
			handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template))
		} else if complication.family == .ModularSmall {
			let template = CLKComplicationTemplateModularSmallStackText()
			template.line1TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count)")
			template.line2TextProvider = CLKSimpleTextProvider(text: "DUE")
			handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template))
		} else if complication.family == .UtilitarianLarge {
			let template = CLKComplicationTemplateUtilitarianLargeFlat()
			template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count) Due Tomorrow", shortText: "\(dueTomorrow.count) Due")
			handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template))
		} else if complication.family == .UtilitarianSmall {
			let template = CLKComplicationTemplateUtilitarianSmallFlat()
			template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count) Due", shortText: "\(dueTomorrow.count)")
			handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template))
		}
		handler(nil)
	}

	func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
		// Call the handler with the timeline entries prior to the given date
		handler(nil)
	}

	func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
		// Call the handler with the timeline entries after to the given date
		let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
		guard let assignments = assignments else {
			handler(nil)
			return
		}
		var dateComponents = NSDateComponents()
		dateComponents.day = 1
		let tomorrow = calendar?.dateByAddingComponents(dateComponents, toDate: date, options: NSCalendarOptions(rawValue: 0))
		dateComponents = (calendar?.components([.Year, .Month, .Day], fromDate: tomorrow!))!
		dateComponents.hour = 0
		dateComponents.minute = 0
		let tomorrowMidnight = (calendar?.dateFromComponents(dateComponents))!
		var futureDates: [NSDate] = []
		var futureDate = tomorrowMidnight
		for _ in 0 ... 7 {
			futureDates.append(futureDate)
			let dateComponents = NSDateComponents()
			dateComponents.day = 1
			futureDate = (calendar?.dateByAddingComponents(dateComponents, toDate: date, options: NSCalendarOptions(rawValue: 0)))!
		}
		if complication.family == .CircularSmall {
			var entries: [CLKComplicationTimelineEntry] = []
			for futureDate in futureDates {
				let dueTomorrow = assignments[futureDate] ?? []
				let template = CLKComplicationTemplateCircularSmallSimpleText()
				template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count)")
				entries.append(CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: template))

			}
			handler(entries)
		} else if complication.family == .ModularLarge {
			var entries: [CLKComplicationTimelineEntry] = []
			for futureDate in futureDates {
				let dueTomorrow = assignments[futureDate] ?? []
				let template = CLKComplicationTemplateModularLargeTable()
				template.headerTextProvider = CLKSimpleTextProvider(text: "Nothing due")
				if dueTomorrow.count > 0 {
					template.headerTextProvider = CLKSimpleTextProvider(text: "Due tomorrow", shortText: "Due")
					template.row1Column1TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow[0].courseName.characters.last!)")
					template.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow[0].title)")
				}
				if dueTomorrow.count > 1 {
					template.row2Column1TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow[1].courseName.characters.last!)")
					template.row2Column2TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow[1].title)")
				}
				entries.append(CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: template))
			}
			handler(entries)
		} else if complication.family == .ModularSmall {
			var entries: [CLKComplicationTimelineEntry] = []
			for futureDate in futureDates {
				let dueTomorrow = assignments[futureDate] ?? []
				let template = CLKComplicationTemplateModularSmallStackText()
				template.line1TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count)")
				template.line2TextProvider = CLKSimpleTextProvider(text: "DUE")
				entries.append(CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: template))
			}
			handler(entries)
		} else if complication.family == .UtilitarianLarge {
			var entries: [CLKComplicationTimelineEntry] = []
			for futureDate in futureDates {
				let dueTomorrow = assignments[futureDate] ?? []
				let template = CLKComplicationTemplateUtilitarianLargeFlat()
				template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count) Due Tomorrow", shortText: "\(dueTomorrow.count) Due")
				entries.append(CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: template))
			}
			handler(entries)
		} else if complication.family == .UtilitarianSmall {
			var entries: [CLKComplicationTimelineEntry] = []
			for futureDate in futureDates {
				let dueTomorrow = assignments[futureDate] ?? []
				let template = CLKComplicationTemplateUtilitarianSmallFlat()
				template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count) Due", shortText: "\(dueTomorrow.count)")
				entries.append(CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: template))
			}
			handler(entries)
		}
		handler(nil)
	}

	// MARK: - Update Scheduling

	func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
		// Call the handler with the date when you would next like to be given the opportunity to update your complication content
		handler(NSDate(timeIntervalSinceNow: 60 * 60))
	}

	// MARK: - Placeholder Templates

	func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
		// This method will be called once per supported complication, and the results will be cached
		if complication.family == .CircularSmall {
			let template = CLKComplicationTemplateCircularSmallSimpleText()
			template.textProvider = CLKSimpleTextProvider(text: "--")
			handler(template)
		} else if complication.family == .ModularLarge {
			let template = CLKComplicationTemplateModularLargeTable()
			template.headerTextProvider = CLKSimpleTextProvider(text: "Due tomorrow", shortText: "Due")
			template.row1Column1TextProvider = CLKSimpleTextProvider(text: "--")
			template.row1Column2TextProvider = CLKSimpleTextProvider(text: "Assignment")
			template.row2Column1TextProvider = CLKSimpleTextProvider(text: "--")
			template.row2Column2TextProvider = CLKSimpleTextProvider(text: "Assignment 2")
			handler(template)
		} else if complication.family == .ModularSmall {
			let template = CLKComplicationTemplateModularSmallStackText()
			template.line1TextProvider = CLKSimpleTextProvider(text: "--")
			template.line2TextProvider = CLKSimpleTextProvider(text: "DUE")
			handler(template)
		} else if complication.family == .UtilitarianLarge {
			let template = CLKComplicationTemplateUtilitarianLargeFlat()
			template.textProvider = CLKSimpleTextProvider(text: "-- Due Tomorrow", shortText: "-- Due")
			handler(template)
		} else if complication.family == .UtilitarianSmall {
			let template = CLKComplicationTemplateUtilitarianSmallFlat()
			template.textProvider = CLKSimpleTextProvider(text: "-- Due", shortText: "--")
			handler(template)
		}
		handler(nil)
	}

	func requestedUpdateDidBegin() {
		(WKExtension.sharedExtension().delegate as? ExtensionDelegate)?.sendMessage(["assignments": ""], replyHandler: { reply in
			if let data = reply["assignments"] as? NSData {
				if let assignments = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDate: [SchoolLoopAssignment]] {
					self.assignments = assignments
					let server = CLKComplicationServer.sharedInstance()
					for complication in server.activeComplications! {
						server.reloadTimelineForComplication(complication)
					}
				}
			}
			}, errorHandler: { error in
			print(error)
		})
	}
}
