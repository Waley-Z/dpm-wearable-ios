//
//  PeerView.swift
//  E4tester
//
//  Created by Waley Zheng on 7/22/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
    }
}

struct PeerView: View {
    @EnvironmentObject var modelData: ModelData

    var peer: Peer
    @State private var showDetail = false
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State var relativeDate: String = ""

    func fatigueLevelDisplay(fatigue_level: Int) -> String {
        if (fatigue_level == -1) {
            return "N/A"
        } else if (fatigue_level >= 100) {
            return "100%"
        } else {
            return String(fatigue_level) + "%"
        }
    }
    
    func relativeDateDisplay(last_update: Int) -> String {
        if (last_update < 1662472360){
            return ""
        } else {
            return Date(timeIntervalSince1970: Double(last_update)).timeAgoDisplay()
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                FatigueLevelGraph(peer: peer)
                    .frame(width: 50, height: 30)

                VStack(alignment: .leading) {
                    Text(peer.first_name)
                        .font(.headline)
                    HStack{
                        Text(fatigueLevelDisplay(fatigue_level: peer.fatigue_level))
//                            .font(.callout)
                        Text(relativeDate)
                            .foregroundColor(.secondary)
                            .onReceive(timer) { _ in
                                print("update peer last_update")
                                self.relativeDate = relativeDateDisplay(last_update: peer.last_update)
                            }
                            .onAppear() {
                                self.relativeDate = relativeDateDisplay(last_update: peer.last_update)
                            }
                    }
                }

                Spacer()

                Button {
                    withAnimation {
                        showDetail.toggle()
                    }
                } label: {
                    Label("Graph", systemImage: "chevron.right.circle")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .rotationEffect(.degrees(showDetail ? 90 : 0))
                        .scaleEffect(showDetail ? 1.5 : 1)
                        .padding()
                }
            }

            if showDetail {
                HStack{
                    Text("Fatigue Level")
                        .rotationEffect(.degrees(270))
                        .fixedSize()
                        .frame(width: 10, height: 90)
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
                    VStack{
                        FatigueLevelGraph(peer: peer)
                            .frame(height: 200)
//                            .border(Color.gray)
                        HStack() {
                            Text("6am")
                            Spacer()
                            Text("9am")
                            Spacer()
                            Text("12pm")
                            Spacer()
                            Text("3pm")
                            Spacer()
                        }
//                        .border(Color.gray)

                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .transition(.moveAndFade)
                .onAppear() {
                    Task {
                        await modelData.uploadActivity(peer_id: peer.id, if_open: true)
                    }
                }
                .onDisappear() {
                    Task {
                        await modelData.uploadActivity(peer_id: peer.id, if_open: false)
                    }
                }
            }
        }
    }
}

//struct PeerView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            HikeView(hike: ModelData().hikes[0])
//                .padding()
//            Spacer()
//        }
//    }
//}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

