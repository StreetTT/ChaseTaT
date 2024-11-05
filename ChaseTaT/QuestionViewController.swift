//
//  QuestionViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 29/10/2024.
//

import UIKit
// MARK: - Variables
class QuestionViewController: UIViewController {
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer3: UIButton!
    var answers : [UIButton] = []
    var question: QuestionItems?
    @IBOutlet weak var clockText: UILabel!
    var timer: Timer?
    var timerCount = 15
    var selectedAnswer = -1
    var chasersAnswer = -1
    @IBOutlet weak var chaserToken: UILabel!
    @IBOutlet weak var playerToken: UILabel!
    let chaserTime = Int.random(in: (8...14)) // What time the chaser answers
    var name = ""
    @IBOutlet weak var unwindButton: UIButton!
    var playerWasCorrect = false
    var chaserWasCorrect = true
    var systemTicks : Timer?
    var ticksCount = 0
    
// MARK: - Load + Segue
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the view with relvent text and states
        chaserToken.isHidden = true
        playerToken.isHidden = true
        playerToken.text = name
        chaserToken.text = "Chaser"
        unwindButton.isHidden = true
        makeButtonSelected(to: unwindButton)
        unwindButton.setTitle("Return to the Ladder", for: .normal)
        audioClips = getAllMP3Players()
        playAudio("Question")
        unwindButton.addTarget(self, action: #selector(handleUnwind(_:)), for: .touchUpInside)
        
        
        // Load question info onto the view
        print("Answer: \(question!.answers[question!.correct-1]) ")
        questionText.text = question!.question_text
        answers = [answer1, answer2, answer3]
        let letters = ["A", "B", "C"]
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
    
    @objc func handleUnwind(_ sender: UIButton){
        stopAllAudio()
        performSegue(withIdentifier: "unwindToMainGame", sender: nil)
    }

    // MARK: - Answering
    
    @objc func answerClicked(_ sender: UIButton){
        // Highlight players choice
        if selectedAnswer != -1 {
            return
        }
        selectedAnswer = answers.firstIndex(of: sender)!
        if selectedAnswer == question!.correct - 1 { playerWasCorrect = true }
        print("Selected: \(question!.answers[selectedAnswer]) ")
        makeButtonHighlighted(to: answers[selectedAnswer])
        playAudio("ContestantLockIn")
        playerToken.isHidden = false
        
    }
    
    func calculateChaserAnswer() -> Int {
        // Either they give the right answer or they randomly give a wrong one
        let epsilon = Int.random(in: (1...100))
        var x = question!.correct - 1
        if epsilon <= 25 {
            while x == question!.correct - 1 {
                x = Int.random(in: (1...3)) - 1
            }
            chaserWasCorrect = false
        }
        return x
    }
    // MARK: - repeatedly Fired
    
    @objc func tickClocked() {
        // timer to coreograpgh the reveal of the correct answer and chasers answer
        ticksCount += 1
        if ticksCount == 9 {
            makeButtonCorrect(to: answers[question!.correct - 1])
            playAudio("Correct Answer")
        } else if ticksCount == 21 {
            makeButtonChasersAnswer(to: answers[chasersAnswer])
            playAudio("ChaserAnswer")
            unwindButton.isHidden = false
            if systemTicks != nil {
                systemTicks?.invalidate()
                systemTicks = nil
            }
        }
    }
    
    @objc func timerFired() {
        // check every second if countown has reached 0 or if player and chaser have answered
        timerCount -= 1 // deincrement our seconds counter
        clockText.text = String(format: "%02d", timerCount)
        
        if chaserTime == timerCount {
            chasersAnswer = calculateChaserAnswer()
            playAudio("ChaserLockIn")
            chaserToken.isHidden = false
        }
        
        if (selectedAnswer != -1 && chasersAnswer != -1) || timerCount <= 0 {
            //stop the timer
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            stopAudio("Question")
            clockText.isHidden = true
            // Start the systemTicks timmer
            if systemTicks == nil {
                systemTicks = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(tickClocked), userInfo: nil, repeats: true)
            }
            
        }
    }
    
    
    
}
