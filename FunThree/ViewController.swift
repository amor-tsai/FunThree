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
    @IBOutlet weak var TodayGoalStateLable: UILabel!
    @IBOutlet weak var YesterdayGoalStateLable: UILabel!
    
    @IBOutlet weak var GoalSetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GoalSetButton.backgroundColor = .clear
        GoalSetButton.setTitleColor(UIColor.black, for: .normal)
        GoalSetButton.layer.cornerRadius = 5
        GoalSetButton.layer.borderWidth = 1
        GoalSetButton.layer.borderColor = UIColor.black.cgColor
        
        self.YesterdayStepsLable.text = "\(self.motion.getYesterdaySteps())"
        self.YesterdayGoalStateLable.text = "\(self.motion.getYesterdayGoalStateDesc())"
        
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        self.startDailyGoalMonitoring()
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
//        Timer.scheduledTimer(
//            timeInterval: 1/20.0,
//            target: self,
//            selector: #selector(self.updateMotionLable),
//            userInfo: nil,
//            repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveCurrentMotion(_:)), name: .didReceiveCurrentMotion, object: nil)
    }
    
    func startPedometerMonitoring(){
        motion.startPedometerUpdates()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveTodaySteps(_:)), name: .didReceiveTodaySteps, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveYesterdaySteps(_:)), name: .didReceiveYesterdaySteps, object: nil)
    }
    
    // Daily goal changed monitoring
    func startDailyGoalMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDailyGoal(_:)), name: .didReceiveDailyGoal, object: nil)
    }
    
    @objc
    func updateMotionLable() {
        self.CurrentMotionLable.text = "Current Motion: \(self.motion.getCurrentMotion())"
        self.YesterdayStepsLable.text = "\(self.motion.getYesterdaySteps())"
        self.TodayStepsLable.text = "\(self.motion.getTodaySteps())"
    }
    
    @objc
    func onDidReceiveTodaySteps(_ notification: Notification) {
        DispatchQueue.main.async {
            self.TodayStepsLable.text = "\(self.motion.getTodaySteps())"
            self.TodayGoalStateLable.text = "\(self.motion.getTodayGoalStateDesc())"
        }
    }
    
    @objc
    func onDidReceiveYesterdaySteps(_ notification: Notification) {
        DispatchQueue.main.async {
            self.YesterdayStepsLable.text = "\(self.motion.getYesterdaySteps())"
            self.YesterdayGoalStateLable.text = "\(self.motion.getYesterdayGoalStateDesc())"
        }
    }
    
    @objc
    func onDidReceiveDailyGoal(_ notification: Notification) {
        print("daily goal changed \(notification)")
        print("\(self.motion.getYesterdayGoalStateDesc())")
        DispatchQueue.main.async {
            self.YesterdayGoalStateLable.text = "\(self.motion.getYesterdayGoalStateDesc())"
            self.TodayGoalStateLable.text = "\(self.motion.getTodayGoalStateDesc())"
        }
    }
    
    @objc
    func onDidReceiveCurrentMotion(_ notification: Notification) {
        DispatchQueue.main.async {
            self.CurrentMotionLable.text = "Current Motion: \(self.motion.getCurrentMotion())"
        }
    }
}

