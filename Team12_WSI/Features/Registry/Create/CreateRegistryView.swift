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

    @State private var step: GiftDNAStep = .basics
    @State private var selectedEvent: RegistryEvent = .wedding
    @State private var eventDate = Date()
    @State private var namesOnRegistry = ""
    @State private var guestNote = ""
    @State private var homeVision: GiftDNAChoice?
    @State private var lifestyleMoments: Set<String> = []
    @State private var homeType: GiftDNAChoice?
    @State private var roomScale: Double = 2.4
    @State private var priorities: Set<String> = []
    @State private var dailyRituals: Set<String> = []
    @State private var homeCircle: Set<String> = []
    @State private var productCategories: Set<String> = []
    @State private var budgetPreference: GiftDNAChoice?
    @State private var giftPreferences: Set<String> = []
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

            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        if step == .homeVision {
                            editorialHero(height: 168)
                        }

                        if step == .basics {
                            basicsForm
                        } else {
                            screenHeader(title: step.title, subtitle: step.subtitle)
                        }

                        switch step {
                        case .basics:
                            EmptyView()
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
                        case .productCategories:
                            multiChoiceGrid(GiftDNAData.productCategories, selection: $productCategories)
                        case .budget:
                            singleChoiceGrid(GiftDNAData.budgetPreferences, selection: $budgetPreference, imageCards: false)
                        case .giftPreferences:
                            multiChoiceGrid(GiftDNAData.giftPreferences, selection: $giftPreferences)
                        case .visualStyle:
                            largeImageChoiceGrid(GiftDNAData.visualStyles, selection: $visualStyles)
                        case .generating:
                            EmptyView()
                        }
                    }
                    .frame(width: max(0, proxy.size.width - 32), alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, step == .visualStyle ? 152 : 132)
                }
                .scrollClipDisabled(false)
            }

            bottomContinueButton
        }
    }

    var basicsForm: some View {
        VStack(alignment: .leading, spacing: 18) {
            basicsHero
            eventTypeCard
            dateCard
            registryNamesCard
            guestNoteCard
        }
    }

    var basicsHero: some View {
        ZStack(alignment: .bottomLeading) {
            Image("giftdna_living_room")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 236)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            WSRegistryPalette.ivory.opacity(0.96),
                            WSRegistryPalette.ivory.opacity(0.72),
                            WSRegistryPalette.ivory.opacity(0.08)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            WSRegistryPalette.ivory,
                            WSRegistryPalette.ivory.opacity(0.16),
                            WSRegistryPalette.ivory
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 14) {
                Text("Just the basics\nto get started")
                    .font(.system(size: 38, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("We'll personalize your registry experience.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.78))
                    .lineSpacing(4)
                    .frame(maxWidth: 250, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 236)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    var eventTypeCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            formSectionLabel("EVENT TYPE")

            LazyVGrid(columns: twoColumns, spacing: 10) {
                ForEach(RegistryEvent.onboardingEvents) { event in
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.86)) {
                            selectedEvent = event
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: event.iconName)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(selectedEvent == event ? WSRegistryPalette.gold : WSRegistryPalette.cocoa.opacity(0.78))
                                .frame(width: 24)

                            Text(event.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(selectedEvent == event ? WSRegistryPalette.cream : WSRegistryPalette.espresso)
                                .lineLimit(1)
                                .minimumScaleFactor(0.62)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, minHeight: 62)
                        .background(
                            selectedEvent == event ? WSRegistryPalette.espresso : WSRegistryPalette.porcelain,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selectedEvent == event ? WSRegistryPalette.espresso.opacity(0.12) : WSRegistryPalette.hairline.opacity(0.62), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onboardingCardPadding()
    }

    var dateCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            formSectionLabel("DATE")

            DatePicker(selection: $eventDate, displayedComponents: .date) {
                HStack(spacing: 13) {
                    Image(systemName: "calendar")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.gold)
                    Text(eventDate.formatted(date: .long, time: .omitted))
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
            }
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(WSRegistryPalette.gold)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.62), lineWidth: 1)
            )
        }
        .onboardingCardPadding()
    }

    var registryNamesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            formSectionLabel("NAMES ON REGISTRY")

            HStack(spacing: 13) {
                Image(systemName: "person.2")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.gold)
                TextField("Priya & Arjun", text: $namesOnRegistry)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.62), lineWidth: 1)
            )
        }
        .onboardingCardPadding()
    }

    var guestNoteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                formSectionLabel("ADD A NOTE FOR YOUR GUESTS")
                Spacer()
                Text("Optional")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.82))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(WSRegistryPalette.ivory, in: Capsule())
            }

            Text("Share a personal message or story about your new journey. This will be visible to anyone who views your registry.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.78))
                .lineSpacing(3)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $guestNote)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 112)
                    .padding(.horizontal, 56)
                    .padding(.vertical, 14)

                Text("“")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.gold)
                    .padding(.leading, 18)
                    .padding(.top, 16)

                if guestNote.isEmpty {
                    Text("Thank you so much for being part of our special day and helping us build our future together...")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.55))
                        .lineSpacing(4)
                        .padding(.leading, 70)
                        .padding(.trailing, 18)
                        .padding(.top, 26)
                        .allowsHitTesting(false)
                }

                Text("\(guestNote.count)/500")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(14)
            }
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.62), lineWidth: 1)
            )
            .onChange(of: guestNote) { _, newValue in
                if newValue.count > 500 {
                    guestNote = String(newValue.prefix(500))
                }
            }

            HStack(spacing: 14) {
                Image(systemName: "sparkle")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("A personal note helps your guests feel more connected to your story.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.82))
                    .lineSpacing(3)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .onboardingCardPadding()
    }
    
    func formSectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .tracking(2.1)
            .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.78))
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
        .padding(.bottom, 8)
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
                .lineLimit(1)
                .minimumScaleFactor(0.76)
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
        VStack(spacing: 12) {
            ForEach(choices) { choice in
                let isSelected = selection.wrappedValue.contains(choice.id)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                        if isSelected {
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
                            .frame(height: 132)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        WSRegistryPalette.espresso.opacity(0.18),
                                        WSRegistryPalette.espresso.opacity(0.72)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: choice.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(WSRegistryPalette.cream)
                                .frame(width: 30, height: 30)
                                .shadow(color: WSRegistryPalette.espresso.opacity(0.55), radius: 4, x: 0, y: 2)

                            Text(choice.title)
                                .font(.system(size: 23, weight: .semibold, design: .serif))
                                .foregroundStyle(WSRegistryPalette.cream)
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                                .shadow(color: WSRegistryPalette.espresso.opacity(0.55), radius: 4, x: 0, y: 2)

                            Spacer()

                            selectionIndicator(isSelected: isSelected)
                        }
                        .padding(16)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(isSelected ? WSRegistryPalette.gold : WSRegistryPalette.hairline.opacity(0.45), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: WSRegistryPalette.espresso.opacity(isSelected ? 0.13 : 0.045), radius: isSelected ? 14 : 8, x: 0, y: 6)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func choiceCard(_ choice: GiftDNAChoice, isSelected: Bool, imageCards: Bool) -> some View {
        VStack(spacing: imageCards ? 8 : 10) {
            if imageCards {
                ZStack(alignment: .topTrailing) {
                    Image("giftdna_living_room")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 76)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [WSRegistryPalette.espresso.opacity(0.04), WSRegistryPalette.espresso.opacity(0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    selectionIndicator(isSelected: isSelected)
                        .padding(8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(choice.tint.opacity(isSelected ? 0.18 : 0.11))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: choice.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(isSelected ? WSRegistryPalette.gold : WSRegistryPalette.cocoa)
                        }

                    selectionIndicator(isSelected: isSelected)
                        .offset(x: 8, y: -8)
                }
                .frame(height: 58)
            }

            VStack(spacing: imageCards ? 4 : 0) {
                Text(choice.title)
                    .font(.system(size: imageCards ? 14 : 13, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.52)
                    .frame(maxWidth: .infinity, minHeight: imageCards ? 24 : 24, alignment: .center)

                if imageCards, let subtitle = choice.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .frame(maxWidth: .infinity, minHeight: 18, alignment: .top)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, imageCards ? 10 : 12)
        .padding(.top, imageCards ? 10 : 12)
        .padding(.bottom, imageCards ? 10 : 12)
        .frame(height: imageCards ? 154 : 106, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? WSRegistryPalette.gold : WSRegistryPalette.hairline.opacity(0.44), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(isSelected ? 0.11 : 0.035), radius: isSelected ? 12 : 6, x: 0, y: 5)
        .scaleEffect(isSelected ? 1.01 : 1)
    }

    func selectionIndicator(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? WSRegistryPalette.gold : WSRegistryPalette.porcelain.opacity(0.94))
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(isSelected ? WSRegistryPalette.gold : WSRegistryPalette.hairline.opacity(0.72), lineWidth: 1.4)
                )
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.cream)
            }
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
                ZStack {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))

                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundStyle(WSRegistryPalette.cream)
                .padding(.horizontal, 20)
                .frame(height: 58)
                .background(WSRegistryPalette.espresso, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.42)
            .padding(.horizontal, 16)
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
            GridItem(.flexible(), spacing: 12, alignment: .top),
            GridItem(.flexible(), spacing: 0, alignment: .top)
        ]
    }

    var canContinue: Bool {
        switch step {
        case .basics:
            return !namesOnRegistry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
        case .productCategories:
            return !productCategories.isEmpty
        case .budget:
            return budgetPreference != nil
        case .giftPreferences:
            return !giftPreferences.isEmpty
        case .visualStyle:
            return !visualStyles.isEmpty
        case .generating:
            return true
        }
    }

    var parsedRegistryNames: (first: String, last: String) {
        let cleaned = namesOnRegistry.trimmingCharacters(in: .whitespacesAndNewlines)
        let separators = [" & ", " and ", ","]
        for separator in separators where cleaned.contains(separator) {
            let parts = cleaned.components(separatedBy: separator).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if let first = parts.first, let last = parts.dropFirst().first, !first.isEmpty, !last.isEmpty {
                return (first, last)
            }
        }
        return (cleaned.isEmpty ? "GiftDNA" : cleaned, "Home")
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
            let names = parsedRegistryNames
            registryRepo.createRegistry(firstName: names.first, lastName: names.last, event: selectedEvent, date: eventDate)
            tabBarVM.resetRegistryFlow()
            tabBarVM.selectTab(.registry)
        }
    }
}


