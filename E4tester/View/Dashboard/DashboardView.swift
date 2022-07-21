//
//  DashboardView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    
    var body: some View {

        ScrollView{
            VStack{
                SwiftUIViewController()
                    .frame(height: 50)
                    .padding()
                
                InfoView()
                
                Spacer()
//                CollapsibleView()
            }
        }
    }
}


struct SwiftUIViewController: UIViewControllerRepresentable {
    @EnvironmentObject var modelData: ModelData
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController(delegate: context.coordinator,
                                            max_heart_rate: modelData.user.max_heart_rate,
                                            rest_heart_rate: modelData.user.rest_heart_rate,
                                            hrr_cp: modelData.user.hrr_cp,
                                            awc_tot: modelData.user.awc_tot,
                                            k_value: modelData.user.k_value
        
        )
//        viewController.delegate = context.coordinator
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
