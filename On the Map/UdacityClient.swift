//
//  UdacityClient.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/3/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    static let sharedInstance =  UdacityClient()
    var session = NSURLSession.sharedSession()
    var sessionId:String!
    var userId:Int!
    var firstName:String!
    var lastName:String!
    
}
