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
    
    // MARK: - Load + Segue
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set text and delegates
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
            ViewController.amount = -1
        }
        
    }
    // MARK: - Buttons and Input stuff
    @IBAction func GameButton(_ sender: Any) {
        performSegue(withIdentifier: "toMainGame", sender: nil)
    }
    @IBAction func ScoreboardButton(_ sender: Any) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        namefield.resignFirstResponder()
        GameButton(self)
        return true
    }
    

}
