//
//  ViewController.swift
//  FunThree
//
//  Created by Amor on 2021/10/10.
//

import UIKit

class ViewController: UIViewController {

    let motion = {
        return MotionModel.sharedInstance()
    }()
    
    @IBOutlet weak var TodayStepsLable: UILabel!
    @IBOutlet weak var YesterdayStepsLable: UILabel!
    @IBOutlet weak var CurrentMotionLable: UILabel!
    @IBOutlet weak var DailyGoalLable: UILabel!
    
    @IBOutlet weak var GoalSetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GoalSetButton.backgroundColor = .clear
        GoalSetButton.setTitleColor(UIColor.black, for: .normal)
        GoalSetButton.layer.cornerRadius = 5
        GoalSetButton.layer.borderWidth = 1
        GoalSetButton.layer.borderColor = UIColor.black.cgColor
        
        
        
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        
        self.dailyGoalDisplay()
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
            timeInterval: 1/20.0,
            target: self,
            selector: #selector(self.updateMotionLable),
            userInfo: nil,
            repeats: true)
        
    }
    
    func startPedometerMonitoring(){
        motion.startPedometerUpdates()
    }
    
    // daily goal display
    func dailyGoalDisplay() {
        let goal = motion.getDailyGoal()
        if (0 == goal) {
            self.DailyGoalLable.text = "No goal set"
        } else if goal <= Int(truncating: self.motion.getYesterdaySteps()) {
            self.DailyGoalLable.text = "Goal reached"
        }
        else {
            self.DailyGoalLable.text = "\(goal)"
        }
    }
    
    @objc
    func updateMotionLable() {
        self.CurrentMotionLable.text = "Current Motion: \(self.motion.getCurrentMotion())"
        self.YesterdayStepsLable.text = "\(self.motion.getYesterdaySteps())"
        self.TodayStepsLable.text = "\(self.motion.getTodaySteps())"
    }

}