private extension View {
    func onboardingCardPadding() -> some View {
        self
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(WSRegistryPalette.cream.opacity(0.78), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.035), radius: 14, x: 0, y: 8)
    }
}

private extension RegistryEvent {
    var iconName: String {
        switch self {
        case .wedding: return "circlebadge.2"
        case .housewarming: return "house"
        case .baby: return "figure.2.and.child.holdinghands"
        case .birthday: return "birthday.cake"
        case .anniversary: return "heart"
        case .other: return "gift"
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        let rows = rows(for: subviews, maxWidth: maxWidth)
        let height = rows.reduce(CGFloat.zero) { total, row in
            total + row.height + (row.index == rows.count - 1 ? 0 : rowSpacing)
        }
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        for row in rows(for: subviews, maxWidth: bounds.width) {
            var x = origin.x
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(
                    at: CGPoint(x: x, y: origin.y + (row.height - size.height) / 2),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            origin.y += row.height + rowSpacing
        }
    }

    private func rows(for subviews: Subviews, maxWidth: CGFloat) -> [FlowRow] {
        var rows: [FlowRow] = []
        var current = FlowRow(index: 0)
        var currentWidth: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let proposedWidth = current.indices.isEmpty ? size.width : currentWidth + spacing + size.width

            if proposedWidth > maxWidth, !current.indices.isEmpty {
                rows.append(current)
                current = FlowRow(index: rows.count)
                currentWidth = 0
            }

            current.indices.append(index)
            current.height = max(current.height, size.height)
            currentWidth = currentWidth == 0 ? size.width : currentWidth + spacing + size.width
        }

        if !current.indices.isEmpty {
            rows.append(current)
        }

        return rows
    }

    private struct FlowRow {
        let index: Int
        var indices: [Subviews.Index] = []
        var height: CGFloat = 0
    }
}

private enum GiftDNAStep: Int, CaseIterable {
    case basics
    case homeVision
    case moments
    case homeType
    case priorities
    case rituals
    case people
    case productCategories
    case budget
    case giftPreferences
    case visualStyle
    case generating

