//
//  ViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 24/10/2024.
//

import UIKit

struct QuizQuestionData: Codable {
    let category : String
    var questions: [QuestionItems]
}

struct QuestionItems: Codable {
    let question_text : String
    let answers : [String]
    let correct : Int
}

func getJSONQuestionData() -> QuizQuestionData? {
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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(getJSONQuestionData()!)
        // Do any additional setup after loading the view.
        
        let  theQuizQuestions = getJSONQuestionData()
        if theQuizQuestions != nil {
            for aQuestion in theQuizQuestions!.questions  {
                print(aQuestion.question_text)
            }
        }
    }


}

