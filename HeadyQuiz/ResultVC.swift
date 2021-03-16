//
//  ResultVC.swift
//  HeadyQuiz
//

import UIKit
import Foundation
import SQLite

class ResultVC: UIViewController {
    
    var score: Int?
    var totalScore: Int?
    var score_s: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        setupViews(view:self.view)
    }
    
    func showRating() {
        var rating = ""
        var color = UIColor.black
        guard let sc = score, let tc = totalScore else { return }
        let score_s = sc * 100 / tc
        if score_s < 10 {
            rating = "Poor - F"
            color = UIColor.darkGray
        }  else if score_s < 40 {
            rating = "Average - C"
            color = UIColor.blue
        } else if score_s < 60 {
            rating = "Good - B-"
            color = UIColor.yellow
        } else if score_s < 80 {
            rating = "Excellent - A"
            color = UIColor.red
        } else if score_s <= 100 {
            rating = "Outstanding - A+"
            color = UIColor.orange
        }
        lblRating.text = "\(rating)"
        lblRating.textColor=color
        
        do {
            let databaseFileName = "HeadyQuiz.sqlite3"
            let databaseFilePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(databaseFileName)"
            let db = try Connection(databaseFilePath)
            
            let uuid_string = UIDevice.current.identifierForVendor!.uuidString

            let results = Table("results")
            let id = Expression<Int64>("id")
            let uuid = Expression<String>("uuid")
            let scores = Expression<Int>("scores")
                
            try db.run(results.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(uuid)
                t.column(scores)
            })
            
            let insert = results.insert(uuid <- uuid_string, scores <- score_s)
            let _ = try db.run(insert)
                        
            for result in try db.prepare(results) {
                print("id: \(result[uuid]), scores: \(result[scores])")
            }
            
        } catch {
          print("Could not make connection")
          print("Unexpected error: \(error).")
        }

    }

    @objc func btnRestartAction() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setupViews(view: UIView) {
        self.view.addSubview(lblTitle)
        lblTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80).isActive=true
        lblTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        lblTitle.widthAnchor.constraint(equalToConstant: 250).isActive=true
        lblTitle.heightAnchor.constraint(equalToConstant: 80).isActive=true
        
        self.view.addSubview(lblScore)
        lblScore.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 0).isActive=true
        lblScore.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        lblScore.widthAnchor.constraint(equalToConstant: 150).isActive=true
        lblScore.heightAnchor.constraint(equalToConstant: 60).isActive=true
        lblScore.text = "\(score!) / \(totalScore!)"
        
        self.view.addSubview(lblRating)
        lblRating.topAnchor.constraint(equalTo: lblScore.bottomAnchor, constant: 40).isActive=true
        lblRating.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        lblRating.widthAnchor.constraint(equalToConstant: 200).isActive=true
        lblRating.heightAnchor.constraint(equalToConstant: 60).isActive=true
        showRating()
        
        self.view.addSubview(btnRestart)
        btnRestart.topAnchor.constraint(equalTo: lblRating.bottomAnchor, constant: 40).isActive=true
        btnRestart.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        btnRestart.widthAnchor.constraint(equalToConstant: 150).isActive=true
        btnRestart.heightAnchor.constraint(equalToConstant: 50).isActive=true
        btnRestart.addTarget(self, action: #selector(btnRestartAction), for: .touchUpInside)
        
        lblTitle.alpha = 0.0
        UIView.animate(withDuration: 1.0) {
            self.lblTitle.alpha = 1.0
            view.layoutIfNeeded()
        }
    }
    
    let lblTitle: UILabel = {
        
        guard let customFont = UIFont(name: "BellBottom.Laser", size:46) else {
            fatalError("""
                Failed to load the "Bellbottom" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        
        let lbl=UILabel()
        lbl.text="Your Score"
        lbl.textColor=UIColor(hue: 0.6833, saturation: 1, brightness: 0.59, alpha: 1.0)
        lbl.textAlignment = .center
        lbl.font = UIFontMetrics.default.scaledFont(for: customFont)
        lbl.numberOfLines=2
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let lblScore: UILabel = {
        let lbl=UILabel()
        lbl.text="0 / 0"
        lbl.textColor=UIColor.black
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 24)
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let lblRating: UILabel = {
        let lbl=UILabel()
        lbl.text="Good"
        lbl.textColor=UIColor.black
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 22)
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let btnRestart: UIButton = {
        let btn = UIButton()
        btn.setTitle("Restart", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor=UIColor.orange
        btn.layer.cornerRadius=5
        btn.clipsToBounds=true
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
}
