import SwiftUI
import PhotosUI

struct AddFishScreen: View {
    @EnvironmentObject private var store: AppDataStore
    private let rawScale: CGFloat
    let onBack: () -> Void
    let onSaved: () -> Void
    var initialTemplateTitle: String? = nil

    @State private var fishName = ""
    @State private var market = ""
    @State private var purchaseDate = Date()
    @State private var pricePerKg = ""
    @State private var notes = ""
    @State private var rating: Double = 3.5
    @State private var showFreshAnalysis = true
    @State private var checklist: [ChecklistDecision] = []
    @State private var isChecklistAutoMode = true
    @State private var showDatePickerSheet = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var pickedImages: [PickedImage] = []
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case fishName
        case market
        case price
        case notes
    }

    private struct PickedImage: Identifiable, Equatable {
        let id = UUID()
        let image: UIImage
    }

    private var scale: CGFloat {
        guard rawScale.isFinite, rawScale > 0 else { return 1.0 }
        return min(max(rawScale, 0.82), 1.15)
    }

    init(scale: CGFloat, onBack: @escaping () -> Void, onSaved: @escaping () -> Void, initialTemplateTitle: String? = nil) {
        self.rawScale = scale
        self.onBack = onBack
        self.onSaved = onSaved
        self.initialTemplateTitle = initialTemplateTitle
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24 * scale) {
                    titleBlock
                    identificationCard
                    freshnessCard
                    ratingCard
                    notesCard
                    if showFreshAnalysis {
                        freshAnalysisCard
                    }
                    saveButton
                }
                .padding(.horizontal, 16 * scale)
                .padding(.top, 24 * scale)
                .padding(.bottom, 20 * scale)
            }
        }
        .onAppear {
            guard checklist.isEmpty else { return }
            if let initialTemplateTitle,
               let template = store.template(by: initialTemplateTitle) {
                checklist = template.items.map {
                    ChecklistDecision(title: $0.title, goodOption: $0.goodOption, badOption: $0.badOption, selectedGood: true)
                }
                isChecklistAutoMode = false
            } else {
                checklist = store.checklistForProduct(fishName)
            }
        }
        .onChange(of: fishName) { newValue in
            guard isChecklistAutoMode else { return }
            checklist = store.checklistForProduct(newValue)
        }
        .sheet(isPresented: $showDatePickerSheet) {
            datePickerSheet
                .presentationDetents([.height(520 * scale)])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: selectedPhotoItems) { items in
            Task {
                var images: [PickedImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(PickedImage(image: image))
                    }
                }
                if !images.isEmpty {
                    pickedImages.append(contentsOf: images)
                }
                // Clear picker selection to avoid re-applying stale items.
                selectedPhotoItems = []
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if focusedField == .price {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                Circle()
                    .fill(Color(red: 0.169, green: 0.098, blue: 0.706))
                    .frame(width: 42 * scale, height: 42 * scale)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15 * scale, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(SoundPlainButtonStyle())

            Spacer()

            Text("Add fish")
                .font(.system(size: 26 * scale, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

            Spacer()
            Color.clear.frame(width: 42 * scale, height: 42 * scale)
        }
        .padding(.horizontal, 16 * scale)
        .frame(height: 42 * scale)
        .padding(.top, 16 * scale)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8 * scale) {
            Text("Freshness Checker")
                .font(.system(size: 36 * scale, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text("Detailed evaluation of your latest\nmaritimw acquisition")
                .font(.system(size: 24 * scale, weight: .regular))
                .foregroundStyle(.black.opacity(0.5))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
    }

    private var identificationCard: some View {
        VStack(alignment: .leading, spacing: 10 * scale) {
            inputBlock(title: "Product Identification", text: $fishName, placeholder: "Product Name", field: .fishName)
            inputBlock(title: "Market", text: $market, placeholder: "Place of Purchase", field: .market)
            dateInputBlock

            VStack(alignment: .leading, spacing: 12 * scale) {
                Text("Image")
                    .font(.system(size: 17 * scale, weight: .medium))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8 * scale) {
                        addPhotoTile
                        ForEach(pickedImages) { item in
                            fishPhotoTile(image: item.image, size: 100 * scale) {
                                pickedImages.removeAll { $0.id == item.id }
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 20 * scale)
        .padding(.horizontal, 16 * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private var freshnessCard: some View {
        VStack(alignment: .leading, spacing: 24 * scale) {
            Text("Freshness Checklist")
                .font(.system(size: 24 * scale, weight: .semibold))

            VStack(spacing: 24 * scale) {
                ForEach(Array(checklist.enumerated()), id: \.element.id) { index, row in
                    HStack {
                        Text(row.title)
                            .font(.system(size: 20 * scale, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                        HStack(spacing: 12 * scale) {
                            checklistOption(title: row.goodOption, selected: row.selectedGood) {
                                checklist[index].selectedGood = true
                            }
                            checklistOption(title: row.badOption, selected: !row.selectedGood) {
                                checklist[index].selectedGood = false
                            }
                        }
                        .padding(12 * scale)
                        .background(Color(red: 0.91, green: 0.91, blue: 0.965))
                        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
                    }
                }
            }
        }
        .padding(.vertical, 20 * scale)
        .padding(.horizontal, 16 * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 24 * scale) {
            Text("Holistic Rating")
                .font(.system(size: 24 * scale, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8 * scale) {
                HStack {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18 * scale, height: 18 * scale)
                        .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0.0))
                    Spacer()
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18 * scale, height: 18 * scale)
                        .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0.0))
                }
                .frame(height: 18 * scale)

                ratingSliderSection
            }
            .frame(minHeight: 59 * scale)
        }
        .padding(.vertical, 20 * scale)
        .padding(.horizontal, 16 * scale)
        .frame(maxWidth: .infinity, minHeight: 151 * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private var ratingSliderSection: some View {
        VStack(spacing: 6 * scale) {
            Slider(
                value: $rating,
                in: 0...5,
                step: 0.1
            )
            .tint(Color(red: 0.169, green: 0.098, blue: 0.706))

            HStack {
                Text("0.0")
                Spacer()
                Text(String(format: "%.1f", rating))
                Spacer()
                Text("5.0")
            }
            .font(.system(size: 12 * scale, weight: .regular))
            .foregroundStyle(.black.opacity(0.5))
        }
        .frame(minHeight: 33 * scale)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            inputBlock(
                title: "Price per kg",
                text: $pricePerKg,
                placeholder: "$ 0.00",
                field: .price,
                keyboardType: .decimalPad
            )
            VStack(alignment: .leading, spacing: 12 * scale) {
                Text("Notes")
                    .font(.system(size: 17 * scale, weight: .semibold))
                TextField("Observation details, recipe...", text: $notes)
                    .font(.system(size: 17 * scale, weight: .regular))
                    .padding(16 * scale)
                    .frame(minHeight: 124 * scale, alignment: .topLeading)
                    .background(Color(red: 0.91, green: 0.91, blue: 0.965))
                    .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
                    .focused($focusedField, equals: .notes)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
            }
        }
        .padding(.vertical, 20 * scale)
        .padding(.horizontal, 16 * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private var saveButton: some View {
        Button(action: saveAssessment) {
            Text("Save to Archive")
                .font(.system(size: 20 * scale, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: 56 * scale)
                .background(Color(red: 0.169, green: 0.098, blue: 0.706))
                .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
        }
        .buttonStyle(SoundPlainButtonStyle())
    }

    private var freshAnalysisCard: some View {
        let evaluation = FreshnessEngine.evaluate(checklist: checklist, rating: rating)
        return VStack(alignment: .leading, spacing: 24 * scale) {
            HStack(spacing: 12 * scale) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 20 * scale))
                    .foregroundStyle(.white)
                Text("ANALYSIS COMPLETE")
                    .font(.system(size: 17 * scale, weight: .regular))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            VStack(alignment: .leading, spacing: 16 * scale) {
                Text(verdictHeadline(evaluation.verdict))
                    .font(.system(size: 40 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(verdictBody(evaluation.verdict))
                    .font(.system(size: 17 * scale, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .bottom, spacing: 8 * scale) {
                HStack(alignment: .bottom, spacing: 4 * scale) {
                    Text("\(evaluation.score)")
                        .font(.system(size: 24 * scale, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("/ 100")
                        .font(.system(size: 17 * scale, weight: .regular))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Text("freshness score")
                    .font(.system(size: 17 * scale, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 32 * scale)
        .padding(.horizontal, 16 * scale)
        .frame(maxWidth: .infinity, minHeight: 272 * scale, alignment: .leading)
        .background(Color(red: 0.169, green: 0.098, blue: 0.706))
        .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
    }

    private var addPhotoTile: some View {
        PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 3, matching: .images) {
            VStack(spacing: 4 * scale) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 25 * scale))
                    .foregroundStyle(Color(red: 0.663, green: 0.663, blue: 0.773))
                Text("PHOTO")
                    .font(.system(size: 12 * scale, weight: .regular))
                    .foregroundStyle(Color(red: 0.663, green: 0.663, blue: 0.773))
            }
            .frame(width: 100 * scale, height: 100 * scale)
            .overlay(
                RoundedRectangle(cornerRadius: 34 * scale, style: .continuous)
                    .stroke(Color(red: 0.663, green: 0.663, blue: 0.773), style: StrokeStyle(lineWidth: 1 * scale, dash: [5 * scale]))
            )
        }
        .buttonStyle(SoundPlainButtonStyle())
    }

    private func fishPhotoTile(image: UIImage, size: CGFloat, onDelete: @escaping () -> Void) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 34 * scale, style: .continuous))

            Button(action: onDelete) {
                Circle()
                    .fill(.red)
                    .frame(width: 24 * scale, height: 24 * scale)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 8 * scale, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(SoundPlainButtonStyle())
            .padding(.top, 2 * scale)
            .padding(.trailing, 2 * scale)
        }
    }

    private func checklistOption(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17 * scale, weight: .semibold))
                .foregroundStyle(selected ? .white : .black.opacity(0.5))
                .padding(.horizontal, 8 * scale)
                .frame(width: 72 * scale, height: 28 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 8 * scale, style: .continuous)
                        .fill(selected ? Color(red: 0.169, green: 0.098, blue: 0.706) : .clear)
                )
        }
        .buttonStyle(SoundPlainButtonStyle())
    }

    private func inputBlock(
        title: String,
        text: Binding<String>,
        placeholder: String,
        field: Field,
        trailingIcon: String? = nil,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            Text(title)
                .font(.system(size: 17 * scale, weight: .semibold))
            HStack {
                TextField(placeholder, text: text)
                    .font(.system(size: 17 * scale, weight: .regular))
                    .foregroundStyle(.black.opacity(0.6))
                    .keyboardType(keyboardType)
                    .focused($focusedField, equals: field)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                if let trailingIcon {
                    Image(trailingIcon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20 * scale, height: 20 * scale)
                        .foregroundStyle(.black.opacity(0.5))
                }
            }
            .padding(16 * scale)
            .frame(height: 52 * scale)
            .background(Color(red: 0.91, green: 0.91, blue: 0.965))
            .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
        }
    }

    private var dateInputBlock: some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            Text("Date of Purchase")
                .font(.system(size: 17 * scale, weight: .semibold))
            Button {
                showDatePickerSheet = true
            } label: {
                HStack {
                    Text(formattedPurchaseDate)
                        .font(.system(size: 17 * scale, weight: .regular))
                        .foregroundStyle(.black.opacity(0.6))
                    Spacer()
                    Image("lets-icons_date-fill")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20 * scale, height: 20 * scale)
                        .foregroundStyle(.black.opacity(0.5))
                }
                .padding(16 * scale)
                .frame(height: 52 * scale)
                .background(Color(red: 0.91, green: 0.91, blue: 0.965))
                .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
            }
            .buttonStyle(SoundPlainButtonStyle())
        }
    }

    private var datePickerSheet: some View {
        VStack(spacing: 16 * scale) {
            Text("Select Purchase Date")
                .font(.system(size: 20 * scale, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            DatePicker(
                "",
                selection: $purchaseDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(Color(red: 0.169, green: 0.098, blue: 0.706))
            .padding(.horizontal, 8 * scale)
            .background(Color(red: 0.965, green: 0.98, blue: 0.996))
            .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))

            Button {
                showDatePickerSheet = false
            } label: {
                Text("Done")
                    .font(.system(size: 20 * scale, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52 * scale)
                    .background(Color(red: 0.169, green: 0.098, blue: 0.706))
                    .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
            }
            .buttonStyle(SoundPlainButtonStyle())
        }
        .padding(16 * scale)
        .background(Color.white)
    }

    private var formattedPurchaseDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: purchaseDate)
    }

    private func saveAssessment() {
        let name = fishName.trimmingCharacters(in: .whitespacesAndNewlines)
        let place = market.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !place.isEmpty else { return }

        let priceText = pricePerKg
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let parsedPrice = Double(priceText)
        let checklistData = checklist

        store.addAssessment(
            productName: name,
            purchasePlace: place,
            purchaseDate: purchaseDate,
            pricePerKg: parsedPrice,
            note: notes,
            rating: rating,
            checklist: checklistData
        )
        onSaved()
    }

    private func verdictHeadline(_ verdict: FreshnessVerdict) -> String {
        switch verdict {
        case .excellent: return "Fresh"
        case .medium: return "Use Today"
        case .poor: return "Not Fresh"
        }
    }

    private func verdictBody(_ verdict: FreshnessVerdict) -> String {
        switch verdict {
        case .excellent:
            return "Based on the provided metrics, this specimen is in peak condition for consumption. Suitable for raw preparation or light searing."
        case .medium:
            return "Quality is acceptable but should be cooked immediately. Prefer thorough heat treatment and avoid long storage."
        case .poor:
            return "This specimen shows multiple spoilage signs. Cooking is not recommended for safety reasons."
        }
    }
}

#Preview {
    AddFishScreen(scale: 1.0, onBack: {}, onSaved: {})
        .environmentObject(AppDataStore())
}
