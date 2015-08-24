//
//  Contact.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation
class Contact {
    enum Type : Int {
        case T = 0 // For Teacher
        case S     // For Student
    };
    
    var id : Int = -1
    var name : String = ""
    var type : Type = Type.S
    var unit : String = ""
    var title : String = ""
}