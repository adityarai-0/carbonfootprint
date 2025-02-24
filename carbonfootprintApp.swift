//
//  CarbonFootprintTrackerApp.swift
//  CarbonFootprintTracker
//
//  Created by Developer on 2025-02-24
//
//  This updated app tracks your daily carbon footprint with an enhanced UI.
//  It includes four main screens: Dashboard, Log Entry, Trends, and History.
//  The Trends screen displays a chart (using SwiftUI Charts) for recent records,
//  and the History screen features an export button to share stored JSON data.
//  Offline data is stored locally using JSON persistence.

import SwiftUI
import Combine
import Charts  // Requires iOS 16+

// MARK: - Custom Color Extension
extension Color {
    static let primaryOrange = Color(red: 1.0, green: 0.5, blue: 0.0)
    static let primaryYellow = Color(red: 1.0, green: 0.8, blue: 0.0)
}

// MARK: - Date Extensions
extension Date {
    /// Returns the date in a medium format (e.g., Feb 24, 2025)
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    /// Returns the time in a short format (e.g., 3:45 PM)
    func timeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - Data Model
struct CarbonRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var transportationKm: Double
    var energyKWh: Double
    var wasteKg: Double
    var notes: String
    
    /// Computed emission from transportation (kg CO₂ per km)
    var transportationEmission: Double { transportationKm * 0.21 }
    /// Computed emission from energy usage (kg CO₂ per kWh)
    var energyEmission: Double { energyKWh * 0.5 }
    /// Computed emission from waste (kg CO₂ per kg)
    var wasteEmission: Double { wasteKg * 0.1 }
    /// Total emission from all categories
    var totalEmission: Double { transportationEmission + energyEmission + wasteEmission }
}

// MARK: - Data Manager for Offline Persistence
class CarbonDataManager: ObservableObject {
    @Published var records: [CarbonRecord] = []
    
    private let fileName = "carbonRecords.json"
    private let fileManager = FileManager.default
    
    init() {
        loadRecords()
    }
    
    /// Returns the URL for the local JSON file.
    private func dataFileURL() -> URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    /// Public accessor for the file URL (used for sharing/export).
    var publicDataFileURL: URL? { dataFileURL() }
    
    /// Loads records from the JSON file.
    func loadRecords() {
        guard let url = dataFileURL(), fileManager.fileExists(atPath: url.path) else {
            records = []
            return
        }
        do {
            let data = try Data(contentsOf: url)
            records = try JSONDecoder().decode([CarbonRecord].self, from: data)
        } catch {
            print("Error loading records: \(error)")
            records = []
        }
    }
    
    /// Saves the current records to the JSON file.
    func saveRecords() {
        guard let url = dataFileURL() else { return }
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: url)
        } catch {
            print("Error saving records: \(error)")
        }
    }
    
    /// Adds a new carbon record.
    func addRecord(_ record: CarbonRecord) {
        records.append(record)
        saveRecords()
    }
    
    /// Deletes a record.
    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveRecords()
    }
    
    /// Returns today's record if available.
    func recordForToday() -> CarbonRecord? {
        return records.first { Calendar.current.isDateInToday($0.date) }
    }
    
    /// Returns records sorted by date (most recent first).
    func sortedRecords() -> [CarbonRecord] {
        return records.sorted { $0.date > $1.date }
    }
}

// MARK: - Main App Entry Point
@main
struct CarbonFootprintTrackerApp: App {
    @StateObject private var dataManager = CarbonDataManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(dataManager)
        }
    }
}

// MARK: - Main View with Tab Navigation
struct MainView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            LogEntryView()
                .tabItem { Label("Log Entry", systemImage: "plus.circle.fill") }
            TrendsView()
                .tabItem { Label("Trends", systemImage: "chart.line.uptrend.xyaxis") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }
        }
        .accentColor(.primaryOrange)
    }
}

