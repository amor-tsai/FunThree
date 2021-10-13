//
//  MotionModel.swift
//  FunThree
//
//
//
//  Created by Amor on 2021/10/10.
//

import Foundation
import CoreMotion

//extend the Date so I can easily get yesterday, tomorow and midnight
extension Date {
    var dayBefore: Date {//Yesterday
        return Calendar.current.date(byAdding: .day, value: -1, to: midnight)!
    }
    var dayAfter: Date {//tomorow
        return Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
    }
    var midnight: Date {//midnight
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
}

class MotionModel {
    
    // MARK: Properties
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let customQueue = OperationQueue()
    
    let DAILY_GOAL = "DailyGoal" // key to store daily goal
    
    private var todaySteps:NSNumber
    private var yesterdaySteps:NSNumber
    private var motionDesc : String
    private var dailyGoal : Int
    
    private static let singleInstance: MotionModel = {
       let shared = MotionModel()
        return shared
    }() // return single instance
    
    init() {
        self.yesterdaySteps = 0
        self.todaySteps = 0
        self.motionDesc = ""
        self.dailyGoal = UserDefaults.standard.integer(forKey: DAILY_GOAL)// if daily goal does not set, 0 will be assigned.
    }
    
    class func sharedInstance() -> MotionModel {
        return singleInstance
    }
    
    
    // set daily goal and store the value
    func dailyGoalSet(dailyGoal:String) {
        
        self.dailyGoal = Int(dailyGoal) ?? 0
        UserDefaults.standard.set(self.dailyGoal, forKey: DAILY_GOAL)
    }
    
    // get daily goal
    func getDailyGoal() -> Int {
        return self.dailyGoal
    }
    
    //start activity updates
    func startActivityUpdates() {
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: customQueue) {
            (activity:CMMotionActivity?) -> Void in
                if let unwrappedActivity = activity {
                    self.motionDesc = ""
                    print(unwrappedActivity.description)
                    if unwrappedActivity.walking {
                        self.motionDesc += " walking, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    if unwrappedActivity.running {
                        self.motionDesc += " running, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    if unwrappedActivity.unknown {
                        self.motionDesc += " unknown, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    if unwrappedActivity.stationary {
                        self.motionDesc += " still, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    if unwrappedActivity.cycling {
                        self.motionDesc += " cycling, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    if unwrappedActivity.automotive {
                        self.motionDesc += " driving, conf: \(unwrappedActivity.confidence.rawValue)"
                    }
                    // MARK: 
                    //Sometimes, the CMMotionActivity is none of above even lauched a while
                    //it looks werid if displaying empty string, so I add "uncertainty" to describe this situation
                    //CMMotionActivity @ 1588877.195945,<startDate,2021-10-11 17:31:40 +0000,confidence,2,unknown,0,stationary,0,walking,0,running,0,automotive,0,cycling,0>
                    if self.motionDesc == "" {
                        self.motionDesc = "uncertainty"
                    }
                }
            }
        }
    }
    
    // start pedometer updates
    func startPedometerUpdates() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from: Date().midnight) { (pedData:CMPedometerData?, error:Error?) in
                if pedData != nil {
                    self.todaySteps = pedData!.numberOfSteps
                    print("start pedometer update: \(String(describing: pedData?.numberOfSteps))")
                }
            }
        }
    }
    
    // return a string description of current motion
    // return empty string if CMMotionActivityManager is inactive
    func getCurrentMotion() -> String {
        return self.motionDesc
    }
    
    //stop activity updates
    func stopActivityUpdates() {
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.stopActivityUpdates()
        }
    }
    
    // stop pedometer updates
    func stopPedometerUpdates() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.stopUpdates()
        }
    }
    
    // get steps of yesterday
    func getYesterdaySteps() -> NSNumber {
        self.pedometer.queryPedometerData(from: Date().dayBefore, to: Date().midnight) {
            (pedData: CMPedometerData?,error:Error?) -> Void in
            if pedData?.numberOfSteps != nil {
//                print("yesterday \(pedData?.numberOfSteps)")
                self.yesterdaySteps = pedData!.numberOfSteps
//                print(self.yesterdaySteps)
            }
        }
        return self.yesterdaySteps
    }
    
    // get steps of today
    func getTodaySteps() -> NSNumber {
        return self.todaySteps
    }
    
}
