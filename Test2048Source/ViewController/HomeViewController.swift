//
//  HomeViewController.swift
//  Test2048Source
//
//  Created by SathizMacMini on 23/08/21.
//

import UIKit

class HomeViewController: UIViewController {

     let start: ExtensionforPlay
     var bestScoreTxt = 0
     var timeAuto: Timer?
     var msgLbl = [UIButton]()
     var startSwipes: CGPoint?
     var lastValueMove = 0  // TODO: Implement a more elegant solution
    
    @IBOutlet weak var mainBoard: MainForBoard!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var bestLbl: UILabel!
    @IBOutlet weak var resetBtn: UIButton!
   
    

    
    required init?(coder aDecoder: NSCoder) {
       
        start = ExtensionforPlay()
        super.init(coder: aDecoder)
        
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        start.delegate = self
        mainBoard.size = start.boardSize
        mainBoard.updateValuesWithModel(start.model, canSpawn: true)
        ScoreLabel()
        
    }
    
   
    
   
    @IBAction func didClickResetGame(_ sender: AnyObject) {
        exitMsg()
        start.reset()
    }
    
    
    fileprivate func ScoreLabel() {
        if (start.score > bestScoreTxt) {
            bestScoreTxt = start.score
          
        }
        scoreLbl.attributedText = attributedText("Score", value: "\(start.score)")
        bestLbl.attributedText = attributedText("Best", value: "\(bestScoreTxt)")
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
        didClickResetGame(sender)
    }
    
    @objc func continuePlayingButtonTapped(_ sender: AnyObject) {
        exitMsg()
    }
    
    @objc func autoMove() {
        if timeAuto == nil || timeAuto!.isValid == false {
            timeAuto = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(HomeViewController.autoMove), userInfo: nil, repeats: true)
        }
        switch(arc4random_uniform(4)) {
        case 0: shortUp()
        case 1: shortDown()
        case 2: shortRight()
        case 3: shortLeft()
        default: break
        }
    }
    
    @objc func shortUp() { start.swipe(.y(.decrease)) }
    @objc func shortDown() { start.swipe(.y(.increase)) }
    @objc func shortLeft() { start.swipe(.x(.decrease)) }
    @objc func shortRight() { start.swipe(.x(.increase)) }
}
// MARK: Touch handling
extension HomeViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            startSwipes = touch.location(in: view)
            lastValueMove = 0
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let swipeStart = startSwipes, let touch = touches.first else { return }
        
        let treshold: CGFloat = 250.0
        let loc = touch.location(in: view)
        let diff = CGPoint(x: loc.x - swipeStart.x, y: loc.y - swipeStart.y)
        
        func evaluateDirection(_ a: CGFloat, _ b: CGFloat, _ sensitivity: CGFloat) -> Bool {
            let delta = sensitivity * max(abs(b)/(abs(a)+abs(b)), 0.05)
            return sensitivity >= 0 ? a > delta : a < delta
        }
        
        if diff.x > 0 && evaluateDirection(diff.x, diff.y, treshold) && lastValueMove != 1 {
            shortRight()
            lastValueMove = 1
        } else if diff.x < 0 && evaluateDirection(diff.x, diff.y, -treshold) && lastValueMove != 2 {
            shortLeft()
            lastValueMove = 2
        } else if diff.y > 0 && evaluateDirection(diff.y, diff.x, treshold) && lastValueMove != 3 {
            shortDown()
            lastValueMove = 3
        } else if diff.y < 0 && evaluateDirection(diff.y, diff.x, -treshold) && lastValueMove != 4 {
            shortUp()
            lastValueMove = 4
        }
        
        self.startSwipes = loc
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
    
    @objc func shortReset() { start.reset() }
}

extension HomeViewController: ExtensionforPlayDelegate {
    func didProcessMove(_ game: ExtensionforPlay) {
        mainBoard.updateValuesWithModel(game.model, canSpawn: false)
        mainBoard.titleAniFrame()
        
      
    }
    
    func gameOver(_ game: ExtensionforPlay) {
        self.messageLbldisplay("Game over!",
                            subtitle: "Tap to try again",
                            action: #selector(HomeViewController.newGameButtonTapped(_:)))
    }
    
    func reached(_ game: ExtensionforPlay) {
        self.messageLbldisplay("You win!",
                            subtitle: "Tap to continue playing",
                            action: #selector(HomeViewController.continuePlayingButtonTapped(_:)))
    }
    
    func ScoreChanged(_ game: ExtensionforPlay, score: Int) {
        ScoreLabel()
        if score > 0 {
            scoreChangeNtfdisplay("+ \(score)")
        }
    }
    
    func tileMerged(_ game: ExtensionforPlay, from: CGPoint, to: CGPoint) {
        mainBoard.moveAndRemoveTile(from: from.boardPosition, to: to.boardPosition)
    }
    
    func tileSpawnedAtPoint(_ game: ExtensionforPlay, point: CGPoint) {
        mainBoard.updateValuesWithModel(game.model, canSpawn: true)
    }
    
    func tileMoved(_ game: ExtensionforPlay, from: CGPoint, to: CGPoint) {
        mainBoard.moveTile(from: from.boardPosition, to: to.boardPosition)
    }
    
    func exitMsg() {
        for message in msgLbl {
            UIView.animate(withDuration: 0.1, animations: {
                message.alpha = 0
                }, completion: { _ in
                    message.removeFromSuperview()
            })
        }
        msgLbl.removeAll()
    }
    
    private func scoreChangeNtfdisplay(_ text: String) {
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
    
    private func messageLbldisplay(_ title: String, subtitle: String, action: Selector) {
        let messageButton = UIButton(type: .custom)
        
        msgLbl.append(messageButton)
        
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
        
        if timeAuto != nil {
            timeAuto!.invalidate()
            timeAuto = nil
        }
    }
}

extension CGPoint {
    var boardPosition: BoardPosition {
        return (x: Int(self.x), y: Int(self.y))
    }
}
