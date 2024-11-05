//
//  QuestionViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 29/10/2024.
//

import UIKit
import AVFoundation

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
    let chaserTime = Int.random(in: (8...14)) // What time the chaser answers
    var name = ""
    @IBOutlet weak var unwindButton: UIButton!
    var playerWasCorrect = false
    var chaserWasCorrect = true
    var systemTicks : Timer?
    var ticksCount = 15
    var audioClips = [String:AVAudioPlayer?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            stopClock()
            stopAudio("Question")
            if systemTicks == nil {
                systemTicks = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(tickClocked), userInfo: nil, repeats: true)
            }
            
        }
    }
    
    @objc func tickClocked() {
        // check every 1/4 of a second
        ticksCount += 1
        if ticksCount == 24 {
            makeButtonCorrect(to: answers[question!.correct - 1])
            playAudio("Correct Answer")
        } else if ticksCount == 36 {
            makeButtonChasersAnswer(to: answers[chasersAnswer])
            playAudio("ChaserAnswer")
            unwindButton.isHidden = false
            if systemTicks != nil {
                systemTicks?.invalidate()
                systemTicks = nil
            }
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
            chaserWasCorrect = false
        }
        return x
    }
    
    @objc func handleUnwind(_ sender: UIButton){
        stopAllAudio()
        performSegue(withIdentifier: "unwindToMainGame", sender: nil)
    }
    // MARK: - Audio

    func playAudio(_ name: String) {
        let audioPlayer = findAudio(name)
        if (audioPlayer == nil) || (audioPlayer?.isPlaying == false) {
            //select a random audio clip URL from those in the audioClips dictionary
            audioPlayer?.play() //and play it
        }
    }
    
    func findAudio(_ name: String) -> AVAudioPlayer? {
        for (key,AVAP) in audioClips{
            if key == name {
                return AVAP
            }
        }
        return nil
    }
    
    func stopAllAudio() {
        for (key,_) in audioClips{
            stopAudio(key)
        }
    }
    
    func setupAudioPlayers(toPlay audioFileURL:URL) -> AVAudioPlayer? {
        var audioPlayer: AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Can't play the audio \(audioFileURL.absoluteString)")
            print(error.localizedDescription)
        }
        return audioPlayer
    }
     
    @objc func stopAudio(_ name: String) {
        let audioPlayer = findAudio(name)
         if audioPlayer?.isPlaying == true { //we can only stop it if it's still playing
             audioPlayer?.stop()
         }
     }
    
    func getAllMP3Players() -> [String:AVAudioPlayer?] {
        var filePaths = [URL]() //URL array
        var audioFileNames = [String]() //String array
        var theResult = [String:AVAudioPlayer?]()

        let bundlePath = Bundle.main.bundleURL
        do {
            try FileManager.default.createDirectory(atPath: bundlePath.relativePath, withIntermediateDirectories: true)
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: bundlePath, includingPropertiesForKeys: nil, options: [])
            
            // filter the directory contents
            filePaths = directoryContents.filter{ $0.pathExtension == "mp3" }
            
            //get the file names, without the extensions
            audioFileNames = filePaths.map{ $0.deletingPathExtension().lastPathComponent }
        } catch {
            print(error.localizedDescription) //output the error
        }
        //print(audioFileNames) //for debugging purposes only
        for loop in 0..<filePaths.count { //Build up the dictionary.
            theResult[audioFileNames[loop]] = setupAudioPlayers(toPlay: filePaths[loop])
        }
        return theResult
    }
}
