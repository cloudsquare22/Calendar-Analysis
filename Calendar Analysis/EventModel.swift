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
        let predicate = eventStore.predicateForEvents(withStart: from, end: to, calendars: [calendar])
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
        var fromdc = Calendar.current.dateComponents(in: .current, from: from)
        var todc = Calendar.current.dateComponents(in: .current, from: to)
        fromdc.hour = 0
        fromdc.minute = 0
        fromdc.second = 0
        todc.hour = 23
        todc.minute = 59
        todc.second = 59
        let alltime = (todc.date!.timeIntervalSince(fromdc.date!) + 1.0) / 60
        print(fromdc)
        print(todc)
        print("alltime:\(alltime)")
        self.analysis = "\(sumtime) min \(round(sumtime / alltime * 100)) %"
    }

}
