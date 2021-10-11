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
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: midnight)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
    }
    var midnight: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
}

class MotionModel {
    
    // MARK: Properties
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let customQueue = OperationQueue()
    
    private var todaySteps:NSNumber
    private var yesterdaySteps:NSNumber
    
    
    private var activity:CMMotionActivity?
    
    init() {
        self.yesterdaySteps = 0
        self.todaySteps = 0
    }
    
    //start activity updates
    func startActivityUpdates() {
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: customQueue) {
            (activity:CMMotionActivity?) -> Void in
                if let unwrappedActivity = activity {
                    self.activity = unwrappedActivity
//                    print(self.activity?.description)
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
                    print("start pedometer update: \(pedData?.numberOfSteps)")
                }
            }
        }
    }
    
    // return a string description of current motion
    // return empty string if CMMotionActivityManager is inactive
    func getCurrentMotion() -> String {
        var motionDesc:String = ""
        if let act = self.activity {
//            print(activity.description)
            //{unknown, still, walking, running, cycling, driving}
            if act.walking {
                motionDesc += "walking, conf: \(act.confidence.rawValue)"
            }
            if act.running {
                motionDesc += "running, conf: \(act.confidence.rawValue)"
            }
            if act.unknown {
                motionDesc += "unknown, conf: \(act.confidence.rawValue)"
            }
            if act.stationary {
                motionDesc += "still, conf: \(act.confidence.rawValue)"
            }
            if act.cycling {
                motionDesc += "cycling, conf: \(act.confidence.rawValue)"
            }
            if act.automotive {
                motionDesc += "driving, conf: \(act.confidence.rawValue)"
            }
        }
//        print(motionDesc)
        return motionDesc
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
