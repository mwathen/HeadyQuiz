//
//  ViewController.swift
//  HeadyQuiz
//

import UIKit
import AVFoundation
import SwiftUI
import SQLite

extension UIView {

        func fadeTransition(_ duration:CFTimeInterval) {
            let animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.duration = duration
            layer.add(animation, forKey: CATransitionType.fade.rawValue)
        }
    }

class ViewController: UIViewController {
    
    var window: UIWindow?
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="Heady Quiz"
        self.view.backgroundColor=UIColor.white
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Restart", style: .plain, target: nil, action: nil)
        
        setupViews(view:self.view)
        
        let xPosition = imgView.frame.minX

        moveIt(imgView,1.5,0,xPosition)
        
        playSound()
        
        do {
            let databaseFileName = "HeadyQuiz.sqlite3"
            let databaseFilePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(databaseFileName)"
            let db = try Connection(databaseFilePath)
            
            let uuid_string = UIDevice.current.identifierForVendor!.uuidString

            print(uuid_string)
            let results = Table("results")
            let uuid = Expression<String>("uuid")
            let scores = Expression<Int>("scores")
            
            for result in try db.prepare(results.filter(uuid == uuid)) {
                print("id: \(result[uuid]), scores: \(result[scores])")
                lblLastScore.text = "Last Score: "+String(result[scores])
            }
            
        } catch {
          print("Could not make connection")
          print("Unexpected error: \(error).")
        }

    }
    
    @objc func btnGetStartedAction() {
        let v=QuizVC()
        self.navigationController?.pushViewController(v, animated: true)
    }
    
    func setupViews(view: UIView) {
        
        /* for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        } */
        
        self.view.addSubview(lblTitle)
        lblTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive=true
        lblTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        lblTitle.widthAnchor.constraint(equalToConstant: 250).isActive=true
        lblTitle.heightAnchor.constraint(equalToConstant: 80).isActive=true
        
        self.view.addSubview(imgView)
        imgView.heightAnchor.constraint(equalToConstant: 160).isActive=true
        imgView.widthAnchor.constraint(equalToConstant: 284).isActive=true
        imgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        imgView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40).isActive=true
        
        self.view.addSubview(btnGetStarted)
        btnGetStarted.heightAnchor.constraint(equalToConstant: 50).isActive=true
        btnGetStarted.widthAnchor.constraint(equalToConstant: 150).isActive=true
        btnGetStarted.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        btnGetStarted.bottomAnchor
            .constraint(equalTo: self.view.bottomAnchor, constant: -180).isActive=true
        
        self.view.addSubview(lblLastScore)
        lblLastScore.heightAnchor.constraint(equalToConstant: 50).isActive=true
        lblLastScore.widthAnchor.constraint(equalToConstant: 150).isActive=true
        lblLastScore.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        lblLastScore.bottomAnchor
            .constraint(equalTo: self.view.bottomAnchor, constant: -120).isActive=true
        
        lblTitle.alpha = 0.0
        UIView.animate(withDuration: 1.0) {
            self.lblTitle.alpha = 1.0
            view.layoutIfNeeded()
        }

    }
    
    //for startup, iterate through 3 different jam images
    func moveIt(_ imageView: UIImageView,_ speed:CGFloat,_ iteration:Int, _ xPosition:CGFloat) {
        let speeds = speed
        var iterationx = iteration
        let imageSpeed = speeds / view.frame.size.width
        let averageSpeed = (40 - imageView.frame.origin.x) * imageSpeed
        if (iterationx < 3) {
            if (iterationx == 2) {
                imageView.image = UIImage(named: "widespread_panic.jpg")
            }
            UIView.animate(withDuration: TimeInterval(averageSpeed), delay: 0.0, options: .curveLinear, animations: {
            imageView.frame.origin.x = self.view.frame.size.width
            }, completion: { (_) in
            imageView.frame.origin.x = -imageView.frame.size.width
                iterationx += 1
                self.moveIt(imageView,speeds,iterationx,xPosition)
            })
        } else if (iterationx == 3) {
            imageView.image = UIImage(named: "phish2.jpg")
            UIView.animate(withDuration: TimeInterval(1), delay: 0.0, options: .curveLinear, animations: {
                imageView.frame.origin.x = xPosition
            })
        } else {
            //do nothing
        }
    }
    
    func playSound() {
        
        guard let gd_url = Bundle.main.url(forResource: "caseyjones_short", withExtension: "mp3") else { return }
        
        guard let phish_url = Bundle.main.url(forResource: "stash", withExtension: "mp3") else { return }
        
        let urls_all = [gd_url, phish_url]
        let url = urls_all.randomElement()!

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
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
        lbl.text="Heady Quiz"
        lbl.textColor=UIColor(hue: 0.6833, saturation: 1, brightness: 0.59, alpha: 1.0)
        lbl.textAlignment = .center
        lbl.font = UIFontMetrics.default.scaledFont(for: customFont)
        //lbl.font = UIFont.systemFont(ofSize: 46)
        lbl.numberOfLines=2
        lbl.translatesAutoresizingMaskIntoConstraints=false

        return lbl
    }()
    
    let lblLastScore: UILabel = {
        
        let lbl=UILabel()
        
        lbl.textColor=UIColor(hue: 0.6833, saturation: 1, brightness: 0.59, alpha: 1.0)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints=false

        return lbl
    }()
    
    let imgView: UIImageView = {
        let v=UIImageView()
        //let imagename = "7413.jpg"
        v.image = UIImage(named: "grateful_dead.jpg")
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let btnGetStarted: UIButton = {
        let btn=UIButton()
        btn.setTitle("Take the Quiz", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor=UIColor.red
        btn.layer.cornerRadius=5
        btn.layer.masksToBounds=true
        btn.translatesAutoresizingMaskIntoConstraints=false
        btn.addTarget(self, action: #selector(btnGetStartedAction), for: .touchUpInside)
        return btn
    }()
}








