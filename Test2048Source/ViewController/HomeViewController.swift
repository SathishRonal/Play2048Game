//
//  HomeViewController.swift
//  Test2048Source
//
//  Created by SathizMacMini on 20/08/21.
//

import UIKit

class HomeViewController: UIViewController {
    let kBestScoreKey = "kBestScoreKey"
    let kPersistedModelKey = "kPersistedModelKey"
    let kPersistedModelScoreKey = "kPersistedModelScoreKey"
    
    @IBOutlet weak var mainBoard: MainForBoard!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var bestLbl: UILabel!
    
    @IBOutlet weak var resetBtn: UIButton!
   
    
    fileprivate let game: ExtensionforPlay
    fileprivate var bestScore = 0
    fileprivate var autoTimer: Timer?
    fileprivate var presentedMessages = [UIButton]()
    fileprivate var swipeStart: CGPoint?
    fileprivate var lastMove = 0  // TODO: Implement a more elegant solution
    
    required init?(coder aDecoder: NSCoder) {
       
            game = ExtensionforPlay()
       
        
        super.init(coder: aDecoder)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.delegate = self
        
        mainBoard.size = game.boardSize
        mainBoard.updateValuesWithModel(game.model, canSpawn: true)

        
        
        updateScoreLabel()
    }
    
    @IBAction func toggleAutoRun(_ sender: AnyObject) {
        if let timer = autoTimer {
            timer.invalidate()
            autoTimer = nil
        } else {
            autoMove()
        }
    }
    
    @IBAction func resetGame(_ sender: AnyObject) {
        dismissMessages()
        game.reset()
    }
    
    fileprivate func updateScoreLabel() {
        if (game.score > bestScore) {
            bestScore = game.score
          
        }
        
        scoreLbl.attributedText = attributedText("Score", value: "\(game.score)")
        bestLbl.attributedText = attributedText("Best", value: "\(bestScore)")
    }
    
    fileprivate func attributedText(_ title: String, value: String) -> NSAttributedString {
        let res = NSMutableAttributedString(string: title, attributes: [
            .foregroundColor : UIColor(red: 238.0/255.0, green: 228.0/255.0, blue: 214.0/255.0, alpha: 1)
            ])
        res.append(NSAttributedString(string: "\n\(value)", attributes: [
            .foregroundColor : UIColor(white: 1, alpha: 1)
            ]))
        return res
    }
    
    @objc func newGameButtonTapped(_ sender: AnyObject) {
        resetGame(sender)
    }
    
    @objc func continuePlayingButtonTapped(_ sender: AnyObject) {
        dismissMessages()
    }
    
    @objc func autoMove() {
        if autoTimer == nil || autoTimer!.isValid == false {
            autoTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(HomeViewController.autoMove), userInfo: nil, repeats: true)
        }
        switch(arc4random_uniform(4)) {
        case 0: shortUp()
        case 1: shortDown()
        case 2: shortRight()
        case 3: shortLeft()
        default: break
        }
    }
    
    @objc func shortUp() { game.swipe(.y(.decrease)) }
    @objc func shortDown() { game.swipe(.y(.increase)) }
    @objc func shortLeft() { game.swipe(.x(.decrease)) }
    @objc func shortRight() { game.swipe(.x(.increase)) }
}
// MARK: Touch handling
extension HomeViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            swipeStart = touch.location(in: view)
            lastMove = 0
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let swipeStart = swipeStart, let touch = touches.first else { return }
        
        let treshold: CGFloat = 250.0
        let loc = touch.location(in: view)
        let diff = CGPoint(x: loc.x - swipeStart.x, y: loc.y - swipeStart.y)
        
        func evaluateDirection(_ a: CGFloat, _ b: CGFloat, _ sensitivity: CGFloat) -> Bool {
            let delta = sensitivity * max(abs(b)/(abs(a)+abs(b)), 0.05)
            return sensitivity >= 0 ? a > delta : a < delta
        }
        
        if diff.x > 0 && evaluateDirection(diff.x, diff.y, treshold) && lastMove != 1 {
            shortRight()
            lastMove = 1
        } else if diff.x < 0 && evaluateDirection(diff.x, diff.y, -treshold) && lastMove != 2 {
            shortLeft()
            lastMove = 2
        } else if diff.y > 0 && evaluateDirection(diff.y, diff.x, treshold) && lastMove != 3 {
            shortDown()
            lastMove = 3
        } else if diff.y < 0 && evaluateDirection(diff.y, diff.x, -treshold) && lastMove != 4 {
            shortUp()
            lastMove = 4
        }
        
        self.swipeStart = loc
    }
}

