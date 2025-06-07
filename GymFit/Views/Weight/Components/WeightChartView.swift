import SwiftUI
import Charts

struct WeightChartView: View {
    let entries: [WeightEntry]
    let selectedEntry: WeightEntry?
    let onEntrySelected: (WeightEntry?) -> Void
    
    private var sortedEntries: [WeightEntry] {
        entries.sorted(by: { $0.date < $1.date })
    }
    
    private var weightRange: (min: Double, max: Double) {
        let weights = entries.map { $0.weight }
        return (weights.min() ?? 0, weights.max() ?? 0)
    }
    
    private var averageWeight: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { $0.weight }.reduce(0, +) / Double(entries.count)
    }
    
    private var weightChange: Double? {
        guard entries.count >= 2 else { return nil }
        let sorted = sortedEntries
        return sorted.last!.weight - sorted.first!.weight
    }
    
    private var weeklyChange: Double? {
        guard entries.count >= 2 else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let recentEntries = entries.filter { $0.date >= weekAgo }
        guard let first = recentEntries.first, let last = recentEntries.last else { return nil }
        return last.weight - first.weight
    }
    
    private var trend: String {
        guard let change = weightChange else { return "Sin datos suficientes" }
        if change > 0 {
            return "Tendencia al alza"
        } else if change < 0 {
            return "Tendencia a la baja"
        } else {
            return "Peso estable"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Resumen Principal
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Peso Actual")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let lastEntry = sortedEntries.last {
                        Text(String(format: "%.1f kg", lastEntry.weight))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Cambio Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let change = weightChange {
                        HStack(spacing: 4) {
                            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text(String(format: "%.1f kg", abs(change)))
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(change >= 0 ? .red : .green)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Gráfica
            VStack(alignment: .leading, spacing: 12) {
                Text("Progreso")
                    .font(.headline)
                
                Chart {
                    ForEach(sortedEntries) { entry in
                        LineMark(
                            x: .value("Fecha", entry.date),
                            y: .value("Peso", entry.weight)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.5), .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        PointMark(
                            x: .value("Fecha", entry.date),
                            y: .value("Peso", entry.weight)
                        )
                        .foregroundStyle(Color.blue.opacity(0.5))
                        .symbolSize(50)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text(String(format: "%.1f", weight))
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Análisis Detallado
            VStack(spacing: 16) {
                Text("Análisis Detallado")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    StatCard(
                        title: "Promedio",
                        value: String(format: "%.1f kg", averageWeight),
                        icon: "chart.bar.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Cambio Semanal",
                        value: weeklyChange.map { String(format: "%.1f kg", $0) } ?? "N/A",
                        icon: "calendar",
                        color: .orange
                    )
                }
                
                HStack(spacing: 20) {
                    StatCard(
                        title: "Mínimo",
                        value: String(format: "%.1f kg", weightRange.min),
                        icon: "arrow.down",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Máximo",
                        value: String(format: "%.1f kg", weightRange.max),
                        icon: "arrow.up",
                        color: .red
                    )
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                    Text(trend)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
        .padding()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
} 