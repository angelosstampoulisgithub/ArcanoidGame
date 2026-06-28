//
//  ContentView.swift
//  Arcanoid
//
//  Created by Angelos Staboulis on 28/6/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    var body: some View {
        GeometryReader { geo in
                  ZStack {
                      // Retro background
                      LinearGradient(
                          colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.15)],
                          startPoint: .top,
                          endPoint: .bottom
                      )
                      .ignoresSafeArea()
                      
                      // Bricks
                      ForEach(viewModel.bricks) { brick in
                          if !brick.isDestroyed {
                              RoundedRectangle(cornerRadius: 3)
                                  .fill(brickColor(for: brick))
                                  .overlay(
                                      RoundedRectangle(cornerRadius: 3)
                                          .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                  )
                                  .frame(width: brick.rect.width, height: brick.rect.height)
                                  .position(x: brick.rect.midX, y: brick.rect.midY)
                          }
                      }
                      
                      // Paddle
                      RoundedRectangle(cornerRadius: 4)
                          .fill(Color.white)
                          .frame(width: viewModel.paddleRect.width,
                                 height: viewModel.paddleRect.height)
                          .position(x: viewModel.paddleRect.midX,
                                    y: viewModel.paddleRect.midY)
                          .shadow(color: .white.opacity(0.4), radius: 4)
                      
                      // Ball
                      Circle()
                          .fill(Color.yellow)
                          .overlay(
                              Circle()
                                  .stroke(Color.white.opacity(0.6), lineWidth: 2)
                          )
                          .frame(width: 16, height: 16)
                          .position(viewModel.ballCenter)
                          .shadow(color: .yellow.opacity(0.7), radius: 6)
                      
                      // Particles
                      ForEach(viewModel.particles) { particle in
                          Circle()
                              .fill(Color.orange.opacity(particle.life))
                              .frame(width: 6, height: 6)
                              .position(particle.position)
                      }
                      
                      // HUD
                      VStack {
                          HStack {
                              Text("ARKANOID")
                                  .font(.system(size: 24, weight: .heavy, design: .monospaced))
                                  .foregroundColor(.cyan)
                              Spacer()
                              Text("Score: \(viewModel.score)")
                                  .foregroundColor(.white)
                                  .font(.system(size: 16, weight: .bold, design: .monospaced))
                              Text("High: \(viewModel.highScore)")
                                  .foregroundColor(.yellow)
                                  .font(.system(size: 16, weight: .bold, design: .monospaced))
                              Button(viewModel.gameState == .running ? "Restart" : "Start") {
                                  viewModel.setup(in: geo.frame(in: .local))
                                  viewModel.startGame()
                              }
                              .buttonStyle(.borderedProminent)
                          }
                          .padding(.horizontal)
                          .padding(.top, 8)
                          
                          Spacer()
                          
                          if viewModel.gameState == .gameOver {
                              statusView(text: "GAME OVER", color: .red)
                          } else if viewModel.gameState == .win {
                              VStack(spacing: 12) {
                                  statusView(text: "YOU WIN!", color: .green)
                                  Button("Next Level") {
                                      viewModel.nextLevel(in: geo.frame(in: .local))
                                  }
                                  .buttonStyle(.borderedProminent)
                              }
                          }
                          
                          Spacer().frame(height: 20)
                      }
                  }
                  .onAppear {
                      viewModel.setup(in: geo.frame(in: .local))
                  }
                  .gesture(
                      DragGesture(minimumDistance: 0)
                          .onChanged { value in
                              viewModel.movePaddle(to: value.location.x)
                          }
                  )
              }
          }
          
          private func brickColor(for brick: Brick) -> LinearGradient {
              switch brick.type {
              case .normal:
                  return LinearGradient(
                      colors: [Color.green, Color.blue],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                  )
              case .strong:
                  return LinearGradient(
                      colors: [Color.red, Color.orange],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                  )
              case .powerUp:
                  return LinearGradient(
                      colors: [Color.purple, Color.cyan],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                  )
              }
          }
          
          private func statusView(text: String, color: Color) -> some View {
              Text(text)
                  .font(.system(size: 40, weight: .heavy, design: .monospaced))
                  .foregroundColor(color)
                  .shadow(color: color.opacity(0.7), radius: 10)
                  .padding(.bottom, 40)
          }
}

#Preview {
    ContentView()
}
