//
//  MenuViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 30/10/2024.
//

import UIKit

// MARK: - Variables
class MenuViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var scoreboardButton: UIButton!
    @IBOutlet weak var gameButton: UIButton!
    var muted = false
    @IBOutlet weak var muteButton: UIButton!
    var systemTicks : Timer?
    var ticksCount = 0
    @IBOutlet weak var loadingView: UIView!
    var scores: [Player] = loadScores()
    @IBOutlet weak var instructionButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Load + Segue
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set defaults
        namefield.addTarget(self, action: #selector(statusUpdate(_:)), for: .editingChanged)
        statusLabel.isHidden = true
        loadingView.isHidden = true
        audioClips = getAllMP3Players()
        playAudio("Intro")
        namefield.delegate = self
        namefield.placeholder = "Enter your name"
        gameButton.setTitle("Start Game", for: .normal)
        scoreboardButton.setTitle("View Leaderboard", for: .normal)
        instructionButton.setTitle("How to Play", for: .normal)
        for button in [gameButton, scoreboardButton, instructionButton] {
            makeButtonHighlighted(to: button!)
        }
        print(scores)
        

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Passes player's name to the main game
        if segue.identifier == "toMainGame"{
            let ViewController = segue.destination as! ViewController
            ViewController.name = (namefield.text ?? "Player")
            ViewController.oldWinnings = if let index = scores.firstIndex(where: {$0.name == namefield.text && $0.live }) {
                scores[index].score
            } else {
                -1
            }
            
        } else if segue.identifier == "toScores"{
            let ScoresVC = segue.destination as! ScoresViewController
            ScoresVC.scores = scores
        }
    }
        
    @IBAction func unwindToPlayAgain(_ segue: UIStoryboardSegue){
        // Unwind, relax your mind
        // Unwinds just to segue back into the game with a new amount
        _ = segue.source as? NewGameViewController
        loadingView.isHidden = false
        scores = loadScores()
        // Start the systemTicks timmer
        if systemTicks == nil {
            systemTicks = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(tickClocked(_:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func tickClocked(_ sender: UIButton) {
        // timer to give a one second delay before loading back into the game
        // I just didn't want to use a delay, the don't make sense
        ticksCount += 1
        if ticksCount == 2 {
            if systemTicks != nil {
                systemTicks?.invalidate()
                systemTicks = nil
                ticksCount = 0
            }
            loadingView.isHidden = true
            performSegue(withIdentifier: "toMainGame", sender: nil)
        }
    }
    
    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue){
        // Unwind, relax your mind
        // Unwinds and resets main menu
        let _ = segue.source as? NewGameViewController
        playAudio("Intro")
        namefield.text  = ""
        scores = loadScores()
        statusLabel.isHidden = true

        
              
    }
    // MARK: - Buttons and Input stuff
    @IBAction func GameButton(_ sender: Any) {
        stopAllAudio()
        performSegue(withIdentifier: "toMainGame", sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Clicking Return deoes the same as clicking Start Game
        namefield.resignFirstResponder()
        GameButton(self)
        return true
    }
    
    @IBAction func MuteButton(_ sender: Any) {
        // Made spesifically for Adam and George!
        if muted {
            muteButton.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
            unmuteAll()
            playAudio("Intro")
            muted = false
        } else {
            muteButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
            muteAll()
            muted = true
        }
    }
    
    // MARK: - Fancy Stuff
    @objc func statusUpdate(_ textField: UITextField) {
            // This method is called after every character press to show the score of the name typed in
            if let index = scores.firstIndex(where: {$0.name == textField.text && $0.live }) {
                statusLabel.text = "Current Score: \(String(scores[index].score))"
                statusLabel.isHidden = false
            } else {
                statusLabel.isHidden = true
            }
        }
    

}
