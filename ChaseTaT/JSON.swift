//
//  JSON.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 11/11/2024.
//
// Global Methods based off of Phil's used to handle all JSON collection throught the project

import UIKit

struct QuizQuestionData: Codable {
    // [Given by Phil]
    let category : String
    var questions: [QuestionItems]
}

struct QuestionItems: Codable {
    // [Given by Phil]
    let question_text : String
    let answers : [String]
    let correct : Int
}

func getJSONQuestionData() -> QuizQuestionData? {
    // Load in the JSON file that hold the questions [Given by Phil]

    let bundleFolderURL = Bundle.main.url(forResource: "chase_questions", withExtension: "json")!
    do {
        let retrievedData = try Data(contentsOf: bundleFolderURL)
        do {
            let theQuizData = try JSONDecoder().decode(QuizQuestionData.self, from: retrievedData)
            return theQuizData
        } catch {
            print("couldn't decode file contents"); return nil
        }
    } catch {
        print("couldn't retrieve file contents"); return nil
    }
}
