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
    @State var filterString: String = ""

    var body: some View {
        VStack {
            Text("Calendar Analysys")
                .font(.largeTitle)
            HStack {
                Image(systemName: "calendar")
                Picker("Calendar", selection: self.$selectCalendar, content: {
                    ForEach(0..<self.eventsModel.calendars.count, id: \.self) { index in
                        Text(self.eventsModel.calendars[index].title)
                            .tag(index)
                    }
                })
                    .pickerStyle(.menu)
            }
            VStack {
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
                }
                HStack {
                    Button(action: {
                        (self.fromdate, self.todate) = self.eventsModel.thisMonth(isLastMonth: true)
                    },
                           label: {
                        Text("Last month")
                    })
                        .buttonStyle(.borderedProminent)
                    Button(action: {
                        (self.fromdate, self.todate) = self.eventsModel.thisMonth()
                    },
                           label: {
                        Text("This month")
                    })
                        .buttonStyle(.borderedProminent)
                }
                HStack {
                    Button(action: {
                        (self.fromdate, self.todate) = self.eventsModel.thisYear(isLastYear: true)
                    },
                           label: {
                        Text("Last year")
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
            }
            DatePicker("From", selection: self.$fromdate, displayedComponents: [.date])
                .datePickerStyle(.compact)
            DatePicker("To", selection: self.$todate, displayedComponents: [.date])
                .datePickerStyle(.compact)
            HStack {
                Image(systemName: "magnifyingglass")
                Spacer()
                TextField(text: self.$filterString, prompt: Text("Filter string"), label: {
                    
                })
            }
            Button(action: {
                if self.fromdate <= self.todate {
                    self.eventsModel.actionAnalysis(from: fromdate, to: todate, calendar: self.eventsModel.calendars[self.selectCalendar], filterString: self.filterString)
                }
                else {
                    self.isErrorFromto = true
                }
            }, label: {
                Text("Analysis")
            })
                .buttonStyle(.borderedProminent)
            AnalysisResultView()
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

struct AnalysisResultView: View {
    @EnvironmentObject var eventsModel: EventsModel
    
    var body: some View {
        HStack {
            Text("Total time")
            Spacer()
            Text(String(format: "%.0f", self.eventsModel.analysis.totaltimemin) + " min")
            Text(String(format: "%.1f", self.eventsModel.analysis.percent) + "%")
        }
        HStack {
            Text("All time")
            Spacer()
            Text(String(format: "%.0f", self.eventsModel.analysis.alltimemin) + " min")
        }
        HStack {
            Text("Event count")
            Spacer()
            Text(String(format: "%d", self.eventsModel.analysis.count))
        }
    }
}
