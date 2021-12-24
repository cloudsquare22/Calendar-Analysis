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
    
    init() {
        self.getCalendars()
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
    
    func thisWeek() -> (Date, Date) {
        var resultFrom = Date()
        let matchingMonday = DateComponents(weekday: 2)
        let weekday = Calendar.current.component(.weekday, from: resultFrom)
        if weekday != 2 {
            resultFrom = Calendar.current.nextDate(after: resultFrom, matching: matchingMonday, matchingPolicy: .nextTime, direction: .backward)!
        }
        var resultTo = Date()
        let matchingSunday = DateComponents(weekday: 1)
        if weekday != 1 {
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

}
