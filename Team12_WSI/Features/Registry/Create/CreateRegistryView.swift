//
//  CreateRegistryView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 04/04/26.
//

import SwiftUI

struct CreateRegistryView: View {
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var registryRepo: RegistryRepository

    @State private var step: GiftDNAStep = .homeVision
    @State private var homeVision: GiftDNAChoice?
    @State private var lifestyleMoments: Set<String> = []
    @State private var homeType: GiftDNAChoice?
    @State private var roomScale: Double = 2.4
    @State private var priorities: Set<String> = []
    @State private var dailyRituals: Set<String> = []
    @State private var homeCircle: Set<String> = []
    @State private var visualStyles: Set<String> = []
    @State private var generationProgress: Double = 0
    @State private var completedGenerationSteps: Set<String> = []

    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()

            switch step {
            case .generating:
                generationScreen
            default:
                questionScreen
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(step.displayIndex)/\(GiftDNAStep.allCases.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(WSRegistryPalette.porcelain, in: Capsule())
            }
        }
        .tint(WSRegistryPalette.gold)
    }
}

private extension CreateRegistryView {
    var questionScreen: some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    if step == .homeVision {
                        editorialHero(height: 168)
                    }

                    screenHeader(title: step.title, subtitle: step.subtitle)

                    switch step {
                    case .homeVision:
                        singleChoiceGrid(GiftDNAData.homeVisions, selection: $homeVision, imageCards: true)
                    case .moments:
                        multiChoiceGrid(GiftDNAData.moments, selection: $lifestyleMoments)
                    case .homeType:
                        singleChoiceGrid(GiftDNAData.homeTypes, selection: $homeType, imageCards: false)
                        roomScaleCard
                    case .priorities:
                        multiChoiceGrid(GiftDNAData.priorities, selection: $priorities)
                    case .rituals:
                        multiChoiceGrid(GiftDNAData.rituals, selection: $dailyRituals)
                    case .people:
                        multiChoiceGrid(GiftDNAData.people, selection: $homeCircle)
                    case .visualStyle:
                        largeImageChoiceGrid(GiftDNAData.visualStyles, selection: $visualStyles)
                    case .generating:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 118)
            }

            bottomContinueButton
        }
    }

    var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(WSRegistryPalette.hairline.opacity(0.35))
                Capsule()
                    .fill(WSRegistryPalette.gold)
                    .frame(width: proxy.size.width * step.progress)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }

    func screenHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)

            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func editorialHero(height: CGFloat) -> some View {
        Image("giftdna_living_room")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(WSRegistryPalette.cream.opacity(0.65), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.08), radius: 18, x: 0, y: 10)
    }

    func singleChoiceGrid(_ choices: [GiftDNAChoice], selection: Binding<GiftDNAChoice?>, imageCards: Bool) -> some View {
        LazyVGrid(columns: twoColumns, spacing: 14) {
            ForEach(choices) { choice in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        selection.wrappedValue = choice
                    }
                } label: {
                    choiceCard(choice, isSelected: selection.wrappedValue?.id == choice.id, imageCards: imageCards)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func multiChoiceGrid(_ choices: [GiftDNAChoice], selection: Binding<Set<String>>) -> some View {
        LazyVGrid(columns: twoColumns, spacing: 14) {
            ForEach(choices) { choice in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        if selection.wrappedValue.contains(choice.id) {
                            selection.wrappedValue.remove(choice.id)
                        } else {
                            selection.wrappedValue.insert(choice.id)
                        }
                    }
                } label: {
                    choiceCard(choice, isSelected: selection.wrappedValue.contains(choice.id), imageCards: false)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func largeImageChoiceGrid(_ choices: [GiftDNAChoice], selection: Binding<Set<String>>) -> some View {
        VStack(spacing: 14) {
            ForEach(choices) { choice in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                        if selection.wrappedValue.contains(choice.id) {
                            selection.wrappedValue.remove(choice.id)
                        } else {
                            selection.wrappedValue.insert(choice.id)
                        }
                    }
                } label: {
                    ZStack(alignment: .bottomLeading) {
                        Image("giftdna_living_room")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 154)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, WSRegistryPalette.espresso.opacity(0.62)],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )

                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 5) {
                                Image(systemName: choice.icon)
                                    .font(.system(size: 18, weight: .medium))
                                Text(choice.title)
                                    .font(.system(size: 21, weight: .semibold, design: .serif))
                            }
                            .foregroundStyle(WSRegistryPalette.cream)

                            Spacer()

                            selectionIndicator(isSelected: selection.wrappedValue.contains(choice.id))
                        }
                        .padding(18)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(selection.wrappedValue.contains(choice.id) ? WSRegistryPalette.gold : WSRegistryPalette.hairline.opacity(0.55), lineWidth: selection.wrappedValue.contains(choice.id) ? 2 : 1)
                    )
                    .shadow(color: WSRegistryPalette.espresso.opacity(selection.wrappedValue.contains(choice.id) ? 0.16 : 0.07), radius: selection.wrappedValue.contains(choice.id) ? 20 : 12, x: 0, y: 10)
                    .scaleEffect(selection.wrappedValue.contains(choice.id) ? 1.012 : 1)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func choiceCard(_ choice: GiftDNAChoice, isSelected: Bool, imageCards: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                if imageCards {
                    Image("giftdna_living_room")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 74)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(WSRegistryPalette.espresso.opacity(0.12))
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(choice.tint.opacity(0.16))
                        .frame(height: 54)
                        .overlay(alignment: .leading) {
                            Image(systemName: choice.icon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.cocoa)
                                .padding(.leading, 14)
                        }
                }

                selectionIndicator(isSelected: isSelected)
                    .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Image(systemName: choice.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isSelected ? WSRegistryPalette.gold : WSRegistryPalette.cocoa)
                    Text(choice.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let subtitle = choice.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(2)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: imageCards ? 158 : 138, alignment: .topLeading)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isSelected ? WSRegistryPalette.gold : WSRegistryPalette.hairline.opacity(0.58), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(isSelected ? 0.13 : 0.055), radius: isSelected ? 16 : 10, x: 0, y: 8)
        .scaleEffect(isSelected ? 1.015 : 1)
    }

    func selectionIndicator(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? WSRegistryPalette.gold : WSRegistryPalette.cream.opacity(0.94))
                .frame(width: 28, height: 28)
            Image(systemName: isSelected ? "checkmark" : "circle")
                .font(.system(size: isSelected ? 12 : 10, weight: .bold))
                .foregroundStyle(isSelected ? WSRegistryPalette.cream : WSRegistryPalette.hairline)
        }
    }

    var roomScaleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Room scale")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text("Optional")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }
                Spacer()
                Text(roomScaleLabel)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cocoa)
            }

            Slider(value: $roomScale, in: 1...4, step: 1)
                .tint(WSRegistryPalette.gold)

            HStack {
                Text("Intimate")
                Spacer()
                Text("Expansive")
            }
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(WSRegistryPalette.warmGray)
        }
        .padding(20)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1)
        )
    }

    var roomScaleLabel: String {
        switch roomScale {
        case 1: return "Small"
        case 2: return "Balanced"
        case 3: return "Open"
        default: return "Grand"
        }
    }

    var bottomContinueButton: some View {
        VStack(spacing: 0) {
            Button {
                goForward()
            } label: {
                HStack {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(WSRegistryPalette.cream)
                .padding(.horizontal, 20)
                .frame(height: 58)
                .background(WSRegistryPalette.espresso, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.42)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .background(.ultraThinMaterial)
    }

    var generationScreen: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let imageHeight = min(340, height * 0.40)
            let ringY = min(height - geometry.safeAreaInsets.bottom - 104, height * 0.80)

            ZStack {
                WSRegistryPalette.ivory.ignoresSafeArea()

                Image("giftdna_living_room")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: imageHeight)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [
                                WSRegistryPalette.ivory,
                                WSRegistryPalette.ivory.opacity(0.30),
                                WSRegistryPalette.ivory.opacity(0.08),
                                WSRegistryPalette.ivory.opacity(0.98)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .position(x: width / 2, y: height - imageHeight / 2)
                    .ignoresSafeArea(edges: .bottom)

                Text("WILLIAMS SONOMA")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .tracking(1.9)
                    .foregroundStyle(WSRegistryPalette.espresso.opacity(0.82))
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
                    .frame(width: width - 44)
                    .position(x: width / 2, y: geometry.safeAreaInsets.top + 78)

                VStack(spacing: 30) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 34, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.gold.opacity(0.76))
                        .symbolEffect(.pulse, options: .repeating.speed(0.45), value: completedGenerationSteps.count)

                    VStack(spacing: 18) {
                        Text("Creating your\nhome profile...")
                            .font(.system(size: 32, weight: .regular, design: .serif))
                            .foregroundStyle(WSRegistryPalette.espresso)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Our AI is understanding your lifestyle and building your personalized home readiness.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: 292)
                }
                .frame(width: width - 44)
                .position(x: width / 2, y: height * 0.42)

                generationProgressRing
                    .position(x: width / 2, y: ringY)
            }
            .frame(width: width, height: height)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear(perform: runGeneration)
    }

    var generationProgressRing: some View {
        ZStack {
            Circle()
                .fill(WSRegistryPalette.porcelain.opacity(0.95))
                .frame(width: 138, height: 138)
                .shadow(color: WSRegistryPalette.espresso.opacity(0.18), radius: 20, x: 0, y: 10)

            Circle()
                .stroke(WSRegistryPalette.cream.opacity(0.95), lineWidth: 13)
                .frame(width: 120, height: 120)

            Circle()
                .trim(from: 0, to: generationProgress)
                .stroke(
                    WSRegistryPalette.gold,
                    style: StrokeStyle(lineWidth: 13, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.55), value: generationProgress)

            Text("\(Int(generationProgress * 100))%")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .monospacedDigit()
        }
    }

    var twoColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ]
    }

    var canContinue: Bool {
        switch step {
        case .homeVision:
            return homeVision != nil
        case .moments:
            return !lifestyleMoments.isEmpty
        case .homeType:
            return homeType != nil
        case .priorities:
            return !priorities.isEmpty
        case .rituals:
            return !dailyRituals.isEmpty
        case .people:
            return !homeCircle.isEmpty
        case .visualStyle:
            return !visualStyles.isEmpty
        case .generating:
            return true
        }
    }

    func goForward() {
        guard let next = step.next else { return }
        withAnimation(.easeInOut(duration: 0.24)) {
            step = next
        }
    }

    func runGeneration() {
        generationProgress = 0
        completedGenerationSteps = []

        Task { @MainActor in
            for (index, item) in GiftDNAData.generationSteps.enumerated() {
                try? await Task.sleep(nanoseconds: 520_000_000)
                withAnimation(.easeInOut(duration: 0.55)) {
                    generationProgress = Double(index + 1) / Double(GiftDNAData.generationSteps.count)
                    completedGenerationSteps.insert(item)
                }
            }

            try? await Task.sleep(nanoseconds: 450_000_000)
            registryRepo.createRegistry(firstName: "GiftDNA", lastName: "Home", event: .housewarming, date: Date())
            tabBarVM.resetRegistryFlow()
            tabBarVM.selectTab(.registry)
        }
    }
}

