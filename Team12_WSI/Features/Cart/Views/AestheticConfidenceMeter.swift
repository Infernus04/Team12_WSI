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
                        .font(.wsSerif(size: 18, weight: .semibold))
                        .foregroundColor(.wsCharcoal)
                    
                    Text("Aesthetic Style · \(analysis.overallAesthetic)")
                        .font(.wsBody(size: 12, weight: .medium))
                        .foregroundColor(.wsCharcoal.opacity(0.65))
                }
                
                Spacer()
                
                Text("\(Int(analysis.confidenceScore))%")
                    .font(.wsBody(size: 18, weight: .bold))
                    .foregroundColor(.wsCharcoal)
            }
            
            Text(analysis.completenessStatus.title)
                .font(.wsBody(size: 13, weight: .semibold))
                .foregroundColor(statusColor)
            
            Text(statusDescription)
                .font(.wsBody(size: 13))
                .foregroundColor(.wsCharcoal.opacity(0.8))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.wsWarmIvory)
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color.wsMutedBrass)
                        .frame(width: max(0, geometry.size.width * CGFloat(analysis.confidenceScore) / 100.0), height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 1.0), value: analysis.confidenceScore)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .background(Color.wsSurface)
        .cornerRadius(2)
        .wsLuxuryShadow()
    }
    
    private var statusColor: Color {
        switch analysis.completenessStatus {
        case .clashing: return Color.wsCrimson
        case .complete: return Color.wsCharcoal
        default: return Color.wsCharcoal.opacity(0.6)
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
