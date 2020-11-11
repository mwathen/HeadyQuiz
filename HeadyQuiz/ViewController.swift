//
//  ViewController.swift
//  HeadyQuiz
//

import UIKit
import AVFoundation


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
        
        playSound()
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
        lblTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150).isActive=true
        lblTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        lblTitle.widthAnchor.constraint(equalToConstant: 250).isActive=true
        lblTitle.heightAnchor.constraint(equalToConstant: 80).isActive=true
        
        self.view.addSubview(btnGetStarted)
        btnGetStarted.heightAnchor.constraint(equalToConstant: 50).isActive=true
        btnGetStarted.widthAnchor.constraint(equalToConstant: 150).isActive=true
        btnGetStarted.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
        btnGetStarted.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive=true
        
        
        lblTitle.alpha = 0.0
        UIView.animate(withDuration: 1.0) {
            self.lblTitle.alpha = 1.0
            view.layoutIfNeeded()
        }
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "caseyjones_short", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

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








