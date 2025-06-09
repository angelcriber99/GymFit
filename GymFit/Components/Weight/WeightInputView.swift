import SwiftUI

struct WeightInputView: View {
    @ObservedObject var weightStore: WeightStore
    @State private var weight: String = ""
    @State private var selectedDate: Date
    @State private var showingDatePicker = false
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(weightStore: WeightStore, editingWeight: WeightEntry? = nil) {
        self.weightStore = weightStore
        _selectedDate = State(initialValue: editingWeight?.date ?? Date())
        _weight = State(initialValue: editingWeight.map { String(format: "%.1f", $0.weight) } ?? "")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con fecha
            VStack(spacing: 8) {
                Button(action: { showingDatePicker.toggle() }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        
                        Text(selectedDate.formatted(date: .long, time: .omitted))
                            .font(.title3)
                            .foregroundColor(.primary)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(showingDatePicker ? 180 : 0))
                    }
                }
                
                if showingDatePicker {
                    DatePicker(
                        "Seleccionar fecha",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .systemBackground))
            
            // Campo de peso
            VStack(spacing: 24) {
                Text("Ingresa tu peso")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    TextField("0.0", text: $weight)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .focused($isFocused)
                        .frame(width: 200)
                    
                    Text("kg")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                
                if let lastWeight = weightStore.weights.last {
                    let difference = (Double(weight.replacingOccurrences(of: ",", with: ".")) ?? 0) - lastWeight.weight
                    if difference != 0 {
                        Text(difference > 0 ? "+\(String(format: "%.1f", difference))" : String(format: "%.1f", difference))
                            .font(.title3)
                            .foregroundColor(difference > 0 ? .red : .green)
                    }
                }
            }
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .systemGroupedBackground))
            
            // Botón de guardar
            Button(action: saveWeight) {
                Text("Guardar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidWeight ? Color.blue : Color.gray)
            }
            .disabled(!isValidWeight)
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear {
            isFocused = true
        }
        .animation(.spring(), value: showingDatePicker)
    }
    
    private var isValidWeight: Bool {
        guard let weightValue = Double(weight.replacingOccurrences(of: ",", with: ".")) else {
            return false
        }
        return weightValue > 0 && weightValue < 500
    }
    
    private func saveWeight() {
        guard let weightValue = Double(weight.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        
        weightStore.addWeight(weightValue, date: selectedDate)
        dismiss()
    }
}

struct NumberButton: View {
    let number: Int
    var isDecimal: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if isDecimal {
                Text(".")
                    .font(.title)
                    .fontWeight(.medium)
            } else {
                Text("\(number)")
                    .font(.title)
                    .fontWeight(.medium)
            }
        }
        .frame(width: 60, height: 60)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(30)
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
} 