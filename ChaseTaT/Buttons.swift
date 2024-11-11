//
//  Buttons.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 11/11/2024.
//
// This file contains global functions used to change buttons across the app
// This way, I can give them meaningful names in storyboard and change them in viewDidLoad()

import UIKit

func makeButtonSelected(to button: UIButton){
    button.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 82/255.0, alpha: 1)
    button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
}

func makeButtonHighlighted(to button: UIButton){
    button.backgroundColor = UIColor(red: 7/255.0, green: 177/255.0, blue: 158/255.0, alpha: 1)
    button.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
    button.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
}

func makeButtonUnfocused(to button: UIButton){
    button.backgroundColor = UIColor(red: 10/255.0, green: 172/255.0, blue: 193/255.0, alpha: 1)
    button.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
}

func makeButtonOptional(to button: UIButton){
    button.backgroundColor = UIColor(red: 67/255.0, green: 113/255.0, blue: 110/255.0, alpha: 1)
    button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
}

func makeButtonCorrect(to button: UIButton){
    button.backgroundColor = UIColor(red: 75/255.0, green: 253/255.0, blue: 158/255.0, alpha: 1)
    button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
}

func makeButtonChasersAnswer(to button: UIButton){
    button.layer.borderWidth = 2
    button.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
}

func makeButtonChasers(to button: UIButton){
    button.backgroundColor = UIColor(red: 182/255.0, green: 35/255.0, blue: 15/255.0, alpha: 1)
    button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
}
