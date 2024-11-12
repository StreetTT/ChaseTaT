//
//  Scores.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 12/11/2024.
//
// To hold the structure used to hold scores, as well as the loading function

import UIKit

struct Player: Codable {
    var name: String
    var score: Int
    var live: Bool
}

func loadScores() -> [Player]{
    // Safely loads scores
    guard let data = UserDefaults.standard.data(forKey: "scores") else {
        return []
    }
    
    do {
        return try JSONDecoder().decode([Player].self, from: data).sorted(by: { $0.score > $1.score} )
    } catch {
        return []
    }
}
