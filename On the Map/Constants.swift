//
//  UdacityConstants.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/3/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Selectors {
        static let KeyboardWillShow: Selector = "keyboardWillShow:"
        static let KeyboardWillHide: Selector = "keyboardWillHide:"
        static let KeyboardDidShow: Selector = "keyboardDidShow:"
        static let KeyboardDidHide: Selector = "keyboardDidHide:"
    }

    struct Udacity {
        struct servicePath {
            static let host = "https://www.udacity.com"
            static let session = host + "/api/session"
            static let users = host + "/api/users"
        }
        struct key {
            static let session = "session"
            static let id = "id"
            static let account = "account"
            static let key = "key"
            static let user = "user"
            static let lastName = "last_name"
            static let firstName = "first_name"
            
        }
    }
    struct Parse {
        struct component {
            static let scheme = "https"
            static let host = "api.parse.com"
            static let path = "/1/classes/StudentLocation"
        }

        struct servicePath {
            static let host = "https://api.parse.com/1/classes"
            static let studentLocation = host + "/StudentLocation"
            static let AppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
        struct key {
            static let results = "results"
            static let lastName = "lastName"
            static let firstName = "firstName"
            static let latitude = "latitude"
            static let longitude = "longitude"
            static let mapString = "mapString"
            static let mediaURL = "mediaURL"
        }
    }
    
}
