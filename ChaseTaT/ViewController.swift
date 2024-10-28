//
//  ViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 24/10/2024.
//

import UIKit


var amountToWin = [30000, 7000, 1000]

class ViewController: UIViewController {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var rung1: UIButton!
    @IBOutlet weak var rung2: UIButton!
    @IBOutlet weak var rung3: UIButton!
    @IBOutlet weak var rung7: UIButton!
    @IBOutlet weak var rung6: UIButton!
    @IBOutlet weak var rung5: UIButton!
    @IBOutlet weak var rung4: UIButton!
    var rungs : [UIButton] = []
    
    func applyLadderShape(to button: UIButton, ofset: CGFloat) -> CGFloat {
        let slant = CGFloat(15)
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
    
    func makeButtonSelected(to button: UIButton){
        button.backgroundColor = UIColor(red: 5/255.0, green: 7/255.0, blue: 82/255.0, alpha: 1)
        button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
    
    func makeButtonHighlighted(to button: UIButton){
        button.backgroundColor = UIColor(red: 10/255.0, green: 172/255.0, blue: 193/255.0, alpha: 1)
        button.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
    }
    
    func makeButtonUnfocused(to button: UIButton){
        button.backgroundColor = UIColor(red: 7/255.0, green: 177/255.0, blue: 158/255.0, alpha: 1)
        button.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
    }
    
    @objc func rungClicked(_ sender: UIButton){
        // When an offer is selected, need to unfocus all rungs above and focus all rungs below, along with emptying all other rungs
        
        let index = rungs.firstIndex(of: sender)!
        print("clicked rung \(index+1)")
        if (2...4).contains(index){
            makeButtonSelected(to: rungs[index])
            for (i, button) in rungs.enumerated(){
                if i < index {
                    makeButtonUnfocused(to: button)
                    button.setTitle("", for: .normal)
                } else if i == index {
                    makeButtonSelected(to: button)
                } else {
                    makeButtonSelected(to: button)
                    button.setTitle("", for: .normal)
                }
            }
            
        }
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

