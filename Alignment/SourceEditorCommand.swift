//
//  SourceEditorCommand.swift
//  Alignment
//
//  Created by Atsushi Kiwaki on 6/16/16.
//  Copyright © 2016 Atsushi Kiwaki. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            completionHandler(NSError(domain: "SampleExtension", code: -1, userInfo: [NSLocalizedDescriptionKey: "None selection"]))
            return
        }

        var regexLeftPart: NSRegularExpression?
        var regexRightPart: NSRegularExpression?
        do {
            regexLeftPart = try NSRegularExpression(pattern: " *=", options: .caseInsensitive)
            regexRightPart = try NSRegularExpression(pattern: "= *", options: .caseInsensitive)
        } catch _ {
            completionHandler(NSError(domain: "SampleExtension", code: -1, userInfo: [NSLocalizedDescriptionKey: ""]))
            return
        }

        let alignPosition = invocation.buffer.lines.enumerated().map { i, line -> Int in
            guard i >= selection.start.line && i <= selection.end.line,
                let line = line as? String,
                let result = regexLeftPart?.firstMatch(in: line, options: .reportProgress, range: NSRange(location: 0, length: line.characters.count)) else {
                    return 0
            }
            return result.range.location
            }.max()

        for index in selection.start.line ... selection.end.line {
            guard let line = invocation.buffer.lines[index] as? NSString else {
                continue
            }

            var newLineString = line as String
            let leftPartRange = line.range(of: "=")
            if leftPartRange.location != NSNotFound {
                let repeatCount = alignPosition! - leftPartRange.location + 1
                if repeatCount != 0 {
                    let whiteSpaces = String(repeating: " ", count: abs(repeatCount))

                    if repeatCount > 0 {
                        newLineString = line.replacingOccurrences(of: "=", with: "\(whiteSpaces)=")
                    } else {
                        newLineString = line.replacingOccurrences(of: "\(whiteSpaces)=", with: "=")
                    }
                }
            }
            
            let newLine = newLineString as NSString
            let rightPartRange = newLine.range(of: "=")
            if rightPartRange.location != NSNotFound {
                let range = NSMakeRange(rightPartRange.location, newLine.length - rightPartRange.location)
                if let afterText = regexRightPart?.stringByReplacingMatches(in: newLineString, options: .anchored, range: range, withTemplate: "= ") {
                    newLineString = afterText
                }
            }
            
            invocation.buffer.lines.replaceObject(at: index, with: newLineString)
        }
        
        completionHandler(nil)
    }
}