    var title: String {
        switch self {
        case .basics: return "Just the basics to get started"
        case .homeVision: return "What kind of home are you building?"
        case .moments: return "How do you imagine spending time at home?"
        case .homeType: return "What best describes your space?"
        case .priorities: return "What matters most in your future home?"
        case .rituals: return "What are your daily rituals?"
        case .people: return "Who are you building this home with?"
        case .productCategories: return "Which products should we prioritize?"
        case .budget: return "What price range feels right?"
        case .giftPreferences: return "How should we sort your gifts?"
        case .visualStyle: return "Which spaces feel most like home to you?"
        case .generating: return "Creating your home profile..."
        }
    }

    var subtitle: String {
        switch self {
        case .basics: return "Tell us what you are celebrating and who the registry is for."
        case .homeVision: return "We'll create a registry around how you'll actually live, host, and grow together."
        case .moments: return "Choose the moments that matter most to you."
        case .homeType: return "This helps us tailor your future registry."
        case .priorities: return "Your answers shape your registry recommendations."
        case .rituals: return "We'll help build around the routines you value most."
        case .people: return "This helps GiftDNA personalize your registry."
        case .productCategories: return "Pick the rooms and product families that should come first in your registry."
        case .budget: return "This helps match recommendations to products your guests will feel good gifting."
        case .giftPreferences: return "Tell us what matters when comparing similar products from the dataset."
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

    static let productCategories = [
        GiftDNAChoice("Cookware & bakeware", icon: "frying.pan"),
        GiftDNAChoice("Dinnerware & serveware", icon: "fork.knife"),
        GiftDNAChoice("Glassware & bar", icon: "wineglass"),
        GiftDNAChoice("Kitchen appliances", icon: "oven"),
        GiftDNAChoice("Coffee & tea", icon: "cup.and.saucer"),
        GiftDNAChoice("Bedding & bath", icon: "bed.double"),
        GiftDNAChoice("Storage & organization", icon: "archivebox"),
        GiftDNAChoice("Decor accents", icon: "sparkles")
    ]

    static let budgetPreferences = [
        GiftDNAChoice("Mostly under $50", icon: "tag"),
        GiftDNAChoice("$50 to $150", icon: "gift"),
        GiftDNAChoice("$150 to $300", icon: "shippingbox"),
        GiftDNAChoice("Investment pieces", icon: "seal")
    ]

    static let giftPreferences = [
        GiftDNAChoice("Top-rated items", icon: "star"),
        GiftDNAChoice("Essentials first", icon: "checklist"),
        GiftDNAChoice("Mix of prices", icon: "slider.horizontal.3"),
        GiftDNAChoice("Available now", icon: "checkmark.seal"),
        GiftDNAChoice("Trusted brands", icon: "building.columns"),
        GiftDNAChoice("Easy to ship", icon: "shippingbox"),
        GiftDNAChoice("Most useful daily", icon: "sun.max"),
        GiftDNAChoice("Statement pieces", icon: "sparkles")
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
        "Reading your product preferences",
        "Building your home readiness profile",
        "Curating your future home"
    ]
}

#Preview {
    NavigationStack {
        CreateRegistryView()
    }
}
