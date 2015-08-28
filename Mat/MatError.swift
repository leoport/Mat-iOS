//
//  MatError.swift
//  Mat
//
//  Created by 君君 on 15/8/21.
//  Copyright © 2015年 梁晶. All rights reserved.
//

import Foundation

enum MatError : ErrorType {
    case NetworkError
    case NetworkDataError
    case AuthFailed
    case HintError(hint: String)
}
func ==(t1: MatError, t2: MatError) -> Bool {
    switch (t1, t2) {
    case (.NetworkError, .NetworkError): return true
    case (.NetworkDataError, .NetworkDataError): return true
    case (.AuthFailed, .AuthFailed): return true
    case (.HintError, .HintError): return true
    default: return false
    }
}