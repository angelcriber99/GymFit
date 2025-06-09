import SwiftUI
import Charts

struct WeightTrackingView: View {
    @StateObject private var weightStore = WeightStore()
    @AppStorage("selectedTimeFrame") private var selectedTimeFrame: TimeFrame = .month
    @State private var animateChart = false
    @State private var showingWeightInput = false
    @State private var showingEditWeight = false
    @State private var newWeight = ""
    @State private var selectedDate = Date()
    @State private var weightToEdit: WeightEntry?
    @FocusState private var isWeightFocused: Bool
    
    var filteredEntries: [WeightEntry] {
        weightStore.weights.filter { entry in
            switch selectedTimeFrame {
            case .week:
                return Calendar.current.isDate(entry.date, equalTo: Date(), toGranularity: .weekOfYear)
            case .month:
                return Calendar.current.isDate(entry.date, equalTo: Date(), toGranularity: .month)
            case .year:
                return Calendar.current.isDate(entry.date, equalTo: Date(), toGranularity: .year)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SummaryCard(weightStore: weightStore)
                
                WeightChartSection(
                    entries: filteredEntries,
                    selectedTimeFrame: $selectedTimeFrame,
                    animate: animateChart
                )
                
                WeightHistorySection(weightStore: weightStore)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Registro de Peso")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { 
                    weightToEdit = nil
                    newWeight = ""
                    selectedDate = Date()
                    showingWeightInput = true 
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .overlay {
            if showingWeightInput || showingEditWeight {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isWeightFocused = false
                        showingWeightInput = false
                        showingEditWeight = false
                    }
                
                WeightInputPopup(
                    weight: $newWeight,
                    date: $selectedDate,
                    isFocused: _isWeightFocused,
                    onSave: {
                        if showingEditWeight, let entry = weightToEdit {
                            weightStore.updateWeight(entry.id, newWeight: Double(newWeight.replacingOccurrences(of: ",", with: ".")) ?? 0, newDate: selectedDate)
                        } else {
                            saveWeight()
                        }
                    },
                    onDismiss: { 
                        showingWeightInput = false
                        showingEditWeight = false
                    },
                    isEditing: showingEditWeight
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: showingWeightInput)
        .animation(.spring(), value: showingEditWeight)
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.spring()) {
                animateChart = true
            }
        }
    }
    
    private var isValidWeight: Bool {
        guard let weightValue = Double(newWeight.replacingOccurrences(of: ",", with: ".")) else {
            return false
        }
        return weightValue > 0 && weightValue < 500
    }
    
    private func saveWeight() {
        guard let weightValue = Double(newWeight.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        
        weightStore.addWeight(weightValue, date: selectedDate)
        newWeight = ""
        showingWeightInput = false
        
        withAnimation(.spring()) {
            animateChart = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateChart = true
            }
        }
    }
}

enum TimeFrame: String, CaseIterable {
    case week = "Semana"
    case month = "Mes"
    case year = "Año"
} 