//
//  GoalViewController.swift
//  FunThree
//
//  Created by Amor on 2021/10/13.
//

import Foundation
import UIKit

class GoalViewController:UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var GoalNumTextField: UITextField!
    @IBOutlet weak var GoalConfirmButton: UIButton!
    
    let motion = {
        return MotionModel.sharedInstance()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoalNumTextField.delegate = self
        GoalNumTextField.keyboardType = .numberPad
        
//        print(self.GoalNumTextField.text)
    }
    
    //make number only keyboard when inputting a number to the daily goal
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    //set the goal and permanently store
    @IBAction func GoalConfirmTap(_ sender: Any) {
        motion.dailyGoalSet(dailyGoal: self.GoalNumTextField.text ?? "")
    }
    
}
