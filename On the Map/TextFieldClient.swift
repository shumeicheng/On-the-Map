//
//  TextFieldController.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/10/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
class TextFieldClient: UIViewController{
    static var sharedInstance = TextFieldClient()
    var targetTextField: UITextField!
    
    func setTextField(textField: UITextField){
        targetTextField = textField
    }
    func keyboardWillShow( notification: NSNotification) {
        if(targetTextField.isFirstResponder()){
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(targetTextField.isFirstResponder()){
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    

    func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
 
    
}