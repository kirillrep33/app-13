import Foundation

enum FreshnessVerdict: String, Codable {
    case excellent
    case medium
    case poor

    var title: String {
        switch self {
        case .excellent: return "Excellent"
        case .medium: return "Average"
        case .poor: return "Poor"
        }
    }

    var badge: String {
        switch self {
        case .excellent: return ""
        case .medium: return ""
        case .poor: return ""
        }
    }
}

struct ChecklistDecision: Codable, Identifiable {
    let id: UUID
    let title: String
    let goodOption: String
    let badOption: String
    var selectedGood: Bool

    init(id: UUID = UUID(), title: String, goodOption: String, badOption: String, selectedGood: Bool) {
        self.id = id
        self.title = title
        self.goodOption = goodOption
        self.badOption = badOption
        self.selectedGood = selectedGood
    }
}

struct FreshnessAssessment: Codable, Identifiable {
    let id: UUID
    let productName: String
    let purchasePlace: String
    let purchaseDate: Date
    let pricePerKg: Double?
    let note: String
    let rating: Double
    let checklist: [ChecklistDecision]
    let score: Int
    let verdict: FreshnessVerdict
    let createdAt: Date
}

struct CookingRecord: Codable, Identifiable {
    let id: UUID
    let productName: String
    let method: String
    let thickness: Double
    let targetTemperature: Int
    let totalSeconds: Int
    let flipAtSeconds: Int
    let actualTotalSeconds: Int?
    let tasteRating: Double
    let cookedAt: Date
}

struct SeafoodEntry: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: String
    let season: String
    let bestMethod: String
    let freshnessSigns: String
}

struct RecipeEntry: Codable, Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let duration: String
    let persons: String
    let ingredients: String
    let sourceURL: String
}

struct TemplateChecklistItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let goodOption: String
    let badOption: String
}

struct ChecklistTemplate: Codable, Identifiable {
    let id: UUID
    var title: String
    var icon: String
    var products: [String]
    var items: [TemplateChecklistItem]
    var isUserTemplate: Bool
}

struct TimerComputation {
    let totalSeconds: Int
    let flipAtSeconds: Int
}

enum TimerEngine {
    private static let methodCoefficient: [String: Double] = [
        "Pan Sear": 3.2,
        "Bake": 4.0,
        "Steam": 3.6,
        "Grill": 3.8,
        "Boil": 2.8,
        "Deep Fry": 2.4,
        "Braise": 4.5
    ]

    // Product factor fine-tunes timing by fish density/fat content.
    private static let productFactor: [String: Double] = [
        "salmon": 1.00,
        "trout": 0.95,
        "cod": 0.90,
        "halibut": 1.10,
        "tuna": 0.85,
        "sea bass": 0.95,
        "dorado": 0.95,
        "flounder": 0.85,
        "mackerel": 0.90,
        "shrimp": 0.55,
        "mussels": 0.60,
        "oysters": 0.55,
        "squid": 0.70,
        "octopus": 1.30,
        "crab": 1.15,
        "lobster": 1.20,
        "scallop": 0.65,
        "pike-perch": 0.95,
        "perch": 0.95
    ]

    static func compute(thickness: Double, method: String, productName: String) -> TimerComputation {
        let methodK = methodCoefficient[method] ?? 4.0
        let productK = resolveProductFactor(productName)
        let minutes = max(1, Int(round(thickness * methodK * productK)))
        let totalSeconds = minutes * 60
        return TimerComputation(totalSeconds: totalSeconds, flipAtSeconds: totalSeconds / 2)
    }

    private static func resolveProductFactor(_ productName: String) -> Double {
        let key = productName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !key.isEmpty, key != "product" else { return 1.0 }
        if let exact = productFactor[key] { return exact }
        if let fuzzy = productFactor.first(where: { key.contains($0.key) || $0.key.contains(key) })?.value {
            return fuzzy
        }
        return 1.0
    }
}

enum FreshnessEngine {
    static func evaluate(checklist: [ChecklistDecision], rating: Double) -> (score: Int, verdict: FreshnessVerdict) {
        let goodCount = checklist.filter(\.selectedGood).count
        let checklistScore = checklist.isEmpty ? 0 : Int((Double(goodCount) / Double(checklist.count)) * 80)
        let ratingScore = Int((rating / 5.0) * 20)
        let score = min(100, max(0, checklistScore + ratingScore))

        let verdict: FreshnessVerdict
        switch score {
        case 75...100: verdict = .excellent
        case 45..<75: verdict = .medium
        default: verdict = .poor
        }
        return (score, verdict)
    }
}

