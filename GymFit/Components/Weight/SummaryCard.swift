import SwiftUI

struct SummaryCard: View {
    @ObservedObject var weightStore: WeightStore
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Peso actual
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Peso Actual")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f kg", weightStore.currentWeight))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let lastWeight = weightStore.weights.dropLast().last {
                        let difference = weightStore.currentWeight - lastWeight.weight
                        let isPositive = difference > 0
                        
                        Text(isPositive ? "+\(String(format: "%.1f", difference))" : String(format: "%.1f", difference))
                            .font(.headline)
                            .foregroundColor(isPositive ? .red : .green)
                        
                        Text("desde el último registro")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            // Estadísticas
            HStack(spacing: 20) {
                StatView(
                    title: "Máximo",
                    value: String(format: "%.1f kg", weightStore.maxWeight),
                    icon: "arrow.up.circle.fill",
                    color: .red
                )
                
                StatView(
                    title: "Mínimo",
                    value: String(format: "%.1f kg", weightStore.minWeight),
                    icon: "arrow.down.circle.fill",
                    color: .green
                )
            }
            
            // Tendencias
            if let trend = calculateTrend() {
                HStack {
                    Image(systemName: trend.icon)
                        .foregroundColor(trend.color)
                    
                    Text(trend.message)
                        .font(.subheadline)
                        .foregroundColor(trend.color)
                }
                .padding(.top, 8)
            }
            
            // Botón para desplegar análisis detallado
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack {
                    Text("Análisis detallado")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 8)
            }
            
            if isExpanded {
                VStack(spacing: 16) {
                    // Tendencia
                    TrendAnalysisCard(weightStore: weightStore)
                    // Proyección
                    ProjectionCard(weightStore: weightStore)
                    // Resumen de últimos registros
                    LastRegistrationsCard(weightStore: weightStore)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func calculateTrend() -> (message: String, icon: String, color: Color)? {
        guard weightStore.weights.count >= 2 else { return nil }
        
        let sortedWeights = weightStore.weights.sorted { $0.date < $1.date }
        let firstWeight = sortedWeights.first!.weight
        let lastWeight = sortedWeights.last!.weight
        let difference = lastWeight - firstWeight
        
        if abs(difference) < 0.5 {
            return ("Manteniendo peso estable", "equal.circle.fill", .blue)
        } else if difference > 0 {
            return ("Tendencia al alza", "arrow.up.circle.fill", .red)
        } else {
            return ("Tendencia a la baja", "arrow.down.circle.fill", .green)
        }
    }
}

struct TrendAnalysisCard: View {
    @ObservedObject var weightStore: WeightStore
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tendencia")
                .font(.headline)
            if let trend = calculateTrend() {
                HStack {
                    Image(systemName: trend.isPositive ? "arrow.up.right" : "arrow.down.right")
                        .foregroundColor(trend.isPositive ? .red : .green)
                    Text(String(format: "%.1f kg", abs(trend.change)))
                        .font(.title2)
                        .bold()
                    Text("en los últimos 30 días")
                        .foregroundColor(.secondary)
                }
                if trend.isPositive {
                    Text("Estás ganando peso")
                        .foregroundColor(.red)
                } else {
                    Text("Estás perdiendo peso")
                        .foregroundColor(.green)
                }
            } else {
                Text("No hay suficientes datos para calcular la tendencia")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    private func calculateTrend() -> (change: Double, isPositive: Bool)? {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentWeights = weightStore.weights.filter { $0.date >= thirtyDaysAgo }
        guard let firstWeight = recentWeights.first?.weight,
              let lastWeight = recentWeights.last?.weight else {
            return nil
        }
        let change = lastWeight - firstWeight
        return (abs(change), change > 0)
    }
}

struct ProjectionCard: View {
    @ObservedObject var weightStore: WeightStore
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Proyección")
                .font(.headline)
            if let projection = calculateProjection() {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Basado en los últimos 4 registros:")
                        .foregroundColor(.secondary)
                    HStack {
                        Text("En 3 meses:")
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f kg", projection.threeMonths))
                            .bold()
                    }
                    HStack {
                        Text("En 6 meses:")
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f kg", projection.sixMonths))
                            .bold()
                    }
                }
            } else {
                Text("Se necesitan más datos para hacer proyecciones")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    private func calculateProjection() -> (threeMonths: Double, sixMonths: Double)? {
        guard let trend = calculateTrend() else { return nil }
        let monthlyChange = trend.isPositive ? trend.change / 30 * 30 : -trend.change / 30 * 30 // Cambio mensual con signo correcto
        let threeMonths = weightStore.currentWeight + (monthlyChange * 3)
        let sixMonths = weightStore.currentWeight + (monthlyChange * 6)
        return (threeMonths, sixMonths)
    }
    private func calculateTrend() -> (change: Double, isPositive: Bool)? {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentWeights = weightStore.weights.filter { $0.date >= thirtyDaysAgo }
        guard let firstWeight = recentWeights.first?.weight,
              let lastWeight = recentWeights.last?.weight else {
            return nil
        }
        let change = lastWeight - firstWeight
        return (abs(change), change > 0)
    }
}

struct LastRegistrationsCard: View {
    @ObservedObject var weightStore: WeightStore
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Últimos registros")
                .font(.headline)
            if weightStore.weights.count >= 4 {
                let lastFour = Array(weightStore.weights.suffix(4))
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(lastFour, id: \.id) { entry in
                        HStack {
                            Text(entry.formattedDate)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1f kg", entry.weight))
                                .bold()
                        }
                    }
                }
            } else {
                Text("Se necesitan más registros para mostrar el resumen")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
} 