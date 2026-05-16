//
//  RegistryEvent.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
enum RegistryEvent: String, CaseIterable, Identifiable, Codable {
    case birthday = "Birthday"
    case wedding = "Wedding"
    case anniversary = "Anniversary"
    case housewarming = "Housewarming"
    case baby = "Baby"
    case other = "Other"
    
    static let onboardingEvents: [RegistryEvent] = [.wedding, .housewarming, .baby, .other]
    
    var id: String { rawValue }
    var title: String { rawValue }
}