private enum GiftDNAStep: Int, CaseIterable {
    case homeVision
    case moments
    case homeType
    case priorities
    case rituals
    case people
    case visualStyle
    case generating

    var title: String {
        switch self {
        case .homeVision: return "What kind of home are you building?"
        case .moments: return "How do you imagine spending time at home?"
        case .homeType: return "What best describes your space?"
        case .priorities: return "What matters most in your future home?"
        case .rituals: return "What are your daily rituals?"
        case .people: return "Who are you building this home with?"
        case .visualStyle: return "Which spaces feel most like home to you?"
        case .generating: return "Creating your home profile..."
        }
    }

    var subtitle: String {
        switch self {
        case .homeVision: return "We’ll create a registry around how you’ll actually live, host, and grow together."
        case .moments: return "Choose the moments that matter most to you."
        case .homeType: return "This helps us tailor your future registry."
        case .priorities: return "Your answers shape your registry recommendations."
        case .rituals: return "We’ll help build around the routines you value most."
        case .people: return "This helps GiftDNA personalize your registry."
        case .visualStyle: return "Choose the styles you naturally gravitate toward."
        case .generating: return "GiftDNA is learning how you live, gather, host, and grow together."
        }
    }

    var displayIndex: Int { rawValue + 1 }
    var progress: CGFloat { CGFloat(displayIndex) / CGFloat(Self.allCases.count) }
    var next: GiftDNAStep? { GiftDNAStep(rawValue: rawValue + 1) }
}

