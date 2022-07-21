////
////  Collapsible.swift
////  E4tester
////
////  Created by Waley Zheng on 7/13/22.
////  Copyright © 2022 Felipe Castro. All rights reserved.
////
//
//import SwiftUI
//
//struct Collapsible<Content: View>: View {
//    @State var label: () -> Text
//    @State var content: () -> Content
//    
//    @State private var collapsed: Bool = true
//    
//    var body: some View {
//        VStack {
//            Button(
//                action: { self.collapsed.toggle() },
//                label: {
//                    HStack {
//                        self.label()
//                        Spacer()
////                        Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
//                    }
//                    .padding(.bottom, 1)
//                    .background(Color.white.opacity(0.01))
//                }
//            )
//            .buttonStyle(PlainButtonStyle())
//            
//            
//            self.content()
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: collapsed ? 0 : 100, maxHeight: collapsed ? 0 : .infinity)
////            .clipped()
////            .animation(.easeOut)
////            .transition(.slide)
//        }
//    }
//}
