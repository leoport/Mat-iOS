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
    
    private var mId : Int
    private var mName : String
    private var mType : Type
    private var mUnit : String
    private var mTitle : String

    required init() {
        mId = 0
        mName = ""
        mType = Type.S
        mUnit = ""
        mTitle = ""
    }

    func getId() -> Int {
        return mId
    }
    func setId(id : Int) {
        mId = id
    }

    func getName() -> String {
        return mName
    }
    func setName(name : String) {
        mName = name
    }

    func getType() -> Type {
        return mType
    }
    func setType(type : Type) {
        mType = type
    }

    func getUnit() -> String {
        return mUnit
    }
    func setUnit(unit : String) {
        mUnit = unit
    }

    func getTitle() -> String {
        return mTitle
    }
    func setTitle(title : String) {
        mTitle = title
    }
}