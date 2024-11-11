//
//  ScoresViewController.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 11/11/2024.
//

import UIKit

class ScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var sortedScores : [(String, Int)]  = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedScores.count < 10 ? sortedScores.count : 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Show a players name and score
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = UIListContentConfiguration.cell()
        
        content.text = "\(sortedScores[indexPath.row].0) : \(sortedScores[indexPath.row].1)"

        cell.contentConfiguration = content
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    

}
