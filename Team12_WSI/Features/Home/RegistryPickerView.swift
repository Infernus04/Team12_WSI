// RegistryPickerView.swift
// Team12_WSI — Modal sheet to pick which registry to add a product to

import SwiftUI

struct RegistryPickerView: View {
    let product: ProductItem
    @EnvironmentObject var registryRepository: RegistryRepository
    @Environment(\.dismiss) private var dismiss

    @State private var selectedRegistryID: UUID? = nil
    @State private var confirmed = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.wsWarmIvory.ignoresSafeArea()

                if registryRepository.registries.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        // Product preview header
                        productPreview
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 16)

                        WSDivider()

                        // Registry list
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                Text("SELECT A REGISTRY")
                                    .font(.wsLabel(size: 9))
                                    .tracking(2)
                                    .foregroundColor(.wsSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 20)

                                ForEach(registryRepository.registries) { registry in
                                    registryRow(registry)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120) // room for CTA
                        }
                    }

                    // Floating CTA
                    VStack {
                        Spacer()
                        addButton
                            .padding(.horizontal, 20)
                            .padding(.bottom, 28)
                            .background(
                                LinearGradient(
                                    colors: [Color.wsWarmIvory.opacity(0), Color.wsWarmIvory],
                                    startPoint: .top, endPoint: .bottom
                                )
                                .frame(height: 100)
                                .ignoresSafeArea(),
                                alignment: .bottom
                            )
                    }
                }
            }
            .navigationTitle("Save to Registry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.wsSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            // Pre-select the active registry if it exists
            selectedRegistryID = registryRepository.activeRegistryID
                ?? registryRepository.registries.first?.id
        }
    }

    // MARK: - Product Preview

    private var productPreview: some View {
        HStack(spacing: 14) {
            CustomAsyncImage(url: product.imageURL)
                .frame(width: 56, height: 56)
                .cornerRadius(4)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.wsBody(size: 13, weight: .semibold))
                    .foregroundColor(.wsCharcoal)
                    .lineLimit(2)
                if let price = product.price {
                    Text("$\(price, specifier: "%.2f")")
                        .font(.wsBody(size: 12))
                        .foregroundColor(.wsCrimson)
                }
            }
            Spacer()
        }
    }

    // MARK: - Registry Row

    private func registryRow(_ registry: Registry) -> some View {
        let isSelected = selectedRegistryID == registry.id

        return Button(action: { selectedRegistryID = registry.id }) {
            HStack(spacing: 14) {
                // Event icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.wsCharcoal : Color.wsChampagne)
                        .frame(width: 44, height: 44)
                    Image(systemName: eventIcon(for: registry.event))
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .white : .wsMutedBrass)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(registry.displayName)
                        .font(.wsBody(size: 14, weight: .semibold))
                        .foregroundColor(.wsCharcoal)
                    Text("\(registry.items.count) item\(registry.items.count == 1 ? "" : "s")")
                        .font(.wsBody(size: 12))
                        .foregroundColor(.wsSecondary)
                }

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.wsCharcoal : Color.wsIvoryShadow, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.wsCharcoal)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(4)
            .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.04), radius: 6, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.wsCharcoal.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button(action: {
            guard let id = selectedRegistryID else { return }
            registryRepository.addProduct(product, toRegistryID: id)
            withAnimation(.spring(response: 0.3)) { confirmed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
        }) {
            HStack(spacing: 8) {
                Image(systemName: confirmed ? "checkmark" : "heart")
                    .font(.system(size: 14))
                Text(confirmed ? "ADDED TO REGISTRY" : "ADD TO REGISTRY")
                    .font(.wsLabel(size: 12))
                    .tracking(1.5)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(confirmed ? Color.wsMutedBrass : (selectedRegistryID != nil ? Color.wsCharcoal : Color.wsSecondary))
            .cornerRadius(4)
            .animation(.easeInOut(duration: 0.2), value: confirmed)
        }
        .disabled(selectedRegistryID == nil || confirmed)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "heart.text.square")
                .font(.system(size: 44, weight: .ultraLight))
                .foregroundColor(.wsMutedBrass)
            VStack(spacing: 8) {
                Text("No Registries Yet")
                    .font(.wsSerif(size: 18))
                    .foregroundColor(.wsCharcoal)
                Text("Create a registry from the Registry tab to start saving products.")
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Button(action: { dismiss() }) {
                Text("CLOSE")
                    .font(.wsLabel(size: 11)).tracking(1.5)
            }
            .buttonStyle(WSSecondaryButtonStyle())
            .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Event Icon Helper

    private func eventIcon(for event: RegistryEvent) -> String {
        switch event {
        case .wedding:      return "heart.circle"
        case .baby:         return "figure.2.and.child.holdinghands"
        case .birthday:     return "gift"
        case .anniversary:  return "rosette"
        case .housewarming: return "house"
        case .other:        return "list.bullet.rectangle"
        }
    }
}
