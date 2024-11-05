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
    
    
    func getAllMP3FileNameURLs() -> [String:URL] {
        var filePaths = [URL]() //URL array
        var audioFileNames = [String]() //String array
        var theResult = [String:URL]()

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
            theResult[audioFileNames[loop]] = filePaths[loop]
        }
        return theResult
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
        print("clicked rung \(playerIndex+1)")
        
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
            performSegue(withIdentifier: "toQuestion", sender: nil)
            
        } else {
            
            playerIndex = -1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Passes a unique question into the QuestionVC
        if segue.identifier == "toQuestion"{
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
    
    func decideMoney() -> [Int]{
        print()
        let baseAmount = amount == -1 ? 1000 : amount
        let risk = amount == -1 ? 1.0 : 1.2
        
        return [Int(Double(baseAmount * 3) * risk), Int(Double(baseAmount) * risk), Int(Double(baseAmount) * 0.5 * risk)]
        
    }
    
    
    func chaserStep(){
        chaserIndex += 1
        makeButtonChasers(to: rungs[chaserIndex])
        if chaserIndex - 1 <= -1{
            return
        }
        makeButtonChasers(to: rungs[chaserIndex - 1])
        
    }
    
    func playerStep(){
        var rung = rungs[playerIndex]
        makeButtonUnfocused(to: rung)
        let x = rung.currentTitle
        rung.setTitle("", for: .normal)
        playerIndex += 1
        rung = rungs[playerIndex]
        makeButtonSelected(to: rung)
        rung.setTitle(x, for: .normal)
        
    }
    
    
    @IBAction func unwindToMainGame(_ segue: UIStoryboardSegue){
        // Unwind, relax your mind
        let sourceVC = segue.source as? QuestionViewController
        if sourceVC!.playerWasCorrect { playerStep() }
        if sourceVC!.chaserWasCorrect { chaserStep() }
        
        // performSegue(withIdentifier: "toQuestion", sender: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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


}

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
