//
//  GCDBlackBox.swift
//  On the Map
//
//  Created by Shu-Mei Cheng on 5/4/16.
//  Copyright © 2016 Shu-Mei Cheng. All rights reserved.
//

import Foundation
func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}