private struct GiftDNAChoice: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let tint: Color
    let subtitle: String?

    init(_ title: String, icon: String, tint: Color = WSRegistryPalette.gold, subtitle: String? = nil) {
        self.id = title
        self.title = title
        self.icon = icon
        self.tint = tint
        self.subtitle = subtitle
    }
}

private enum GiftDNAData {
    static let homeVisions = [
        GiftDNAChoice("Warm & Cozy", icon: "flame", tint: WSRegistryPalette.gold, subtitle: "Layered, welcoming, lived in."),
        GiftDNAChoice("Modern Minimal", icon: "square.split.diagonal", tint: WSRegistryPalette.warmGray, subtitle: "Calm lines and clear surfaces."),
        GiftDNAChoice("Social & Hosting-Focused", icon: "wineglass", tint: WSRegistryPalette.cocoa, subtitle: "A home made for gathering."),
        GiftDNAChoice("Calm & Restorative", icon: "leaf", tint: WSRegistryPalette.sage, subtitle: "Soft rituals and quiet rooms."),
        GiftDNAChoice("Creative & Expressive", icon: "paintpalette", tint: WSRegistryPalette.gold, subtitle: "Personal, storied, artful."),
        GiftDNAChoice("Functional Everyday Living", icon: "checklist", tint: WSRegistryPalette.sage, subtitle: "Beautiful pieces that work hard.")
    ]