@MainActor
final class AppDataStore: ObservableObject {
    @Published private(set) var assessments: [FreshnessAssessment] = []
    @Published private(set) var cookingRecords: [CookingRecord] = []
    @Published private(set) var seafoodCatalog: [SeafoodEntry] = []
    @Published private(set) var recipes: [RecipeEntry] = []
    @Published private(set) var templates: [ChecklistTemplate] = []

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileManager = FileManager.default
    private let dataFolderName = "FishCatchCookData"

    init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        loadAll()
        seedStaticDataIfNeeded()
    }

    func addAssessment(
        productName: String,
        purchasePlace: String,
        purchaseDate: Date,
        pricePerKg: Double?,
        note: String,
        rating: Double,
        checklist: [ChecklistDecision]
    ) {
        let result = FreshnessEngine.evaluate(checklist: checklist, rating: rating)
        let model = FreshnessAssessment(
            id: UUID(),
            productName: productName,
            purchasePlace: purchasePlace,
            purchaseDate: purchaseDate,
            pricePerKg: pricePerKg,
            note: note,
            rating: rating,
            checklist: checklist,
            score: result.score,
            verdict: result.verdict,
            createdAt: Date()
        )
        assessments.insert(model, at: 0)
        saveAssessments()
    }

    func addCookingRecord(
        productName: String,
        method: String,
        thickness: Double,
        targetTemperature: Int,
        totalSeconds: Int,
        flipAtSeconds: Int,
        actualTotalSeconds: Int?,
        tasteRating: Double
    ) {
        let record = CookingRecord(
            id: UUID(),
            productName: productName,
            method: method,
            thickness: thickness,
            targetTemperature: targetTemperature,
            totalSeconds: totalSeconds,
            flipAtSeconds: flipAtSeconds,
            actualTotalSeconds: actualTotalSeconds,
            tasteRating: tasteRating,
            cookedAt: Date()
        )
        cookingRecords.insert(record, at: 0)
        saveCookingRecords()
    }

    func checklistForProduct(_ productName: String) -> [ChecklistDecision] {
        let normalized = productName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return genericChecklist }

        let matched = templates.first { template in
            template.products.contains { keyword in
                normalized.contains(keyword.lowercased())
            }
        }

        let sourceItems = matched?.items ?? genericChecklistItems
        return sourceItems.map {
            ChecklistDecision(
                title: $0.title,
                goodOption: $0.goodOption,
                badOption: $0.badOption,
                selectedGood: true
            )
        }
    }

    func template(by title: String) -> ChecklistTemplate? {
        templates.first { $0.title == title }
    }

    func updateTemplate(title: String, with items: [TemplateChecklistItem]) {
        guard let index = templates.firstIndex(where: { $0.title == title }) else { return }
        templates[index].items = items
        saveTemplates()
    }

    var averagePricePerKg: Double {
        let prices = assessments.compactMap(\.pricePerKg)
        guard !prices.isEmpty else { return 0 }
        return prices.reduce(0, +) / Double(prices.count)
    }

    var favoriteCookingMethod: String {
        let groups = Dictionary(grouping: cookingRecords, by: \.method)
        return groups.max(by: { $0.value.count < $1.value.count })?.key ?? "N/A"
    }

    var timerDeviationText: String {
        let deviations = cookingRecords.compactMap { record -> Double? in
            guard let actual = record.actualTotalSeconds else { return nil }
            return abs(Double(actual - record.totalSeconds)) / 60.0
        }
        guard !deviations.isEmpty else { return "—" }
        let avg = deviations.reduce(0, +) / Double(deviations.count)
        if avg < 0.5 {
            return "On time"
        }
        return String(format: "±%.0f min", avg.rounded())
    }

    var freshestProductName: String {
        assessments.max(by: { $0.score < $1.score })?.productName ?? "N/A"
    }

    private func seedStaticDataIfNeeded() {
        if seafoodCatalog.isEmpty {
            seafoodCatalog = Self.defaultSeafood
            saveSeafood()
        }
        if recipes.isEmpty {
            recipes = Self.defaultRecipes
            saveRecipes()
        }
        if templates.isEmpty {
            templates = Self.defaultTemplates
            saveTemplates()
        }
        removeLegacyDemoRecordsIfNeeded()
    }

    private func loadAll() {
        assessments = load([FreshnessAssessment].self, fileName: "assessments.json") ?? []
        cookingRecords = load([CookingRecord].self, fileName: "cooking-records.json") ?? []
        seafoodCatalog = load([SeafoodEntry].self, fileName: "seafood.json") ?? []
        recipes = load([RecipeEntry].self, fileName: "recipes.json") ?? []
        templates = load([ChecklistTemplate].self, fileName: "templates.json") ?? []
    }

    private func saveAssessments() { save(assessments, fileName: "assessments.json") }
    private func saveCookingRecords() { save(cookingRecords, fileName: "cooking-records.json") }
    private func saveSeafood() { save(seafoodCatalog, fileName: "seafood.json") }
    private func saveRecipes() { save(recipes, fileName: "recipes.json") }
    private func saveTemplates() { save(templates, fileName: "templates.json") }

    private func removeLegacyDemoRecordsIfNeeded() {
        let before = cookingRecords.count
        cookingRecords.removeAll {
            $0.productName == "Salmon" &&
            $0.method == "Bake" &&
            abs($0.thickness - 2.0) < 0.001 &&
            abs($0.tasteRating - 4.8) < 0.001
        }
        if cookingRecords.count != before {
            saveCookingRecords()
        }
    }

    private func save<T: Encodable>(_ value: T, fileName: String) {
        guard let url = fileURL(for: fileName) else { return }
        do {
            let data = try encoder.encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Save error \(fileName): \(error)")
        }
    }

    private func load<T: Decodable>(_ type: T.Type, fileName: String) -> T? {
        guard let url = fileURL(for: fileName), fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(type, from: data)
        } catch {
            print("Load error \(fileName): \(error)")
            return nil
        }
    }

    private func fileURL(for fileName: String) -> URL? {
        guard let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let folder = docs.appendingPathComponent(dataFolderName, isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent(fileName)
    }
}

