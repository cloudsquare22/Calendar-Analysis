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
        let alltime = to.timeIntervalSince(from)
        var sumtime: Double = 0.0
        for event in events {
            print(event.title!)
            if event.isAllDay == false {
                let diff = event.endDate.timeIntervalSince(event.startDate)
                sumtime = sumtime + diff
            }
        }
        self.analysis = "\(sumtime / 60) min \(round(sumtime / alltime * 100)) %"
    }

}
