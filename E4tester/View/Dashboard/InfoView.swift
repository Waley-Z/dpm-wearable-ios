//
//  InfoView.swift
//  E4tester
//
//  Created by Waley Zheng on 7/13/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack{
            Text("\(self.modelData.heartRate)")
                .font(.system(size: 50, weight: .heavy))
            Text("BPM")
                .font(.system(size: 15))
        }
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: 200, height: 200)
        .background(Circle().fill(Color.white).shadow(radius: 3))
        .padding()
        
        VStack{
            Text("\(self.modelData.fatigueLevel)%")
                .font(.system(size: 50, weight: .heavy))
            Text("Fatigue Level")
                .font(.system(size: 15))
        }
        .font(.system(size: 50, weight: .heavy))
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: 200, height: 200)
        .background(Circle().fill(Color.white).shadow(radius: 3))
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
