// HomeEditorialModels.swift
// Team12_WSI

import Foundation

struct LifestyleScene: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let reason: String
}

struct AestheticBundle: Identifiable {
    let id = UUID()
    let title: String
    let compatibilityScore: Int
    let imageName: String
    let description: String
}

struct EditorialArticle: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

struct RegistryInsight: Identifiable {
    let id = UUID()
    let category: String
    let score: Int
    let recommendation: String
}

class HomeEditorialData {
    static let scenes = [
        LifestyleScene(title: "Sunday Brunch Hosting", subtitle: "Warm light and organic textures for shared moments.", imageName: "brunch_scene", reason: "These ceramics complement your oak flooring and hosting frequency."),
        LifestyleScene(title: "Intimate Evening Dining", subtitle: "Layered shadows and brass highlights.", imageName: "dinner_scene", reason: "Designed around your preference for modern minimal dining.")
    ]
    
    static let bundles = [
        AestheticBundle(title: "Modern Autumn Hosting", compatibilityScore: 98, imageName: "bundle_autumn", description: "Ceramic dinnerware, linen napkins, and brass accents."),
        AestheticBundle(title: "Organic Minimalist Morning", compatibilityScore: 92, imageName: "bundle_morning", description: "Hand-thrown mugs and sustainable wood trays.")
    ]
    
    static let articles = [
        EditorialArticle(title: "The Art of Layered Minimalism", subtitle: "How to create depth in neutral spaces.", imageName: "article_minimalism"),
        EditorialArticle(title: "Hosting Elegantly This Autumn", subtitle: "Refined tablescapes for the season.", imageName: "article_hosting")
    ]
}
