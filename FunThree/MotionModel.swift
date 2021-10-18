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

// set extension name of notification
extension Notification.Name {
    static let didReceiveTodaySteps = Notification.Name("didReceiveTodaySteps")// today steps changed
    static let didReceiveYesterdaySteps = Notification.Name("didReceiveYesterdaySteps") // yesterday steps changed
    static let didReceiveDailyGoal = Notification.Name("didReceiveDailyGoal") // daily goal changed
    static let didReceiveCurrentMotion = Notification.Name("didReceiveCurrentMotion") // current motion changed
}

class MotionModel {
    
    // MARK: Properties
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let customQueue = OperationQueue()
    
    let DAILY_GOAL = "DailyGoal" // key to store daily goal
    let YESTERDAY_MARK = "YesterDayMark"
    let CURRENCY = "StepsToCurrency"
    
    private var todaySteps:Int {
        didSet { // when value changed, send notification to observers
            NotificationCenter.default.post(name: .didReceiveTodaySteps, object: nil)
        }
    }
    private var yesterdaySteps:Int {
        didSet { // when value changed, send notification to observers
            NotificationCenter.default.post(name: .didReceiveYesterdaySteps, object: nil)
        }
    }
    private var motionDesc : String
    private var dailyGoal : Int {
        didSet { // when value changed, send notification to observers
            NotificationCenter.default.post(name: .didReceiveDailyGoal, object: nil)
        }
    }
    private var currency : Int
    
    private static let singleInstance: MotionModel = {
       let shared = MotionModel()
        return shared
    }() // return single instance
    
    
    init() {
        self.yesterdaySteps = MotionModel.initYesterdaySteps()
        self.todaySteps = 0
        self.motionDesc = ""
        self.dailyGoal = UserDefaults.standard.integer(forKey: DAILY_GOAL)// if daily goal does not set, 0 will be assigned.
        
        // if meet the goal of yesterday, then currency equals to the 10% of yesterday steps
        self.currency = 0
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
                    
                    NotificationCenter.default.post(name: .didReceiveCurrentMotion, object: nil)
                }
            }
        }
    }
    
    // start pedometer updates
    func startPedometerUpdates() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from: Date().midnight) { (pedData:CMPedometerData?, error:Error?) in
                if pedData != nil {
                    self.todaySteps = Int(truncating: pedData!.numberOfSteps)
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
    func getYesterdaySteps() -> Int {
        if self.yesterdaySteps > 0 {
            return self.yesterdaySteps
        }
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.queryPedometerData(from: Date().dayBefore, to: Date().midnight) {
                (pedData: CMPedometerData?,error:Error?) -> Void in
                if pedData?.numberOfSteps != nil {
                    self.yesterdaySteps = Int(truncating: pedData!.numberOfSteps)
                } else {
                    self.yesterdaySteps = 0
                }
            }
        }
        return self.yesterdaySteps
    }
    
    // get steps of today
    func getTodaySteps() -> Int {
        return self.todaySteps
    }
    
    // get today's goal state description
    // if goal achieved, then return "Well Done!"
    // else return "Goal unreached"
    func getTodayGoalStateDesc() -> String {
        var goalDesc = ""
        if self.dailyGoal <= self.todaySteps {
            goalDesc = "Well Done!" // if goal is reached
        } else {
            goalDesc = "Goal unreached" // if goal is not reached
        }
        return goalDesc
    }
    
    // get yesterday's goal state descrption
    func getYesterdayGoalStateDesc() -> String {
        var goalDesc = ""
        if self.dailyGoal <= self.yesterdaySteps {
            goalDesc = "Well Done!"
        } else {
            goalDesc = "Goal unreached"
        }
        return goalDesc
    }
    
    //whether yesterday's steps meet the daily goal, return true if yes
    //return false if not
    func isYesterdayGoalReached() -> Bool {
        var isReached = false
        if self.yesterdaySteps >= self.dailyGoal {
            isReached = true
        }
        return isReached
    }
    
    // update currency, return true if successfully
    func updateCurrency(number:Int) -> Bool {
        if self.currency + number >= 0 {
            self.currency += number
            UserDefaults.standard.set(self.currency, forKey: CURRENCY)
            return true
        } else {
            return false
        }
    }
    
    func getCurrency() -> Int {
        return self.currency
    }
    
    // set up currency
    func setUpCurrency() {
        let yesterdayMark = UserDefaults.standard.string(forKey: YESTERDAY_MARK)
//        print("yesterdayMark \(yesterdayMark)")
        if yesterdayMark == nil || yesterdayMark != Date().dayBefore.description(with: .current) {
            self.currency = yesterdaySteps/10
            UserDefaults.standard.set(Date().dayBefore.description(with: .current), forKey: YESTERDAY_MARK)
            UserDefaults.standard.set(self.currency, forKey: CURRENCY)
        } else {
            self.currency = UserDefaults.standard.integer(forKey: CURRENCY)
        }
        print(self.currency)
    }
    
    // get yesterday steps
    // since I need the property yesterdaySteps contained a value when it is initialized
    private static func initYesterdaySteps() -> Int {
        var yesterdaySteps: Int = 0
        if CMPedometer.isStepCountingAvailable() {
            CMPedometer().queryPedometerData(from: Date().dayBefore, to: Date().midnight) {
                (pedData: CMPedometerData?,error:Error?) -> Void in
                if pedData?.numberOfSteps != nil {
                    yesterdaySteps = Int(truncating: pedData!.numberOfSteps)
                    print("pedData yesterdaySteps \(yesterdaySteps) \(pedData!.numberOfSteps)")
                } else {
                    yesterdaySteps = 0
                }
            }
        }
        print(yesterdaySteps)
        return yesterdaySteps
    }
}
