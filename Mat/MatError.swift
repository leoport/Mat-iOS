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