//
//  QuestionViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 29/10/2024.
//

import UIKit

class QuestionViewController: UIViewController {
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer3: UIButton!
    var answers : [UIButton] = []
    var question: QuestionItems?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Load question info onto the view
        print("Answer: \(question!.answers[question!.correct]) ")
        questionText.text = question?.question_text
        answers = [answer1, answer2, answer3]
        for (index, answer) in answers.enumerated() {
            answer.setTitle(question?.answers[index], for: .normal)
        }
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