// MARK: External keyboard handling
extension HomeViewController {
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override var keyCommands : [UIKeyCommand]? {
        get {
            return [
                UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(HomeViewController.shortUp)),
                UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(HomeViewController.shortDown)),
                UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(HomeViewController.shortLeft)),
                UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(HomeViewController.shortRight)),
                UIKeyCommand(input: " ", modifierFlags: [], action: #selector(HomeViewController.shortReset))]
        }
    }
    
    @objc func shortReset() { game.reset() }
}

extension HomeViewController: ExtensionforPlayDelegate {
    func game2048DidProcessMove(_ game: ExtensionforPlay) {
        mainBoard.updateValuesWithModel(game.model, canSpawn: false)
        mainBoard.animateTiles()
        
      
    }
    
    func game2048GameOver(_ game: ExtensionforPlay) {
        self.displayMessage("Game over!",
                            subtitle: "Tap to try again",
                            action: #selector(HomeViewController.newGameButtonTapped(_:)))
    }
    
    func game2048Reached2048(_ game: ExtensionforPlay) {
        self.displayMessage("You win!",
                            subtitle: "Tap to continue playing",
                            action: #selector(HomeViewController.continuePlayingButtonTapped(_:)))
    }
    
    func game2048ScoreChanged(_ game: ExtensionforPlay, score: Int) {
        updateScoreLabel()
        if score > 0 {
            displayScoreChangeNotification("+ \(score)")
        }
    }
    
    func game2048TileMerged(_ game: ExtensionforPlay, from: CGPoint, to: CGPoint) {
        mainBoard.moveAndRemoveTile(from: from.boardPosition, to: to.boardPosition)
    }
    
    func game2048TileSpawnedAtPoint(_ game: ExtensionforPlay, point: CGPoint) {
        mainBoard.updateValuesWithModel(game.model, canSpawn: true)
    }
    
    func game2048TileMoved(_ game: ExtensionforPlay, from: CGPoint, to: CGPoint) {
        mainBoard.moveTile(from: from.boardPosition, to: to.boardPosition)
    }
    
    func dismissMessages() {
        for message in presentedMessages {
            UIView.animate(withDuration: 0.1, animations: {
                message.alpha = 0
                }, completion: { _ in
                    message.removeFromSuperview()
            })
        }
        presentedMessages.removeAll()
    }
    
    private func displayScoreChangeNotification(_ text: String) {
        let label = UILabel(frame: scoreLbl.frame)
        label.text = text
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = scoreLbl.font
        scoreLbl.superview!.addSubview(label)
        UIView.animate(withDuration: 0.8, animations: {
            label.alpha = 0
            var rect = label.frame
            rect.origin.y += 50
            label.frame = rect
            }, completion: { _ in
                label.removeFromSuperview()
        })
    }
    
    private func displayMessage(_ title: String, subtitle: String, action: Selector) {
        let messageButton = UIButton(type: .custom)
        
        presentedMessages.append(messageButton)
        
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.backgroundColor = UIColor(white: 1, alpha: 0.5)
        messageButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 36)
        messageButton.addTarget(self, action: action, for: .touchUpInside)
        
        let str = NSMutableAttributedString(string: "\(title)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 36)])
        str.append(NSAttributedString(string: subtitle, attributes: [
            .font : UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor : UIColor(white: 0, alpha: 0.3)
            ]))

        messageButton.setAttributedTitle(str, for: UIControl.State())
        messageButton.alpha = 0
        view.addSubview(messageButton)
        
        messageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        messageButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        messageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        messageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        UIView.animate(withDuration: 0.2) { messageButton.alpha = 1 }
        
        if autoTimer != nil {
            autoTimer!.invalidate()
            autoTimer = nil
        }
    }
}

extension CGPoint {
    var boardPosition: BoardPosition {
        return (x: Int(self.x), y: Int(self.y))
    }
}
