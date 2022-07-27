//
//  FriendsView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        Button{
            print("clicked")
            modelData.nameEntered = false
            modelData.loggedIn = false
            modelData.userCreated = false
        } label: {
            Text("Log Out")
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .frame(width: 180, height: 15)
                .padding()
                .background(Color("PrimaryColorMaize"))
                .cornerRadius(10)
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ModelData())
    }
}
