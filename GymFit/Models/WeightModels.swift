import Foundation
import SwiftUI

public struct WeightEntry: Identifiable, Codable {
    public let id: UUID
    public let weight: Double
    public let date: Date
    
    public init(id: UUID = UUID(), weight: Double, date: Date = Date()) {
        self.id = id
        self.weight = weight
        self.date = date
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

public class WeightStore: ObservableObject {
    @Published public private(set) var weights: [WeightEntry] = []
    private let saveKey = "savedWeights"
    
    public init() {
        loadWeights()
    }
    
    public var currentWeight: Double {
        weights.last?.weight ?? 0.0
    }
    
    public var averageWeight: Double {
        guard !weights.isEmpty else { return 0.0 }
        return weights.map { $0.weight }.reduce(0, +) / Double(weights.count)
    }
    
    public var maxWeight: Double {
        weights.map { $0.weight }.max() ?? 0.0
    }
    
    public var minWeight: Double {
        weights.map { $0.weight }.min() ?? 0.0
    }
    
    public func addWeight(_ weight: Double, date: Date = Date()) {
        let entry = WeightEntry(weight: weight, date: date)
        weights.append(entry)
        saveWeights()
    }
    
    public func updateWeight(_ id: UUID, newWeight: Double, newDate: Date? = nil) {
        if let index = weights.firstIndex(where: { $0.id == id }) {
            let oldEntry = weights[index]
            let entry = WeightEntry(
                id: id,
                weight: newWeight,
                date: newDate ?? oldEntry.date
            )
            weights[index] = entry
            saveWeights()
        }
    }
    
    public func removeWeight(withId id: UUID) {
        weights.removeAll { $0.id == id }
        saveWeights()
    }
    
    private func saveWeights() {
        if let encoded = try? JSONEncoder().encode(weights) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadWeights() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            weights = decoded
        }
    }
} 