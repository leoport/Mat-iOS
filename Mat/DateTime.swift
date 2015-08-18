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
    private static let completeFormatter : NSDateFormatter = DateFormatterWrapper(format : "yyyy-MM-dd HH:mm:ss")
    private static let monthAndDayFormat : NSDateFormatter = DateFormatterWrapper(format : "MM-dd")
    private static let onlyDateFormat    : NSDateFormatter = DateFormatterWrapper(format : "yyyy-MM-dd")
    private static let simpleDateFormat  : NSDateFormatter = DateFormatterWrapper(format : "MM月dd日 HH点mm分")
    private static let digitDateFormat   : NSDateFormatter = DateFormatterWrapper(format : "yyyyMMddHHmmss")


    required init() {
        mDate = NSDate()
    }
    required init(timeIntervalSince1970: NSTimeInterval) {
        mDate = NSDate(timeIntervalSince1970: timeIntervalSince1970)
    }
    required init(date : String) {
        if let d = DateTime.completeFormatter.dateFromString(date) {
            mDate = d
        } else {
            print("failed to format date: " + date)
            mDate = NSDate(timeIntervalSince1970: 0)
        }
        //mDate = DateTime.completeFormatter.dateFromString(date)!
    }
    func toCompleteString() -> String {
        return DateTime.completeFormatter.stringFromDate(mDate)
    }
    func toSimpleString() -> String {
        return DateTime.simpleDateFormat.stringFromDate(mDate)
    }
    func toDigitString() -> String {
        return DateTime.digitDateFormat.stringFromDate(mDate)
    }
    private class DateFormatterWrapper : NSDateFormatter {
        convenience init(format : String) {
            self.init()
            super.dateFormat = format
        }
    }
}