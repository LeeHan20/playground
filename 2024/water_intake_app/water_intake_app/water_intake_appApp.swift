// Importing necessary frameworks
import SwiftUI
import Combine

// MARK: - Data Model for Drink
struct Drink: Identifiable {
    let id = UUID()
    let name: String
    let volume: Double // in milliliters
    let nutrients: [String: Double] // Nutrient name to amount mapping (e.g., ["Sugar": 10.0, "Caffeine": 5.0])
    let imageName: String // Image name for drink representation
}

// MARK: - ViewModel to Manage State
class DrinkTrackerViewModel: ObservableObject {
    @Published var dailyDrinks: [Drink] = []
    @Published var monthlyIntake: [Date: [Drink]] = [:]
    
    // Add a new drink to the daily log
    func addDrink(_ drink: Drink) {
        dailyDrinks.append(drink)
        let today = Calendar.current.startOfDay(for: Date())
        monthlyIntake[today, default: []].append(drink)
    }
    
    
    
    // Calculate nutrient intake for today
    func calculateDailyNutrients() -> [String: Double] {
        var nutrients: [String: Double] = [:]
        for drink in dailyDrinks {
            for (key, value) in drink.nutrients {
                nutrients[key, default: 0] += value
            }
        }
        return nutrients
    }
}

// MARK: - Drink Selection View
struct DrinkSelectionView: View {
    @EnvironmentObject var viewModel: DrinkTrackerViewModel
    @State private var selectedDrink: Drink?
    
    let availableDrinks = [
        Drink(name: "Water", volume: 250, nutrients: ["Water": 250], imageName: "water"),
        Drink(name: "Orange Juice", volume: 250, nutrients: ["Water": 218, "Sugar": 21, "Vitamin C": 124], imageName: "orange_juice"),
        Drink(name: "Coffee", volume: 250, nutrients: ["Water": 235, "Caffeine": 95, "Potassium": 116], imageName: "coffee"),
        Drink(name: "Green Tea", volume: 250, nutrients: ["Water": 245, "Caffeine": 30, "Antioxidants": 100], imageName: "green_tea"),
        Drink(name: "Milk", volume: 250, nutrients: ["Water": 215, "Protein": 8, "Calcium": 300, "Fat": 8], imageName: "milk"),
        Drink(name: "Cola", volume: 250, nutrients: ["Water": 220, "Sugar": 27, "Caffeine": 24, "Phosphorus": 50], imageName: "cola"),
        Drink(name: "Energy Drink", volume: 250, nutrients: ["Water": 200, "Sugar": 27, "Caffeine": 80, "Taurine": 1000], imageName: "energy_drink"),
        Drink(name: "Sports Drink", volume: 250, nutrients: ["Water": 220, "Sugar": 14, "Sodium": 110, "Potassium": 30], imageName: "sports_drink"),
        Drink(name: "Coconut Water", volume: 250, nutrients: ["Water": 235, "Sugar": 6, "Potassium": 600, "Sodium": 252], imageName: "coconut_water"),
        Drink(name: "Lemonade", volume: 250, nutrients: ["Water": 230, "Sugar": 25, "Vitamin C": 30, "Potassium": 20], imageName: "lemonade")
    ]
    
    var body: some View {
        NavigationView {
            List(availableDrinks) { drink in
                NavigationLink(destination: DrinkDetailView(drink: drink)) {
                    HStack {
                        Image(drink.imageName)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        Text(drink.name)
                            .font(.headline)
                        Spacer()
                        Text("\(drink.volume, specifier: "%.0f") ml")
                    }
                }
            }
            .navigationTitle("Select a Drink")
        }
    }
}

// MARK: - Drink Detail View
struct DrinkDetailView: View {
    @EnvironmentObject var viewModel: DrinkTrackerViewModel
    @State private var volume: String = ""
    let drink: Drink
    
    var body: some View {
        VStack(spacing: 20) {
            Image(drink.imageName)
                .resizable()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .padding()
            Text(drink.name)
                .font(.largeTitle)
                .padding()
            TextField("Volume (ml)", text: $volume)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            Button("Add Drink") {
                if let volume = Double(volume), volume > 0 {
                    let adjustedDrink = Drink(name: drink.name, volume: volume, nutrients: drink.nutrients.mapValues { $0 * (volume / drink.volume) }, imageName: drink.imageName)
                    viewModel.addDrink(adjustedDrink)
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle(drink.name)
    }
}

// MARK: - Daily Nutrient Intake View
struct DailyIntakeView: View {
    @EnvironmentObject var viewModel: DrinkTrackerViewModel
    
    var body: some View {
        
        let nutrients = viewModel.calculateDailyNutrients()
        VStack {
            Text("Today's Nutrient Intake")
                .font(.headline)
                .padding()
            List(nutrients.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack {
                    Text(key)
                    Spacer()
                    Text("\(value, specifier: "%.2f") g/ml")
                }
            }
        }
        .navigationTitle("Daily Intake")
    }
}

// MARK: - Monthly Intake View
struct MonthlyIntakeView: View {
    @EnvironmentObject var viewModel: DrinkTrackerViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.monthlyIntake.keys.sorted(), id: \.self) { date in
                if let drinks = viewModel.monthlyIntake[date] {
                    NavigationLink(destination: DailyDetailView(date: date, drinks: drinks)) {
                        HStack {
                            Text(date, style: .date)
                            Spacer()
                            Text("\(drinks.count) drinks")
                        }
                    }
                }
            }
            .navigationTitle("Monthly Intake")
        }
    }
}

// MARK: - Daily Detail View for Monthly Intake
struct DailyDetailView: View {
    let date: Date
    let drinks: [Drink]
    
    var body: some View {
        VStack {
            Text("Intake for \(date, style: .date)")
                .font(.headline)
                .padding()
            List(drinks) { drink in
                HStack {
                    Image(drink.imageName)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    Text(drink.name)
                    Spacer()
                    Text("\(drink.volume, specifier: "%.0f") ml")
                }
            }
        }
    }
}

// MARK: - Main App Entry
@main
struct WaterTrackingApp: App {
    @StateObject private var viewModel = DrinkTrackerViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                DrinkSelectionView()
                    .tabItem {
                        Label("Select Drink", systemImage: "drop.fill")
                    }
                DailyIntakeView()
                    .tabItem {
                        Label("Daily Intake", systemImage: "calendar")
                    }
                MonthlyIntakeView()
                    .tabItem {
                        Label("Monthly Intake", systemImage: "chart.bar")
                    }
            }
            .environmentObject(viewModel)
        }
    }
}
