//
//  ContentView.swift
//  Calendar Analysis
//
//  Created by Shin Inaba on 2021/12/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @EnvironmentObject var eventsModel: EventsModel
    @State var selectCalendar = 0
    @State var fromdate: Date = Date()
    @State var todate: Date = Date()

    var body: some View {
        VStack {
            Text("Calendar Analysys")
            Picker("Calendar", selection: self.$selectCalendar, content: {
                ForEach(0..<self.eventsModel.calendars.count) { index in
                    Text(self.eventsModel.calendars[index].title)
                        .tag(index)
                }
            })
                .pickerStyle(.wheel)
            DatePicker("From", selection: self.$fromdate, displayedComponents: [.date])
                .datePickerStyle(.compact)
            DatePicker("To", selection: self.$todate, displayedComponents: [.date])
                .datePickerStyle(.compact)
            Button(action: {
                self.eventsModel.actionAnalysis(from: fromdate, to: todate, calendar: self.eventsModel.calendars[self.selectCalendar])
            }, label: {
                Text("Analysis")
            })
                .buttonStyle(.borderedProminent)
            Text(self.eventsModel.analysis)
        }
    }
        

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
