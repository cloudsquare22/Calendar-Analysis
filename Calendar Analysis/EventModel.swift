//
//  EventModel.swift
//  Calendar Analysis
//
//  Created by Shin Inaba on 2021/12/23.
//

import SwiftUI
import EventKit

class EventsModel: ObservableObject {
    let eventStore = EKEventStore()
    @Published var calendars: [EKCalendar] = []
    @Published var analysis: Analysis = Analysis()
    @Published var firstWeekday: Int = 2
    
    let userdefault = UserDefaults.standard

    init() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: .EKEventStoreChanged, object: eventStore, queue: nil, using: { notification in
            print("EKEventStoreChanged")
            self.getCalendars()
        })
        self.getCalendars()
        self.load()
    }

    func load() {
        if let firstWeekday = userdefault.object(forKey: "firstWeekday") as? Int {
            self.firstWeekday = firstWeekday
        }
    }

    func save() {
        self.userdefault.set(self.firstWeekday, forKey: "firstWeekday")
    }

    func getCalendars() {
        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            return
        }
        let calendars = eventStore.calendars(for: .event)
        print(calendars)
        for calendar in calendars {
            print(calendar.title)
            print(calendar.type.rawValue)
        }
        self.calendars = calendars.filter({ c in c.type.rawValue < 4 }).sorted(by: {(c1, c2) in c1.title < c2.title})
        print(self.calendars)
    }
    
    func actionAnalysis(from: Date, to: Date, calendar: EKCalendar, filterString: String = "") {
        var fromdc = Calendar.current.dateComponents(in: .current, from: from)
        var todc = Calendar.current.dateComponents(in: .current, from: to)
        fromdc.hour = 0
        fromdc.minute = 0
        fromdc.second = 0
        todc.hour = 23
        todc.minute = 59
        todc.second = 59
        let predicate = eventStore.predicateForEvents(withStart: fromdc.date!, end: todc.date!, calendars: [calendar])
        let events = eventStore.events(matching: predicate)
        var sumtime: Double = 0.0
        var count: Int = 0
        for event in events {
            print(event.title!)
            if event.isAllDay == true {
                continue
            }
            if filterString.isEmpty == false, event.title.contains(filterString) == false {
                continue
            }
            let diff = event.endDate.timeIntervalSince(event.startDate)
            sumtime = sumtime + diff
            count = count + 1
        }
        sumtime = sumtime / 60
        let alltime = (todc.date!.timeIntervalSince(fromdc.date!) + 1.0) / 60
        print(fromdc)
        print(todc)
        print("alltime:\(alltime)")
        self.analysis.totaltimemin = sumtime
        self.analysis.alltimemin = alltime
        self.analysis.percent = sumtime / alltime * 100
        self.analysis.count = count
    }
    
    func thisWeek(interval: Double = 0.0) -> (Date, Date) {
        var resultFrom = Date() - TimeInterval(interval)
        let matchingMonday = DateComponents(weekday: self.firstWeekday)
        let weekday = Calendar.current.component(.weekday, from: resultFrom)
        if weekday != self.firstWeekday {
            resultFrom = Calendar.current.nextDate(after: resultFrom, matching: matchingMonday, matchingPolicy: .nextTime, direction: .backward)!
        }
        let endweekday = (self.firstWeekday + 7 - 1) == 7 ? 7 : (self.firstWeekday + 7 - 1) % 7
        print("\(self.firstWeekday)...\(endweekday)")
        var resultTo = Date() - TimeInterval(interval)
        let matchingSunday = DateComponents(weekday: endweekday)
        if weekday != endweekday {
            resultTo = Calendar.current.nextDate(after: resultFrom, matching: matchingSunday, matchingPolicy: .nextTime, direction: .forward)!
        }
        return (resultFrom, resultTo)
    }
    
    func thisMonth(isLastMonth: Bool = false) -> (Date, Date) {
        var resultFrom = Date()
        var resultTo = Date()
        var fromdc = Calendar.current.dateComponents(in: .current, from: resultFrom)
        var todc = Calendar.current.dateComponents(in: .current, from: resultFrom)
        if isLastMonth == false {
            fromdc.month = fromdc.month!
            fromdc.day = 1
            todc.month = todc.month! + 1
            todc.day = 0
        }
        else {
            fromdc.month = fromdc.month! - 1 == 0 ? 12 : fromdc.month! - 1
            fromdc.day = 1
            fromdc.year = fromdc.month! - 1 == 0 ? fromdc.year! - 1 : fromdc.year
            todc.month = todc.month!
            todc.day = 0
        }
        resultFrom = fromdc.date!
        resultTo = todc.date!
        return (resultFrom, resultTo)
    }

    func thisYear(isLastYear: Bool = false) -> (Date, Date) {
        var resultFrom = Date()
        var resultTo = Date()
        var fromdc = Calendar.current.dateComponents(in: .current, from: resultFrom)
        fromdc.month = 1
        fromdc.day = 1
        fromdc.weekOfYear = 1
        print(fromdc)
        var todc = Calendar.current.dateComponents(in: .current, from: resultFrom)
        todc.month = 12
        todc.day = 31
        if isLastYear == false {
            fromdc.yearForWeekOfYear = fromdc.year
        }
        else {
            fromdc.year = fromdc.year! - 1
            fromdc.yearForWeekOfYear = fromdc.year
            todc.year = todc.year
            todc.yearForWeekOfYear = todc.year
            todc.month = 1
            todc.day = 0
            print(fromdc)
            print(todc)
        }
        resultFrom = fromdc.date!
        resultTo = todc.date!
        return (resultFrom, resultTo)
    }
}

struct Analysis {
    var totaltimemin: Double = 0.0
    var alltimemin: Double = 0.0
    var percent: Double = 0.0
    var count: Int = 0
}
