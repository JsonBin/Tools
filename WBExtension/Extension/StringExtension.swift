//
//  StringExtension.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/6.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

// MARK: - 对字符串进行相应的延展

public extension String {
    
    public var str: WBString {
        return WBString(string: self)
    }
}

/// 重新赋类
public struct WBString {
    
    public var string: String
}

// MARK: - 检验字符串

public extension WBString {
    
    /// - 字符内容统计
    
    /// 统计字符串长度
    public var length: Int {
        return string.characters.count
    }
    
    /// 截取单个字符
    ///
    /// - Parameter i: 第几个字符
    /// - Returns: 字符
    public func substring(_ i: Int) -> String {
        return String(string[string.characters.index(string.startIndex, offsetBy: i)] as Character)
    }
    
    /// 截取字符串
    ///
    /// - Parameter from: 从第几个开始
    /// - Returns: 截取的字符串
    public func substring(from: Int) -> String {
        return string.substring(from: string.index(string.startIndex, offsetBy: from))
    }
    
    /// 截取字符串
    ///
    /// - Parameter to: 到第几个
    /// - Returns: 截取的字符串
    public func substring(to: Int) -> String {
        return string.substring(to: string.index(string.startIndex, offsetBy: to))
    }
    
    // 截取字符串
    public func subscriptString(_ r: Range<Int>) -> String {
        return string.substring(with: string.characters.index(string.startIndex, offsetBy: r.lowerBound)..<string.characters.index(string.startIndex, offsetBy: r.upperBound))
    }
    
    // 获取字符串所占尺寸
    public func sizeWithFont(_ font:UIFont, maxSize MaxSize:CGSize) -> CGSize {
        let attr = [NSFontAttributeName:font]
        let rect = string.boundingRect(with: MaxSize,
                                       options: [.usesFontLeading,.truncatesLastVisibleLine,.usesLineFragmentOrigin],
                                       attributes: attr,
                                       context: nil)
        return rect.size
    }
    
