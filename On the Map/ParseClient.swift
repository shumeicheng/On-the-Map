//
//  ParseClient.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/6/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
class ParseClient :UIViewController {
    static let sharedInstance =  ParseClient()
    
   // var locations:[[String:AnyObject]]!
    var studentInfos : [StudentInfo]!
    var latitude: String!
    var longitude:String!
    var mapString:String!
    var mediaURL:String!
    
}

