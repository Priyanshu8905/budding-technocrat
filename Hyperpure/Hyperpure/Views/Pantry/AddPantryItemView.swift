// AddPantryItemView.swift
// Sheet view allowing kitchen managers to record new pantry items.

import SwiftUI

struct AddPantryItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category = "chicken-eggs"
    @State private var quantity = 10.0
    @State private var unit = "kg"
    @State private var shelfLife = 7
    @State private var depletionRate = 1.0
    
    var onAdd: (String, String, Double, String, Int, Double) -> Void
    
    private let categories = [
        ("chicken-eggs", "Chicken & Eggs"),
        ("frozen", "Frozen & Instant Food"),
        ("sauces-seasoning", "Sauces & Seasoning"),
        ("packaging", "Packaging Material"),
        ("canned-imported", "Canned & Imported Items"),
        ("bakery", "Bakery & Chocolates")
    ]
    
    private let units = ["kg", "litres", "packs", "pcs"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Ingredient Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.0) { cat in
                            Text(cat.1).tag(cat.0)
                        }
                    }
                }
                
                Section(header: Text("Inventory Sizing")) {
                    HStack {
                        Text("Current Stock")
                        Spacer()
                        TextField("Quantity", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        
                        Picker("", selection: $unit) {
                            ForEach(units, id: \.self) { u in
                                Text(u).tag(u)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Stepper("Shelf Life: \(shelfLife) Days", value: $shelfLife, in: 1...365)
                }
                
                Section(header: Text("Depletion Rate")) {
                    HStack {
                        Text("Daily Usage")
                        Spacer()
                        TextField("Usage Rate", value: $depletionRate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("\(unit)/day")
                            .foregroundColor(Theme.textMuted)
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty && quantity > 0 && depletionRate > 0 {
                            onAdd(name, category, quantity, unit, shelfLife, depletionRate)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddPantryItemView { _, _, _, _, _, _ in }
}
