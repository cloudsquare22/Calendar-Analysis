//
//  ContentView.swift
//  Calendar Analysis
//
//  Created by Shin Inaba on 2021/12/23.
//

import SwiftUI
import CoreData

struct AnalysisView: View {
    @EnvironmentObject var eventsModel: EventsModel
    @State var selectCalendar = 0
    @State var fromdate: Date = Date()
    @State var todate: Date = Date()
    @State var isErrorFromto = false

    var body: some View {
        VStack {
            Text("Calendar Analysys")
                .font(.largeTitle)
            Picker("Calendar", selection: self.$selectCalendar, content: {
                ForEach(0..<self.eventsModel.calendars.count) { index in
                    Text(self.eventsModel.calendars[index].title)
                        .tag(index)
                }
            })
                .pickerStyle(.menu)
            HStack {
                Button(action: {
                    (self.fromdate, self.todate) = self.eventsModel.thisWeek(interval: 604_800)
                },
                       label: {
                    Text("Last week")
                })
                    .buttonStyle(.borderedProminent)
                Button(action: {
                    (self.fromdate, self.todate) = self.eventsModel.thisWeek()
                },
                       label: {
                    Text("This week")
                })
                    .buttonStyle(.borderedProminent)
                Button(action: {
                    (self.fromdate, self.todate) = self.eventsModel.thisMonth()
                },
                       label: {
                    Text("This month")
                })
                    .buttonStyle(.borderedProminent)
                Button(action: {
                    (self.fromdate, self.todate) = self.eventsModel.thisYear()
                },
                       label: {
                    Text("This year")
                })
                    .buttonStyle(.borderedProminent)
            }
            DatePicker("From", selection: self.$fromdate, displayedComponents: [.date])
                .datePickerStyle(.compact)
            DatePicker("To", selection: self.$todate, displayedComponents: [.date])
                .datePickerStyle(.compact)
            Button(action: {
                if self.fromdate <= self.todate {
                    self.eventsModel.actionAnalysis(from: fromdate, to: todate, calendar: self.eventsModel.calendars[self.selectCalendar])
                }
                else {
                    self.isErrorFromto = true
                }
            }, label: {
                Text("Analysis")
            })
                .buttonStyle(.borderedProminent)
            Text(self.eventsModel.analysis)
        }
        .alert(isPresented: self.$isErrorFromto) {
                Alert(
                    title: Text("Date"),
                    message: Text("from > to"))
        }
    }
        

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
