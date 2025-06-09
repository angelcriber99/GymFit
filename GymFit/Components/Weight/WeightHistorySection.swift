import SwiftUI

struct WeightHistorySection: View {
    @ObservedObject var weightStore: WeightStore
    @State private var showingEditWeight = false
    @State private var showingDeleteAlert = false
    @State private var weightToEdit: WeightEntry?
    @State private var newWeight = ""
    @State private var selectedDate = Date()
    @FocusState private var isWeightFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Historial de Pesos")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if weightStore.weights.isEmpty {
                Text("No hay registros de peso")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(weightStore.weights.sorted(by: { $0.date > $1.date })) { entry in
                    WeightHistoryRow(entry: entry) {
                        weightToEdit = entry
                        newWeight = String(format: "%.1f", entry.weight)
                        selectedDate = entry.date
                        showingEditWeight = true
                    } onDelete: {
                        weightToEdit = entry
                        showingDeleteAlert = true
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay {
            if showingEditWeight {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isWeightFocused = false
                        showingEditWeight = false
                    }
                
                WeightInputPopup(
                    weight: $newWeight,
                    date: $selectedDate,
                    isFocused: _isWeightFocused,
                    onSave: {
                        if let entry = weightToEdit {
                            weightStore.updateWeight(entry.id, newWeight: Double(newWeight.replacingOccurrences(of: ",", with: ".")) ?? 0, newDate: selectedDate)
                        }
                        showingEditWeight = false
                    },
                    onDismiss: { 
                        showingEditWeight = false
                    },
                    isEditing: true
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: showingEditWeight)
        .alert("¿Eliminar registro?", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let entry = weightToEdit {
                    weightStore.removeWeight(withId: entry.id)
                }
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
    }
}

struct WeightHistoryRow: View {
    let entry: WeightEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.1f kg", entry.weight))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 