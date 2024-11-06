//
//  ViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 24/10/2024.
//

import UIKit
import AVFoundation

// MARK: - JSON
struct QuizQuestionData: Codable {
    // [Given by Phill]
    let category : String
    var questions: [QuestionItems]
}

struct QuestionItems: Codable {
    // [Given by Phill]
    let question_text : String
    let answers : [String]
    let correct : Int
}

func getJSONQuestionData() -> QuizQuestionData? {
    // Load in the JSON file that hold the questions [Given by Phill]

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

// MARK: - Audio

var audioClips = [String:AVAudioPlayer?]()

func playAudio(_ name: String) {
    // play a given audio [Adapted from Phill's]
    let audioPlayer = findAudio(name)
    if (audioPlayer == nil) || (audioPlayer?.isPlaying == false) {
        audioPlayer?.play()
    }
}

func findAudio(_ name: String) -> AVAudioPlayer? {
    // linear search and find AudioPLayer Object
    for (key,AVAP) in audioClips{
        if key == name {
            return AVAP
        }
    }
    return nil
}

func stopAllAudio() {
    // Loop through and stop all audio
    for (key,_) in audioClips{
        stopAudio(key)
    }
}

func setupAudioPlayers(toPlay audioFileURL:URL) -> AVAudioPlayer? {
    // Setup Audio Player obeject [Adapted from Phill's]
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
 
func stopAudio(_ name: String) {
    // stop a given audio [Adapted from Phill's]
    let audioPlayer = findAudio(name)
     if audioPlayer?.isPlaying == true {
         audioPlayer?.stop()
     }
 }

func getAllMP3Players() -> [String:AVAudioPlayer?] {
    // Get all MP3 Files [Given by Phill]
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

// MARK: - Variables
class ViewController: UIViewController {
    var amountToWin = [30000, 7000, 1000]
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var rung1: UIButton!
    @IBOutlet weak var rung2: UIButton!
    @IBOutlet weak var rung3: UIButton!
    @IBOutlet weak var rung7: UIButton!
    @IBOutlet weak var rung6: UIButton!
    @IBOutlet weak var rung5: UIButton!
    @IBOutlet weak var rung4: UIButton!
    var rungs : [UIButton] = []
    var playerIndex = -1
    var questionsSeen : [Int] = []
    let JSONQuestions = getJSONQuestionData()!
    var name = ""
    var amount = -1
    @IBOutlet weak var mainlLabel: UILabel!
    var chaserIndex = -1
    @IBOutlet weak var chaserName: UILabel!
    @IBOutlet weak var currentWinnings: UILabel!
    @IBOutlet weak var playerName: UILabel!
    var systemTicks : Timer?
    var ticksCount = 0
    var playerWasCorrect = false
    var chaserWasCorrect = true
    
    // MARK: - Initial Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playAudio("ladderMoment")
        
        // Set name and stuff
        playerName.text = name
        currentWinnings.text = "£" + String(amount == -1  ? 0 : amount)
        chaserName.text = ["The Beast", "The Man Mountain of Maths", "The Dark Destroyer", "The Barrister", "The Legal Eagle", "The Governess", "Frosty Knickers", "The Sinnerman" , "The Vixen", "The Bolton Brainiac", "The Badass", "The Kiwi Mastermind", "The Supernerd", "The 123"].randomElement()
        
        
        // Set the shape of the rungs
        rungs = [rung1, rung2, rung3, rung4, rung5, rung6, rung7]
        var x: CGFloat =  10
        for rung in rungs {
            x = applyLadderShape(to: rung, ofset: x)
        }
        
        // Set each rung (Money, Colour)
        amountToWin = decideMoney()
        for (index, rung) in rungs.enumerated() {
            rung.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            rung.addTarget(self, action: #selector(rungClicked(_:)), for: .touchUpInside)
            if (2...4).contains(index) {
                rung.setTitle("£\(amountToWin[index - 2])", for: .normal)
                if index == 3 {
                    makeButtonSelected(to: rung)
                } else {
                    makeButtonHighlighted(to: rung)
                }
            } else {
                rung.setTitle("", for: .normal)
                makeButtonUnfocused(to: rung)
            }
        }
        
        // Set Label
        mainLabel.text = "Select an Offer: "
        
    }
    
    func applyLadderShape(to button: UIButton, ofset: CGFloat) -> CGFloat {
        // Apply a mask to the ladder buttons to create the non-parallel ladder
        // ofset is passed in every time to make sure the bottom edge of the last button is the lenght of this buttons top edge
        let slant = CGFloat(14)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: ofset, y: 0))
        path.addLine(to: CGPoint(x: button.bounds.width - ofset , y: 0))
        path.addLine(to: CGPoint(x: button.bounds.width - ofset - slant, y: button.bounds.height))
        path.addLine(to: CGPoint(x: ofset + slant , y: button.bounds.height))
        path.close()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        button.layer.mask = mask
        return CGFloat(ofset + slant)
    }
    
    @objc func rungClicked(_ sender: UIButton){
        // When an offer is selected, need to unfocus all rungs above and focus all rungs below, along with emptying all other rungs
        
        if playerIndex != -1 {
            return
        }
        playerIndex = rungs.firstIndex(of: sender)!
        
        if (2...4).contains(playerIndex){
            makeButtonSelected(to: rungs[playerIndex])
            for (i, button) in rungs.enumerated(){
                if i < playerIndex {
                    makeButtonUnfocused(to: button)
                    button.setTitle("", for: .normal)
                } else if i == playerIndex {
                    makeButtonSelected(to: button)
                } else {
                    makeButtonSelected(to: button)
                    button.setTitle("", for: .normal)
                }
            }
            mainLabel.isHidden = true
            // Segue to Question Screen
            stopAllAudio()
            performSegue(withIdentifier: "toQuestion", sender: nil)
            
        } else {
            
            playerIndex = -1
        }
    }
    
    func decideMoney() -> [Int]{
        // Determine the starting offers for the round
        let baseAmount = amount == -1 ? 1000 : amount
        let risk = amount == -1 ? 1.0 : 1.2
        
        return [Int(Double(baseAmount * 3) * risk), Int(Double(baseAmount) * risk), Int(Double(baseAmount) * 0.5 * risk)]
        
    }

    // MARK: - New Question
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Passes a unique question into the QuestionVC
        if segue.identifier == "toQuestion"{
            // Passes a unique question into the QuestionVC
            let QuestionViewController = segue.destination as! QuestionViewController
            var q = Int.random(in: 0..<(JSONQuestions.questions.count))
            while questionsSeen.contains(q) {
                q = Int.random(in: 0..<(JSONQuestions.questions.count))
            }
            questionsSeen.append(q)
            QuestionViewController.question = JSONQuestions.questions[q]
            QuestionViewController.name = name
        }
        
    }
    
    @IBAction func unwindToMainGame(_ segue: UIStoryboardSegue){
        // Unwind, relax your mind
        // Run relevent checks and transition to the next VC
        let sourceVC = segue.source as? QuestionViewController
        playerWasCorrect = sourceVC!.playerWasCorrect
        chaserWasCorrect = sourceVC!.chaserWasCorrect
        // Start the systemTicks timmer
        if systemTicks == nil {
            systemTicks = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(tickClocked(_:)), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func tickClocked(_ sender: UIButton) {
        // timer to coreograpgh the ladder steps and game over moment
        ticksCount += 1
        if ticksCount == 8 {
            if playerWasCorrect {
                playerStep()
            } else if chaserWasCorrect {
                chaserStep()
            } else {
                gameOverCheck()
            }
        } else if ticksCount == 14 {
            if playerWasCorrect && chaserWasCorrect {
                chaserStep()
            } else if playerWasCorrect || chaserWasCorrect  {
                gameOverCheck()
            }
        } else if ticksCount == 20 {
            gameOverCheck()
        }
    }
    
    
    func chaserStep(){
        // moves the red bar down
        playAudio("ChaserStep")
        chaserIndex += 1
        makeButtonChasers(to: rungs[chaserIndex])
        if chaserIndex - 1 <= -1{
            return
        }
        makeButtonChasers(to: rungs[chaserIndex - 1])
        
    }
    
    func playerStep(){
        // moves the blue bars down
        playAudio("ContestantStep")
        var rung = rungs[playerIndex]
        makeButtonUnfocused(to: rung)
        let x = rung.currentTitle
        rung.setTitle("", for: .normal)
        playerIndex += 1
        if playerIndex == 7 {
            makeButtonUnfocused(to: rung)
            currentWinnings.text = x
            return
        }
        rung = rungs[playerIndex]
        makeButtonSelected(to: rung)
        rung.setTitle(x, for: .normal)
        
    }
    
    func gameOverCheck(){
        // Checke the win conditions
        if chaserIndex == playerIndex {
            // The Game is Over.
            playAudio("ChaserWins")
            print("CHASER WIN")
        } else if playerIndex == 7 {
            print("PLAYER WIN")
            
        } else {
            print("---")
            if systemTicks != nil {
                systemTicks?.invalidate()
                systemTicks = nil
            }
            ticksCount = 0
            performSegue(withIdentifier: "toQuestion", sender: nil)
        }
        
        
    }


}

// MARK: - Button UI
// The next few functions just change the way the buttons look
func makeButtonSelected(to button: UIButton){
    button.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 82/255.0, alpha: 1)
    button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
}

func makeButtonHighlighted(to button: UIButton){
    button.backgroundColor = UIColor(red: 7/255.0, green: 177/255.0, blue: 158/255.0, alpha: 1)
    button.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
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
