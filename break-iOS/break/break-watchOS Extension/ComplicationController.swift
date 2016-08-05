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

	var assignments: [Date: [SchoolLoopAssignment]]?

	override init() {
		super.init()
		(WKExtension.shared().delegate as? ExtensionDelegate)?.sendMessage(["assignments": ""], replyHandler: { reply in
			if let data = reply["assignments"] as? Data {
				if let assignments = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Date: [SchoolLoopAssignment]] {
					self.assignments = assignments
					let server = CLKComplicationServer.sharedInstance()
					for complication in server.activeComplications! {
						server.reloadTimeline(for: complication)
					}
				}
			}
			}, errorHandler: { error in
			print(error)
		})
	}

	// MARK: - Timeline Configuration

	func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
		handler([.forward])
	}

	func getTimelineStartDate(for complication: CLKComplication, withHandler handler: (Date?) -> Void) {
		handler(Date())
	}

	func getTimelineEndDate(for complication: CLKComplication, withHandler handler: (Date?) -> Void) {
		handler(Date(timeIntervalSinceNow: 60 * 60 * 24 * 7))
	}

	func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
		handler(.showOnLockScreen)
	}

	// MARK: - Timeline Population

	func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
		// Call the handler with the current timeline entry
		guard let assignments = assignments else {
			handler(nil)
			return
		}
		let today = Date()
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		var dateComponents = DateComponents()
		dateComponents.day = 1
		let tomorrow = calendar.date(byAdding: dateComponents, to: today, wrappingComponents: true)
		dateComponents = (calendar.dateComponents([.year, .month, .day], from: tomorrow!))
		dateComponents.hour = 0
		dateComponents.minute = 0
		let tomorrowMidnight = (calendar.date(from: dateComponents))!
		let dueTomorrow = assignments[tomorrowMidnight] ?? []
		if complication.family == .circularSmall {
			let template = CLKComplicationTemplateCircularSmallSimpleText()
			template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count)")
			handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
		} else if complication.family == .modularLarge {
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
			handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
		} else if complication.family == .modularSmall {
			let template = CLKComplicationTemplateModularSmallStackText()
			template.line1TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count)")
			template.line2TextProvider = CLKSimpleTextProvider(text: "DUE")
			handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
		} else if complication.family == .utilitarianLarge {
			let template = CLKComplicationTemplateUtilitarianLargeFlat()
			template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count) Due Tomorrow", shortText: "\(dueTomorrow.count) Due")
			handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
		} else if complication.family == .utilitarianSmall {
			let template = CLKComplicationTemplateUtilitarianSmallFlat()
			template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count) Due", shortText: "\(dueTomorrow.count)")
			handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
		}
		handler(nil)
	}

	func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
		// Call the handler with the timeline entries prior to the given date
		handler(nil)
	}

	func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
		// Call the handler with the timeline entries after to the given date
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		guard let assignments = assignments else {
			handler(nil)
			return
		}
		var dateComponents = DateComponents()
		dateComponents.day = 1
		let tomorrow = calendar.date(byAdding: dateComponents, to: date, wrappingComponents: true)
		dateComponents = (calendar.dateComponents([.year, .month, .day], from: tomorrow!))
		dateComponents.hour = 0
		dateComponents.minute = 0
		let tomorrowMidnight = (calendar.date(from: dateComponents))!
		var futureDates: [Date] = []
		var futureDate = tomorrowMidnight
		for _ in 0 ... 7 {
			futureDates.append(futureDate)
			var dateComponents = DateComponents()
			dateComponents.day = 1
			futureDate = (calendar.date(byAdding: dateComponents, to: date, wrappingComponents: true))!
		}
		if complication.family == .circularSmall {
			var entries: [CLKComplicationTimelineEntry] = []
			for futureDate in futureDates {
				let dueTomorrow = assignments[futureDate] ?? []
				let template = CLKComplicationTemplateCircularSmallSimpleText()
				template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count)")
				entries.append(CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: template))

			}
			handler(entries)
		} else if complication.family == .modularLarge {
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
		} else if complication.family == .modularSmall {
			var entries: [CLKComplicationTimelineEntry] = []
			for futureDate in futureDates {
				let dueTomorrow = assignments[futureDate] ?? []
				let template = CLKComplicationTemplateModularSmallStackText()
				template.line1TextProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count)")
				template.line2TextProvider = CLKSimpleTextProvider(text: "DUE")
				entries.append(CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: template))
			}
			handler(entries)
		} else if complication.family == .utilitarianLarge {
			var entries: [CLKComplicationTimelineEntry] = []
			for futureDate in futureDates {
				let dueTomorrow = assignments[futureDate] ?? []
				let template = CLKComplicationTemplateUtilitarianLargeFlat()
				template.textProvider = CLKSimpleTextProvider(text: "\(dueTomorrow.count) Due Tomorrow", shortText: "\(dueTomorrow.count) Due")
				entries.append(CLKComplicationTimelineEntry(date: futureDate, complicationTemplate: template))
			}
			handler(entries)
		} else if complication.family == .utilitarianSmall {
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

	func getNextRequestedUpdateDate(handler: (Date?) -> Void) {
		// Call the handler with the date when you would next like to be given the opportunity to update your complication content
		handler(Date(timeIntervalSinceNow: 60 * 60))
	}

	// MARK: - Placeholder Templates

	func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
		// This method will be called once per supported complication, and the results will be cached
		if complication.family == .circularSmall {
			let template = CLKComplicationTemplateCircularSmallSimpleText()
			template.textProvider = CLKSimpleTextProvider(text: "--")
			handler(template)
		} else if complication.family == .modularLarge {
			let template = CLKComplicationTemplateModularLargeTable()
			template.headerTextProvider = CLKSimpleTextProvider(text: "Due tomorrow", shortText: "Due")
			template.row1Column1TextProvider = CLKSimpleTextProvider(text: "--")
			template.row1Column2TextProvider = CLKSimpleTextProvider(text: "Assignment")
			template.row2Column1TextProvider = CLKSimpleTextProvider(text: "--")
			template.row2Column2TextProvider = CLKSimpleTextProvider(text: "Assignment 2")
			handler(template)
		} else if complication.family == .modularSmall {
			let template = CLKComplicationTemplateModularSmallStackText()
			template.line1TextProvider = CLKSimpleTextProvider(text: "--")
			template.line2TextProvider = CLKSimpleTextProvider(text: "DUE")
			handler(template)
		} else if complication.family == .utilitarianLarge {
			let template = CLKComplicationTemplateUtilitarianLargeFlat()
			template.textProvider = CLKSimpleTextProvider(text: "-- Due Tomorrow", shortText: "-- Due")
			handler(template)
		} else if complication.family == .utilitarianSmall {
			let template = CLKComplicationTemplateUtilitarianSmallFlat()
			template.textProvider = CLKSimpleTextProvider(text: "-- Due", shortText: "--")
			handler(template)
		}
		handler(nil)
	}

	func requestedUpdateDidBegin() {
		(WKExtension.shared().delegate as? ExtensionDelegate)?.sendMessage(["assignments": ""], replyHandler: { reply in
			if let data = reply["assignments"] as? Data {
				if let assignments = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Date: [SchoolLoopAssignment]] {
					self.assignments = assignments
					let server = CLKComplicationServer.sharedInstance()
					for complication in server.activeComplications! {
						server.reloadTimeline(for: complication)
					}
				}
			}
			}, errorHandler: { error in
			print(error)
		})
	}
}
