////
////  FloatingLabelInputInt.swift
////  E4tester
////
////  Created by Waley Zheng on 7/20/22.
////  Copyright © 2022 Felipe Castro. All rights reserved.
////
//
//import SwiftUI
//
//struct FloatingLabelInputInt: View {
//    var label: String
//    @Binding var text: Int
//    
//    init(label: String, text: Binding<Int>) {
//        self.label = label
//        self._text = text
//    }
//    
//    var body: some View {
//        ZStack(alignment: .leading) {
//            Text(self.label)
//                .foregroundColor(self.text.isEmpty ? Color.gray : Color.gray.opacity(0.5))
//                .offset(x: 0,
//                        y: self.text.isEmpty ? 0 : -20)
//                .scaleEffect(self.text.isEmpty ? 1 : 0.8, anchor: .topLeading)
//                .animation(.easeIn(duration: 0.1))
//            TextField("", text: self.$text)
//                .font(Font.headline.weight(.medium))
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .frame(width: 330, height: 60)
//        .background(Color.white)
//        .cornerRadius(10.0)
//        .shadow(color:Color.black.opacity(0.08), radius: 60)
//    }
//}
//
//struct FloatingLabelInputInt_PreviewsWrapper: View {
//    @State private var text: Int = 10
//    var body: some View {
//        FloatingLabelInputInt(label: "Label", text: $text)
//    }
//}
//
//struct FloatingLabelInputInt_Previews: PreviewProvider {
//    static var previews: some View {
//        FloatingLabelInputInt_PreviewsWrapper()
//    }
//}
