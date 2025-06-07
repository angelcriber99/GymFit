import SwiftUI

struct RecentEntriesList: View {
    let entries: [WeightEntry]
    let onDelete: (WeightEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Registros Recientes")
                .font(.headline)
                .padding(.horizontal)
            
            if entries.isEmpty {
                Text("No hay registros")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.date.formatted(date: .long, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(String(format: "%.1f kg", entry.weight))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        Button(action: { onDelete(entry) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }
        }
    }
} 