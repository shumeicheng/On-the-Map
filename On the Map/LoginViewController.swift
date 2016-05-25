//
//  LoginViewController.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/3/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

   
    
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    var session: NSURLSession!
    var sessionId:String!
    var userId:Int!
    var parseClient = ParseClient.sharedInstance
    var udacityClient = UdacityClient.sharedInstance
    var apiService = ApiService.sharedInstance
    
    func displayError(error:String, debugLabelText:String? = nil){
       
        
        performUIUpdatesOnMain {
            self.apiService.errorAlert(error,viewController: self)

            self.setUIEnabled(true)
            self.debugTextLabel.text = "Login Failed (Login Step)."
        }
    }
    
    override func viewWillAppear(animated: Bool) {

        setUIEnabled(true)
    }
    
    @IBAction func loginUdacityPressed(sender: AnyObject) {
        let userName = emailText.text
        let passWord = passwordText.text
        setUIEnabled(true)
        apiService.udacityLogin(userName!, passWord: passWord!, displayError: displayError,viewController: self )
    }
    
    @IBAction func loginFaceBook(sender: AnyObject) {
        self.apiService.faceBookLogin()
    }


}

extension LoginViewController {
    private func setUIEnabled(enabled: Bool){
        debugTextLabel.text = ""
    }
}
