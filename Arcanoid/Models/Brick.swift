//
//  Brick.swift
//  Arcanoid
//
//  Created by Angelos Staboulis on 28/6/26.
//

import Foundation
import SwiftUI
struct Brick: Identifiable {
    let id = UUID()
    var rect: CGRect
    var hitsRemaining: Int
    var type: BrickType
    var isDestroyed: Bool = false
}
