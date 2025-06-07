import SwiftUI
import Charts

struct WeightTrackingView: View {
    @EnvironmentObject private var weightStore: WeightStore
    @State private var showingWeightEntry = false
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: WeightEntry?
    @State private var selectedEntry: WeightEntry?
    
    enum TimeFrame: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case year = "Año"
        case all = "Todo"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SummaryCard(weightStore: weightStore, accentColor: .blue)
                
                Picker("Período", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                WeightChartView(
                    entries: filteredEntries,
                    selectedEntry: selectedEntry,
                    onEntrySelected: { selectedEntry = $0 }
                )
                
                if let entry = selectedEntry {
                    SelectedEntryDetail(
                        entry: entry,
                        onDismiss: { selectedEntry = nil }
                    )
                }
                
                RecentEntriesList(
                    entries: weightStore.entries,
                    onDelete: { entry in
                        entryToDelete = entry
                        showingDeleteAlert = true
                    }
                )
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mi Progreso")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingWeightEntry = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingWeightEntry) {
            NavigationView {
                WeightEntryForm(weightStore: weightStore) {
                    showingWeightEntry = false
                }
                .navigationTitle("Nuevo Registro")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert("¿Eliminar registro?", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let entry = entryToDelete {
                    weightStore.deleteEntry(entry)
                }
            }
        } message: {
            if let entry = entryToDelete {
                Text("¿Estás seguro de que quieres eliminar el registro del \(entry.date.formatted(date: .long, time: .omitted))?")
            }
        }
    }
    
    private var filteredEntries: [WeightEntry] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeFrame {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .all:
            return weightStore.entries
        }
        
        return weightStore.entries.filter { $0.date >= startDate }
    }
} 