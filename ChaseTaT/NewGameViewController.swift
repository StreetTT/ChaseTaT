//
//  NewGameViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 06/11/2024.
//

import UIKit

// MARK: - Variables
class NewGameViewController: UIViewController {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    var win = false
    @IBOutlet weak var currentWinnings: UILabel!
    @IBOutlet weak var currentWinningsLabel: UILabel!
    var winnigs = ""
    
    
    // MARK: - Load + Segue

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set defaults
        print("---")
        playAgainButton.setTitle("Play for More", for: .normal)
        mainMenuButton.setTitle("Cash Out", for: .normal)
        for button in [playAgainButton, mainMenuButton] {
            makeButtonHighlighted(to: button!)
        }
        currentWinnings.text = winnigs
        mainMenuButton.isHidden = false
        mainLabel.isHidden = false
        
        
        // Show different text based on the outcome
        if win {
            mainLabel.text = "YOU WON!"
            currentWinnings.isHidden = false
            currentWinningsLabel.isHidden = false
        } else {
            mainLabel.text = "You Lost..."
            playAgainButton.isHidden = true
            mainMenuButton.setTitle("Main Menu", for: .normal)
        }

    }
    

}
