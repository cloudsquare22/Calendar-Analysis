//
//  MainView.swift
//  Calendar Analysis
//
//  Created by Shin Inaba on 2021/12/26.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var eventsModel: EventsModel
    @State private var selection = 22

    var body: some View {
        TabView(selection: $selection) {
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)
            MyProductView()
                .tabItem {
                    Label("cloudsquare", image: "custom.keyboard.badge.clock")
                }
                .tag(22)
            SettingView()
                .tabItem {
                    Label("Setting", systemImage: "gear")
                }
                .tag(1)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
