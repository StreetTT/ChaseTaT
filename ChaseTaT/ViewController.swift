//
//  ViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 24/10/2024.
//

import UIKit

// MARK: - Variables
class ViewController: UIViewController {
    var amountToWin = [30000, 7000, 1000]
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var rung1: UIButton!
    @IBOutlet weak var rung2: UIButton!
    @IBOutlet weak var rung3: UIButton!
    @IBOutlet weak var rung7: UIButton!
    @IBOutlet weak var rung6: UIButton!
    @IBOutlet weak var rung5: UIButton!
    @IBOutlet weak var rung4: UIButton!
    var rungs : [UIButton] = []
    var playerIndex = -1
    var questionsSeen : [Int] = []
    let JSONQuestions = getJSONQuestionData()!
    var name = ""
    var amount = -1
    @IBOutlet weak var mainlLabel: UILabel!
    var chaserIndex = -1
    @IBOutlet weak var chaserName: UILabel!
    @IBOutlet weak var currentWinnings: UILabel!
    @IBOutlet weak var playerName: UILabel!
    var systemTicks : Timer?
    var ticksCount = 0
    var playerWasCorrect = false
    var chaserWasCorrect = true
    var playerWon = true
    var roundPrize = -1
    var newWinnings = -1
    
    // MARK: - Initial Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set defaults
        playAudio("ladderMoment")
        
        // Set name and stuff
        playerName.text = name
        currentWinnings.text = "£" + String(amount == -1  ? 0 : amount)
        // These are just nicknames for chasers I found on wikipedia
        chaserName.text = ["The Beast", "The Man Mountain of Maths", "The Dark Destroyer", "The Barrister", "The Legal Eagle", "The Governess", "Frosty Knickers", "The Sinnerman" , "The Vixen", "The Bolton Brainiac", "The Badass", "The Kiwi Mastermind", "The Supernerd", "The 123"].randomElement()
        
        
        // Set the shape of the rungs
        rungs = [rung1, rung2, rung3, rung4, rung5, rung6, rung7]
        var x: CGFloat =  10
        for rung in rungs {
            x = applyLadderShape(to: rung, ofset: x)
        }
        
        // Set each rung (Money, Colour)
        amountToWin = decideMoney()
        for (index, rung) in rungs.enumerated() {
            rung.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            rung.addTarget(self, action: #selector(rungClicked(_:)), for: .touchUpInside)
            if (2...4).contains(index) {
                rung.setTitle("£\(amountToWin[index - 2])", for: .normal)
                if index == 3 {
                    makeButtonSelected(to: rung)
                } else {
                    makeButtonHighlighted(to: rung)
                }
            } else {
                rung.setTitle("", for: .normal)
                makeButtonUnfocused(to: rung)
            }
        }
        
        // Set Label
        mainLabel.text = "Select an Offer: "
        
    }
    
