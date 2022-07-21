//
//  ContentView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/18/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var selection: Tab = .dashboard
    
    enum Tab {
        case dashboard
        case profile
    }
    
    var body: some View {
        if modelData.loggedIn {
            TabView(selection: $selection) {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "heart.text.square")
                    }
                    .tag(Tab.dashboard)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(Tab.profile)
            }
        } else if !modelData.nameEntered {
            LoginView()
        } else {
            LoginDetailView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
