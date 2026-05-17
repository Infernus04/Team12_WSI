// ARQuickLookView.swift
// Team12_WSI — AR Quick Look presenter using QLPreviewController + USDZ

import SwiftUI
import QuickLook
import ARKit

// MARK: - AR Quick Look representable (low-level UIKit wrapper)

struct ARQuickLookView: UIViewControllerRepresentable {

    let fileURL: URL
    var onDismiss: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UINavigationController {
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator
        previewController.delegate   = context.coordinator
        let nav = UINavigationController(rootViewController: previewController)
        nav.modalPresentationStyle = .fullScreen
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    final class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let parent: ARQuickLookView
        init(parent: ARQuickLookView) { self.parent = parent }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController,
                               previewItemAt index: Int) -> any QLPreviewItem {
            parent.fileURL as NSURL
        }

        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            parent.onDismiss?()
        }
    }
}

// MARK: - ARQuickLookScreen: full-screen AR view with Exit AR button overlay

struct ARQuickLookScreen: View {
    let fileURL: URL
    let onExit: () -> Void

    @State private var exitScale: CGFloat = 1.0
    @State private var exitOpacity: Double = 1.0

    var body: some View {
        ZStack(alignment: .topLeading) {

            // AR preview fills entire screen
            ARQuickLookView(fileURL: fileURL, onDismiss: onExit)
                .ignoresSafeArea()

            // ── Exit AR button — always visible top-left ──────────────
            Button(action: onExit) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Exit AR")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.2)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.6))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .scaleEffect(exitScale)
                .opacity(exitOpacity)
            }
            .padding(.top, 56)    // clears status bar
            .padding(.leading, 20)
            .onAppear {
                // Two-pulse animation on launch so user notices the button
                withAnimation(.easeInOut(duration: 0.9).repeatCount(2, autoreverses: true)) {
                    exitScale = 1.1
                }
                // After pulses settle, fade slightly to be less intrusive
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        exitScale   = 1.0
                        exitOpacity = 0.85
                    }
                }
            }
        }
    }
}

// MARK: - ARViewButton: reusable camera icon for product cards

struct ARViewButton: View {
    let modelURL: URL?
    var size: CGFloat = 32

    @State private var showAR = false

    var body: some View {
        Button {
            guard modelURL != nil else { return }
            showAR = true
        } label: {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: size * 0.5, weight: .medium))
                .foregroundColor(modelURL != nil ? .wsPrimary : .wsSecondary)
                .frame(width: size, height: size)
                .background(Color.white.opacity(0.92))
                .clipShape(Circle())
        }
        .fullScreenCover(isPresented: $showAR) {
            if let url = modelURL {
                ARQuickLookScreen(fileURL: url, onExit: { showAR = false })
            }
        }
    }
}

// MARK: - ARModelLibrary: resolves thesofa.usdz from the app bundle

enum ARModelLibrary {
    static var sofaURL: URL? {
        // Primary: app bundle (Copy Bundle Resources)
        if let url = Bundle.main.url(forResource: "thesofa", withExtension: "usdz") {
            return url
        }
        // Fallback: file-system sync group paths
        let candidates = [
            Bundle.main.bundlePath + "/thesofa.usdz",
            Bundle.main.bundlePath + "/3D model/thesofa.usdz"
        ]
        return candidates
            .map { URL(fileURLWithPath: $0) }
            .first { FileManager.default.fileExists(atPath: $0.path) }
    }
}
