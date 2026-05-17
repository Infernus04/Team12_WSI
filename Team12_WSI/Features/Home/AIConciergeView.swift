// AIConciergeView.swift
// Team12_WSI — Elegant AI Concierge dedicated Chatbot panel

import SwiftUI

struct ConciergeChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
    let products: [ProductItem]
}

struct AIConciergeView: View {
    let allProducts: [ProductItem]
    let registryRepository: RegistryRepository
    let onSelectProduct: (ProductItem) -> Void

    @Environment(\.dismiss) private var dismiss

    // Chatbot States
    @State private var messages: [ConciergeChatMessage] = [
        ConciergeChatMessage(
            isUser: false,
            text: "Welcome to your Aura AI Concierge. I am your personal home designer, trained on the complete Williams-Sonoma catalog. Feel free to ask me anything in natural language—whether you are looking for premium cookware, organic dining plates, or suggestions to complete your registry style!",
            products: []
        )
    ]
    @State private var chatInputText = ""
    @State private var isAILoading = false

    var body: some View {
        ZStack {
            Color.wsWarmIvory.ignoresSafeArea()

            VStack(spacing: 0) {
                conciergeHeader
                WSDivider()
                askAuraTab
            }
        }
    }

    // MARK: - Header

    private var conciergeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundColor(.wsMutedBrass)
                    Text("AURA AI CONCIERGE")
                        .font(.wsLabel(size: 10))
                        .tracking(2)
                        .foregroundColor(.wsMutedBrass)
                }
                Text("Your Home Intelligence")
                    .font(.wsDisplay(size: 22))
                    .foregroundColor(.wsCharcoal)
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.wsCharcoal)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
                    .wsShadow()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.wsWarmIvory)
    }

    // MARK: - Ask Aura AI Chatbot

    private var askAuraTab: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(messages) { msg in
                            chatBubble(msg: msg)
                                .id(msg.id)
                        }

                        if isAILoading {
                            typingIndicator
                                .id("typingIndicator")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onChange(of: isAILoading) { loading in
                    if loading {
                        withAnimation { proxy.scrollTo("typingIndicator", anchor: .bottom) }
                    }
                }
            }

            if messages.count == 1 {
                chatQuickSuggestions
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
            }

            chatInputBar
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
    }

    private func chatBubble(msg: ConciergeChatMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if msg.isUser {
                Spacer()

                Text(msg.text)
                    .font(.wsSerif(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(WSRegistryPalette.espresso, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(WSRegistryPalette.gold)
                    .frame(width: 28, height: 28)
                    .background(WSRegistryPalette.gold.opacity(0.12), in: Circle())
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 12) {
                    Text(msg.text)
                        .font(.wsSerif(size: 14))
                        .foregroundColor(WSRegistryPalette.espresso)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .wsShadow()

                    if !msg.products.isEmpty {
                        chatCarousel(products: msg.products)
                            .padding(.top, 4)
                    }
                }

                Spacer()
            }
        }
    }

    private func chatCarousel(products: [ProductItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECOMMENDED FROM THE CATALOG  ✦")
                .font(.wsLabel(size: 8))
                .tracking(1.5)
                .foregroundColor(WSRegistryPalette.gold)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(products) { product in
                        Button {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSelectProduct(product)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                CustomAsyncImage(url: product.imageURL)
                                    .frame(width: 102, height: 102)
                                    .clipped()
                                    .cornerRadius(8)

                                Text(product.name)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(WSRegistryPalette.espresso)
                                    .lineLimit(1)
                                    .frame(width: 102, alignment: .leading)

                                if let price = product.price {
                                    Text("$\(price, specifier: "%.2f")")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(WSRegistryPalette.espresso)
                                }
                            }
                            .padding(8)
                            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var typingIndicator: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 12))
                .foregroundColor(WSRegistryPalette.gold)
                .frame(width: 28, height: 28)
                .background(WSRegistryPalette.gold.opacity(0.12), in: Circle())

            HStack(spacing: 5) {
                Circle()
                    .fill(WSRegistryPalette.warmGray.opacity(0.4))
                    .frame(width: 6, height: 6)
                Circle()
                    .fill(WSRegistryPalette.warmGray.opacity(0.6))
                    .frame(width: 6, height: 6)
                Circle()
                    .fill(WSRegistryPalette.warmGray.opacity(0.8))
                    .frame(width: 6, height: 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .wsShadow()
        }
    }

    private var chatQuickSuggestions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SUGGESTED DISCOVERIES")
                .font(.wsLabel(size: 8))
                .tracking(1.5)
                .foregroundColor(WSRegistryPalette.gold)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                suggestionButton("🍳 Premium Cookware") {
                    submitChatQuery("Show me premium cookware and pans under $500")
                }
                suggestionButton("🍽️ Organic Dinnerware") {
                    submitChatQuery("Recommend ceramic plates and organic bowls")
                }
                suggestionButton("🍷 Entertaining & Wine") {
                    submitChatQuery("What wine glasses and entertaining tools should I add?")
                }
                suggestionButton("🧼 Elegant Homekeeping") {
                    submitChatQuery("Show me Williams Sonoma board oils or homekeeping items")
                }
            }
        }
    }

    private func suggestionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(WSRegistryPalette.espresso)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(WSRegistryPalette.hairline.opacity(0.62), lineWidth: 1)
                )
                .wsShadow()
        }
        .buttonStyle(.plain)
    }

    private var chatInputBar: some View {
        HStack(spacing: 12) {
            TextField("Message ", text: $chatInputText, axis: .vertical)
                .font(.system(size: 15))
                .foregroundColor(WSRegistryPalette.espresso)
                .lineLimit(1...5)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 48)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(WSRegistryPalette.porcelain)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(WSRegistryPalette.hairline.opacity(0.85), lineWidth: 1)
                )

            Button {
                let query = chatInputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !query.isEmpty else { return }
                submitChatQuery(query)
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(WSRegistryPalette.porcelain)
                    .frame(width: 48, height: 48)
                    .background(WSRegistryPalette.espresso, in: Circle())
                    .wsShadow()
            }
            .disabled(chatInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func submitChatQuery(_ query: String) {
        chatInputText = ""

        let userMessage = ConciergeChatMessage(isUser: true, text: query, products: [])
        messages.append(userMessage)

        isAILoading = true

        AuraAIService.shared.sendMessage(query, catalog: allProducts) { replyText, recommendedItems in
            isAILoading = false
            let aiMessage = ConciergeChatMessage(isUser: false, text: replyText, products: recommendedItems)
            withAnimation(.spring()) {
                messages.append(aiMessage)
            }
        }
    }
}
