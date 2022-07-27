//
//  CrewView.swift
//  E4tester
//
//  Created by Waley Zheng on 7/22/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct CrewView: View {
    @EnvironmentObject var modelData: ModelData
    
    let timer = Timer.publish(every: 60,tolerance: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack{
            ForEach (modelData.crew){peer in
                PeerView(peer: peer)
            }
        }
        .onReceive(timer) { _ in
            print("update crew")
            Task {
                await modelData.updateCrew()
            }
            
        }
        .onAppear {
            print("init")
            Task {
                await modelData.updateCrew()
            }
        }
    }
}

struct CrewView_Previews: PreviewProvider {
    static var previews: some View {
        CrewView()
            .environmentObject(ModelData())
    }
}
