//
//  KnowledgeBaseView.swift
//  BufalloSteaklovers
//
//  Screen 4 — Knowledge Base (Library): categories + knowledge cards (Figma 390×844).
//

import SwiftUI

// MARK: - Models

private enum LibraryCategory: Int, CaseIterable, Identifiable {
    case meatCuts
    case doneness
    case tips
    case spices

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .meatCuts: return "Meat Cuts"
        case .doneness: return "Doneness"
        case .tips: return "Tips"
        case .spices: return "Spices"
        }
    }

    var systemImage: String {
        switch self {
        case .meatCuts: return "fork.knife"
        case .doneness: return "flame"
        case .tips: return "lightbulb"
        case .spices: return "sparkles"
        }
    }
}

private struct MeatCutKnowledge: Identifiable {
    var id: String { title }
    let title: String
    let description: String
    let idealThickness: String
    let imageAssetName: String
}

private struct DonenessKnowledge: Identifiable {
    var id: String { title }
    let title: String
    /// Short line under title (`#D7CCC8`, 12 pt).
    let subtitle: String
    /// Right-aligned, `#FF5722`, 12 pt semibold (e.g. `46–49°C`).
    let tempRange: String
    /// Meat color swatch (`Ellipse 7`, 51×51).
    let swatchHex: String
}

private struct TipKnowledge: Identifiable {
    var id: String { title }
    let title: String
    let description: String
    /// Figma: single-line body → `83` pt; two-line body → `97` pt.
    let tallCard: Bool
}

private struct SpiceKnowledge: Identifiable {
    var id: String { title }
    let title: String
    let description: String
    /// Asset catalog name (Figma exports in `Assets.xcassets`).
    let imageAssetName: String
}

// MARK: - Content

private enum KnowledgeRepository {
    static let meatCuts: [MeatCutKnowledge] = [
        .init(title: "Ribeye", description: "Marbled, juicy, with a fat cap", idealThickness: "3–4 cm", imageAssetName: "1"),
        .init(title: "Striploin", description: "Leaner than ribeye, rich beef flavor", idealThickness: "3–4 cm", imageAssetName: "2"),
        .init(title: "T-Bone", description: "Filet + striploin, bone in the middle", idealThickness: "4–5 cm", imageAssetName: "3"),
        .init(title: "Filet Mignon", description: "Most tender, very low fat", idealThickness: "4–5 cm", imageAssetName: "4"),
        .init(title: "New York Strip", description: "Similar to striploin, firm texture", idealThickness: "3 cm", imageAssetName: "5"),
        .init(title: "Tomahawk", description: "Ribeye with long bone", idealThickness: "5–6 cm", imageAssetName: "6"),
        .init(title: "Picanha", description: "Fat cap on top, tender meat", idealThickness: "3–4 cm", imageAssetName: "7"),
        .init(title: "Flat Iron", description: "Flat, marbled, budget-friendly", idealThickness: "2–3 cm", imageAssetName: "8"),
        .init(title: "Denver", description: "Marbled, from chuck, tender", idealThickness: "2–3 cm", imageAssetName: "9"),
        .init(title: "Vegas Strip", description: "Short rib cut, very fatty", idealThickness: "3–4 cm", imageAssetName: "10")
    ]

    static let doneness: [DonenessKnowledge] = [
        .init(title: "Blue Rare", subtitle: "Cold red center", tempRange: "46–49°C", swatchHex: "6A1B9A"),
        .init(title: "Rare", subtitle: "Warm red center", tempRange: "50–52°C", swatchHex: "D32F2F"),
        .init(title: "Medium Rare", subtitle: "Warm pink center", tempRange: "53–55°C", swatchHex: "FF5252"),
        .init(title: "Medium", subtitle: "Pink, springy", tempRange: "56–60°C", swatchHex: "FF8A80"),
        .init(title: "Medium Well", subtitle: "Slightly pink", tempRange: "61–65°C", swatchHex: "8D6E63"),
        .init(title: "Well Done", subtitle: "Dark brown throughout", tempRange: "66°C+", swatchHex: "F95F00")
    ]

