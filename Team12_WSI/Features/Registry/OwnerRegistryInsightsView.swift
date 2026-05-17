//
//  OwnerRegistryInsightsView.swift
//  Team12_WSI
//
//  Full-screen AI-powered registry insights view.
//  Shows overall score, per-dimension breakdowns, budget distribution,
//  strengths, and actionable suggestions.
//

import SwiftUI

struct OwnerRegistryInsightsView: View {
    let registry: Registry

    @Environment(\.dismiss) var dismiss
    @State private var report: RegistryInsightsReport?
    @State private var isAnalyzing = true
    @State private var selectedInsight: RegistryInsight?
    @State private var sectionAppeared = [false, false, false, false, false]

    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()

            if isAnalyzing {
                analyzingState
            } else if let report {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        overallScoreHero(report: report)
                            .opacity(sectionAppeared[0] ? 1 : 0)
                            .offset(y: sectionAppeared[0] ? 0 : 20)

                        quickStatsRow(report: report)
                            .opacity(sectionAppeared[1] ? 1 : 0)
                            .offset(y: sectionAppeared[1] ? 0 : 20)

                        insightCardsSection(report: report)
                            .opacity(sectionAppeared[2] ? 1 : 0)
                            .offset(y: sectionAppeared[2] ? 0 : 20)

                        budgetBreakdownSection(report: report)
                            .opacity(sectionAppeared[3] ? 1 : 0)
                            .offset(y: sectionAppeared[3] ? 0 : 20)

                        suggestionsSection(report: report)
                            .opacity(sectionAppeared[4] ? 1 : 0)
                            .offset(y: sectionAppeared[4] ? 0 : 20)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 60)
                }
                .onAppear { animateSections() }
            }
        }
        .navigationTitle("AI Registry Insights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(WSRegistryPalette.ivory, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { await runAnalysis() }
    }

    // MARK: - Analyzing State

    private var analyzingState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(WSRegistryPalette.hairline.opacity(0.4), lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AngularGradient(
                            colors: [WSRegistryPalette.gold, WSRegistryPalette.gold.opacity(0.3)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(isAnalyzing ? 360 : 0))
                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: isAnalyzing)

                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
            }

            VStack(spacing: 10) {
                Text("Analyzing Your Registry")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)

                Text("AURA is evaluating your aesthetic balance,\nbudget distribution, and completeness.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Overall Score Hero

    private func overallScoreHero(report: RegistryInsightsReport) -> some View {
        VStack(spacing: 20) {
            // Score Ring
            ZStack {
                Circle()
                    .stroke(WSRegistryPalette.hairline.opacity(0.3), lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(report.overallScore))
                    .stroke(
                        AngularGradient(
                            colors: [report.overallTier.color, report.overallTier.color.opacity(0.5)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int((report.overallScore * 100).rounded()))")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text("/ 100")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }
            }

            // Tier badge
            HStack(spacing: 6) {
                Image(systemName: report.overallTier.icon)
                    .font(.system(size: 12, weight: .bold))
                Text(report.overallTier.rawValue)
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
            }
            .foregroundStyle(report.overallTier.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(report.overallTier.color.opacity(0.12), in: Capsule())

            // Headline + Tagline
            VStack(spacing: 8) {
                Text(report.headline)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .multilineTextAlignment(.center)

                Text(report.tagline)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)

            // Strengths chips
            if !report.topStrengths.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(report.topStrengths, id: \.self) { strength in
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                Text(strength)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundStyle(Color(hex: "#6F8768"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#6F8768").opacity(0.1), in: Capsule())
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(24)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    // MARK: - Quick Stats

    private func quickStatsRow(report: RegistryInsightsReport) -> some View {
        HStack(spacing: 0) {
            quickStat(label: "Total Value", value: report.totalValueText)
            quickDivider
            quickStat(label: "Avg Price", value: report.averagePriceText)
            quickDivider
            quickStat(label: "Price Range", value: report.priceRangeText)
        }
        .padding(.vertical, 18)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
    }

    private func quickStat(label: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var quickDivider: some View {
        Rectangle()
            .fill(WSRegistryPalette.hairline.opacity(0.5))
            .frame(width: 1, height: 36)
    }

    // MARK: - Insight Cards (Dimension Breakdown)

    private func insightCardsSection(report: RegistryInsightsReport) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("DIMENSION BREAKDOWN")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(WSRegistryPalette.gold)
            }

            // Skip first (overall) insight
            let dimensionInsights = Array(report.insights.dropFirst())
            ForEach(dimensionInsights) { insight in
                insightCard(insight)
            }
        }
    }

    private func insightCard(_ insight: RegistryInsight) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: insight.category.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: insight.category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(insight.category.rawValue)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .textCase(.uppercase)

                    Text(insight.headline)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }

                Spacer()

                // Mini score ring
                ZStack {
                    Circle()
                        .stroke(WSRegistryPalette.hairline.opacity(0.35), lineWidth: 3)
                        .frame(width: 40, height: 40)

                    Circle()
                        .trim(from: 0, to: CGFloat(insight.score))
                        .stroke(insight.tier.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))

                    Text("\(insight.scorePercentage)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
            }

            // Detail
            Text(insight.detail)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.9))
                .lineSpacing(4)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(WSRegistryPalette.hairline.opacity(0.35))
                        .frame(height: 5)
                    Capsule()
                        .fill(insight.tier.color)
                        .frame(width: geo.size.width * CGFloat(insight.score), height: 5)
                }
            }
            .frame(height: 5)

            // Suggestions
            if !insight.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(insight.suggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(WSRegistryPalette.gold)
                                .padding(.top, 2)

                            Text(suggestion)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.85))
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(12)
                .background(WSRegistryPalette.gold.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(16)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.025), radius: 10, x: 0, y: 5)
    }

    // MARK: - Budget Breakdown

    private func budgetBreakdownSection(report: RegistryInsightsReport) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("BUDGET DISTRIBUTION")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(WSRegistryPalette.gold)
            }

            // Stacked bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    ForEach(report.budgetBreakdown) { bucket in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(bucket.color)
                            .frame(width: max(8, geo.size.width * CGFloat(bucket.percentage)))
                    }
                }
            }
            .frame(height: 16)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            // Legend
            VStack(spacing: 10) {
                ForEach(report.budgetBreakdown) { bucket in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(bucket.color)
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(bucket.label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(WSRegistryPalette.espresso)
                            Text(bucket.range)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                        }

                        Spacer()

                        Text("\(bucket.count) item\(bucket.count == 1 ? "" : "s")")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.cocoa)

                        Text("\(Int((bucket.percentage * 100).rounded()))%")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(bucket.color)
                            .frame(width: 38, alignment: .trailing)
                    }
                }
            }
        }
        .padding(18)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.025), radius: 10, x: 0, y: 5)
    }

    // MARK: - Suggestions

    private func suggestionsSection(report: RegistryInsightsReport) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("PERSONALIZED RECOMMENDATIONS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(WSRegistryPalette.gold)
            }

            if report.topSuggestions.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: "#6F8768"))

                    Text("Your registry is in excellent shape! No critical improvements needed.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineSpacing(3)
                }
                .padding(16)
                .background(Color(hex: "#6F8768").opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(report.topSuggestions.enumerated()), id: \.offset) { index, suggestion in
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(WSRegistryPalette.espresso, in: Circle())

                            Text(suggestion)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(WSRegistryPalette.espresso)
                                .lineSpacing(3)

                            Spacer(minLength: 4)
                        }
                        .padding(14)
                        .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(WSRegistryPalette.hairline.opacity(0.4), lineWidth: 1)
                        )
                    }
                }
            }

            // Powered by AURA
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("Powered by AURA Intelligence")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                Spacer()
                Text("Updated \(report.generatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.7))
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.025), radius: 10, x: 0, y: 5)
    }

    // MARK: - Helpers

    private func runAnalysis() async {
        // Simulate AI processing time
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        let result = RegistryAIInsightsEngine.analyze(registry: registry)
        withAnimation(.easeOut(duration: 0.5)) {
            report = result
            isAnalyzing = false
        }
    }

    private func animateSections() {
        for i in sectionAppeared.indices {
            withAnimation(.easeOut(duration: 0.5).delay(Double(i) * 0.12)) {
                sectionAppeared[i] = true
            }
        }
    }
}
