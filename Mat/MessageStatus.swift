//
//  MessageStatus.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation
enum MessageStatus : Int {
    case Init = 0
    case Confirmed
    case Ignored
    case Accomplished
    case Closed
}