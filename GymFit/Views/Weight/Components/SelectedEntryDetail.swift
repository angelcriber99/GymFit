import SwiftUI

struct SelectedEntryDetail: View {
    let entry: WeightEntry
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Detalles del Registro")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("Fecha")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(entry.date.formatted(date: .long, time: .omitted))
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Peso")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f kg", entry.weight))
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
} 