private extension AppDataStore {
    var genericChecklistItems: [TemplateChecklistItem] {
        [
            .init(id: UUID(), title: "Eyes", goodOption: "Clear", badOption: "Cloudy"),
            .init(id: UUID(), title: "Grills", goodOption: "Red", badOption: "Brown"),
            .init(id: UUID(), title: "Smell", goodOption: "Ocean", badOption: "Sour"),
            .init(id: UUID(), title: "Texture", goodOption: "Firm", badOption: "Soft"),
            .init(id: UUID(), title: "Scales", goodOption: "Shiny", badOption: "Dull")
        ]
    }

    var genericChecklist: [ChecklistDecision] {
        genericChecklistItems.map {
            ChecklistDecision(title: $0.title, goodOption: $0.goodOption, badOption: $0.badOption, selectedGood: true)
        }
    }

    static let defaultSeafood: [SeafoodEntry] = [
        .init(id: UUID(), name: "Salmon", type: "Oily fish", season: "Year-round", bestMethod: "Grill, baking", freshnessSigns: "Bright skin, firm flesh"),
        .init(id: UUID(), name: "Cod", type: "Lean fish", season: "Winter-spring", bestMethod: "Steam, baking", freshnessSigns: "White flesh, clean smell"),
        .init(id: UUID(), name: "Tuna", type: "Oily fish", season: "Summer-autumn", bestMethod: "Grill, sashimi", freshnessSigns: "Dark red flesh, glossy look"),
        .init(id: UUID(), name: "Atlantic Salmon", type: "Oily fish", season: "Year-round", bestMethod: "Baking, curing", freshnessSigns: "Pink flesh, sea aroma"),
        .init(id: UUID(), name: "Halibut", type: "Oily fish", season: "Autumn-winter", bestMethod: "Baking, frying", freshnessSigns: "Dense white flesh"),
        .init(id: UUID(), name: "Pike-perch", type: "Lean fish", season: "Spring-summer", bestMethod: "Steam, fish soup", freshnessSigns: "Clear eyes, elastic flesh"),
        .init(id: UUID(), name: "Sea Perch", type: "Lean fish", season: "Year-round", bestMethod: "Grill, baking", freshnessSigns: "Bright scales, red gills"),
        .init(id: UUID(), name: "Dorado", type: "Lean fish", season: "Year-round", bestMethod: "Grill, baking", freshnessSigns: "Silvery skin, clean smell"),
        .init(id: UUID(), name: "Sea Bass", type: "Lean fish", season: "Year-round", bestMethod: "Grill, steam", freshnessSigns: "Shiny scales, elastic flesh"),
        .init(id: UUID(), name: "Flounder", type: "Lean fish", season: "Autumn-winter", bestMethod: "Frying, baking", freshnessSigns: "Even skin, no spots"),
        .init(id: UUID(), name: "Shrimp", type: "Crustaceans", season: "Year-round", bestMethod: "Boiling, grill", freshnessSigns: "Pink color, curled tail"),
        .init(id: UUID(), name: "Mussels", type: "Mollusks", season: "Autumn-spring", bestMethod: "Boiling, baking", freshnessSigns: "Closed shells, sea smell"),
        .init(id: UUID(), name: "Oysters", type: "Mollusks", season: "Autumn-winter", bestMethod: "Raw, grill", freshnessSigns: "Closed shells, salty smell"),
        .init(id: UUID(), name: "Squid", type: "Mollusks", season: "Year-round", bestMethod: "Grill, frying", freshnessSigns: "Elastic body, clean smell"),
        .init(id: UUID(), name: "Octopus", type: "Mollusks", season: "Year-round", bestMethod: "Boiling, grill", freshnessSigns: "Elastic tentacles, no slime"),
        .init(id: UUID(), name: "Crab", type: "Crustaceans", season: "Spring-summer", bestMethod: "Boiling, steam", freshnessSigns: "Heavy body, active movement"),
        .init(id: UUID(), name: "Lobster", type: "Crustaceans", season: "Year-round", bestMethod: "Boiling, grill", freshnessSigns: "Active, hard shell"),
        .init(id: UUID(), name: "Scallop", type: "Mollusks", season: "Autumn-winter", bestMethod: "Grill, raw", freshnessSigns: "Closed shell, sweet sea smell"),
        .init(id: UUID(), name: "Trout", type: "Oily fish", season: "Year-round", bestMethod: "Baking, grill", freshnessSigns: "Pink flesh, bright color"),
        .init(id: UUID(), name: "Mackerel", type: "Oily fish", season: "Spring-autumn", bestMethod: "Smoking, grill", freshnessSigns: "Bright striped skin, firm flesh")
    ]

