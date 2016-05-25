//
//  InputPinController.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/5/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InputPinController : UIViewController,MKMapViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var locationText: UITextField!
    
   
    @IBOutlet weak var mapViewIndicator: UIActivityIndicatorView!
    
 
    var annotation: MKPointAnnotation!
    var textFieldClient = TextFieldClient.sharedInstance
    var parseClient = ParseClient.sharedInstance
    var debug : Bool = false
    
    override func viewWillAppear(animated: Bool) {
        locationText.text = "Enter Your Location Here"
        mapViewIndicator.stopAnimating()
        mapViewIndicator.hidesWhenStopped = true        
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationText.delegate = self
        textFieldClient.setTextField(locationText)
        textFieldClient.subscribeToNotification(UIKeyboardWillShowNotification, selector: Constants.Selectors.KeyboardWillShow)
        textFieldClient.subscribeToNotification(UIKeyboardWillHideNotification, selector: Constants.Selectors.KeyboardWillHide)
 
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textFieldClient.unsubscribeFromAllNotifications()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        locationText.resignFirstResponder()
        parseClient.mapString = locationText.text
        if(debug){ print(textField.text) }
        return true
    }
    
    @IBAction func findOntheMap(sender: AnyObject) {
        
        
        mapViewIndicator.startAnimating()
        annotation = MKPointAnnotation()
        let location = locationText.text
      
        
        if (locationText.text != nil){
            // if location is valid
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(location!, completionHandler: { (placemarks,error) in
                if let placemark = placemarks?[0] {
                    self.mapViewIndicator.stopAnimating() // hide the indicator now!
                    if((error) != nil){
                        
                        ApiService.sharedInstance.errorAlert("Error: \(error?.localizedDescription) :\(self.locationText.text) on the map", viewController: self)
                        
                    }
                    
                    
                    
                    let long = (placemark.location!.coordinate.longitude)
                    let lat = placemark.location!.coordinate.latitude
                    self.parseClient.latitude = String(lat)
                    self.parseClient.longitude = String(long)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    self.annotation.coordinate = coordinate
                    let udacity = UdacityClient.sharedInstance
                    self.annotation.title = "\(udacity.firstName) \(udacity.lastName)"
                    self.annotation.subtitle = self.parseClient.mediaURL
                
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("LinkedInViewController") as! LinkedInViewController
                    controller.annotation = self.annotation
                    controller.mapViewIndicator = self.mapViewIndicator
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                }})
            
           
        }
        
    }
}