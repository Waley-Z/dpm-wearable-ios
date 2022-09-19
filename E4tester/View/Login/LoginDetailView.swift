//
//  LoginDetailView.swift
//  E4tester
//
//  Created by Waley Zheng on 7/20/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct LoginDetailView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack{
            FloatingLabelInput(label: "First Name", text: $modelData.user.first_name)
            FloatingLabelInput(label: "Last Name", text: $modelData.user.last_name)
            FloatingLabelInput(label: "Group ID", text: $modelData.user.group_id)
            FloatingLabelInput(label: "Age", text: $modelData.inputs.age)
            FloatingLabelInput(label: "Rest Heart Rate", text: $modelData.inputs.rest_heart_rate)
            FloatingLabelInput(label: "Heart Rate Reserve CP", text: $modelData.inputs.hrr_cp)
            FloatingLabelInput(label: "Total AWC", text: $modelData.inputs.awc_tot)
            FloatingLabelInput(label: "K-Value", text: $modelData.inputs.k_value)
            
            Button{
                print("clicked")
                Task {
                    await modelData.uploadUserInfo()
                }
            } label: {
                Text("Log In / Sign Up")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(width: 180, height: 15)
                    .padding()
                    .background(Color("PrimaryColorMaize"))
                    .cornerRadius(10)
            }
            .padding(.vertical)
        }
    }
}

struct LoginDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LoginDetailView()
            .environmentObject(ModelData())
    }
}
