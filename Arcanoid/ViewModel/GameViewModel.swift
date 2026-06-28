//
//  GameViewModel.swift
//  Arcanoid
//
//  Created by Angelos Staboulis on 28/6/26.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

final class GameViewModel: ObservableObject {
    @Published var paddleRect: CGRect = .zero
    @Published var ballCenter: CGPoint = .zero
    @Published var ballVelocity: CGPoint = CGPoint(x: 4, y: -4)
    @Published var bricks: [Brick] = []
    @Published var particles: [Particle] = []
    @Published var gameState: GameState = .ready
    @Published var score: Int = 0
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "ArkanoidHighScore")
    @Published var currentLevelIndex: Int = 0
    
    private var timer: Timer?
    private var bounds: CGRect = .zero
    
    private var bouncePlayer: AVAudioPlayer?
    private var breakPlayer: AVAudioPlayer?
    private var powerUpPlayer: AVAudioPlayer?
    
    init() {
        setupSounds()
    }
    
    private func setupSounds() {
        func load(_ name: String) -> AVAudioPlayer? {
            guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return nil }
            return try? AVAudioPlayer(contentsOf: url)
        }
        bouncePlayer = load("bounce")
        breakPlayer = load("break")
        powerUpPlayer = load("powerup")
    }
    
    func setup(in bounds: CGRect) {
        self.bounds = bounds
        
        // Paddle
        let paddleSize = CGSize(width: 140, height: 18)
        paddleRect = CGRect(
            x: bounds.midX - paddleSize.width / 2,
            y: bounds.maxY - 80,
            width: paddleSize.width,
            height: paddleSize.height
        )
        
        // Ball
        ballCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        ballVelocity = CGPoint(x: 4, y: -4)
        
        // Level bricks
        let level = levels[currentLevelIndex % levels.count]
        bricks = []
        let rows = level.rows
        let cols = level.cols
        let brickWidth = bounds.width / CGFloat(cols) - 8
        let brickHeight: CGFloat = 24
        
        for row in 0..<rows {
            for col in 0..<cols {
                let type = level.layout(row, col)
                let hits: Int
                switch type {
                case .normal: hits = 1
                case .strong: hits = 2
                case .powerUp: hits = 1
                }
                let x = CGFloat(col) * (brickWidth + 8) + 4
                let y = CGFloat(row) * (brickHeight + 8) + 40
                let rect = CGRect(x: x, y: y, width: brickWidth, height: brickHeight)
                bricks.append(Brick(rect: rect, hitsRemaining: hits, type: type))
            }
        }
        
        particles.removeAll()
        score = 0
        gameState = .ready
    }
    
    func startGame() {
        guard gameState != .running else { return }
        gameState = .running
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1/120, repeats: true) { _ in
            self.step()
        }
    }
    
    func stopGame() {
        timer?.invalidate()
        timer = nil
        gameState = .gameOver
        updateHighScore()
    }
    
    private func updateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "ArkanoidHighScore")
        }
    }
    
    func nextLevel(in bounds: CGRect) {
        currentLevelIndex = (currentLevelIndex + 1) % levels.count
        setup(in: bounds)
        startGame()
    }
    
    func movePaddle(to x: CGFloat) {
        let clampedX = max(bounds.minX,
                           min(x - paddleRect.width / 2, bounds.maxX - paddleRect.width))
        paddleRect.origin.x = clampedX
    }
    
    private func step() {
        guard gameState == .running else { return }
        
        // Move ball
        ballCenter.x += ballVelocity.x
        ballCenter.y += ballVelocity.y
        
        // Particles decay
        for i in particles.indices {
            particles[i].life -= 0.02
        }
        particles.removeAll { $0.life <= 0 }
        
        // Wall collisions
        if ballCenter.x <= bounds.minX + 8 || ballCenter.x >= bounds.maxX - 8 {
            ballVelocity.x *= -1
            bouncePlayer?.play()
        }
        if ballCenter.y <= bounds.minY + 8 {
            ballVelocity.y *= -1
            bouncePlayer?.play()
        }
        
        // Bottom (lose)
        if ballCenter.y >= bounds.maxY + 20 {
            stopGame()
            return
        }
        
        // Paddle collision
        let ballRect = CGRect(x: ballCenter.x - 8, y: ballCenter.y - 8, width: 16, height: 16)
        if paddleRect.intersects(ballRect) && ballVelocity.y > 0 {
            ballVelocity.y *= -1
            
            let relativeHit = (ballCenter.x - paddleRect.midX) / (paddleRect.width / 2)
            ballVelocity.x = max(-7, min(7, ballVelocity.x + relativeHit * 2.5))
            bouncePlayer?.play()
        }
        
        // Brick collisions
        for i in bricks.indices {
            guard !bricks[i].isDestroyed else { continue }
            if bricks[i].rect.intersects(ballRect) {
                bricks[i].hitsRemaining -= 1
                score += 10
                spawnParticles(at: bricks[i].rect)
                
                if bricks[i].hitsRemaining <= 0 {
                    bricks[i].isDestroyed = true
                    breakPlayer?.play()
                    if bricks[i].type == .powerUp {
                        applyRandomPowerUp()
                        powerUpPlayer?.play()
                    }
                } else {
                    bouncePlayer?.play()
                }
                
                ballVelocity.y *= -1
                break
            }
        }
        
        // Win condition
        if bricks.allSatisfy({ $0.isDestroyed }) {
            timer?.invalidate()
            timer = nil
            gameState = .win
            updateHighScore()
        }
    }
    
    private func spawnParticles(at rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for _ in 0..<8 {
            let offset = CGPoint(
                x: CGFloat.random(in: -rect.width/4...rect.width/4),
                y: CGFloat.random(in: -rect.height/4...rect.height/4)
            )
            particles.append(
                Particle(position: CGPoint(x: center.x + offset.x,
                                           y: center.y + offset.y),
                         life: Double.random(in: 0.3...0.7))
            )
        }
    }
    
    private func applyRandomPowerUp() {
        let choice = Int.random(in: 0...2)
        switch choice {
        case 0:
            // enlarge paddle
            paddleRect.size.width = min(paddleRect.width * 1.3, bounds.width * 0.5)
        case 1:
            // speed up ball
            ballVelocity.x *= 1.2
            ballVelocity.y *= 1.2
        case 2:
            // slow ball
            ballVelocity.x *= 0.8
            ballVelocity.y *= 0.8
        default:
            break
        }
    }
}
