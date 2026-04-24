import SwiftUI

private enum ArchiveSegment: String, CaseIterable {
    case assessments = "Assessments"
    case cooks = "Cooks"
    case templates = "Templates"
}

private struct ArchiveCardData: Identifiable {
    let id = UUID()
    let title: String
    let price: String
    let location: String
    let date: String
    let rating: String
    let stars: Int
}

private struct CookCardData: Identifiable {
    let id = UUID()
    let title: String
    let rating: String
    let method: String
    let cookTime: String
}

private struct TemplateCardData {
    let title: String
    let emoji: String
    let tags: [String]
}

struct ArchiveAssessmentsScreen: View {
    @EnvironmentObject private var store: AppDataStore
    let scale: CGFloat
    let isAssessmentsEmpty: Bool
    let isCooksEmpty: Bool
    let onTemplateTap: (String) -> Void
    let onAddFishTap: () -> Void
    @State private var selectedSegment: ArchiveSegment = .assessments

    private var templateCards: [TemplateCardData] {
        store.templates.map {
            TemplateCardData(
                title: $0.title,
                emoji: $0.icon,
                tags: $0.items.map(\.goodOption)
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            VStack(spacing: 24 * scale) {
                stats
                segmentedControl
            }
            .padding(.top, 12 * scale)
            .padding(.horizontal, 16 * scale)
            .padding(.bottom, 12 * scale)

            if selectedSegment == .assessments && isAssessmentsEmpty {
                VStack {
                    Spacer()
                    assessmentsEmptyState
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16 * scale)
            } else if selectedSegment == .cooks && isCooksEmpty {
                VStack {
                    Spacer()
                    cooksEmptyState
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16 * scale)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16 * scale) {
                        if selectedSegment == .assessments {
                            if isAssessmentsEmpty {
                                assessmentsEmptyState
                            } else {
                                ForEach(mappedAssessments) { card in
                                    ArchiveCardView(card: card, scale: scale)
                                }
                            }
                        } else if selectedSegment == .cooks {
                            ForEach(mappedCookingRecords) { card in
                                CookCardView(card: card, scale: scale)
                            }
                        } else {
                            ForEach(Array(templateCards.enumerated()), id: \.offset) { _, card in
                                TemplateCardView(card: card, scale: scale)
                                    .onTapGesture {
                                        onTemplateTap(card.title)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 16 * scale)
                    .padding(.bottom, 12 * scale)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var assessmentsEmptyState: some View {
        VStack(spacing: 0) {
            Text("Your assessment is Empty")
                .font(.system(size: 22 * scale, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 329 * scale, height: 26 * scale, alignment: .center)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("Click on the plus sign to add")
                .font(.system(size: 22 * scale, weight: .medium))
                .foregroundStyle(Color(red: 60.0 / 255.0, green: 60.0 / 255.0, blue: 67.0 / 255.0).opacity(0.6))
                .frame(width: 329 * scale, height: 26 * scale, alignment: .center)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(width: 329 * scale, height: 52 * scale, alignment: .center)
    }

    private var cooksEmptyState: some View {
        VStack(spacing: 0) {
            Text("There are no rated dishes yet")
                .font(.system(size: 22 * scale, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 329 * scale, height: 26 * scale, alignment: .center)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text("We look forward to your assessments.")
                .font(.system(size: 22 * scale, weight: .medium))
                .foregroundStyle(Color(red: 60.0 / 255.0, green: 60.0 / 255.0, blue: 67.0 / 255.0).opacity(0.6))
                .frame(width: 329 * scale, height: 52 * scale, alignment: .center)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.65)
        }
        .frame(width: 329 * scale, height: 78 * scale, alignment: .center)
    }

    private var navBar: some View {
        VStack(spacing: 0) {
            HStack {
                Color.clear
                    .frame(width: 26 * scale, height: 42 * scale)

                Spacer()

                Text("Archive")
                    .font(.system(size: 34 * scale, weight: .semibold))
                    .foregroundStyle(.black)

                Spacer()

                Button(action: onAddFishTap) {
                    Circle()
                        .fill(Color(red: 0.169, green: 0.098, blue: 0.706))
                        .frame(width: 34 * scale, height: 34 * scale)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 20 * scale, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(SoundPlainButtonStyle())
            }
            .padding(.horizontal, 16 * scale)
            .frame(height: 42 * scale)
        }
        .frame(height: 46 * scale)
        .padding(.top, 8 * scale)
    }

    private var stats: some View {
        VStack(spacing: 12 * scale) {
            HStack {
                HStack(spacing: 4 * scale) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 24 * scale))
                    Text(String(format: "$%.2f", store.averagePricePerKg))
                        .font(.system(size: 28 * scale, weight: .semibold))
                }
                .foregroundStyle(.white)

                Spacer()

                Text("Avg price / kg")
                    .font(.system(size: 17 * scale, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(10 * scale)
            .frame(height: 52 * scale)
            .background(Color(red: 0.169, green: 0.098, blue: 0.706))
            .clipShape(RoundedRectangle(cornerRadius: 14 * scale, style: .continuous))

            HStack(spacing: 12 * scale) {
                smallStat(icon: "fork.knife", title: store.favoriteCookingMethod, subtitle: "Top preparation", bgColor: Color(red: 0.463, green: 0.843, blue: 0.769))
                smallStat(icon: "clock.fill", title: timerAccuracy, subtitle: "Timer accuracy", bgColor: Color(red: 0.91, green: 0.91, blue: 0.965))
            }
        }
    }

    private func smallStat(icon: String, title: String, subtitle: String, bgColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10 * scale) {
            HStack(spacing: 4 * scale) {
                Image(systemName: icon)
                    .font(.system(size: 24 * scale))
                Text(title)
                    .font(.system(size: 24 * scale, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(.black)

            Text(subtitle)
                .font(.system(size: 17 * scale, weight: .semibold))
                .foregroundStyle(.black.opacity(0.5))
                .lineLimit(1)
        }
        .padding(10 * scale)
        .frame(maxWidth: .infinity, minHeight: 78 * scale, alignment: .leading)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 14 * scale, style: .continuous))
    }

    private var timerAccuracy: String {
        store.timerDeviationText
    }

    private var mappedAssessments: [ArchiveCardData] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return store.assessments.map { item in
            ArchiveCardData(
                title: item.productName,
                price: item.pricePerKg.map { String(format: "$%.2f", $0) } ?? "—",
                location: item.purchasePlace,
                date: formatter.string(from: item.purchaseDate),
                rating: item.verdict.title,
                stars: max(1, min(5, Int(item.rating.rounded())))
            )
        }
    }

    private var mappedCookingRecords: [CookCardData] {
        store.cookingRecords.map { item in
            let minutes = item.totalSeconds / 60
            let seconds = item.totalSeconds % 60
            return CookCardData(
                title: item.productName,
                rating: String(format: "%.1f", item.tasteRating),
                method: item.method,
                cookTime: String(format: "%dm %02ds", minutes, seconds)
            )
        }
    }

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(ArchiveSegment.allCases, id: \.self) { segment in
                Button {
                    selectedSegment = segment
                } label: {
                    Text(segment.rawValue)
                        .font(.system(size: 14 * scale, weight: selectedSegment == segment ? .semibold : .medium))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, minHeight: 28 * scale)
                        .background {
                            if selectedSegment == segment {
                                RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.06), radius: 10 * scale, y: 2 * scale)
                            }
                        }
                }
                .buttonStyle(SoundPlainButtonStyle())
            }
        }
        .padding(.horizontal, 8 * scale)
        .padding(.vertical, 4 * scale)
        .frame(height: 36 * scale)
        .background(Color(red: 0.365, green: 0.365, blue: 0.51).opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 100 * scale, style: .continuous))
    }
}

private struct ArchiveCardView: View {
    let card: ArchiveCardData
    let scale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            VStack(alignment: .leading, spacing: 8 * scale) {
                HStack {
                    Text(card.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    Spacer()
                    Text(card.price)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                .font(.system(size: 32 * scale, weight: .semibold))
                .foregroundStyle(.black)

                HStack {
                    HStack(spacing: 4 * scale) {
                        Image("bxs_map")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20 * scale, height: 20 * scale)
                        Text(card.location)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .opacity(0.5)

                    Spacer()

                    Text(card.date)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .opacity(0.5)
                }
                .font(.system(size: 20 * scale, weight: .medium))
                .foregroundStyle(.black)
            }

            HStack {
                HStack(spacing: 0) {
                    ForEach(0..<card.stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24 * scale))
                            .foregroundStyle(Color(red: 0.169, green: 0.098, blue: 0.706))
                    }
                }

                Spacer()

                Text(card.rating)
                    .font(.system(size: 17 * scale, weight: .medium))
                    .foregroundStyle(Color(red: 0.169, green: 0.098, blue: 0.706))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 32 * scale)
                    .padding(.vertical, 2 * scale)
                    .background(Color(red: 0.835, green: 0.812, blue: 1.0))
                    .clipShape(Capsule())
            }
        }
        .padding(16 * scale)
        .frame(maxWidth: .infinity, minHeight: 124 * scale, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
        .shadow(color: Color(red: 30.0 / 255.0, green: 0, blue: 1).opacity(0.25), radius: 4 * scale, y: 4 * scale)
    }
}

