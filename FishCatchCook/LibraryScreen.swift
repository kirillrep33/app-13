import SwiftUI

private enum LibrarySegment: String, CaseIterable {
    case seafood = "Seafood"
    case recipes = "Recipes"
}

private struct LibraryRecipeCardData: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let duration: String
    let persons: String
    let ingredients: String
    let sourceURL: String
    let cardHeight: CGFloat
}

private struct SeafoodCardData: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let seasonality: String
    let cookingWays: String
    let freshnessSigns: String
    let emoji: String
}

struct LibraryScreen: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var store: AppDataStore
    let scale: CGFloat
    @State private var selectedSegment: LibrarySegment = .seafood
    @State private var expandedRecipeTitles: Set<String> = []

    private var cards: [LibraryRecipeCardData] {
        store.recipes.map {
            LibraryRecipeCardData(
                title: $0.title,
                subtitle: $0.subtitle,
                duration: $0.duration,
                persons: $0.persons,
                ingredients: $0.ingredients,
                sourceURL: $0.sourceURL,
                cardHeight: 546
            )
        }
    }

    private var seafoodCards: [SeafoodCardData] {
        store.seafoodCatalog.map {
            SeafoodCardData(
                title: $0.name,
                subtitle: $0.type,
                seasonality: $0.season,
                cookingWays: $0.bestMethod,
                freshnessSigns: $0.freshnessSigns,
                emoji: "🐟"
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24 * scale) {
                    segmentControl

                    if selectedSegment == .seafood {
                        ForEach(seafoodCards) { card in
                            seafoodCard(card)
                        }
                    } else {
                        ForEach(cards) { card in
                            recipeCard(card)
                        }
                    }
                }
                .padding(.top, 24 * scale)
                .padding(.horizontal, 16 * scale)
                .padding(.bottom, 12 * scale)
            }
        }
    }

    private var navBar: some View {
        HStack {
            Color.clear.frame(width: 26 * scale, height: 42 * scale)
            Spacer()
            Text("Culinary Library")
                .font(.system(size: 30 * scale, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Color.clear.frame(width: 34 * scale, height: 34 * scale)
        }
        .padding(.horizontal, 16 * scale)
        .frame(height: 42 * scale)
        .padding(.top, 16 * scale)
    }

    private var segmentControl: some View {
        HStack(spacing: 12 * scale) {
            segmentButton(.seafood)
            segmentButton(.recipes)
        }
        .padding(12 * scale)
        .frame(height: 60 * scale)
        .background(Color(red: 0.91, green: 0.91, blue: 0.965))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private func segmentButton(_ segment: LibrarySegment) -> some View {
        let selected = selectedSegment == segment
        return Button {
            selectedSegment = segment
        } label: {
            Text(segment.rawValue)
                .font(.system(size: 17 * scale, weight: .semibold))
                .foregroundStyle(selected ? .white : .black)
                .frame(maxWidth: .infinity, minHeight: 36 * scale)
                .background(selected ? Color(red: 0.169, green: 0.098, blue: 0.706) : .clear)
                .opacity(selected ? 1 : 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 8 * scale, style: .continuous))
        }
        .buttonStyle(SoundPlainButtonStyle())
    }

    private func recipeCard(_ card: LibraryRecipeCardData) -> some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            Image("Rectangle 2")
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
            .frame(height: 174 * scale)

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text(card.title)
                    .font(.system(size: 24 * scale, weight: .semibold))
                    .foregroundStyle(.black)
                Text(card.subtitle)
                    .font(.system(size: 17 * scale, weight: .regular))
                    .foregroundStyle(.black.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 12 * scale) {
                HStack(spacing: 4 * scale) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 20 * scale))
                    Text(card.duration)
                        .font(.system(size: 17 * scale, weight: .medium))
                }
                HStack(spacing: 4 * scale) {
                    Image("material-symbols_fork-spoon")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20 * scale, height: 20 * scale)
                    Text(card.persons)
                        .font(.system(size: 17 * scale, weight: .medium))
                }
            }
            .foregroundStyle(.black)

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text("INGREDIENTS")
                    .font(.system(size: 17 * scale, weight: .medium))
                    .textCase(.uppercase)
                let isExpanded = expandedRecipeTitles.contains(card.title)
                Text(card.ingredients)
                    .font(.system(size: 17 * scale, weight: .regular))
                    .foregroundStyle(.black.opacity(0.5))
                    .lineSpacing(2 * scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(isExpanded ? nil : 3)
                if shouldShowSeeMore(for: card.ingredients) {
                    Button {
                        toggleIngredients(for: card.title)
                    } label: {
                        Text(isExpanded ? "see less" : "see more")
                            .font(.system(size: 17 * scale, weight: .semibold))
                            .underline()
                            .foregroundStyle(Color(red: 0.169, green: 0.098, blue: 0.706))
                    }
                    .buttonStyle(SoundPlainButtonStyle())
                }
            }
            .padding(.horizontal, 12 * scale)
            .padding(.vertical, 16 * scale)
            .background(Color(red: 0.91, green: 0.91, blue: 0.965))
            .clipShape(RoundedRectangle(cornerRadius: 12 * scale, style: .continuous))

            Button {
                if let url = URL(string: card.sourceURL) {
                    openURL(url)
                }
            } label: {
                Text("Recipe")
                    .font(.system(size: 17 * scale, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 44 * scale)
                    .background(Color(red: 0.169, green: 0.098, blue: 0.706))
                    .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
            }
            .buttonStyle(SoundPlainButtonStyle())
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 20 * scale)
        .frame(maxWidth: .infinity, minHeight: card.cardHeight * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }

    private func shouldShowSeeMore(for ingredients: String) -> Bool {
        ingredients.split(separator: "\n").count > 3
    }

    private func toggleIngredients(for title: String) {
        if expandedRecipeTitles.contains(title) {
            expandedRecipeTitles.remove(title)
        } else {
            expandedRecipeTitles.insert(title)
        }
    }

    private func seafoodCard(_ card: SeafoodCardData) -> some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            Image("Rectangle 2-2")
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
            .frame(height: 174 * scale)

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text(card.title)
                    .font(.system(size: 24 * scale, weight: .semibold))
                    .foregroundStyle(.black)
                Text(card.subtitle)
                    .font(.system(size: 17 * scale, weight: .regular))
                    .foregroundStyle(.black.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 12 * scale) {
                HStack(spacing: 4 * scale) {
                    Image("lets-icons_date-fill")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20 * scale, height: 20 * scale)
                    Text(card.seasonality)
                        .font(.system(size: 17 * scale, weight: .medium))
                }
                HStack(spacing: 4 * scale) {
                    Image("material-symbols_fork-spoon")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20 * scale, height: 20 * scale)
                    Text(card.cookingWays)
                        .font(.system(size: 17 * scale, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
            .foregroundStyle(.black)

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text("FRESHNESS SIGNS")
                    .font(.system(size: 17 * scale, weight: .medium))
                    .textCase(.uppercase)
                    .foregroundStyle(Color(red: 0.169, green: 0.098, blue: 0.706))
                Text(card.freshnessSigns)
                    .font(.system(size: 17 * scale, weight: .regular))
                    .foregroundStyle(.black.opacity(0.5))
                    .lineSpacing(2 * scale)
            }
            .padding(.horizontal, 12 * scale)
            .padding(.vertical, 16 * scale)
            .background(Color(red: 0.91, green: 0.91, blue: 0.965))
            .clipShape(RoundedRectangle(cornerRadius: 12 * scale, style: .continuous))
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 20 * scale)
        .frame(maxWidth: .infinity, minHeight: 462 * scale)
        .background(Color(red: 0.965, green: 0.98, blue: 0.996))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
    }
}

