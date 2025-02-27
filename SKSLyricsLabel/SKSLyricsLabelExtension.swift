//
//  SKSLyricsLabelTool.swift
//  SKSMultiLineLyricsView
//
//  Created by sks on 2020/9/25.
//  Copyright © 2020 chenzhenchao. All rights reserved.
//

import UIKit

extension NSAttributedString {
    /// 对富文本进行平均分割区域
    /// - Parameters:
    ///   - width: 分割单元的宽度
    ///   - height: ⚠️分割单元的高度，请谨慎使用font.lineHeight，如果使用了，务必自增一些高度甚至可以使用font.lineHeight * 1.5，否则CTFramesetterCreateFrame时将导致单元格面积不足以放下富文本内容分割失败
    /// - Returns: 分割后的富文本数组
    public func sks_separatedAttLines(width: CGFloat, height: CGFloat) -> [NSAttributedString] {
        let textFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let rectPath: CGPath = CGPath(rect: textFrame, transform: nil)

        var textPos = 0
        let cfAttStr: CFAttributedString = self as CFAttributedString

        let framesetter: CTFramesetter = CTFramesetterCreateWithAttributedString(cfAttStr)
        var pagingResult = [NSAttributedString]()

        while textPos < self.length {
            let frame: CTFrame = CTFramesetterCreateFrame(framesetter, CFRange(location: textPos, length: 0), rectPath, nil)
            let frameRange = CTFrameGetVisibleStringRange(frame)
            if frameRange.length == 0 {
              // 如果传入的width和height不足以放下文字内容（比如字体是20，但是传入的高度却只有18，那明显放下不嘛），CTFrameGetVisibleStringRange顾名思义这是在可视范围内分割内容，导致frameRange长度为0，分割就会失败。
              pagingResult.append(self)
              break
            }

            let range = NSRange(location: frameRange.location, length: frameRange.length)
            let subStr = self.attributedSubstring(from: range)
            pagingResult.append(subStr)
            textPos += frameRange.length
        }

        return pagingResult
    }
        
    /// 获取富文本内尺寸最大的Font
    public func sks_maxAttbuteFont() -> UIFont? {
        var maxFont: UIFont?
        for index in 0..<self.length {
            let subChar = self.attributes(at: index, effectiveRange: nil)
            if let vFont = subChar[NSAttributedString.Key.font] as? UIFont {
                if vFont.pointSize > maxFont?.pointSize ?? 0 {
                    maxFont = vFont
                }
            }
        }

        return maxFont
    }
    
    /// 获取富文本内尺寸最小的Font
    public func sks_minAttbuteFont() -> UIFont? {
        var minFont: UIFont?
        for index in 0..<self.length {
            let subChar = self.attributes(at: index, effectiveRange: nil)
            if let vFont = subChar[NSAttributedString.Key.font] as? UIFont {
                if minFont?.pointSize ?? 0 == 0 {
                    minFont = vFont
                }
                if minFont?.pointSize ?? 0 > vFont.pointSize {
                    minFont = vFont
                }
            }
        }

        return minFont
    }
    
    /// 最大字体和最小字体相差的倍数
    public func sks_maxminDifferenceMultiple() -> CGFloat {
        let maxFont = self.sks_maxAttbuteFont()
        let minFont = self.sks_minAttbuteFont()

        guard let vMaxHeight = maxFont?.lineHeight, let vMinHeight = minFont?.lineHeight else {
            return 0
        }

        let space = vMaxHeight / vMinHeight
        return space
    }
    
}

extension String {
    
    // 文字宽度
    public func sks_width(_ font: UIFont) -> CGFloat {
        return NSString(string: self).size(withAttributes: [NSAttributedString.Key.font: font]).width
    }
    
    // 文字高度
    public func sks_height(_ font: UIFont, width: CGFloat) -> CGFloat {
        return self.sks_size(font, maxSize: CGSize(width: width, height: CGFloat(MAXFLOAT))).height
    }
    
    // 文字尺寸
    public func sks_size(_ font: UIFont, maxSize: CGSize) -> CGSize {
        let attrs = [NSAttributedString.Key.font: font]
        return NSString(string: self).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attrs, context: nil).size
    }
    
    // 去除空格
    public func sks_removeSpace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