    // 返回指定字符串的height
    public func textHeightWithMaxWidth(_ maxWidth:CGFloat, font andFont:UIFont) -> CGFloat {
        let size = sizeWithFont(andFont, maxSize: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }
    
    /// - 判断字符串的内容等
    
    /// 检验字符串是否为空
    public var isnull: Bool {
        
        if string.isEmpty{
            return true
        }
        let str = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if str == Optional.none {
            return true
        }
        if str.isKind(of: NSNull.classForCoder()) {
            return true
        }
        if str.isEmpty {
            return true
        }
        if str == "(null)" || str == "<null>" || str == "null" {
            return true
        }
        return false
    }
    
    /// 检验是否为合法字符串(字母，数字，下划线)
    public var isValidateString: Bool {
        let nameCharacters = CharacterSet(charactersIn: "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789").inverted
        let userNameRange = string.rangeOfCharacter(from: nameCharacters)
        if userNameRange == nil {
            return false
        }
        return true
    }
    
    // 检验字符串中是否含有指定字符串
    public func isHaveString(_ desString:String) -> Bool {
        let rang = string.range(of: desString)
        return rang == nil ? false : true
    }
    
    /// 检验字符串是否包含中文
    public var isHaveChinese: Bool {
        for index in 0..<length {
            let strCode = (string as NSString).character(at: index)
            if strCode > 0x4e00 && strCode < 0x9fff {
                return true
            }
        }
        return false
    }
    
    /// 检验是否为全数字
    public var isAllNumber: Bool {
        for index in 0..<length {
            let str = (string as NSString).character(at: index)
            if isdigit(Int32(str)) != 0 {
                return true
            }
        }
        return false
    }
    
    /// 检验是否为全中文
    public var isAllChinese: Bool {
        let chineseRegex = "^[\\u4e00-\\u9fa5]{0,}$"
        let chinesePredicate = NSPredicate(format: "SELF MATCHES %@", chineseRegex)
        return chinesePredicate.evaluate(with: string)
    }
    
    /// 检验是否为手机号
    public var isValidateMobileNumber: Bool {
        /**
         * 手机号码
         * 移动号段：
         * 134 135 136 137 138 139 147 150 151 152 157 158 159 178 182 183 184 187 188
         * 联通号段：
         * 130 131 132 145 155 156 171 175 176 185 186
         * 电信号段：
         * 133 149 153 173 177 180 181 189
         * 虚拟运营商:
         * 170
         */
        /**
         * 大陆地区固话及小灵通
         * 区号：010,020,021,022,023,024,025,027,028,029
         * 号码：七位或八位
         */
        // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
        let phoneRegex = "^(0|86|17951)?(13[0-9]|15[012356789]|17[1678]|18[0-9]|14[579])[0-9]{8}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: string)
    }
    
    /// 检验密码合格性(6-20位数字、字母)
    public var isValidatePassWord: Bool {
        let passwordRegex = "^[a-zA-Z0-9]{6,20}+$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: string)
    }
    
    /// 检验是否为邮箱
    public var isValidateEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: string)
    }
    
    /// 检验是否为车牌号
    public var isValidateCarNo: Bool {
        let carRegex = "^[A-Za-z]{1}[A-Za-z_0-9]{5}$"
        let carPredicate = NSPredicate(format: "SELF MATCHES %@", carRegex)
        return carPredicate.evaluate(with: string)
    }
    
    /// 检验是否为身份证号码
    public var isValidateCard: Bool {
        var flag = false
        if length <= 0 { return flag }
        let cardRegex = "^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$"
        let cardPredicate = NSPredicate(format: "SELF MATCHES %@", cardRegex)
        flag = cardPredicate.evaluate(with: string)
        
        // 通过上面验证，说明身份证合法，还需算准确性
        if flag{
            if length == 18{
                // 将前17位加权因子保存
                let idCardWiArray = ["7","9","10","5","8","4","2","1","6","3","7","9","10","5","8","4","2"]
                // 除以11后，可能产生的11位余数、验证码保存
                let idCardYArray = ["1","0","10","9","8","7","6","5","4","3","2"]
                
                var idCardWiSum = 0  // 用来保存前17位各自乘以加权因子后的总和
                for index in 0..<17 {
                    let subString = (string as NSString).substring(with: NSMakeRange(index, 1))
                    let subStrIndex = (subString as NSString).integerValue
                    let idCardWiIndex = (idCardWiArray[index] as NSString).integerValue
                    
                    idCardWiSum += subStrIndex * idCardWiIndex
                }
                
                // 计算出校验码所在数组的位置
                let idCardMod = idCardWiSum % 11
                
                // 得到最后一位身份证号码
                let idCardLast = (string as NSString).substring(from: 17)
                
                // 如果等于2，则校验码为10，身份证号码最后一位应为X
                if idCardMod == 2{
                    if idCardLast == "X" || idCardLast == "x" {
                        return flag
                    }
                    flag = false
                    return flag
                }
                // 用计算出的验证码与身份证最后一位匹配，若一致，则有效，否则无效
                if idCardLast == idCardYArray[idCardMod] {
                    return flag
                }
                flag = false
                return flag
            }
            flag = false
            return flag
        }
        return flag
    }
    
    /// - 对字符串进行各种转换
    
    // 16进制转为颜色
    public func hexColor(_ alpha:CGFloat = 1.0) -> UIColor{
        var colorStr = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        // String should be 6 or 8 characters
        if colorStr.str.length < 6 {
            WB_Log("HexString's length should be 6 or 8, otherwise return blackColor! _____ 16进制数的长度至少为6或8个字符,否则返回为黑色!")
            return UIColor.black
        }
        // 转换成标准16进制数
        if colorStr.hasPrefix("#") {
            colorStr = colorStr.replacingCharacters(in: colorStr.range(of: "#")!, with: "0x")
        }
        // 如果字符串头没包含 "0x" 则不是合格的16进制数
        if !colorStr.hasPrefix("0x"){
            WB_Log("HexString formal error , otherwise return blackColor! _____ 16进制数的格式错误,否则返回为黑色!")
            return UIColor.black
        }
        // 十六进制字符串转成整形。
        let colorLong = strtoull(colorStr.cString(using: String.Encoding.utf8), UnsafeMutablePointer(bitPattern: 0), 16)
        // 通过位与方法获取三色值
        let R = (colorLong & 0xFF0000) >> 16
        let G = (colorLong & 0x00FF00) >> 8
        let B = (colorLong & 0x0000ff)
        
        return UIColor(red: CGFloat(R)/255.0,
                       green: CGFloat(G)/255.0,
                       blue: CGFloat(B)/255.0,
                       alpha: alpha)
    }
    
    // 字符进行md5加密 <首先引入 <CommonCrypto/CommonDigest.h> >
    public var md5String: String {
        let str = string.cString(using: .utf8)
        let strLen = CUnsignedInt(string.lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        return String(format: hash as String)
    }
    
    /// - 对字符串进行一系列的字符操作
    
    private struct WBStringKey {
        static let colorKey = "color"
        static let fontKey = "font"
        static let rangeKey = "range"
    }
    
    public enum WBRangeFormatType : Int{
        case correct
        case error
        case out
    }
    
    // 校验范围(NSRange)
    public func checkRange(_ range:NSRange) -> WBRangeFormatType {
        let location = range.location
        let len = range.length
        if location > 0 && len > 0{
            if (range.location+range.length) <= length{
                return .correct
            }
            WB_Log("The range out-of-bounds! ____ range超出字符串的范围!")
            return .out
        }
        WB_Log("The range format is wrong: NSMakeRange(a,b) (a>0,b>0)! ____ range的格式错误!")
        return .error
    }
    
    // 改变字符串的字体大小、颜色
    public func changeColor(_ color:UIColor?, colorRange andColorRange:NSRange?, font andFont:UIFont?, fontRange andFontRange:NSRange?) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        if let andColorRange = andColorRange {
            if checkRange(andColorRange) == .correct {
                if let color = color {
                    attributedString.addAttribute(NSForegroundColorAttributeName,
                                                  value: color,
                                                  range: andColorRange)
                }
                else{
                    WB_Log("color is nil! ____ 颜色为nil!")
                }
            }
        }
        if let andFontRange = andFontRange {
            if checkRange(andFontRange) == .correct{
                if let andFont = andFont {
                    attributedString.addAttribute(NSFontAttributeName,
                                                  value: andFont,
                                                  range: andFontRange)
                }
                else{
                    WB_Log("font is nil! ____字体为nil!")
                }
            }
        }
        return attributedString
    }
    
    // 改变多段字符串为同种颜色
    public func changeColor(_ color:UIColor, ranges andRanges:[NSRange]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        for range in andRanges {
            if checkRange(range) == .correct{
                attributedString.addAttribute(NSForegroundColorAttributeName,
                                              value: color,
                                              range: range)
            }
        }
        return attributedString
    }
    
    // 改变多段字符串为同种字体大小
    public func changeFont(_ font:UIFont, ranges andRanges:[NSRange]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        for range in andRanges {
            if checkRange(range) == .correct{
                attributedString.addAttribute(NSFontAttributeName,
                                              value: font,
                                              range: range)
            }
        }
        return attributedString
    }
    
    // 改变多段字符串的颜色和字体大小, 字典里的key为固定的3个字符串,“color”/“font”/“range”
    // 比如:
    // let string = "abcdefghijklmnopqrstuvwxyz"
    // let dictionary = ["color":UIColor.white,
    //                 "font":UIFont.smallSystemFontSize,
    //                 "range":[NSMakeRange(0,2),NSMakeRange(6,10)]]
    // let attributedstring = string.wb_changeColorAndFont([dictionary])
    public func changeColorAndFont(_ changes:[NSDictionary]) -> NSMutableAttributedString{
        let attributedString = NSMutableAttributedString(string: string)
        for dictionary in changes {
            let color = dictionary.object(forKey: WBStringKey.colorKey)
            if color == nil {
                WB_Log("warning: NSColorKey -> nil! ____ 字典<\(dictionary)>对应的'color'->value为nil!")
            }
            let font = dictionary.object(forKey: WBStringKey.fontKey)
            if font == nil {
                WB_Log("warning: NSFontKey -> nil! ____ 字典<\(dictionary)>对应的'font'->value为nil!")
            }
            let ranges:[NSRange]! = dictionary.object(forKey: WBStringKey.rangeKey) as? [NSRange]
            if ranges == nil{
                WB_Log("warning: NSRangeKey -> nil! ____ 字典<\(dictionary)>对应的'range'->value为nil!")
            }
            if ranges.count > 0 {
                for range in ranges {
                    if checkRange(range) == .correct{
                        if let color = color {
                            attributedString.addAttribute(NSForegroundColorAttributeName,
                                                          value: color,
                                                          range: range)
                        }
                        if let font = font {
                            attributedString.addAttribute(NSFontAttributeName,
                                                          value: font,
                                                          range: range)
                        }
                    }
                }
            }
        }
        return attributedString
    }
    
    // 对相应的字符串进行颜色、字体进行改变
    // 比如:
    // let string = "abcdefghijklmnopqrstuvwxyz"
    // let attributedstring = string.wb_changeWithString("mno",
    //                                                  color:UIColor.red,
    //                                                  font: UIFont.smallSystemFontSize)
    public func changeWithString(_ setString:String, color andColor:UIColor?, font andFont:UIFont?) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        var len = length
        while len > setString.str.length {
            let range = (string as NSString).range(of: setString,
                                                   options: .backwards,
                                                   range: NSMakeRange(0, len))
            if checkRange(range) == .correct{
                if andColor == nil && andFont == nil{
                    WB_Log("warning: color and font is nil! ____ 未对将要改变的字符串进行字体大小及颜色进行设置!")
                }
                if let andColor = andColor {
                    attributedString.addAttribute(NSForegroundColorAttributeName,
                                                  value: andColor,
                                                  range: range)
                }
                if let andFont = andFont {
                    attributedString.addAttribute(NSFontAttributeName,
                                                  value: andFont,
                                                  range: range)
                }
                len = range.location
            }
        }
        return attributedString
    }
    
    /// 为字符串添加中划线
    public var addCenterLine: NSMutableAttributedString {
        let attributes = [NSStrikethroughStyleAttributeName:NSUnderlineStyle.styleSingle.rawValue]
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        return attributedString
    }
    
    /// 为字符串添加下划线
    public var addUnderLine: NSMutableAttributedString {
        let attributes = [NSUnderlineStyleAttributeName:NSUnderlineStyle.styleSingle.rawValue]
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        return attributedString
    }
}
