import SwiftUI
import Charts

struct WeightChartSection: View {
    let entries: [WeightEntry]
    @Binding var selectedTimeFrame: TimeFrame
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Progreso")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("Período", selection: $selectedTimeFrame) {
                    Text("1 Mes").tag(TimeFrame.month)
                    Text("1 Año").tag(TimeFrame.year)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            .padding(.horizontal)
            
            if entries.isEmpty {
                EmptyChartView()
            } else {
                Chart {
                    ForEach(entries) { entry in
                        LineMark(
                            x: .value("Fecha", entry.date),
                            y: .value("Peso", entry.weight)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Fecha", entry.date),
                            y: .value("Peso", entry.weight)
                        )
                        .foregroundStyle(Color.blue)
                        .symbolSize(50)
                    }
                    
                    if let average = calculateAverage() {
                        RuleMark(
                            y: .value("Promedio", average)
                        )
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .trailing) {
                            Text("Promedio: \(String(format: "%.1f", average)) kg")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .chartYScale(domain: calculateYAxisDomain())
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text(String(format: "%.1f", weight))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(formatDate(date))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .frame(height: 250)
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
    }
    
    private func calculateAverage() -> Double? {
        guard !entries.isEmpty else { return nil }
        return entries.map { $0.weight }.reduce(0, +) / Double(entries.count)
    }
    
    private func calculateYAxisDomain() -> ClosedRange<Double> {
        guard !entries.isEmpty else { return 0...100 }
        let weights = entries.map { $0.weight }
        let min = weights.min() ?? 0
        let max = weights.max() ?? 100
        let padding = (max - min) * 0.1
        return (min - padding)...(max + padding)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}

struct EmptyChartView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No hay datos para mostrar")
                .font(.headline)
            
            Text("Agrega registros de peso para ver tu progreso")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
} 