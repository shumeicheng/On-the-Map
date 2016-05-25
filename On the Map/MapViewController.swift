//
//  MapViewController.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/5/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
   
    var apiService = ApiService.sharedInstance
    var parseClient = ParseClient.sharedInstance
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
      
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for oneStudent in parseClient.studentInfos {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(oneStudent.latitude) 
            let long = CLLocationDegrees(oneStudent.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = oneStudent.firstName
            let last = oneStudent.lastName
            let mediaURL = oneStudent.urlLink
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            let toOpen = view.annotation?.subtitle!
            if (toOpen != nil)  {
                guard app.openURL(NSURL(string: toOpen!)!) else {
                    apiService.errorAlert("Failed to open URL:\(toOpen!)", viewController: self)
                    return
                }
            }
        }
    }
    
    private func enterInputPinViewController(){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InputPinController") as! InputPinController
        
        self.presentViewController(controller, animated: true, completion: nil)
     
    }
    func displayError(error:String, debugLabelText:String? = nil){
        print (error)
        performUIUpdatesOnMain {
          //self.debugTextLabel.text = "Query location failed."
        }
    }
  
    @IBAction func freshMap(sender: AnyObject) {
        apiService.getStudentLocations(displayError, viewController: self)
    }
    
    @IBAction func dropPin(sender: AnyObject) {
        apiService.dropPin(displayError, viewController: self)
        // check dup pin first
    }

    @IBAction func logOut(sender: AnyObject) {
        
        apiService.logOut(displayError,viewController: self)
    }

    private func checkDupPin(){
        
    }
}