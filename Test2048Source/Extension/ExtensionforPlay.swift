//
//  ExtensionforPlay.swift
//  Test2048Source
//
//  Created by SathizMacMini on 21/08/21.
//

import UIKit



@objc protocol ExtensionforPlayDelegate {
   
    @objc optional func ScoreChanged(_ game: ExtensionforPlay, score: Int) // score is the delta
    @objc optional func gameOver(_ game: ExtensionforPlay)
    @objc optional func reached(_ game: ExtensionforPlay)
    
    
    @objc optional func tileSpawnedAtPoint(_ game: ExtensionforPlay, point: CGPoint)
    @objc optional func tileMoved(_ game: ExtensionforPlay, from: CGPoint, to: CGPoint)
    @objc optional func tileMerged(_ game: ExtensionforPlay, from: CGPoint, to: CGPoint)
    @objc optional func didProcessMove(_ game: ExtensionforPlay)
}

enum Direction: Int {
    case none = 0
    case increase = 1
    case decrease = -1
}

enum SwipeAxis {
    case x(Direction)
    case y(Direction)
}

class ExtensionforPlay: NSObject {
    var delegate: ExtensionforPlayDelegate?
    
    var model = Array(repeating: 0, count: 16)
    var boardSize: Int {
        get {
            return model.size
        }
    }
    
    fileprivate var seen2048 = false
    fileprivate var totalMoves = 0
    fileprivate var _score = 0 {
        didSet {
            delegate?.ScoreChanged?(self, score: _score - oldValue)
        }
    }
    var score: Int {
        get { return _score }
    }
    
    override init() {
        super.init()
        reset()
    }
    
    convenience init(gameModel: [Int]) {
        self.init()
        model = gameModel
        _score = model.reduce(0, +)
    }
    
    func reset() {
        totalMoves = 0
        resetBoardModel()
    }
    
    func swipe(_ axis: SwipeAxis) {
        switch axis {
        case .x(let d): process(d, yCompareDirection: .none)
        case .y(let d): process(.none, yCompareDirection: d)
        }
    }
    
    fileprivate func process(_ xCompareDirection: Direction, yCompareDirection: Direction) {
        func startFromDirection(_ direction: Direction) -> Int {
            switch direction {
            case .none: return 0
            case .decrease: return 1
            case .increase: return model.size - 2
            }
        }
        
        var merges = [(x: Int, y: Int)]()
        var totalChanges = 0
        var changes = 0
        var accumulatedScore = 0
        
        repeat {
            changes = 0
            
            var y = startFromDirection(yCompareDirection)
            while y >= 0 && y < model.size {
                defer { y += yCompareDirection == .increase ? -1 : 1 }
                var x = startFromDirection(xCompareDirection)
                while x < model.size && x >= 0 {
                    defer { x += xCompareDirection == .increase ? -1 : 1 }
                    if model[x, y] == 0 {
                        continue
                    }
                    let comparePosition = (x: x + xCompareDirection.rawValue, y: y + yCompareDirection.rawValue)
                    let compareValue = model[comparePosition.x, comparePosition.y]
                    if compareValue == 0 {
                        // Move
                        model[comparePosition.x, comparePosition.y] = model[x, y]
                        model[x, y] = 0
                        
                        delegate?.tileMoved?(self, from: CGPoint(x: x, y: y), to: CGPoint(x: comparePosition.x, y: comparePosition.y))
                        
                        changes += 1
                    } else if compareValue == model[x, y] {
                        var merged = false
                        for (mX, mY) in merges {
                            if (mX == comparePosition.x && mY == comparePosition.y) || (x == mX && y == mY) {
                                merged = true
                                break
                            }
                        }
                        if merged {
                            continue
                        }
                        // Merge
                        model[comparePosition.x, comparePosition.y] = compareValue * 2
                        model[x, y] = 0
                        
                        merges.append(comparePosition)
                        
                        delegate?.tileMerged?(self, from: CGPoint(x: x, y: y), to: CGPoint(x: comparePosition.x, y: comparePosition.y))
                        
                        if !seen2048 && model[comparePosition.x, comparePosition.y] == 2048 {
                            seen2048 = true
                            delegate?.reached?(self)
                        }
                        
                        accumulatedScore += compareValue * 2
                        changes += 1
                    }
                }
            }
            totalChanges += changes
        } while changes > 0
        
        _score += accumulatedScore
        
        if totalChanges > 0 {
            totalMoves += 1
            spawnRandom2or4()
        }
        
        delegate?.didProcessMove?(self)
        
        if model.indecies(of: 0).count <= 0 && !model.moveIsPossible {
            delegate?.gameOver?(self)
        }
    }
    
    fileprivate func resetBoardModel() {
        _score = 0
        for i in 0..<model.count { model[i] = 0 }
        for _ in 0..<2 { spawnRandom2or4() }
    }
    
    fileprivate func spawnRandom2or4() {
        guard let empty = model.indecies(of: 0).randomElement() else { fatalError() }
        model[empty.x, empty.y] = (Int(arc4random_uniform(2)) + 1) * 2
        delegate?.tileSpawnedAtPoint?(self, point: CGPoint(x: empty.x, y: empty.y))
    }
}

// 2048 matrix methods
extension Array where Element : Equatable {
    var moveIsPossible: Bool {
        get {
            for y in 0..<size {
                for x in 0..<size {
                    if (y > 0 && self[x, y - 1] == self[x, y]) ||
                       (x > 0 && self[x - 1, y] == self[x, y]) ||
                       (y < size - 1 && self[x, y + 1] == self[x, y]) ||
                        (x < size - 1 && self[x + 1, y] == self[x, y]) {
                        return true
                    }
                }
            }
            return false
        }
    }
}
