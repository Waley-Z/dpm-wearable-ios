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
    
    var body: some View {
        // ver. 1
        //        VStack{
        //            ForEach (modelData.crew){peer in
        //                PeerView(peer: peer)
        //            }
        //        }
        
        VStack{
            HStack{
                Spacer()
                ForEach(Array(modelData.crew.enumerated()), id: \.element) { index, peer in
                    Circle()
                        .fill(Color.getColor(withIndex: index))
                        .frame(width: 8, height: 8)
                    Text(peer.first_name)
                    Spacer()
                }
            }
            .font(.system(size: 16, weight: .medium))
//            .foregroundColor(.secondary)
            .transition(.moveAndFade)
            .frame(height: 15)
            .padding(.bottom, 5)
            
            HStack{
                Text("Fatigue Level")
                    .rotationEffect(.degrees(270))
                    .fixedSize()
                    .frame(width: 10, height: 90)
                    .font(.system(size: 16))
                VStack{
                    Text("100%")
                    Spacer()
                    Text("75%")
                    Spacer()
                    Text("50%")
                    Spacer()
                    Text("25%")
                    Spacer()
                    Text("0%")
                    HStack{
                        Text("")
                    }
                }
                //                    .border(Color.gray)
                // ver 2.1
                VStack{
                    MultiLineChartView(peers: modelData.crew)
                        .frame(height: 280)
                    //                .border(.green)
                    // ver. 2.0
                    //                ZStack{
                    //                    ForEach(Array(modelData.crew.enumerated()), id: \.element) { index, peer in
                    //                        LineChartView(peer: peer, radius: 2)
                    //                            .accentColor(Color.Colors[index % 6])
                    //                    }
                    //                }
                    //                .frame(height: 300)
                    //                .border(.gray)
                    HStack() {
                        LabelView
                    }
                    //                        .border(Color.gray)
                    
                }
            }
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .transition(.moveAndFade)
        }
    }

    var LabelView: some View {
        Group {
            Spacer()
            HStack {
                Text("7am")
                Spacer()
                Text("9am")
                Spacer()
                Text("11am")
                Spacer()
                Text("1pm")
                Spacer()
                Text("3pm")
            }
            Spacer()
        }
    }
}


struct CrewView_Previews: PreviewProvider {
    static var previews: some View {
        CrewView()
            .environmentObject(ModelData())
    }
}
