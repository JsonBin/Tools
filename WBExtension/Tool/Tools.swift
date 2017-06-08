//
//  Tools.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/7.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

// MARK: - DEBUG Log

public func WHLogs<T>(_ message:T, file File:NSString = #file, method Method:String = #function, line Line:Int = #line) {
    #if DEBUG
        print("\(File.lastPathComponent)[\(Line)], \(Method): \(message)")
    #endif
}

// MARK: - Tools

public class Tools {

    
    // MARK: - 获取系统缓存
    
    public static var getSystemCache: CGFloat{
        
        let cachePath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last!
        let manager = FileManager.default
        if !manager.fileExists(atPath: cachePath) { return 0 }
        
        guard let filePaths = manager.subpaths(atPath: cachePath) else {
            return 0
        }
        var filesize:CGFloat = 0
        for file in filePaths.enumerated() {
            let fileAbsolutePath = (cachePath as NSString).appendingPathComponent(file.element)
            filesize +=  fileSizeAtPath(fileAbsolutePath)
        }
        return filesize
    }
    
    // MARK: - 清除系统缓存
    
    public class func clearSystemCache() -> Void{
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last!
        let manager = FileManager.default
        guard let files = manager.subpaths(atPath: path) else {
            return
        }
        for filePath in files{
            
            let newPath = (path as NSString).appendingPathComponent(filePath)
            if manager.fileExists(atPath: newPath) {
                do {
                    try manager.removeItem(atPath: newPath)
                } catch {
                    WHLogs("\(newPath)的缓存目录不存在!")
                }
            }
        }
    }
    
    
    private static func fileSizeAtPath(_ path:String) -> CGFloat{
        let manager = FileManager.default
        if manager.fileExists(atPath: path){
            do {
                let dictionary = try manager.attributesOfItem(atPath: path) as NSDictionary
                return dictionary.object(forKey: "NSFileSize") as! CGFloat
            } catch  {
                return 0
            }
        }
        return 0
    }
    
}
