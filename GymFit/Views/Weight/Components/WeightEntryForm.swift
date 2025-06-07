import SwiftUI

struct WeightEntryForm: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var weightStore: WeightStore
    @State private var weight: String = ""
    @State private var date = Date()
    let onDismiss: () -> Void
    
    var body: some View {
        Form {
            Section {
                TextField("Peso (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                
                DatePicker("Fecha", selection: $date, displayedComponents: .date)
            }
            
            Section {
                Button(action: saveEntry) {
                    Text("Guardar")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
                .disabled(weight.isEmpty)
            }
        }
    }
    
    private func saveEntry() {
        guard let weightValue = Double(weight.replacingOccurrences(of: ",", with: ".")) else { return }
        let entry = WeightEntry(date: date, weight: weightValue)
        weightStore.addEntry(entry)
        onDismiss()
    }
} 