    static let tips: [TipKnowledge] = [
        .init(title: "Meat Temperature", description: "Take the meat out 1 hour before cooking", tallCard: false),
        .init(title: "Drying", description: "Pat the steak dry with a paper towel before cooking", tallCard: true),
        .init(title: "Salt", description: "Salt 40 minutes before cooking or right before", tallCard: true),
        .init(title: "Oil", description: "Add butter only at the end", tallCard: false),
        .init(title: "Garlic", description: "Don’t add garlic at the beginning — it will burn", tallCard: false),
        .init(title: "Flipping", description: "Flip every 30 seconds for even cooking", tallCard: false),
        .init(title: "Resting", description: "Resting time = 50% of cooking time", tallCard: false),
        .init(title: "Thermometer", description: "Measure at the thickest part, avoid touching bone", tallCard: true),
        .init(title: "Pan", description: "Cast iron retains heat better than steel", tallCard: false),
        .init(title: "Smoke", description: "Oil smoke point matters (avocado > olive oil)", tallCard: false)
    ]

    static let spices: [SpiceKnowledge] = [
        .init(title: "Hickory", description: "Strong smoke, for beef", imageAssetName: "_35"),
        .init(title: "Cherry", description: "Sweet smoke, for poultry and pork", imageAssetName: "Frame-2"),
        .init(title: "Rosemary", description: "Aromatizing butter at the end", imageAssetName: "Capa_1"),
        .init(title: "Thyme", description: "Aromatizing butter at the end", imageAssetName: "Capa_1-2")
    ]
}

// MARK: - Tips icon (Figma: `49×43`, stroke `rgba(255,193,7,0.5)`)

private struct TipsLightbulbGlyph: View {
    var scale: CGFloat

    private var accent: Color { Color(steakHex: "FFC107").opacity(0.5) }

    var body: some View {
        let w = fpScale(49, scale)
        let h = fpScale(43, scale)
        let line = max(2, fpScale(3.5, scale))

        Canvas { context, size in
            let domeRect = CGRect(
                x: size.width * 0.22,
                y: size.height * 0.06,
                width: size.width * 0.56,
                height: size.height * 0.52
            )
            var dome = Path()
            dome.addEllipse(in: domeRect)
            context.stroke(dome, with: .color(accent), lineWidth: line)

            func hLine(_ yFrac: CGFloat, x0: CGFloat, x1: CGFloat) {
                var p = Path()
                p.move(to: CGPoint(x: size.width * x0, y: size.height * yFrac))
                p.addLine(to: CGPoint(x: size.width * x1, y: size.height * yFrac))
                context.stroke(p, with: .color(accent), lineWidth: line)
            }
            hLine(0.75, x0: 0.375, x1: 0.625)
            hLine(0.9167, x0: 0.4167, x1: 0.5833)
        }
        .frame(width: w, height: h)
        .accessibilityHidden(true)
    }
}

// MARK: - Shapes

/// Left edge of a `103×103` tile matches card corner `16` (Figma).
private struct KnowledgeCardImageMask: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let r = min(radius, min(rect.width, rect.height) / 2)
        var p = Path()
        p.move(to: CGPoint(x: r, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: r, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: 0, y: rect.maxY - r), control: CGPoint(x: 0, y: rect.maxY))
        p.addLine(to: CGPoint(x: 0, y: r))
        p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
        p.closeSubpath()
        return p
    }
}

// MARK: - Category chip

