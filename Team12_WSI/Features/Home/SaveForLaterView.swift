// SaveForLaterView.swift
// Team12_WSI — Premium "Buy Later" list sheet

import SwiftUI

struct SaveForLaterView: View {
    @StateObject private var viewModel = SaveForLaterViewModel()
    @EnvironmentObject var saveForLaterRepository: SaveForLaterRepository
    @EnvironmentObject var cartRepository: CartRepository
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Color.wsWarmIvory.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Header
                header

                WSDivider()

                if viewModel.isEmpty {
                    emptyState
                } else {
                    // MARK: Items list
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(viewModel.items) { item in
                                SaveForLaterRow(
                                    item: item,
                                    onMoveToCart: { viewModel.moveToCart(item) },
                                    onRemove: { viewModel.remove(item) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }

                    // MARK: Footer hint
                    VStack(spacing: 4) {
                        WSDivider()
                        Text("\(viewModel.items.count) ITEM\(viewModel.items.count == 1 ? "" : "S") SAVED FOR LATER")
                            .font(.wsLabel(size: 9))
                            .tracking(1.5)
                            .foregroundColor(.wsSecondary)
                            .padding(.vertical, 16)
                    }
                    .background(Color.wsWarmIvory)
                }
            }
        }
        .onAppear {
            viewModel.bind(
                saveForLaterRepository: saveForLaterRepository,
                cartRepository: cartRepository
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("SAVED FOR LATER")
                    .font(.wsLabel(size: 11))
                    .tracking(2)
                    .foregroundColor(.wsMutedBrass)
                Text("Buy Later")
                    .font(.wsDisplay(size: 22))
                    .foregroundColor(.wsCharcoal)
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.wsCharcoal)
                    .frame(width: 36, height: 36)
                    .background(Color.wsIvoryShadow)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bookmark")
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundColor(.wsMutedBrass)
            VStack(spacing: 8) {
                Text("Your list is empty")
                    .font(.wsSerif(size: 18))
                    .foregroundColor(.wsCharcoal)
                Text("Save items to buy later from any product page.")
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Save For Later Row

struct SaveForLaterRow: View {
    let item: CartItem
    let onMoveToCart: () -> Void
    let onRemove: () -> Void

    @State private var moved = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Thumbnail
            CustomAsyncImage(url: item.imageURL)
                .frame(width: 88, height: 88)
                .cornerRadius(2)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsCharcoal)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("$\(item.price, specifier: "%.2f")")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.wsCrimson)

                Spacer().frame(height: 2)

                // Action row
                HStack(spacing: 10) {
                    // Move to Bag
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) { moved = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            onMoveToCart()
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: moved ? "checkmark" : "bag")
                                .font(.system(size: 10))
                            Text(moved ? "MOVED" : "MOVE TO BAG")
                                .font(.wsLabel(size: 9))
                                .tracking(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(moved ? Color.wsMutedBrass : Color.wsCharcoal)
                        .cornerRadius(2)
                    }

                    // Remove
                    Button(action: onRemove) {
                        Text("REMOVE")
                            .font(.wsLabel(size: 9))
                            .tracking(1)
                            .foregroundColor(.wsSecondary)
                            .underline()
                    }
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(2)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
