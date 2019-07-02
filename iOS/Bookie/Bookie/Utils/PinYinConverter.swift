//
//  PinYinConverter.swift
//  Bookie
//
//  Created by 法好 on 2019/7/2.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Foundation

class PYConverter {
    static func transformChinese(_ word: String) -> String {
        let pinyin: NSMutableString = NSMutableString(string: word)
        CFStringTransform(pinyin, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(pinyin, nil, kCFStringTransformStripCombiningMarks, false)
        return pinyin.uppercased
    }

}