    func applyLadderShape(to button: UIButton, ofset: CGFloat) -> CGFloat {
        // Apply a mask to the ladder buttons to create the non-parallel ladder
        // ofset is passed in every time to make sure the bottom edge of the last button is the lenght of this buttons top edge
        let slant = CGFloat(14)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: ofset, y: 0))
        path.addLine(to: CGPoint(x: button.bounds.width - ofset , y: 0))
        path.addLine(to: CGPoint(x: button.bounds.width - ofset - slant, y: button.bounds.height))
        path.addLine(to: CGPoint(x: ofset + slant , y: button.bounds.height))
        path.close()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        button.layer.mask = mask
        return CGFloat(ofset + slant)
    }
    
    @objc func rungClicked(_ sender: UIButton){
        // When an offer is selected, need to unfocus all rungs above and focus all rungs below, along with emptying all other rungs
        
        if playerIndex != -1 {
            return
        }
        playerIndex = rungs.firstIndex(of: sender)!
        
        if (2...4).contains(playerIndex){
            makeButtonSelected(to: rungs[playerIndex])
            for (i, button) in rungs.enumerated(){
                if i < playerIndex {
                    makeButtonUnfocused(to: button)
                    button.setTitle("", for: .normal)
                } else if i == playerIndex {
                    makeButtonSelected(to: button)
                    roundPrize = Int(button.currentTitle!.dropFirst())!
                } else {
                    makeButtonSelected(to: button)
                    button.setTitle("", for: .normal)
                }
            }
            mainLabel.isHidden = true
            
            // Segue to Question Screen
            stopAllAudio()
            performSegue(withIdentifier: "toQuestion", sender: nil)
            
        } else {
            
            playerIndex = -1
        }
    }
    
    func decideMoney() -> [Int]{
        // Determine the starting offers for the round
        let baseAmount = amount == -1 ? 1000 : amount
        let risk = amount == -1 ? 1.0 : 1.2
        
        return [Int(Double(baseAmount * 3) * risk), Int(Double(baseAmount) * risk), Int(Double(baseAmount) * 0.5 * risk)]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Passes a unique question into the QuestionVC
        if segue.identifier == "toQuestion"{
            // Passes a unique question into the QuestionVC
            let QuestionViewController = segue.destination as! QuestionViewController
            if questionsSeen.count == JSONQuestions.questions.count {
                questionsSeen = []
            }
            var q = Int.random(in: 0..<(JSONQuestions.questions.count))
            while questionsSeen.contains(q) {
                q = Int.random(in: 0..<(JSONQuestions.questions.count))
            }
            questionsSeen.append(q)
            QuestionViewController.question = JSONQuestions.questions[q]
            QuestionViewController.name = name
        }
        
        // MARK: - Between Questions
        
        if segue.identifier == "toWinOrLose"{
            // Passes a unique question into the QuestionVC
            let NewGameViewController = segue.destination as! NewGameViewController
            NewGameViewController.win = playerWon
            NewGameViewController.winnigs = "£" + String(newWinnings)
        }
        
    }
    
    
    
    @IBAction func unwindToMainGame(_ segue: UIStoryboardSegue){
        // Unwind, relax your mind
        // Run relevent checks and transition to the next VC
        let sourceVC = segue.source as? QuestionViewController
        playerWasCorrect = sourceVC!.playerWasCorrect
        chaserWasCorrect = sourceVC!.chaserWasCorrect
        // Start the systemTicks timmer
        if systemTicks == nil {
            systemTicks = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(tickClocked(_:)), userInfo: nil, repeats: true)
        }
        
    }
    
    
    @objc func tickClocked(_ sender: UIButton) {
        // timer to coreograpgh the ladder steps and game over moment
        ticksCount += 1
        if ticksCount == 7 {
            if playerWasCorrect {
                playerStep()
            } else if chaserWasCorrect {
                chaserStep()
            } else {
                gameOverCheck()
            }
        } else if ticksCount == 13 {
            if playerWasCorrect && chaserWasCorrect {
                chaserStep()
            } else if playerWasCorrect || chaserWasCorrect  {
                gameOverCheck()
            }
        } else if ticksCount == 19 {
            gameOverCheck()
        }
    }
    
    
    func chaserStep(){
        // moves the red bar down
        playAudio("ChaserStep")
        chaserIndex += 1
        let rung = rungs[chaserIndex]
        makeButtonChasers(to: rung)
        if chaserIndex == playerIndex {
            rung.setTitle("", for: .normal)
        }
        if chaserIndex - 1 <= -1{
            return
        }
        makeButtonChasers(to: rungs[chaserIndex - 1])
        
    }
    
    func playerStep(){
        // moves the blue bars down
        playAudio("ContestantStep")
        var rung = rungs[playerIndex]
        makeButtonUnfocused(to: rung)
        let x = rung.currentTitle
        rung.setTitle("", for: .normal)
        playerIndex += 1
        if playerIndex == 7 {
            makeButtonUnfocused(to: rung)
            return
        }
        rung = rungs[playerIndex]
        makeButtonSelected(to: rung)
        rung.setTitle(x, for: .normal)
        
    }
    
    func gameOverCheck(){
        // Check if the win conditions have been met
        print("---")
        if systemTicks != nil {
            systemTicks?.invalidate()
            systemTicks = nil
            ticksCount = 0
        }
        
        if (chaserIndex != playerIndex) && (playerIndex != 7) {
            performSegue(withIdentifier: "toQuestion", sender: nil)
        } else {
            // MARK: - Game End
            // Start the systemTicks timmer
            if chaserIndex == playerIndex {
                ChaserWin()
            } else if playerIndex == 7 {
                newWinnings = roundPrize+(amount == -1  ? 0 : amount)
                PlayerWin()
                saveScore()
            }
            
            mainLabel.isHidden = false
            if systemTicks == nil {
                systemTicks = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(endingTickClocked(_:)), userInfo: nil, repeats: true)
            }
            
        }
        
        
    }
    
    @objc func endingTickClocked(_ sender: UIButton){
        ticksCount += 1
        if ticksCount == 3 || ticksCount == 6 {
            
            if playerWon && ticksCount == 6 {
                if systemTicks != nil {
                    systemTicks?.invalidate()
                    systemTicks = nil
                }
                ticksCount = 0
                performSegue(withIdentifier: "toWinOrLose", sender: nil)
            } else if !playerWon && ticksCount == 3 {
                if systemTicks != nil {
                    systemTicks?.invalidate()
                    systemTicks = nil
                }
                ticksCount = 0
                performSegue(withIdentifier: "toWinOrLose", sender: nil)
            }
            
        }
    }
    
    
    func ChaserWin(){
        playerWon = false
        print("CHASER WIN")
        mainLabel.text = "CHASER WINS"
        playAudio("ChaserWins")
        for rung in rungs{
            makeButtonChasers(to: rung)
        }
    }
    
    func PlayerWin(){
        print("PLAYER WIN")
        mainLabel.text = "\(name.uppercased()) WINS"
        playAudio("ContestantWin")
        for rung in rungs{
            makeButtonSelected(to: rung)
        }
    }
    
    func saveScore(){
        var scoresDict = UserDefaults.standard.dictionary(forKey: "scores") ?? [:]
        scoresDict[name] = newWinnings
        UserDefaults.standard.set(scoresDict, forKey: "scores")
        print(scoresDict)
        
    }
    
}