    static let defaultRecipes: [RecipeEntry] = [
        .init(id: UUID(), title: "Baked Dijon Salmon", subtitle: "Main dish", duration: "30 min", persons: "4 person", ingredients: "• Salmon fillets\n• Dijon mustard\n• Garlic\n• Olive oil\n• Lemon juice", sourceURL: "https://www.allrecipes.com/search?q=baked+dijon+salmon"),
        .init(id: UUID(), title: "Garlic Butter Baked Cod", subtitle: "Main dish", duration: "25 min", persons: "4 person", ingredients: "• Cod fillets\n• Butter\n• Garlic\n• Parsley\n• Lemon", sourceURL: "https://www.allrecipes.com/search?q=garlic+butter+baked+cod"),
        .init(id: UUID(), title: "Pan-Seared Tuna Steaks", subtitle: "Main dish", duration: "20 min", persons: "2 person", ingredients: "• Tuna steaks\n• Soy sauce\n• Sesame oil\n• Black pepper\n• Lime", sourceURL: "https://www.allrecipes.com/search?q=pan+seared+tuna+steaks"),
        .init(id: UUID(), title: "Lemon Herb Trout", subtitle: "Main dish", duration: "30 min", persons: "2 person", ingredients: "• Whole trout\n• Lemon slices\n• Dill\n• Butter\n• Salt", sourceURL: "https://www.allrecipes.com/search?q=lemon+herb+trout"),
        .init(id: UUID(), title: "Parmesan Crusted Halibut", subtitle: "Main dish", duration: "35 min", persons: "4 person", ingredients: "• Halibut fillets\n• Parmesan\n• Breadcrumbs\n• Mayo\n• Paprika", sourceURL: "https://www.allrecipes.com/search?q=parmesan+crusted+halibut"),
        .init(id: UUID(), title: "Fish Tacos with Slaw", subtitle: "Street food", duration: "35 min", persons: "4 person", ingredients: "• White fish\n• Tortillas\n• Cabbage slaw\n• Sour cream\n• Lime", sourceURL: "https://www.allrecipes.com/search?q=fish+tacos+slaw"),
        .init(id: UUID(), title: "Cajun Blackened Salmon", subtitle: "Main dish", duration: "25 min", persons: "4 person", ingredients: "• Salmon\n• Cajun seasoning\n• Butter\n• Garlic powder\n• Lemon", sourceURL: "https://www.allrecipes.com/search?q=cajun+blackened+salmon"),
        .init(id: UUID(), title: "Honey Garlic Shrimp", subtitle: "Main dish", duration: "20 min", persons: "4 person", ingredients: "• Shrimp\n• Honey\n• Garlic\n• Soy sauce\n• Chili flakes", sourceURL: "https://www.allrecipes.com/search?q=honey+garlic+shrimp"),
        .init(id: UUID(), title: "Shrimp Scampi Pasta", subtitle: "Pasta", duration: "30 min", persons: "4 person", ingredients: "• Shrimp\n• Spaghetti\n• Butter\n• Garlic\n• White wine", sourceURL: "https://www.allrecipes.com/search?q=shrimp+scampi+pasta"),
        .init(id: UUID(), title: "Coconut Shrimp", subtitle: "Appetizer", duration: "35 min", persons: "6 person", ingredients: "• Shrimp\n• Coconut flakes\n• Flour\n• Eggs\n• Panko", sourceURL: "https://www.allrecipes.com/search?q=coconut+shrimp"),
        .init(id: UUID(), title: "Garlic Mussels", subtitle: "Seafood", duration: "20 min", persons: "4 person", ingredients: "• Mussels\n• Garlic\n• White wine\n• Butter\n• Parsley", sourceURL: "https://www.allrecipes.com/search?q=garlic+mussels"),
        .init(id: UUID(), title: "Steamed Mussels in Tomato Broth", subtitle: "Seafood", duration: "30 min", persons: "4 person", ingredients: "• Mussels\n• Tomatoes\n• Onion\n• Garlic\n• Basil", sourceURL: "https://www.allrecipes.com/search?q=steamed+mussels+tomato+broth"),
        .init(id: UUID(), title: "Grilled Oysters", subtitle: "Seafood", duration: "25 min", persons: "4 person", ingredients: "• Oysters\n• Butter\n• Parmesan\n• Garlic\n• Lemon", sourceURL: "https://www.allrecipes.com/search?q=grilled+oysters"),
        .init(id: UUID(), title: "Oyster Rockefeller", subtitle: "Classic", duration: "40 min", persons: "4 person", ingredients: "• Oysters\n• Spinach\n• Butter\n• Breadcrumbs\n• Parmesan", sourceURL: "https://www.allrecipes.com/search?q=oyster+rockefeller"),
        .init(id: UUID(), title: "Calamari Fritti", subtitle: "Appetizer", duration: "30 min", persons: "4 person", ingredients: "• Squid rings\n• Flour\n• Cornstarch\n• Lemon\n• Marinara", sourceURL: "https://www.allrecipes.com/search?q=calamari+fritti"),
        .init(id: UUID(), title: "Grilled Squid with Lemon", subtitle: "Seafood", duration: "25 min", persons: "3 person", ingredients: "• Squid tubes\n• Olive oil\n• Garlic\n• Lemon\n• Parsley", sourceURL: "https://www.allrecipes.com/search?q=grilled+squid+lemon"),
        .init(id: UUID(), title: "Spanish Octopus", subtitle: "Seafood", duration: "90 min", persons: "4 person", ingredients: "• Octopus\n• Potatoes\n• Paprika\n• Olive oil\n• Sea salt", sourceURL: "https://www.allrecipes.com/search?q=spanish+octopus"),
        .init(id: UUID(), title: "Braised Octopus", subtitle: "Main dish", duration: "120 min", persons: "4 person", ingredients: "• Octopus\n• Tomatoes\n• Onion\n• Red wine\n• Bay leaf", sourceURL: "https://www.allrecipes.com/search?q=braised+octopus"),
        .init(id: UUID(), title: "Crab Cakes", subtitle: "Main dish", duration: "35 min", persons: "4 person", ingredients: "• Crab meat\n• Breadcrumbs\n• Mayo\n• Dijon\n• Parsley", sourceURL: "https://www.allrecipes.com/search?q=crab+cakes"),
        .init(id: UUID(), title: "Creamy Crab Dip", subtitle: "Appetizer", duration: "25 min", persons: "8 person", ingredients: "• Crab meat\n• Cream cheese\n• Sour cream\n• Cheddar\n• Old Bay", sourceURL: "https://www.allrecipes.com/search?q=creamy+crab+dip"),
        .init(id: UUID(), title: "Lobster Bisque", subtitle: "Soup", duration: "60 min", persons: "6 person", ingredients: "• Lobster meat\n• Stock\n• Cream\n• Tomato paste\n• Brandy", sourceURL: "https://www.allrecipes.com/search?q=lobster+bisque"),
        .init(id: UUID(), title: "Broiled Lobster Tails", subtitle: "Main dish", duration: "25 min", persons: "2 person", ingredients: "• Lobster tails\n• Butter\n• Garlic\n• Paprika\n• Lemon", sourceURL: "https://www.allrecipes.com/search?q=broiled+lobster+tails"),
        .init(id: UUID(), title: "Seared Scallops", subtitle: "Main dish", duration: "20 min", persons: "2 person", ingredients: "• Sea scallops\n• Butter\n• Garlic\n• Salt\n• Lemon", sourceURL: "https://www.allrecipes.com/search?q=seared+scallops"),
        .init(id: UUID(), title: "Scallop Risotto", subtitle: "Rice", duration: "50 min", persons: "4 person", ingredients: "• Scallops\n• Arborio rice\n• Broth\n• Parmesan\n• White wine", sourceURL: "https://www.allrecipes.com/search?q=scallop+risotto"),
        .init(id: UUID(), title: "Baked Mackerel", subtitle: "Main dish", duration: "30 min", persons: "4 person", ingredients: "• Mackerel fillets\n• Lemon\n• Garlic\n• Olive oil\n• Herbs", sourceURL: "https://www.allrecipes.com/search?q=baked+mackerel"),
        .init(id: UUID(), title: "Smoked Mackerel Pate", subtitle: "Spread", duration: "15 min", persons: "6 person", ingredients: "• Smoked mackerel\n• Cream cheese\n• Lemon zest\n• Dill\n• Pepper", sourceURL: "https://www.allrecipes.com/search?q=smoked+mackerel+pate"),
        .init(id: UUID(), title: "Classic Tuna Melt", subtitle: "Sandwich", duration: "20 min", persons: "2 person", ingredients: "• Canned tuna\n• Mayo\n• Bread\n• Cheddar\n• Onion", sourceURL: "https://www.allrecipes.com/search?q=classic+tuna+melt"),
        .init(id: UUID(), title: "Tuna Pasta Salad", subtitle: "Salad", duration: "25 min", persons: "6 person", ingredients: "• Tuna\n• Pasta\n• Mayo\n• Celery\n• Peas", sourceURL: "https://www.allrecipes.com/search?q=tuna+pasta+salad"),
        .init(id: UUID(), title: "Baked Cod with Tomatoes", subtitle: "Main dish", duration: "35 min", persons: "4 person", ingredients: "• Cod\n• Cherry tomatoes\n• Olives\n• Garlic\n• Basil", sourceURL: "https://www.allrecipes.com/search?q=baked+cod+tomatoes"),
        .init(id: UUID(), title: "Beer-Battered Fish", subtitle: "Main dish", duration: "30 min", persons: "4 person", ingredients: "• White fish\n• Beer\n• Flour\n• Baking powder\n• Salt", sourceURL: "https://www.allrecipes.com/search?q=beer+battered+fish"),
        .init(id: UUID(), title: "Salmon Patties", subtitle: "Main dish", duration: "30 min", persons: "4 person", ingredients: "• Salmon\n• Eggs\n• Onion\n• Breadcrumbs\n• Parsley", sourceURL: "https://www.allrecipes.com/search?q=salmon+patties"),
        .init(id: UUID(), title: "Teriyaki Salmon Bowls", subtitle: "Bowl", duration: "35 min", persons: "4 person", ingredients: "• Salmon\n• Teriyaki sauce\n• Rice\n• Broccoli\n• Sesame seeds", sourceURL: "https://www.allrecipes.com/search?q=teriyaki+salmon+bowls"),
        .init(id: UUID(), title: "Creamy Salmon Chowder", subtitle: "Soup", duration: "45 min", persons: "6 person", ingredients: "• Salmon\n• Potatoes\n• Cream\n• Celery\n• Onion", sourceURL: "https://www.allrecipes.com/search?q=salmon+chowder"),
        .init(id: UUID(), title: "Pesto Baked Trout", subtitle: "Main dish", duration: "30 min", persons: "2 person", ingredients: "• Trout fillets\n• Pesto\n• Lemon\n• Olive oil\n• Parmesan", sourceURL: "https://www.allrecipes.com/search?q=pesto+baked+trout"),
        .init(id: UUID(), title: "Mediterranean Sea Bass", subtitle: "Main dish", duration: "35 min", persons: "2 person", ingredients: "• Sea bass\n• Tomatoes\n• Olives\n• Capers\n• Lemon", sourceURL: "https://www.allrecipes.com/search?q=mediterranean+sea+bass"),
        .init(id: UUID(), title: "Dorado in Foil", subtitle: "Main dish", duration: "35 min", persons: "2 person", ingredients: "• Dorado\n• Lemon\n• Garlic\n• Parsley\n• Olive oil", sourceURL: "https://www.allrecipes.com/search?q=dorado+fish+foil"),
        .init(id: UUID(), title: "Baked Flounder", subtitle: "Main dish", duration: "25 min", persons: "4 person", ingredients: "• Flounder fillets\n• Butter\n• Lemon\n• Paprika\n• Parsley", sourceURL: "https://www.allrecipes.com/search?q=baked+flounder"),
        .init(id: UUID(), title: "Shrimp Fried Rice", subtitle: "Rice", duration: "25 min", persons: "4 person", ingredients: "• Shrimp\n• Rice\n• Eggs\n• Peas\n• Soy sauce", sourceURL: "https://www.allrecipes.com/search?q=shrimp+fried+rice"),
        .init(id: UUID(), title: "Shrimp Curry", subtitle: "Main dish", duration: "35 min", persons: "4 person", ingredients: "• Shrimp\n• Coconut milk\n• Curry paste\n• Onion\n• Cilantro", sourceURL: "https://www.allrecipes.com/search?q=shrimp+curry"),
        .init(id: UUID(), title: "Mussels Marinara", subtitle: "Seafood", duration: "30 min", persons: "4 person", ingredients: "• Mussels\n• Tomato sauce\n• Garlic\n• Basil\n• Olive oil", sourceURL: "https://www.allrecipes.com/search?q=mussels+marinara"),
        .init(id: UUID(), title: "Lemon Garlic Scallop Pasta", subtitle: "Pasta", duration: "30 min", persons: "4 person", ingredients: "• Scallops\n• Pasta\n• Garlic\n• Butter\n• Lemon", sourceURL: "https://www.allrecipes.com/search?q=lemon+garlic+scallop+pasta"),
        .init(id: UUID(), title: "Tuna Poke Bowl", subtitle: "Bowl", duration: "20 min", persons: "2 person", ingredients: "• Tuna\n• Rice\n• Soy sauce\n• Avocado\n• Sesame", sourceURL: "https://www.allrecipes.com/search?q=tuna+poke+bowl"),
        .init(id: UUID(), title: "Seafood Paella", subtitle: "Rice", duration: "55 min", persons: "6 person", ingredients: "• Shrimp\n• Mussels\n• Squid\n• Rice\n• Saffron", sourceURL: "https://www.allrecipes.com/search?q=seafood+paella"),
        .init(id: UUID(), title: "Cioppino Seafood Stew", subtitle: "Stew", duration: "60 min", persons: "6 person", ingredients: "• Fish fillets\n• Shrimp\n• Mussels\n• Tomatoes\n• White wine", sourceURL: "https://www.allrecipes.com/search?q=cioppino+seafood+stew"),
        .init(id: UUID(), title: "Baked Haddock", subtitle: "Main dish", duration: "30 min", persons: "4 person", ingredients: "• Haddock\n• Butter\n• Cracker crumbs\n• Lemon\n• Dill", sourceURL: "https://www.allrecipes.com/search?q=baked+haddock"),
        .init(id: UUID(), title: "Fish and Chips", subtitle: "Classic", duration: "40 min", persons: "4 person", ingredients: "• White fish\n• Potatoes\n• Flour\n• Beer\n• Oil", sourceURL: "https://www.allrecipes.com/search?q=fish+and+chips"),
        .init(id: UUID(), title: "Sardine Pasta", subtitle: "Pasta", duration: "25 min", persons: "4 person", ingredients: "• Sardines\n• Spaghetti\n• Garlic\n• Chili flakes\n• Parsley", sourceURL: "https://www.allrecipes.com/search?q=sardine+pasta"),
        .init(id: UUID(), title: "Anchovy Garlic Toasts", subtitle: "Appetizer", duration: "15 min", persons: "4 person", ingredients: "• Anchovies\n• Baguette\n• Garlic\n• Olive oil\n• Parsley", sourceURL: "https://www.allrecipes.com/search?q=anchovy+toasts"),
        .init(id: UUID(), title: "Smoked Salmon Bagel", subtitle: "Breakfast", duration: "10 min", persons: "2 person", ingredients: "• Smoked salmon\n• Bagels\n• Cream cheese\n• Capers\n• Red onion", sourceURL: "https://www.allrecipes.com/search?q=smoked+salmon+bagel"),
        .init(id: UUID(), title: "Salmon Caesar Salad", subtitle: "Salad", duration: "25 min", persons: "2 person", ingredients: "• Salmon\n• Romaine\n• Parmesan\n• Croutons\n• Caesar dressing", sourceURL: "https://www.allrecipes.com/search?q=salmon+caesar+salad"),
        .init(id: UUID(), title: "Seafood Lasagna", subtitle: "Pasta", duration: "75 min", persons: "8 person", ingredients: "• Shrimp\n• Crab\n• Lasagna sheets\n• Ricotta\n• Mozzarella", sourceURL: "https://www.allrecipes.com/search?q=seafood+lasagna"),
        .init(id: UUID(), title: "Shrimp Etouffee", subtitle: "Stew", duration: "45 min", persons: "6 person", ingredients: "• Shrimp\n• Roux\n• Onion\n• Bell pepper\n• Celery", sourceURL: "https://www.allrecipes.com/search?q=shrimp+etouffee"),
        .init(id: UUID(), title: "Lemon Pepper Tilapia", subtitle: "Main dish", duration: "20 min", persons: "4 person", ingredients: "• Tilapia\n• Lemon pepper\n• Butter\n• Garlic\n• Parsley", sourceURL: "https://www.allrecipes.com/search?q=lemon+pepper+tilapia"),
        .init(id: UUID(), title: "Seafood Gumbo", subtitle: "Stew", duration: "75 min", persons: "8 person", ingredients: "• Shrimp\n• Crab\n• Fish\n• Okra\n• Roux", sourceURL: "https://www.allrecipes.com/search?q=seafood+gumbo")
    ]

