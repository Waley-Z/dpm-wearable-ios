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
    var peer: Peer
    @State private var showDetail = false
    let timer = Timer.publish(every: 5,tolerance: 10, on: .main, in: .common).autoconnect()
    @State var relativeDate: String = ""

    var body: some View {
        VStack {
            HStack {
                FatigueLevelGraph(peer: peer)
                    .frame(width: 50, height: 30)

                VStack(alignment: .leading) {
                    Text(peer.fullname)
                        .font(.headline)
                    HStack{
                        Text(String(peer.fatigue_level) + "%")
//                            .font(.callout)
                        Text(relativeDate)
                            .foregroundColor(.secondary)
                            .onReceive(timer) { _ in
                                print("update last_update")
                                self.relativeDate = Date(timeIntervalSince1970: Double(peer.last_update)).timeAgoDisplay()
                            }
                            .onAppear() {
                                self.relativeDate = Date(timeIntervalSince1970: Double(peer.last_update)).timeAgoDisplay()
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
                    VStack{
                        FatigueLevelGraph(peer: peer)
                            .frame(height: 200)
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
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .transition(.moveAndFade)
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

