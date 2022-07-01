//
//  E4 tester
//
//

import SwiftUI

@main
struct DPMApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var modelData = ModelData()
    
    init() {
        print("EmpaticaAPI initialized")
        EmpaticaAPI.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                print("App is active")
                EmpaticaAPI.prepareForResume()
            case .inactive:
                print("App is inactive")
            case .background:
                print("App is in background")
                EmpaticaAPI.prepareForBackground()
            @unknown default:
                print("Oh - interesting: I received an unexpected new value.")
            }
        }
    }
}
