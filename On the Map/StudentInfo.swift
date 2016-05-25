//
//  StudentInfo.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/20/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
struct StudentInfo {
    var latitude: Double
    var longitude: Double
    var urlLink: String
    var firstName : String
    var lastName : String
    
    init(dictionary: [String:AnyObject] ) {
        // dictionary is from Parse result
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        urlLink = dictionary["mediaURL"] as! String
    }
    init(latitude: Double, longitude: Double, firstName: String, lastName: String, urlLink:String){
        self.latitude = latitude
        self.longitude = longitude
        self.firstName = firstName
        self.lastName = lastName
        self.urlLink = urlLink
    }
    
    static func studentInfoFromParseData (results:[[String:AnyObject]]) -> [StudentInfo] {
        var studentInfo = [StudentInfo]()
        
        for oneStudent in results {

            studentInfo.append(StudentInfo(dictionary: oneStudent))
        }
        return studentInfo
    }
    // update the information also remove all the duplication for this student.
    static func updateStudentInfo(studentInfo: StudentInfo, var studentInfos: [StudentInfo]){
        // find the student and update information
        var foundStudent : StudentInfo!
        var indexArray : [Int] = []
        var index  = 0
        
        for student in studentInfos
        {
            if(student.lastName == studentInfo.lastName && student.firstName == student.firstName){
                if(foundStudent != nil){
                    indexArray.append(index)
                }
                foundStudent = student
                            }
            index =  index + 1
        }
        if(foundStudent != nil){
            foundStudent.longitude = studentInfo.longitude
            foundStudent.latitude = studentInfo.latitude
            foundStudent.urlLink = studentInfo.urlLink
        }
        
        for i in indexArray {
            studentInfos.removeAtIndex(i)
        }
    }
    
    
}