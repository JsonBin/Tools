//
//  WBError.swift
//  WBExtension
//
//  Created by zwb on 17/3/2.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

// MARK: - 处理错误类

public enum WBError : Error {
    
    case invalidURL(url: ImageURLConvertible)
    
    case failure(error:Error)
    
    case readFileFailure(reason: CacheFailedReason)
    
    public enum CacheFailedReason {
        case readFailed(msg:String, error:Error)
    }
}

extension Error {
    
    static func descriptError(_ code:Int, message msg:String) -> Error {
        return NSError(domain: "com.wbwebimage.error", code: code, userInfo: [NSLocalizedDescriptionKey:msg]) as Error
    }
}

extension WBError {
    var reaseon: String? {
        switch self {
        case .readFileFailure(let reason):
            return reason.message
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        case .readFileFailure(let reason):
            return reason.error
        default:
            return nil
        }
    }
}

extension WBError.CacheFailedReason {
    var message: String {
        switch self {
        case .readFailed(let message,_):
            return message
        }
    }
    
    var error: Error {
        switch self {
        case .readFailed(_,let error):
            return error
        }
    }
}
