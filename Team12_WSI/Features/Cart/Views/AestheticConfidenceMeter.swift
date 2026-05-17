//
//  AestheticConfidenceMeter.swift
//  Team12_WSI
//

import SwiftUI

struct AestheticConfidenceMeter: View {
    let analysis: AuraCartAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aura Harmony")
                        .font(AuraDesign.Fonts.serif(size: 18, weight: .semibold))
                        .foregroundColor(AuraDesign.Colors.charcoal)
                    
                    Text("Aesthetic Style · \(analysis.overallAesthetic)")
                        .font(AuraDesign.Fonts.sansSerif(size: 12, weight: .medium))
                        .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.65))
                }
                
                Spacer()
                
                Text("\(Int(analysis.confidenceScore))%")
                    .font(AuraDesign.Fonts.sansSerif(size: 18, weight: .bold))
                    .foregroundColor(AuraDesign.Colors.charcoal)
            }
            
            Text(analysis.completenessStatus.title)
                .font(AuraDesign.Fonts.sansSerif(size: 13, weight: .semibold))
                .foregroundColor(statusColor)
            
            Text(statusDescription)
                .font(AuraDesign.Fonts.sansSerif(size: 13))
                .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.8))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AuraDesign.Colors.cream)
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(AuraDesign.Colors.mutedGold)
                        .frame(width: max(0, geometry.size.width * CGFloat(analysis.confidenceScore) / 100.0), height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 1.0), value: analysis.confidenceScore)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private var statusColor: Color {
        switch analysis.completenessStatus {
        case .clashing: return AuraDesign.Colors.errorRed
        case .complete: return AuraDesign.Colors.successGreen
        default: return AuraDesign.Colors.charcoal.opacity(0.6)
        }
    }
    
    private var statusDescription: String {
        switch analysis.completenessStatus {
        case .incomplete:
            return "Start with one more coordinated piece to let Aura shape the direction."
        case .building:
            return "The cart has a promising point of view and room for one more thoughtful layer."
        case .complete:
            return "This mix reads as a resolved collection with a confident, polished mood."
        case .clashing:
            return "One item is pulling the composition off-balance, so Aura is suggesting a cleaner direction."
        }
    }
}
