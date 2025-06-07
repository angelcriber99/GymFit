import SwiftUI

struct ContentView: View {
    @StateObject private var weightStore = WeightStore()
    
    var body: some View {
        NavigationView {
            WeightTrackingView()
                .environmentObject(weightStore)
        }
    }
}

#Preview {
    ContentView()
} 