//
//  ApiService.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/4/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit

class  ApiService : NSObject{
    static let sharedInstance = ApiService()
    var udacityClient = UdacityClient.sharedInstance
    var parseClient = ParseClient.sharedInstance
        
    func completeLogin(viewController: UIViewController) {
        performUIUpdatesOnMain {
            // need this check to prevent executaion when pass into a function.
            if(self.parseClient.studentInfos != nil){
                
                let controller = viewController.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
                viewController.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
   
    func errorAlert(error:String, viewController:UIViewController){
        performUIUpdatesOnMain() {
            let alert = UIAlertController(title: "Alert", message: error , preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            if(viewController.presentedViewController==nil){
              viewController.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    func errorChecking(data:NSData!, response:NSURLResponse!, error:NSError!, displayError:(error:String,debugLabelText:String?)->Void, viewController:UIViewController, from:String) -> Bool{
        guard (error == nil) else { // Handle error…
            displayError(error: "there is an error with your request: \(error)",debugLabelText: nil)
            errorAlert(error.localizedDescription, viewController: viewController)
            return false
        }
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
             displayError(error:from, debugLabelText:nil)
             errorAlert(from, viewController: viewController)
            return false
        }
        
        /* GUARD: Was there any data returned? */
        guard let ldata = data else {
            displayError(error:"No data was returned by the request!",debugLabelText:nil)
            errorAlert("No data was returned by the request!", viewController: viewController
            )
            return false
        }
        return true
        
    }
    
    private func ParseURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Parse.component.scheme
        components.host = Constants.Parse.component.host
        components.path = Constants.Parse.component.path + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    

    
    func udacityLogin( userName: String, passWord: String, displayError:((error:String, debugLabelText:String?) -> Void),viewController: UIViewController){
        //"https://www.udacity.com/api/session"
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.Udacity.servicePath.session)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyString = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(passWord)\"}}"
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = udacityClient.session.dataTaskWithRequest(request) { data, response, error in
            if(self.errorChecking(data,response: response,error: error,displayError: displayError,viewController :viewController,from:"Login failed due to incorrect credentials") == false){
               return
        }
            
 
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
               // displayError(error:"Could not parse the data as JSON: '\(data)'",debugLabelText: nil)
                return
            }
        
            //print(parsedResult)
            let session = parsedResult[Constants.Udacity.key.session] as! [ String: AnyObject]
            self.udacityClient.sessionId  = session[Constants.Udacity.key.id] as! String
            let account = parsedResult[Constants.Udacity.key.account] as! [ String: AnyObject]
            //print (account)
            let stringId = account[Constants.Udacity.key.key] as! String
            self.udacityClient.userId = Int(stringId)
            //print (self.udacityClient.userId)
            self.getUserData(displayError,viewController: viewController)
        }
        task.resume()
    }
    private func getUserData(displayError:((error:String, debugLabelText:String?)-> Void),viewController:UIViewController){
        //"https://www.udacity.com/api/users
        let request = NSMutableURLRequest(URL: NSURL(string:Constants.Udacity.servicePath.users+"/\(self.udacityClient.userId)")!)
        
        let task = udacityClient.session.dataTaskWithRequest(request) { data, response, error in
            if(self.errorChecking(data,response: response,error: error, displayError:displayError,viewController: viewController,from:"login failing during retrieving user data") == false){
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                displayError(error: "Could not parse the data as JSON: '\(data)'",debugLabelText: nil)
                return
            }
        
            
            let user = parsedResult[Constants.Udacity.key.user] as! [String:AnyObject]
            self.udacityClient.lastName = user[Constants.Udacity.key.lastName] as! String
            
            self.udacityClient.firstName = user[Constants.Udacity.key.firstName] as! String
            self.getStudentLocations(displayError,viewController: viewController)

            
        }
        task.resume()
    }
    
    // request locations from server and display on map
    func getStudentLocations(displayError:((error:String, debugLabelText:String?) -> Void), viewController: UIViewController){
        
        
        //"https://api.parse.com/1/classes/StudentLocation"
        let params = ["limit": 100, "order": "-updatedAt"]
        let url = ParseURLFromParameters(params,withPathExtension: nil)
        let request = NSMutableURLRequest(URL: url)//NSURL(string:Constants.Parse.servicePath.studentLocation )!)

        request.addValue(Constants.Parse.servicePath.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
  
        request.addValue(Constants.Parse.servicePath.key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if(self.errorChecking(data,response: response,error: error, displayError:displayError,viewController: viewController,from:"login failing during retrieving student locations") == false){
                return
            }
            

             let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                //displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            let locations = parsedResult[Constants.Parse.key.results] as! [[String:AnyObject]]
            self.parseClient.studentInfos = StudentInfo.studentInfoFromParseData(locations)
            self.completeLogin(viewController)
        }
        task.resume()
        
        
    }
    func checkItem(item:String?, error:String, viewController: UIViewController) -> Bool{
        if(item == nil){
            errorAlert(error, viewController: viewController)
            return false
        }
        return true
    }
    //update location
    func postStudentLocation(displayError: ((error:String, debugLabelText:String?) -> Void),completeLogin:((Void)->Void), viewController:UIViewController){
      
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.Parse.servicePath.studentLocation )!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.Parse.servicePath.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.Parse.servicePath.key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard ( checkItem(String(udacityClient.userId) , error: "Missing userId", viewController: viewController ) &&
             checkItem(udacityClient.firstName , error:"Missing first name", viewController:viewController) &&
             checkItem(udacityClient.lastName, error:"Missing last name", viewController:viewController) &&
             checkItem(parseClient.mediaURL,error:"missing URL link", viewController: viewController) &&
            checkItem(parseClient.mapString, error:"missing location",viewController: viewController) ) else {
        
            return
        }
        
        let bodyString = "{\"uniqueKey\": \"\(udacityClient.userId!)\", \"firstName\": \"\(udacityClient.firstName!)\", \"lastName\": \"\(udacityClient.lastName!)\",\"mapString\": \"\(parseClient.mapString!)\", \"mediaURL\": \"\(parseClient.mediaURL!)\",\"latitude\": \(parseClient.latitude!),\"longitude\": \(parseClient.longitude!)}"
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if(self.errorChecking(data,response: response,error: error, displayError:displayError,viewController:  viewController,from:"failing during posting location") == false){
                return
            }
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                completeLogin()
              
            } catch {
                displayError(error: "Could not parse the data as JSON: '\(data)'",debugLabelText: "")
                return
            }
            
        }
        task.resume()
    
    }
    
    func lookupLocation(displayError: ((error:String, debugLabelText:String?) -> Void ), viewController:UIViewController)  {
        let urlString = Constants.Parse.servicePath.studentLocation+"?where=%7B%22uniqueKey%22%3A%22\(udacityClient.userId!)%22%7D"
        let url = NSURL(string: urlString)

        let request = NSMutableURLRequest(URL: url!)
        request.addValue(Constants.Parse.servicePath.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.Parse.servicePath.key, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
          
            if(self.errorChecking(data,response: response,error: error, displayError:displayError,viewController: viewController,from:"failing during look up locaiton") == false){
                return
            }
         
            if(data == data){
                 performUIUpdatesOnMain {
                    let message = "You Have Already Posted a Student Location. Would you like to Overwrite Your Current Location?"
                    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let overwrite = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: {action in
                        self.enterInputPinViewController(viewController)
                    })
                    alert.addAction(overwrite)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                    }))
                    viewController.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                self.enterInputPinViewController(viewController)
            }
        }
        task.resume()
      
    }
    
    func gotoURL(urlString: String,viewController: UIViewController){
        if let url = NSURL(string: urlString){
            guard  UIApplication.sharedApplication().openURL(url) else {
                errorAlert("failed to open \(url)", viewController: viewController)
                return
            }
        }
  
    }
    private func enterInputPinViewController(viewController:UIViewController){
         performUIUpdatesOnMain {
            let controller = viewController.storyboard!.instantiateViewControllerWithIdentifier("InputPinController") as! InputPinController
        
            viewController.presentViewController(controller, animated: true, completion: nil)
        }
        
    }

    func dropPin(displayError:((error:String, debugLabelText:String?) -> Void),viewController: UIViewController){
        lookupLocation(displayError,viewController: viewController)
    }
    
    func faceBookLogin(){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"DADFMS4SN9e8BAD6vMs6yWuEcrJlMZChFB0ZB0PCLZBY8FPFYxIPy1WOr402QurYWm7hj1ZCoeoXhAk2tekZBIddkYLAtwQ7PuTPGSERwH1DfZC5XSef3TQy1pyuAPBp5JJ364uFuGw6EDaxPZBIZBLg192U8vL7mZAzYUSJsZA8NxcqQgZCKdK4ZBA2l2ZA6Y1ZBWHifSM0slybL9xJm3ZBbTXSBZCMItjnZBH25irLhIvbxj01QmlKKP3iOnl8Ey;\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error...
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        
    }
    
    func logOut(displayError:((error:String, debugLabelText:String?) -> Void), viewController:UIViewController){
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.Udacity.servicePath.session)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if(self.errorChecking(data,response: response,error: error, displayError:displayError,viewController: viewController,from:"failing during requesting logout") == false){
                return
            }
            

            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            let loginViewController = viewController.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController")
            viewController.presentViewController(loginViewController!, animated: true, completion: nil)
            

        }
        task.resume()
        
        

    }
}