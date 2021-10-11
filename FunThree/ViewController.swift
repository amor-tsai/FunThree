//
//  ViewController.swift
//  FunThree
//
//  Created by Amor on 2021/10/10.
//

import UIKit

class ViewController: UIViewController {

    let motion = MotionModel()
    
    @IBOutlet weak var TodayStepsLable: UILabel!
    @IBOutlet weak var YesterdayStepsLable: UILabel!
    @IBOutlet weak var CurrentMotionLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.startActivityMonitoring()
        self.startPedometerMonitoring()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //Do any additional setup after view disappeared
        
        motion.stopActivityUpdates()
        motion.stopPedometerUpdates()
    }
    
    // MARK: =====Motion Methods=====
    func startActivityMonitoring(){
        motion.startActivityUpdates()
        Timer.scheduledTimer(
            timeInterval: 0.3,
            target: self,
            selector: #selector(self.updateMotionLable),
            userInfo: nil,
            repeats: true)
    }
    
    func startPedometerMonitoring(){
        motion.startPedometerUpdates()
        DispatchQueue.main.async {
            self.YesterdayStepsLable.text = "\(self.motion.getYesterdaySteps())"
        }
    }
    
    @objc
    func updateMotionLable() {
        self.CurrentMotionLable.text = "Current Motion: \(self.motion.getCurrentMotion())"
        self.YesterdayStepsLable.text = "\(self.motion.getYesterdaySteps())"
        self.TodayStepsLable.text = "\(self.motion.getTodaySteps())"
    }

}

