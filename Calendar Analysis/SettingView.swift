//
//  SettingView.swift
//  Calendar Analysis
//
//  Created by Shin Inaba on 2021/12/26.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var eventsModel: EventsModel
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

    var body: some View {
        NavigationView {
            Form {
                Section(header: Label("Calendar", systemImage: "calendar")) {
                    Picker(selection: self.$eventsModel.firstWeekday, content: {
                        ForEach(1..<8) { index in
                            Text(Calendar.current.weekdaySymbols[index - 1])
                                .tag(index)
                        }
                    }, label: {
                        Text("1st weekday")
                    })
                        .onChange(of: self.eventsModel.firstWeekday) { old, new in
                            self.eventsModel.save()
                        }
                }
                Section(header: Text("About")) {
                    VStack {
                        HStack {
                            Spacer()
//                            Image("neCal")
//                                .cornerRadius(16)
//                                .padding(8.0)
                            VStack(){
                                Text("Calendar Analysis")
                                    .font(.largeTitle)
                                Text("Version \(version)")
                            }
                            .padding(8.0)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Image("cloudsquare")
                            Text("©️ 2021-2023 cloudsquare.jp")
                                .font(.footnote)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
//            .padding(8)
            .navigationTitle("Setting")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