// MARK: - Dashboard Screen
struct DashboardView: View {
    @EnvironmentObject var dataManager: CarbonDataManager
    private var todaysRecord: CarbonRecord? { dataManager.recordForToday() }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Today's Carbon Footprint")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryOrange)
                        .padding(.top)
                    
                    if let record = todaysRecord {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Date:").fontWeight(.semibold)
                                Text(record.date.formatted())
                            }
                            Divider()
                            HStack {
                                Text("Transportation:")
                                Spacer()
                                Text(String(format: "%.2f kg CO₂", record.transportationEmission))
                                    .foregroundColor(.primaryOrange)
                            }
                            HStack {
                                Text("Energy:")
                                Spacer()
                                Text(String(format: "%.2f kg CO₂", record.energyEmission))
                                    .foregroundColor(.primaryOrange)
                            }
                            HStack {
                                Text("Waste:")
                                Spacer()
                                Text(String(format: "%.2f kg CO₂", record.wasteEmission))
                                    .foregroundColor(.primaryOrange)
                            }
                            Divider()
                            HStack {
                                Text("Total:").font(.headline)
                                Spacer()
                                Text(String(format: "%.2f kg CO₂", record.totalEmission))
                                    .font(.headline)
                                    .foregroundColor(.primaryOrange)
                            }
                            if !record.notes.isEmpty {
                                Divider()
                                Text("Notes:").fontWeight(.semibold)
                                Text(record.notes).italic()
                            }
                        }
                        .padding()
                        .background(Color.primaryYellow.opacity(0.3))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        VStack {
                            Text("No entry for today.")
                                .font(.title3)
                            Text("Please add your daily data in the Log Entry tab.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

// MARK: - Log Entry Screen with Haptic Feedback
struct LogEntryView: View {
    @EnvironmentObject var dataManager: CarbonDataManager
    @State private var transportationKm: String = ""
    @State private var energyKWh: String = ""
    @State private var wasteKg: String = ""
    @State private var notes: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case transportation, energy, waste, notes
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transportation").foregroundColor(.primaryOrange)) {
                    TextField("Kilometers Driven", text: $transportationKm)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .transportation)
                }
                Section(header: Text("Energy Usage").foregroundColor(.primaryOrange)) {
                    TextField("Electricity Used (kWh)", text: $energyKWh)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .energy)
                }
                Section(header: Text("Waste Production").foregroundColor(.primaryOrange)) {
                    TextField("Waste Produced (kg)", text: $wasteKg)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .waste)
                }
                Section(header: Text("Additional Notes").foregroundColor(.primaryOrange)) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .notes)
                }
                Section {
                    Button(action: saveEntry) {
                        HStack {
                            Spacer()
                            Text("Save Entry").fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .navigationTitle("Log Entry")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Input Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func saveEntry() {
        guard let transportValue = Double(transportationKm),
              let energyValue = Double(energyKWh),
              let wasteValue = Double(wasteKg) else {
            alertMessage = "Please enter valid numbers for all fields."
            showAlert = true
            return
        }
        if dataManager.recordForToday() != nil {
            alertMessage = "An entry for today already exists. Delete the existing entry to add a new one."
            showAlert = true
            return
        }
        let newRecord = CarbonRecord(date: Date(),
                                     transportationKm: transportValue,
                                     energyKWh: energyValue,
                                     wasteKg: wasteValue,
                                     notes: notes)
        dataManager.addRecord(newRecord)
        transportationKm = ""
        energyKWh = ""
        wasteKg = ""
        notes = ""
        focusedField = nil
        // Provide haptic feedback upon successful save.
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - Trends Screen using SwiftUI Charts (iOS 16+)
struct TrendsView: View {
    @EnvironmentObject var dataManager: CarbonDataManager
    
    var body: some View {
        NavigationView {
            VStack {
                if #available(iOS 16.0, *) {
                    // Filter records from the last 7 days.
                    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                    let recentRecords = dataManager.records.filter { $0.date >= sevenDaysAgo }
                    
                    Chart {
                        ForEach(recentRecords) { record in
                            LineMark(
                                x: .value("Date", record.date),
                                y: .value("Emission", record.totalEmission)
                            )
                            .foregroundStyle(Color.primaryOrange)
                            PointMark(
                                x: .value("Date", record.date),
                                y: .value("Emission", record.totalEmission)
                            )
                            .foregroundStyle(Color.primaryYellow)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 7))
                    }
                    .frame(height: 300)
                    .padding()
                } else {
                    Text("Trends chart requires iOS 16 or later.")
                        .foregroundColor(.secondary)
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("Trends")
        }
    }
}

// MARK: - History Screen with Export Feature
struct HistoryView: View {
    @EnvironmentObject var dataManager: CarbonDataManager
    @State private var showDetail: Bool = false
    @State private var selectedRecord: CarbonRecord?
    @State private var isSharePresented: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.sortedRecords()) { record in
                    Button(action: {
                        selectedRecord = record
                        showDetail = true
                    }) {
                        RecordRowView(record: record)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete(perform: deleteRecords)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("History")
            .toolbar {
                // Export data button.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isSharePresented = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showDetail) {
                if let record = selectedRecord {
                    RecordDetailView(record: record)
                }
            }
            .sheet(isPresented: $isSharePresented) {
                if let url = dataManager.publicDataFileURL {
                    ActivityView(activityItems: [url])
                } else {
                    ActivityView(activityItems: ["No data available"])
                }
            }
        }
    }
    
    func deleteRecords(offsets: IndexSet) {
        dataManager.deleteRecord(at: offsets)
    }
}

// MARK: - Record Row View
struct RecordRowView: View {
    let record: CarbonRecord
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.date.formatted())
                    .font(.headline)
                Text(record.date.timeFormatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(String(format: "%.1f kg", record.totalEmission))
                .font(.subheadline)
                .foregroundColor(.primaryOrange)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Record Detail View
struct RecordDetailView: View {
    let record: CarbonRecord
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Detailed Record")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryOrange)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Date:").fontWeight(.semibold)
                            Spacer()
                            Text(record.date.formatted())
                        }
                        HStack {
                            Text("Time:").fontWeight(.semibold)
                            Spacer()
                            Text(record.date.timeFormatted())
                        }
                        Divider()
                        HStack {
                            Text("Transportation:")
                            Spacer()
                            Text(String(format: "%.2f km", record.transportationKm))
                        }
                        HStack {
                            Text("Energy:")
                            Spacer()
                            Text(String(format: "%.2f kWh", record.energyKWh))
                        }
                        HStack {
                            Text("Waste:")
                            Spacer()
                            Text(String(format: "%.2f kg", record.wasteKg))
                        }
                        Divider()
                        HStack {
                            Text("Emissions from Transport:")
                            Spacer()
                            Text(String(format: "%.2f kg CO₂", record.transportationEmission))
                        }
                        HStack {
                            Text("Emissions from Energy:")
                            Spacer()
                            Text(String(format: "%.2f kg CO₂", record.energyEmission))
                        }
                        HStack {
                            Text("Emissions from Waste:")
                            Spacer()
                            Text(String(format: "%.2f kg CO₂", record.wasteEmission))
                        }
                        Divider()
                        HStack {
                            Text("Total Emissions:").font(.headline)
                            Spacer()
                            Text(String(format: "%.2f kg CO₂", record.totalEmission))
                                .font(.headline)
                                .foregroundColor(.primaryOrange)
                        }
                        if !record.notes.isEmpty {
                            Divider()
                            Text("Notes:").fontWeight(.semibold)
                            Text(record.notes).italic()
                        }
                    }
                    .padding()
                    .background(Color.primaryYellow.opacity(0.3))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .navigationTitle("Record Detail")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Custom Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.primaryOrange)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - ActivityView for Sharing Data
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

