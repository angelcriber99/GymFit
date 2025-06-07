import SwiftUI

struct SummaryCard: View {
    @ObservedObject var weightStore: WeightStore
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Resumen")
                .font(.headline)
            
            HStack(spacing: 20) {
                MetricItem(
                    title: "Promedio",
                    value: String(format: "%.1f", weightStore.averageWeight),
                    unit: "kg",
                    color: accentColor
                )
                
                MetricItem(
                    title: "Máximo",
                    value: String(format: "%.1f", weightStore.maxWeight),
                    unit: "kg",
                    color: accentColor
                )
                
                MetricItem(
                    title: "Mínimo",
                    value: String(format: "%.1f", weightStore.minWeight),
                    unit: "kg",
                    color: accentColor
                )
            }
            
            if let change = weightStore.weightChange {
                HStack {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(String(format: "%.1f kg", abs(change)))
                    Text(change >= 0 ? "aumento" : "disminución")
                }
                .font(.subheadline)
                .foregroundColor(change >= 0 ? .red : .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
} 