import Foundation
import SwiftUI

@MainActor
class WeightStore: ObservableObject {
    @Published private(set) var entries: [WeightEntry] = []
    
    init() {
        loadEntries()
    }
    
    func addEntry(_ entry: WeightEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func deleteEntry(_ entry: WeightEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "weightEntries")
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "weightEntries"),
           let decoded = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            entries = decoded
        }
    }
    
    var averageWeight: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { $0.weight }.reduce(0, +) / Double(entries.count)
    }
    
    var maxWeight: Double {
        entries.map { $0.weight }.max() ?? 0
    }
    
    var minWeight: Double {
        entries.map { $0.weight }.min() ?? 0
    }
    
    var weightChange: Double? {
        guard entries.count >= 2 else { return nil }
        let sortedEntries = entries.sorted { $0.date < $1.date }
        return sortedEntries.last!.weight - sortedEntries.first!.weight
    }
} 