    static let defaultTemplates: [ChecklistTemplate] = [
        .init(id: UUID(), title: "Whole Fish", icon: "🐟", products: ["salmon", "trout", "dorado", "sea bass"], items: [
            .init(id: UUID(), title: "Eyes", goodOption: "Clear", badOption: "Cloudy"),
            .init(id: UUID(), title: "Grills", goodOption: "Red", badOption: "Brown"),
            .init(id: UUID(), title: "Smell", goodOption: "Ocean", badOption: "Sour"),
            .init(id: UUID(), title: "Scales", goodOption: "Shiny", badOption: "Dull"),
            .init(id: UUID(), title: "Texture", goodOption: "Firm", badOption: "Soft")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Fish Fillet", icon: "🥩", products: ["cod", "halibut", "tuna"], items: [
            .init(id: UUID(), title: "Meat color", goodOption: "Even", badOption: "Spots"),
            .init(id: UUID(), title: "Smell", goodOption: "Clean", badOption: "Sour"),
            .init(id: UUID(), title: "Texture", goodOption: "Firm", badOption: "Loose"),
            .init(id: UUID(), title: "Moisture", goodOption: "Natural", badOption: "Dry")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Shrimp", icon: "🦐", products: ["shrimp"], items: [
            .init(id: UUID(), title: "Color", goodOption: "Pink", badOption: "Gray"),
            .init(id: UUID(), title: "Smell", goodOption: "Sea", badOption: "Ammonia"),
            .init(id: UUID(), title: "Tail", goodOption: "Bent", badOption: "Straight"),
            .init(id: UUID(), title: "Shell", goodOption: "Whole", badOption: "Damaged")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Shell Mollusks", icon: "🦪", products: ["mussels", "oysters", "scallop"], items: [
            .init(id: UUID(), title: "Shell", goodOption: "Closed", badOption: "Open"),
            .init(id: UUID(), title: "Smell", goodOption: "Sea", badOption: "Sour"),
            .init(id: UUID(), title: "Weight", goodOption: "Heavy", badOption: "Light"),
            .init(id: UUID(), title: "Tap reaction", goodOption: "Reactive", badOption: "No reaction")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Squid & Octopus", icon: "🦑", products: ["squid", "octopus"], items: [
            .init(id: UUID(), title: "Elasticity", goodOption: "Firm", badOption: "Soft"),
            .init(id: UUID(), title: "Color", goodOption: "Natural", badOption: "Yellowish"),
            .init(id: UUID(), title: "Smell", goodOption: "Sea", badOption: "Sharp"),
            .init(id: UUID(), title: "Surface", goodOption: "No slime", badOption: "Slimy")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Crustaceans", icon: "🦀", products: ["crab", "lobster", "crayfish"], items: [
            .init(id: UUID(), title: "Activity", goodOption: "Active", badOption: "Sluggish"),
            .init(id: UUID(), title: "Weight", goodOption: "Heavy", badOption: "Light"),
            .init(id: UUID(), title: "Shell", goodOption: "Hard", badOption: "Soft"),
            .init(id: UUID(), title: "Smell", goodOption: "Sea", badOption: "Sour")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Sashimi Fish", icon: "🍣", products: ["tuna", "salmon"], items: [
            .init(id: UUID(), title: "Color", goodOption: "Bright", badOption: "Dull"),
            .init(id: UUID(), title: "Texture", goodOption: "Firm", badOption: "Loose"),
            .init(id: UUID(), title: "Smell", goodOption: "Neutral", badOption: "Strong"),
            .init(id: UUID(), title: "Cut date", goodOption: "Today", badOption: "Unknown")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Frozen Seafood", icon: "🧊", products: ["frozen"], items: [
            .init(id: UUID(), title: "Package", goodOption: "Intact", badOption: "Damaged"),
            .init(id: UUID(), title: "Ice", goodOption: "No excess", badOption: "Too much"),
            .init(id: UUID(), title: "Color", goodOption: "Natural", badOption: "Changed"),
            .init(id: UUID(), title: "Smell after thaw", goodOption: "Clean", badOption: "Sour")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Canned Fish", icon: "🥫", products: ["canned", "sardines"], items: [
            .init(id: UUID(), title: "Can", goodOption: "No dents", badOption: "Damaged"),
            .init(id: UUID(), title: "Expiry", goodOption: "Valid", badOption: "Expired"),
            .init(id: UUID(), title: "Smell", goodOption: "Normal", badOption: "Off"),
            .init(id: UUID(), title: "Color", goodOption: "Natural", badOption: "Dark")
        ], isUserTemplate: false),
        .init(id: UUID(), title: "Soup Fish", icon: "🍲", products: ["zander", "perch", "soup"], items: [
            .init(id: UUID(), title: "Grills", goodOption: "Red", badOption: "Brown"),
            .init(id: UUID(), title: "Eyes", goodOption: "Clear", badOption: "Cloudy"),
            .init(id: UUID(), title: "Texture", goodOption: "Firm", badOption: "Soft"),
            .init(id: UUID(), title: "Smell", goodOption: "Sea", badOption: "Sour")
        ], isUserTemplate: false)
    ]
}
