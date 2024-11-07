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
    var amount = -1
    var muted = false
    @IBOutlet weak var muteButton: UIButton!
    var systemTicks : Timer?
    var ticksCount = 0
    @IBOutlet weak var loadingView: UIView!
    
    // MARK: - Load + Segue
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set defaults
        loadingView.isHidden = true
        audioClips = getAllMP3Players()
        playAudio("Intro")
        namefield.delegate = self
        namefield.placeholder = "Enter your name"
        gameButton.setTitle("Start Game", for: .normal)
        scoreboardButton.setTitle("View Scoreboard", for: .normal)
        makeButtonHighlighted(to: gameButton)
        makeButtonHighlighted(to: scoreboardButton)

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Passes player's name to the main game
        if segue.identifier == "toMainGame"{
            let ViewController = segue.destination as! ViewController
            ViewController.name = namefield.text ?? "Player"
            ViewController.amount = amount
        }
        
    }
    
    @IBAction func unwindToPlayAgain(_ segue: UIStoryboardSegue){
        // Unwind, relax your mind
        // Unwinds just to segue back into the game with a new amount
        let NewGameVC = segue.source as? NewGameViewController
        loadingView.isHidden = false
        amount = Int((NewGameVC!.winnigs).dropFirst())!
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
        amount = -1
        
              
    }
    // MARK: - Buttons and Input stuff
    @IBAction func GameButton(_ sender: Any) {
        stopAllAudio()
        performSegue(withIdentifier: "toMainGame", sender: nil)
    }
    
    @IBAction func ScoreboardButton(_ sender: Any) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        namefield.resignFirstResponder()
        GameButton(self)
        return true
    }
    
    // MARK: - Mute and Unmute
    // Here you go Adam! 
    
    @IBAction func MuteButton(_ sender: Any) {
        mute()
    }
    
    func mute() {
        if muted {
            muteButton.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
            audioClips = getAllMP3Players()
            playAudio("Intro")
            muted = false
        } else {
            muteButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
            stopAudio("Intro")
            audioClips = [:]
            muted = true
        }
        
    }
    

}
