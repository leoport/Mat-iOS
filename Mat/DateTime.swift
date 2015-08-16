//
//  DateTime.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class DateTime {
    private var mDate : NSDate
    required init() {
        mDate = NSDate(timeIntervalSince1970: 0)
    }
}