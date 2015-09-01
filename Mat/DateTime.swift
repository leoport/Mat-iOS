//
//  DateTime.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

class DateTime : Equatable {
    static let completeFormatter : NSDateFormatter = DateFormatterWrapper(format : "yyyy-MM-dd HH:mm:ss")
    private static let monthAndDayFormat : NSDateFormatter = DateFormatterWrapper(format : "MM-dd")
    private static let onlyDateFormat    : NSDateFormatter = DateFormatterWrapper(format : "yyyy-MM-dd")
    private static let simpleDateFormat  : NSDateFormatter = DateFormatterWrapper(format : "MM月dd日 HH点mm分")
    private static let digitDateFormat   : NSDateFormatter = DateFormatterWrapper(format : "yyyyMMddHHmmss")
    static let Zero = DateTime(timeIntervalSince1970: 0)

    private var date : NSDate

    var completeString : String {
        get {
            return DateTime.completeFormatter.stringFromDate(date)
        }
    }

    var simpleString : String {
        get {
            return DateTime.simpleDateFormat.stringFromDate(date)
        }
    }

    var digitString : String {
        get {
            return DateTime.digitDateFormat.stringFromDate(date)
        }
    }

    required init() {
        date = NSDate()
    }
    required init(timeIntervalSince1970: NSTimeInterval) {
        date = NSDate(timeIntervalSince1970: timeIntervalSince1970)
    }
    required init(date: NSDate) {
        self.date = date
    }
    required init(datetimeString : String) {
        if (datetimeString == "0000-00-00 00:00:00") {
            date = NSDate()
        } else if let tempDate = DateTime.completeFormatter.dateFromString(datetimeString) {
            date = tempDate
        } else {
            print("failed to format date: " + datetimeString)
            date = NSDate(timeIntervalSince1970: 0)
        }
    }
    class DateFormatterWrapper : NSDateFormatter {
        convenience init(format : String) {
            self.init()
            super.dateFormat = format
        }
    }
}

func ==(lhs: DateTime, rhs: DateTime) -> Bool {
    return lhs.date == rhs.date
}