    static let moments = [
        GiftDNAChoice("Hosting dinners with friends", icon: "fork.knife"),
        GiftDNAChoice("Slow mornings & coffee rituals", icon: "cup.and.saucer"),
        GiftDNAChoice("Cooking together", icon: "frying.pan"),
        GiftDNAChoice("Quiet evenings", icon: "moon"),
        GiftDNAChoice("Celebrating milestones", icon: "sparkles"),
        GiftDNAChoice("Work-from-home balance", icon: "laptopcomputer"),
        GiftDNAChoice("Weekend baking", icon: "birthday.cake"),
        GiftDNAChoice("Family meals", icon: "person.2"),
        GiftDNAChoice("Wine nights", icon: "wineglass"),
        GiftDNAChoice("Wellness & self-care", icon: "leaf")
    ]

    static let homeTypes = [
        GiftDNAChoice("City apartment", icon: "building.2"),
        GiftDNAChoice("First home", icon: "house"),
        GiftDNAChoice("Family house", icon: "house.lodge"),
        GiftDNAChoice("Shared living space", icon: "person.2"),
        GiftDNAChoice("Cozy small home", icon: "sofa"),
        GiftDNAChoice("Open entertaining space", icon: "table.furniture")
    ]

    static let priorities = [
        GiftDNAChoice("Comfort", icon: "sofa"),
        GiftDNAChoice("Functionality", icon: "slider.horizontal.3"),
        GiftDNAChoice("Hosting", icon: "wineglass"),
        GiftDNAChoice("Timeless quality", icon: "seal"),
        GiftDNAChoice("Organization", icon: "square.grid.2x2"),
        GiftDNAChoice("Emotional warmth", icon: "heart"),
        GiftDNAChoice("Flexibility", icon: "arrow.triangle.2.circlepath"),
        GiftDNAChoice("Aesthetics", icon: "sparkles"),
        GiftDNAChoice("Daily ease", icon: "sun.max"),
        GiftDNAChoice("Shared experiences", icon: "person.3")
    ]

    static let rituals = [
        GiftDNAChoice("Morning coffee", icon: "cup.and.saucer"),
        GiftDNAChoice("Tea rituals", icon: "mug"),
        GiftDNAChoice("Cooking nightly", icon: "frying.pan"),
        GiftDNAChoice("Reading corners", icon: "book"),
        GiftDNAChoice("Wellness routines", icon: "leaf"),
        GiftDNAChoice("Sunday hosting", icon: "table.furniture"),
        GiftDNAChoice("Baking weekends", icon: "birthday.cake"),
        GiftDNAChoice("Evening wine rituals", icon: "wineglass"),
        GiftDNAChoice("Cozy movie nights", icon: "play.tv"),
        GiftDNAChoice("Shared breakfasts", icon: "fork.knife")
    ]

    static let people = [
        GiftDNAChoice("My partner", icon: "heart"),
        GiftDNAChoice("Future family", icon: "figure.2.and.child.holdinghands"),
        GiftDNAChoice("Pets", icon: "pawprint"),
        GiftDNAChoice("Frequent guests", icon: "person.3"),
        GiftDNAChoice("Mostly just us", icon: "person.2"),
        GiftDNAChoice("Friends always visiting", icon: "door.left.hand.open"),
        GiftDNAChoice("Children in the future", icon: "figure.and.child.holdinghands"),
        GiftDNAChoice("Multi-generational family", icon: "house.and.flag")
    ]

    static let visualStyles = [
        GiftDNAChoice("Warm Modern", icon: "sun.max"),
        GiftDNAChoice("Soft Scandinavian", icon: "snowflake"),
        GiftDNAChoice("Earthy Minimalism", icon: "leaf"),
        GiftDNAChoice("Quiet Luxury", icon: "sparkles"),
        GiftDNAChoice("Coastal Calm", icon: "water.waves"),
        GiftDNAChoice("Vintage Editorial", icon: "camera")
    ]

    static let generationSteps = [
        "Understanding your lifestyle",
        "Mapping your home priorities",
        "Building your home readiness profile",
        "Curating your future home"
    ]


}

#Preview {
    NavigationStack {
        CreateRegistryView()
    }
}
