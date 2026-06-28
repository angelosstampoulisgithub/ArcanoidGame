//
//  ArcanoidApp.swift
//  Arcanoid
//
//  Created by Angelos Staboulis on 28/6/26.
//

import SwiftUI

@main
struct ArcanoidApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 900, height: 700)
        }
        .windowResizability(.contentSize)
    }
}
