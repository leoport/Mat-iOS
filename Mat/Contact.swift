//
//  Contact.swift
//  Mat
//
//  Created by 君君 on 15/8/13.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation
class Contact {
    
    var id : Int = -1
    var name : String = ""
    var type : ContactType = ContactType.Student
    var unit : String = ""
    var title : String = ""
}

enum ContactType : String {
    case Teacher = "T"
    case Student = "S"
}