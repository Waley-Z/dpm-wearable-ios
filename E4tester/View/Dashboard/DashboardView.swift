//
//  DashboardView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        VStack{
            SwiftUIViewController()
                .frame(height: 50)
                .padding()
            
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
            
            Spacer()
        }
    }
}


struct SwiftUIViewController: UIViewControllerRepresentable {
    @EnvironmentObject var modelData: ModelData
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController(delegate: context.coordinator)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
    
    class Coordinator: NSObject, ViewControllerDelegate {
        func updateHeartRate(_ viewController: ViewController, heartRate: Int) {
            DispatchQueue.main.async{
                self.parent.modelData.heartRate = heartRate
            }
        }
        
        func updateFatigueLevel(_ viewController: ViewController, fatigueLevel: Int) {
            DispatchQueue.main.async {
                self.parent.modelData.fatigueLevel = fatigueLevel
            }
        }
        
        var parent: SwiftUIViewController
        
        init(_ swiftUIViewController: SwiftUIViewController) {
            parent = swiftUIViewController
        }
    }
    
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
