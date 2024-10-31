//
//  MenuViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 30/10/2024.
//

import UIKit

class MenuViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var namefield: UITextField!
    
    @IBOutlet weak var scoreboardButton: UIButton!
    @IBAction func ScoreboardButton(_ sender: Any) {
    }
    
    @IBOutlet weak var gameButton: UIButton!
    @IBAction func GameButton(_ sender: Any) {
        performSegue(withIdentifier: "toMainGame", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Passes player's name to the main game
        if segue.identifier == "toMainGame"{
            let ViewController = segue.destination as! ViewController
            ViewController.name = namefield.text ?? "Player"
            ViewController.amount = -1
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        namefield.resignFirstResponder()
        GameButton(self)
        return true
    }
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
