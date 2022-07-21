//
//  LoginView.swift
//  E4tester
//
//  Created by Waley Zheng on 7/20/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        VStack{
            FloatingLabelInput(label: "Name", text: $modelData.user.fullname)
            Button{
                print("clicked")
                Task {
                    await modelData.queryName()
                    modelData.nameEntered = true
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(ModelData())
    }
}