private struct LibraryCategoryChip: View {
    @Environment(\.layoutScale) private var scale
    let category: LibraryCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: fpScale(4, scale)) {
                Image(systemName: category.systemImage)
                    .font(.system(size: fpScale(14, scale), weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color(steakHex: "A1887F"))
                    .frame(width: fpScale(16, scale), height: fpScale(16, scale))

                Text(category.title)
                    .font(.system(size: fpScale(13, scale), weight: .bold))
                    .foregroundStyle(isSelected ? Color.white : Color(steakHex: "A1887F"))
                    .lineLimit(1)
            }
            .padding(.vertical, fpScale(8, scale))
            .padding(.horizontal, fpScale(12, scale))
            .background(isSelected ? Color(steakHex: "FF5722") : Color(steakHex: "3E2723"))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
            )
        }
        .buttonStyle(SteakSoundPlainButtonStyle())
    }
}

// MARK: - Card

private struct KnowledgeMeatCard: View {
    @Environment(\.layoutScale) private var scale
    let item: MeatCutKnowledge

    var body: some View {
        KnowledgeCardRow(
            title: item.title,
            description: item.description,
            footer: "Ideal thickness: \(item.idealThickness)",
            imageAssetName: item.imageAssetName,
            scale: scale
        )
    }
}

private struct KnowledgeDonenessCard: View {
    @Environment(\.layoutScale) private var scale
    let item: DonenessKnowledge

    private var cardHeight: CGFloat { fpScale(83, scale) }
    private var swatch: CGFloat { fpScale(51, scale) }
    private var corner: CGFloat { fpScale(16, scale) }

