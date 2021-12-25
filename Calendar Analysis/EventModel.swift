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
    @Published var analysis: String = ""
    @Published var firstWeekday: Int = 2
    
    let userdefault = UserDefaults.standard

    init() {
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
        self.calendars = eventStore.calendars(for: .event)
        print(self.calendars)
    }
    
    func actionAnalysis(from: Date, to: Date, calendar: EKCalendar) {
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
        for event in events {
            print(event.title!)
            if event.isAllDay == false {
                let diff = event.endDate.timeIntervalSince(event.startDate)
                sumtime = sumtime + diff
            }
        }
        sumtime = sumtime / 60
        let alltime = (todc.date!.timeIntervalSince(fromdc.date!) + 1.0) / 60
        print(fromdc)
        print(todc)
        print("alltime:\(alltime)")
        self.analysis = "\(sumtime) min \(round(sumtime / alltime * 100)) %"
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
    
    func thisMonth() -> (Date, Date) {
        var resultFrom = Date()
        var resultTo = Date()
        var fromdc = Calendar.current.dateComponents(in: .current, from: resultFrom)
        fromdc.day = 1
        var todc = Calendar.current.dateComponents(in: .current, from: resultFrom)
        todc.month = todc.month! + 1
        todc.day = 0
        resultFrom = fromdc.date!
        resultTo = todc.date!
        return (resultFrom, resultTo)
    }

    func thisYear() -> (Date, Date) {
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
        resultFrom = fromdc.date!
        resultTo = todc.date!
        return (resultFrom, resultTo)
    }
}
