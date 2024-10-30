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
    let letters = ["A", "B", "C"]
    @IBOutlet weak var clockText: UILabel!
    var timer: Timer?
    var timerCount = 15
    var selectedAnswer = -1
    var chasersAnswer = -1
    @IBOutlet weak var chaserToken: UILabel!
    @IBOutlet weak var playerToken: UILabel!
    let chaserTime = Int.random(in: (8...15)) // What time the chaser answers

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chaserToken.isHidden = true
        playerToken.isHidden = true
        
        // Load question info onto the view
        print("Answer: \(question!.answers[question!.correct]) ")
        questionText.text = question!.question_text
        answers = [answer1, answer2, answer3]
        for (index, answer) in answers.enumerated() {
            makeButtonOptional(to: answer)
            answer.addTarget(self, action: #selector(answerClicked(_:)), for: .touchUpInside)
            answer.setTitle("\(letters[index]). \(question!.answers[index])", for: .normal)
        }
        
        // Start Countdown
        clockText.text = "15"
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        }
    }
    
    @objc func answerClicked(_ sender: UIButton){
        // Highlight players  choice
        if selectedAnswer != -1 {
            return
        }
        selectedAnswer = answers.firstIndex(of: sender)!
        print("Selected: \(question!.answers[selectedAnswer]) ")
        makeButtonHighlighted(to: answers[selectedAnswer])
        playerToken.isHidden = false
        
    }
    
    @objc  func timerFired() {
        // check every second if countown has reached 0 or if player and chaser have answered
        timerCount -= 1 // deincrement our seconds counter
        clockText.text = String(format: "%02d", timerCount)
        
        if chaserTime == timerCount {
            chasersAnswer = calculateChaserAnswer()
            chaserToken.isHidden = false
        }
        
        if (selectedAnswer != -1 && chasersAnswer != -1) || timerCount <= 0 {
            stopClock()
            
            makeButtonCorrect(to: answers[question!.correct - 1])
            makeButtonChasers(to: answers[chasersAnswer])
            
        }
    }
        
    func stopClock() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func calculateChaserAnswer() -> Int {
        // Either they give the right answer or they randomly give a wrong one
        let epsilon = Int.random(in: (1...100))
        var x = question!.correct - 1
        if epsilon <= 25 {
            while x == question!.correct - 1 {
                x = Int.random(in: (1...3)) - 1
            }
        }
        return x
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
