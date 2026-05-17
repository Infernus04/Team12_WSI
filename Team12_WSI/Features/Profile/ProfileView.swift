// ProfileView.swift
// Team12_WSI — Clean iOS-native Profile sheet

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository

    private let orders = OrderJourney.mock
    private let registries = RegistrySnapshot.mock
    private let collections = SavedCollection.mock
    private let services = ServiceCard.mock

    var body: some View {
        NavigationStack {
            List {
                // MARK: Hero header (non-tappable)
                Section {
                    profileHeader
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.wsWarmIvory)
                .listRowSeparator(.hidden)

                // MARK: Orders
                Section(header: sectionLabel("YOUR HOME JOURNEY")) {
                    ForEach(orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderRowView(order: order)
                        }
                    }
                }

                // MARK: Registry
                Section(header: sectionLabel("REGISTRIES")) {
                    ForEach(registries) { reg in
                        NavigationLink(destination: RegistryDetailView(registry: reg)) {
                            RegistryRowView(registry: reg)
                        }
                    }
                }

                // MARK: Saved collections
                Section(header: sectionLabel("SAVED COLLECTIONS")) {
                    ForEach(collections) { col in
                        collectionRow(col)
                    }
                }

                // MARK: Services
                Section(header: sectionLabel("SERVICES")) {
                    ForEach(services.prefix(4)) { svc in
                        serviceRow(svc)
                    }
                }

                // MARK: Membership
                Section(header: sectionLabel("MEMBERSHIP")) {
                    membershipRow
                }

                // MARK: Account
                Section(header: sectionLabel("ACCOUNT")) {
                    accountRow("Saved Addresses", icon: "location")
                    accountRow("Payment Methods", icon: "creditcard")
                    accountRow("Notification Preferences", icon: "bell")
                    accountRow("Privacy & Data", icon: "lock.shield")
                }

                // MARK: Sign out
                Section {
                    Button(role: .destructive, action: {}) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .font(.wsBody(size: 15))
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.wsBody(size: 15, weight: .semibold))
                        .foregroundColor(.wsMutedBrass)
                }
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.wsChampagne)
                    .frame(width: 76, height: 76)
                Text("AA")
                    .font(.wsSerif(size: 26, weight: .semibold))
                    .foregroundColor(.wsMutedBrass)
            }
            VStack(spacing: 4) {
                Text("Ausaf Ahmed")
                    .font(.wsSerif(size: 20, weight: .semibold))
                    .foregroundColor(.wsCharcoal)
                Text("ausaf@email.com")
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    // MARK: - Collection Row

    private func collectionRow(_ col: SavedCollection) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(col.accentColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: col.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(col.accentColor)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(col.title)
                    .font(.wsBody(size: 14))
                    .foregroundColor(.wsCharcoal)
                Text("\(col.itemCount) items")
                    .font(.wsBody(size: 12))
                    .foregroundColor(.wsSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Service Row

    private func serviceRow(_ svc: ServiceCard) -> some View {
        HStack(spacing: 14) {
            Image(systemName: svc.iconName)
                .font(.system(size: 16))
                .foregroundColor(.wsMutedBrass)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(svc.title)
                    .font(.wsBody(size: 14)).foregroundColor(.wsCharcoal)
                Text(svc.subtitle)
                    .font(.wsBody(size: 12)).foregroundColor(.wsSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Membership Row

    private var membershipRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.wsMutedBrass)
            VStack(alignment: .leading, spacing: 2) {
                Text("Reserve Member")
                    .font(.wsBody(size: 14, weight: .semibold)).foregroundColor(.wsCharcoal)
                Text("Early access & priority concierge")
                    .font(.wsBody(size: 12)).foregroundColor(.wsSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Account Row

    private func accountRow(_ label: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.wsMutedBrass)
                .frame(width: 28)
            Text(label)
                .font(.wsBody(size: 14)).foregroundColor(.wsCharcoal)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.wsLabel(size: 10))
            .tracking(1.5)
            .foregroundColor(.wsSecondary)
    }
}

// MARK: - Order Row

struct OrderRowView: View {
    let order: OrderJourney
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(order.deliveryStatus == "Delivered" ? Color.green : Color.wsMutedBrass)
                        .frame(width: 7, height: 7)
                    Text(order.deliveryStatus)
                        .font(.wsBody(size: 11))
                        .foregroundColor(.wsSecondary)
                }
                Spacer()
                Text(order.dateString)
                    .font(.wsBody(size: 11))
                    .foregroundColor(.wsSecondary)
            }
            Text(order.collectionTitle)
                .font(.wsBody(size: 14, weight: .semibold))
                .foregroundColor(.wsCharcoal)
            Text(order.itemNames.joined(separator: " · "))
                .font(.wsBody(size: 12))
                .foregroundColor(.wsSecondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Registry Row

struct RegistryRowView: View {
    let registry: RegistrySnapshot
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(registry.registryName)
                    .font(.wsBody(size: 14, weight: .semibold))
                    .foregroundColor(.wsCharcoal)
                Text("\(registry.purchasedItems) of \(registry.totalItems) items purchased")
                    .font(.wsBody(size: 12))
                    .foregroundColor(.wsSecondary)
            }
            Spacer()
            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(Color.wsIvoryShadow, lineWidth: 3)
                    .frame(width: 38, height: 38)
                Circle()
                    .trim(from: 0, to: registry.completionPercent)
                    .stroke(Color.wsMutedBrass, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 38, height: 38)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(registry.completionPercent * 100))%")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.wsCharcoal)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Order Detail View

struct OrderDetailView: View {
    let order: OrderJourney
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(order.deliveryStatus == "Delivered" ? Color.green : Color.wsMutedBrass)
                            .frame(width: 8, height: 8)
                        Text(order.deliveryStatus.uppercased())
                            .font(.wsLabel(size: 10)).tracking(1.5).foregroundColor(.wsSecondary)
                        Spacer()
                        Text(order.dateString).font(.wsBody(size: 12)).foregroundColor(.wsSecondary)
                    }
                    Text(order.collectionTitle)
                        .font(.wsSerif(size: 20, weight: .semibold)).foregroundColor(.wsCharcoal)
                    Text(order.emotionalLabel)
                        .font(.wsBody(size: 13)).foregroundColor(.wsMutedBrass)
                }
                .padding(.vertical, 6)
            }

            Section(header: Text("ITEMS").font(.wsLabel(size: 10)).tracking(1.5)) {
                ForEach(order.itemNames, id: \.self) { item in
                    Text(item).font(.wsBody(size: 14)).foregroundColor(.wsCharcoal)
                }
            }

            Section(header: Text("ACTIONS").font(.wsLabel(size: 10)).tracking(1.5)) {
                ForEach(["Track Order", "Reorder Collection", "Add to Registry", "View Styling Recommendations"], id: \.self) { action in
                    Button(action: {}) {
                        Text(action).font(.wsBody(size: 14)).foregroundColor(.wsCharcoal)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(order.collectionTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Registry Detail View

struct RegistryDetailView: View {
    let registry: RegistrySnapshot
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(registry.registryName)
                        .font(.wsSerif(size: 20, weight: .semibold)).foregroundColor(.wsCharcoal)
                    Text(registry.occasion)
                        .font(.wsLabel(size: 10)).tracking(1.5).foregroundColor(.wsMutedBrass)

                    // Progress bar
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("\(registry.purchasedItems) of \(registry.totalItems) items purchased")
                                .font(.wsBody(size: 12)).foregroundColor(.wsSecondary)
                            Spacer()
                            Text("\(Int(registry.completionPercent * 100))%")
                                .font(.wsLabel(size: 11)).foregroundColor(.wsCharcoal)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color.wsIvoryShadow).frame(height: 4).cornerRadius(2)
                                Rectangle().fill(Color.wsMutedBrass)
                                    .frame(width: geo.size.width * registry.completionPercent, height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                    }
                }
                .padding(.vertical, 6)
            }

            Section(header: Text("INSIGHTS").font(.wsLabel(size: 10)).tracking(1.5)) {
                ForEach(registry.insights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 13)).foregroundColor(.wsMutedBrass)
                        Text(insight).font(.wsBody(size: 13)).foregroundColor(.wsSecondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(registry.registryName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
