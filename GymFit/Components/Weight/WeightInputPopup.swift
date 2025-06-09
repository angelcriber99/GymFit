import SwiftUI

struct WeightInputPopup: View {
    @Binding var weight: String
    @Binding var date: Date
    @FocusState var isFocused: Bool
    let onSave: () -> Void
    let onDismiss: () -> Void
    let isEditing: Bool
    @State private var showingDatePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(isEditing ? "Editar Peso" : "Registrar Peso")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    isFocused = false
                    onDismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: { 
                isFocused = false
                showingDatePicker.toggle()
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text(date.formatted(date: .long, time: .omitted))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            if showingDatePicker {
                DatePicker(
                    "Fecha",
                    selection: $date,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .onChange(of: date) { _ in
                    showingDatePicker = false
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                TextField("0.0", text: $weight)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .frame(width: 160)
                    .onTapGesture {
                        showingDatePicker = false
                    }
                
                Text("kg")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                isFocused = false
                onSave()
            }) {
                Text(isEditing ? "Actualizar" : "Guardar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidWeight ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isValidWeight)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
    
    private var isValidWeight: Bool {
        guard let weightValue = Double(weight.replacingOccurrences(of: ",", with: ".")) else {
            return false
        }
        return weightValue > 0 && weightValue < 500
    }
} 