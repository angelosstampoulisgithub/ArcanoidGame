//
//  Level.swift
//  Arcanoid
//
//  Created by Angelos Staboulis on 28/6/26.
//

import Foundation
import CoreGraphics

struct Level {
    let rows: Int
    let cols: Int
    let layout: (Int, Int) -> BrickType
}

let levels: [Level] = [
    Level(rows: 6, cols: 12) { row, col in
        if row == 0 || row == 1 {
            return .strong
        } else if (row + col) % 5 == 0 {
            return .powerUp
        } else {
            return .normal
        }
    },
    Level(rows: 7, cols: 13) { row, col in
        if (row - col).magnitude % 4 == 0 {
            return .powerUp
        } else {
            return .normal
        }
    }
]