private struct TemplateCardView: View {
    let card: TemplateCardData
    let scale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            HStack(alignment: .firstTextBaseline) {
                Text(card.title)
                    .font(.system(size: 22 * scale, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                Text(card.emoji)
                    .font(.system(size: 28 * scale))
            }

            tagsRow
        }
        .padding(16 * scale)
        .frame(maxWidth: .infinity, minHeight: 96 * scale, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
        .shadow(color: Color(red: 30.0 / 255.0, green: 0, blue: 1).opacity(0.25), radius: 4 * scale, y: 4 * scale)
    }

    private var tagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4 * scale) {
                ForEach(card.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 17 * scale, weight: .medium))
                        .foregroundStyle(Color(red: 30.0 / 255.0, green: 0, blue: 1))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 12 * scale)
                        .padding(.vertical, 2 * scale)
                        .background(Color(red: 0.835, green: 0.812, blue: 1.0))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private struct CookCardView: View {
    let card: CookCardData
    let scale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            HStack {
                Text(card.title)
                    .font(.system(size: 22 * scale, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                HStack(alignment: .bottom, spacing: 1 * scale) {
                    Text(card.rating)
                        .font(.system(size: 22 * scale, weight: .semibold))
                        .foregroundStyle(.black)

                    Image(systemName: "star.fill")
                        .font(.system(size: 16 * scale))
                        .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0))
                        .padding(.bottom, 2 * scale)
                }
            }

            HStack(spacing: 16 * scale) {
                cookPill(assetIcon: "hugeicons_pan-03", title: card.method)
                cookPill(icon: "clock.fill", title: card.cookTime)
            }
        }
        .padding(16 * scale)
        .frame(maxWidth: .infinity, minHeight: 96 * scale, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
        .shadow(color: Color(red: 30.0 / 255.0, green: 0, blue: 1).opacity(0.25), radius: 4 * scale, y: 4 * scale)
    }

    private func cookPill(icon: String, title: String) -> some View {
        HStack(spacing: 4 * scale) {
            Image(systemName: icon)
                .font(.system(size: 14 * scale, weight: .medium))
                .foregroundStyle(Color(red: 30.0 / 255.0, green: 0, blue: 1))
            Text(title)
                .font(.system(size: 17 * scale, weight: .medium))
                .foregroundStyle(Color(red: 30.0 / 255.0, green: 0, blue: 1))
        }
        .padding(.horizontal, 12 * scale)
        .padding(.vertical, 2 * scale)
        .background(Color(red: 0.835, green: 0.812, blue: 1.0))
        .clipShape(Capsule())
    }

    private func cookPill(assetIcon: String, title: String) -> some View {
        HStack(spacing: 4 * scale) {
            Image(assetIcon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 18 * scale, height: 18 * scale)
                .foregroundStyle(Color(red: 30.0 / 255.0, green: 0, blue: 1))
            Text(title)
                .font(.system(size: 17 * scale, weight: .medium))
                .foregroundStyle(Color(red: 30.0 / 255.0, green: 0, blue: 1))
        }
        .padding(.horizontal, 12 * scale)
        .padding(.vertical, 2 * scale)
        .background(Color(red: 0.835, green: 0.812, blue: 1.0))
        .clipShape(Capsule())
    }
}
