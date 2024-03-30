//
//  MyProductView.swift
//  Calendar Analysis
//
//  Created by Shin Inaba on 2024/03/30.
//

import SwiftUI

struct MyProductView: View {
    @EnvironmentObject
    var eventsModel: EventsModel
    
    @State
    var thisWeekAnalysis: Analysis = Analysis()
    
    @State
    var thisWeekDate: String = ""

    @State
    var lastWeekAnalysis: Analysis = Analysis()

    @State
    var lastWeekDate: String = ""

    fileprivate func updateAnalysis() {
        let thisWeek = self.eventsModel.thisWeek()
        let lastWeek = self.eventsModel.thisWeek(interval: 604_800)
        self.thisWeekAnalysis = self.eventsModel.actionAnalysis(from: thisWeek.0,
                                                                to: thisWeek.1,
                                                                calendar: self.eventsModel.calendars.last!)
        self.thisWeekAnalysis.alltimemin = 60 * 20
        self.thisWeekDate = self.dispDate(from: thisWeek.0, to: thisWeek.1)
        self.lastWeekAnalysis = self.eventsModel.actionAnalysis(from: lastWeek.0,
                                                                to: lastWeek.1,
                                                                calendar: self.eventsModel.calendars.last!)
        self.lastWeekAnalysis.alltimemin = 60 * 20
        self.lastWeekDate = self.dispDate(from: lastWeek.0, to: lastWeek.1)
     }
    
    fileprivate func dispDate(from: Date, to: Date) -> String {
        let dateFormatterFrom = DateFormatter()
        dateFormatterFrom.dateFormat = "M/d 〜"
        dateFormatterFrom.locale = .current
        let dateFormatterTo = DateFormatter()
        dateFormatterTo.dateFormat = " M/d"
        dateFormatterTo.locale = .current
        return dateFormatterFrom.string(from: from) + dateFormatterTo.string(from: to)
    }
    
    fileprivate func changeKaomoji(totaltimemin: Double) -> String {
        var kaomoji: String = "😵"
        if totaltimemin >= 1200 {
            kaomoji = "😀"
        }
        else if totaltimemin >= 600 {
            kaomoji = "😣"

        }
        return kaomoji
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Por lo que debería ser.")
                    .font(.title)
                Text("1200 min")
                    .font(.title)
            }
            .padding(16.0)
            VStack {
                Text(self.lastWeekDate)
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text("\(String(format: "%.0f", self.lastWeekAnalysis.totaltimemin)) min (\(String(format: "%.1f", self.lastWeekAnalysis.percent))%)")
                Text("\(self.changeKaomoji(totaltimemin: self.lastWeekAnalysis.totaltimemin))")
                    .font(.largeTitle)
                ProgressView(value: self.lastWeekAnalysis.totaltimemin,
                             total: self.lastWeekAnalysis.alltimemin)
                .tint(.orange)
            }
            .padding(16.0)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange, lineWidth: 1)
            }
            VStack {
                Text(self.thisWeekDate)
                    .font(.title3)
                    .foregroundStyle(.green)
                Text("\(String(format: "%.0f", self.thisWeekAnalysis.totaltimemin)) min (\(String(format: "%.1f", self.thisWeekAnalysis.percent))%)")
                Text("\(self.changeKaomoji(totaltimemin: self.thisWeekAnalysis.totaltimemin))")
                    .font(.largeTitle)
                ProgressView(value: self.thisWeekAnalysis.totaltimemin,
                             total: self.thisWeekAnalysis.alltimemin)
                .tint(.green)
            }
            .padding(16.0)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green, lineWidth: 1)
            }
            VStack {
                Button("Refresh", systemImage: "arrow.circlepath", action: {
                    self.updateAnalysis()
                })
                .buttonStyle(.borderedProminent)

            }
            .padding(16.0)
            Spacer()
        }
        .padding(16.0)
        .onAppear {
            self.updateAnalysis()
        }
    }
}

#Preview {
    MyProductView()
}