    var body: some View {
        HStack(alignment: .center, spacing: fpScale(8, scale)) {
            Circle()
                .fill(Color(steakHex: item.swatchHex))
                .frame(width: swatch, height: swatch)

            VStack(alignment: .leading, spacing: fpScale(8, scale)) {
                Text(item.title)
                    .font(.system(size: fpScale(18, scale), weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(item.subtitle)
                    .font(.system(size: fpScale(12, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "D7CCC8"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(item.tempRange)
                .font(.system(size: fpScale(12, scale), weight: .semibold))
                .foregroundStyle(Color(steakHex: "FF5722"))
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, fpScale(16, scale))
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }
}

private struct KnowledgeTipCard: View {
    @Environment(\.layoutScale) private var scale
    let item: TipKnowledge

    private var cardHeight: CGFloat {
        fpScale(item.tallCard ? 97 : 83, scale)
    }

    private var corner: CGFloat { fpScale(16, scale) }

    var body: some View {
        HStack(alignment: .center, spacing: fpScale(6, scale)) {
            VStack(alignment: .leading, spacing: fpScale(8, scale)) {
                Text(item.title)
                    .font(.system(size: fpScale(18, scale), weight: .bold))
                    .foregroundStyle(Color(steakHex: "FFC107"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(item.description)
                    .font(.system(size: fpScale(12, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "D7CCC8"))
                    .lineSpacing(fpScale(2, scale))
                    .lineLimit(item.tallCard ? 3 : 2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            TipsLightbulbGlyph(scale: scale)
        }
        .padding(.vertical, fpScale(20, scale))
        .padding(.horizontal, fpScale(16, scale))
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }
}

/// Figma Group 39 / cards `1`–`4`: 342×83, padding 20×16, row gap 6, icon 43×43, text column gap 8, radius 16.
private struct KnowledgeSpiceCard: View {
    @Environment(\.layoutScale) private var scale
    let item: SpiceKnowledge

    private var cardH: CGFloat { fpScale(83, scale) }
    private var iconSide: CGFloat { fpScale(43, scale) }
    private var corner: CGFloat { fpScale(16, scale) }
    private var rowGap: CGFloat { fpScale(6, scale) }
    private var textColGap: CGFloat { fpScale(8, scale) }
    private var contentW: CGFloat { fpScale(342, scale) }

    var body: some View {
        HStack(alignment: .center, spacing: rowGap) {
            Image(item.imageAssetName)
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: iconSide, height: iconSide)
                .accessibilityLabel(item.title)

            VStack(alignment: .leading, spacing: textColGap) {
                Text(item.title)
                    .font(.system(size: fpScale(18, scale), weight: .bold))
                    .foregroundStyle(Color(steakHex: "FFC107"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(item.description)
                    .font(.system(size: fpScale(12, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "D7CCC8"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .lineSpacing(fpScale(2, scale))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, fpScale(20, scale))
        .padding(.horizontal, fpScale(16, scale))
        .frame(maxWidth: contentW)
        .frame(height: cardH)
        .frame(maxWidth: .infinity)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }
}

private struct KnowledgeCardRow: View {
    let title: String
    let description: String
    /// Uppercase amber line (thickness / internal temp / etc.).
    let footer: String
    var imageAssetName: String? = nil
    let scale: CGFloat

    private var cardHeight: CGFloat { fpScale(103, scale) }
    private var imgSide: CGFloat { fpScale(103, scale) }
    private var corner: CGFloat { fpScale(16, scale) }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Group {
                if let name = imageAssetName {
                    Image(name)
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFill()
                        .frame(width: imgSide, height: imgSide)
                        .clipped()
                } else {
                    ZStack {
                        Color(steakHex: "D9D9D9")
                        Image(systemName: "photo")
                            .font(.system(size: fpScale(28, scale), weight: .regular))
                            .foregroundStyle(Color(steakHex: "A1887F").opacity(0.45))
                    }
                    .frame(width: imgSide, height: imgSide)
                }
            }
            .clipShape(KnowledgeCardImageMask(radius: corner))

            VStack(alignment: .leading, spacing: fpScale(8, scale)) {
                Text(title)
                    .font(.system(size: fpScale(18, scale), weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(description)
                    .font(.system(size: fpScale(12, scale), weight: .regular))
                    .foregroundStyle(Color(steakHex: "D7CCC8"))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)

                Text(footer.uppercased())
                    .font(.system(size: fpScale(12, scale), weight: .semibold))
                    .foregroundStyle(Color(steakHex: "FFC107"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.leading, fpScale(12, scale))
            .padding(.trailing, fpScale(10, scale))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .background(Color(steakHex: "3E2723"))
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color(steakHex: "A1887F"), lineWidth: max(fpScale(0.3, scale), 0.5))
        )
    }
}

// MARK: - Screen

struct KnowledgeBaseView: View {
    @Environment(\.layoutScale) private var scale
    @State private var category: LibraryCategory = .meatCuts

    var body: some View {
        VStack(spacing: 0) {
            SteakTabScreenHeader(title: "Knowledge Base")
                .environment(\.layoutScale, scale)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: fpScale(8, scale)) {
                    ForEach(LibraryCategory.allCases) { cat in
                        LibraryCategoryChip(
                            category: cat,
                            isSelected: category == cat
                        ) {
                            category = cat
                        }
                    }
                }
                .padding(.horizontal, fpScale(24, scale))
                .padding(.vertical, fpScale(2, scale))
            }
            .padding(.top, fpScale(24, scale))
            .padding(.bottom, fpScale(24, scale))

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: fpScale(16, scale)) {
                    switch category {
                    case .meatCuts:
                        ForEach(KnowledgeRepository.meatCuts) { item in
                            KnowledgeMeatCard(item: item)
                        }
                    case .doneness:
                        ForEach(KnowledgeRepository.doneness) { item in
                            KnowledgeDonenessCard(item: item)
                        }
                    case .tips:
                        ForEach(KnowledgeRepository.tips) { item in
                            KnowledgeTipCard(item: item)
                        }
                    case .spices:
                        ForEach(KnowledgeRepository.spices) { item in
                            KnowledgeSpiceCard(item: item)
                        }
                    }
                }
                .padding(.horizontal, fpScale(24, scale))
                .padding(.bottom, fpScale(28, scale))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(steakHex: "2D1B11"))
    }
}

#Preview {
    KnowledgeBaseView()
        .environment(\.layoutScale, 1)
}
