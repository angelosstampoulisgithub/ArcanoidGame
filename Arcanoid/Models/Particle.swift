//
//  Particle.swift
//  Arcanoid
//
//  Created by Angelos Staboulis on 28/6/26.
//

import Foundation
import SwiftUI
struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var life: Double
}
