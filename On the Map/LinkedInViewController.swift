//
//  LinkedInViewController.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/5/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LinkedInViewController : UIViewController,MKMapViewDelegate, UITextFieldDelegate{
    //var location:String!
    var parseClient = ParseClient.sharedInstance
    var udacityClient = UdacityClient.sharedInstance
    var annotation: MKPointAnnotation!
    var mapViewIndicator: UIActivityIndicatorView!
    
    var textFieldClient = TextFieldClient.sharedInstance
    var apiService = ApiService.sharedInstance

    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkedInText: UITextField!
    
    func displayError(error:String, debugLabelText:String? = nil){
        
        performUIUpdatesOnMain {
            self.apiService.errorAlert(error,viewController: self)
        
           // self.debugTextLabel.text = "update location failing."
        }
    }
    private func isValidURL(urlString:String!) -> Bool {
        var ret = false
        if urlString == nil {
            return ret
        }
        var url :NSURL = NSURL(fileURLWithPath: urlString)
        if UIApplication.sharedApplication().canOpenURL(url){
            ret = true
        }
        return ret
    }
    
    func completeLogin(){
        // just overwrite  StudentInfo
        let oneStudent = StudentInfo(latitude: Double(parseClient.latitude)!,longitude: Double(parseClient.longitude)!,firstName: udacityClient.firstName,lastName: udacityClient.lastName,urlLink: parseClient.mediaURL)
        StudentInfo.updateStudentInfo(oneStudent, studentInfos: parseClient.studentInfos)
        apiService.completeLogin(self)

    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        parseClient.mediaURL = linkedInText.text // set it here when return key is not pressed.
        // check annotation information
        if(annotation == nil){
            let alert = UIAlertController(title: "Alert", message: "Invalid address, please make sure it is valid!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        if (isValidURL(parseClient.mediaURL ) == false ){
            let alert = UIAlertController(title: "Alert", message: "Invlid URL , please make sure it is correctly entered!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            //update data
            apiService.postStudentLocation(displayError,completeLogin: completeLogin, viewController: self)
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        linkedInText.resignFirstResponder()
        parseClient.mediaURL = linkedInText.text
        return true
    }
    
    @IBAction func pressCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
 
        // zoom in view
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let lat = annotation.coordinate.latitude
        let long = annotation.coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
        mapView.setRegion(region, animated: true)
        

        mapViewIndicator.stopAnimating()
        submitButton.layer.shadowRadius = 5
        submitButton.layer.shadowOpacity = 0.8
        submitButton.layer.shadowOffset = CGSize(width:5,height:5)
        
    }
    override func viewDidLoad() {
        mapViewIndicator.startAnimating()
        self.mapView.addAnnotation(self.annotation)
        linkedInText.delegate = self
        
        textFieldClient.setTextField(linkedInText)
        
        textFieldClient.subscribeToNotification(UIKeyboardWillShowNotification, selector: Constants.Selectors.KeyboardWillShow)
        textFieldClient.subscribeToNotification(UIKeyboardWillHideNotification, selector: Constants.Selectors.KeyboardWillHide)
        
    }
    override func viewWillDisappear(animated: Bool) {
        textFieldClient.unsubscribeFromAllNotifications()
    }
}