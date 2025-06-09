//
//  GymFitApp.swift
//  GymFit
//
//  Created by angel on 6/6/25.
//

import SwiftUI

@main
struct GymFitApp: App {
    @StateObject private var weightStore = WeightStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WeightTrackingView()
                    .environmentObject(weightStore)
            }
        }
    }
}
