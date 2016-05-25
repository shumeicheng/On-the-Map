//
//  TableViewController.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/6/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
class TableViewController : UITableViewController{
    var parseClient = ParseClient.sharedInstance
    var apiService = ApiService.sharedInstance
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "MapTableViewCell"
      
        let oneStudent = parseClient.studentInfos[indexPath.row]
    
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        let name = String(oneStudent.firstName) + " " + String(oneStudent.lastName)
        cell.textLabel!.text = name
        cell.imageView!.image = UIImage(named:"pin")
        
        return cell
      
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseClient.studentInfos.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // goto url link
        let oneStudent = parseClient.studentInfos[indexPath.row]
       
        let urlString = oneStudent.urlLink
        apiService.gotoURL(urlString,viewController: self)
    }
    
    func displayError(error:String, debugLabelText:String? = nil){
        print (error)
        performUIUpdatesOnMain {
            //self.debugTextLabel.text = "Query location failed."
        }
    }

    @IBAction func logOut(sender: AnyObject) {
        apiService.logOut(displayError,viewController: self)
    }
    @IBAction func freshMap(sender: AnyObject) {
        apiService.getStudentLocations(displayError, viewController: self)
    }
    
    @IBAction func dropPin(sender: AnyObject) {
         apiService.dropPin(displayError, viewController: self)
    }
}