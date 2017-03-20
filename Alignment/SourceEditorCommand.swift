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

        let def = UserDefaults(suiteName: "\(Bundle.main.object(forInfoDictionaryKey: "TeamIdentifierPrefix") as? String ?? "")Alignment-for-Xcode")
        let isEnableAssignment = def?.object(forKey: "KEY_ENABLE_ASSIGNMENT") as? Bool ?? true
        let isEnableTypeDeclaration = def?.object(forKey: "KEY_ENABLE_TYPE_DECLARATION") as? Bool ?? false

        do {
            if isEnableAssignment {
                try alignAssignment(invocation: invocation, selection: selection)
            }

            if isEnableTypeDeclaration {
                try alignTypeDeclaration(invocation: invocation, selection: selection)
            }
        } catch {
            completionHandler(NSError(domain: "SampleExtension", code: -1, userInfo: [NSLocalizedDescriptionKey: ""]))
            return
        }

        completionHandler(nil)
    }

    func alignAssignment(invocation: XCSourceEditorCommandInvocation, selection: XCSourceTextRange) throws {
        var regex: NSRegularExpression?
        regex = try NSRegularExpression(pattern: "[^+^%^*^^^<^>^&^|^?^=^-](\\s*)(=)[^=]", options: .caseInsensitive)

        let alignPosition = invocation.buffer.lines.enumerated().map { i, line -> Int in
            guard i >= selection.start.line && i <= selection.end.line,
                let line = line as? String,
                let result = regex?.firstMatch(in: line, options: .reportProgress, range: NSRange(location: 0, length: line.characters.count)) else {
                    return 0
            }
            return result.rangeAt(1).location
            }.max()

        for index in selection.start.line ... selection.end.line {
            guard let line = invocation.buffer.lines[index] as? String,
                let result = regex?.firstMatch(in: line, options: .reportProgress, range: NSRange(location: 0, length: line.characters.count)) else {
                    continue
            }

            let range = result.rangeAt(2)
            if range.location != NSNotFound {
                let repeatCount = alignPosition! - range.location + 1
                if repeatCount != 0 {
                    let whiteSpaces = String(repeating: " ", count: abs(repeatCount))

                    if repeatCount > 0 {
                        invocation.buffer.lines.replaceObject(at: index, with: line.replacingOccurrences(of: "=", with: "\(whiteSpaces)=", options: [.regularExpression], range: line.startIndex..<line.index(line.startIndex, offsetBy: range.location+1)))
                    } else {
                        invocation.buffer.lines.replaceObject(at: index, with: line.replacingOccurrences(of: "\(whiteSpaces)=", with: "="))
                    }
                }
            }
        }
    }

    func alignTypeDeclaration(invocation: XCSourceEditorCommandInvocation, selection: XCSourceTextRange) throws {
        var regex: NSRegularExpression?
        regex = try NSRegularExpression(pattern: " *:", options: .caseInsensitive)

        let alignPosition1 = invocation.buffer.lines.enumerated().map { i, line -> Int in
            guard i >= selection.start.line && i <= selection.end.line,
                let line = line as? String,
                let result = regex?.firstMatch(in: line, options: .reportProgress, range: NSRange(location: 0, length: line.characters.count)) else {
                    return 0
            }
            return result.range.location
            }.max()

        for index in selection.start.line ... selection.end.line {
            guard let line = invocation.buffer.lines[index] as? NSString else {
                continue
            }

            let range = line.range(of: ":")
            if range.location != NSNotFound {
                let repeatCount = alignPosition1! - range.location + 1
                if repeatCount != 0 {
                    let whiteSpaces = String(repeating: " ", count: abs(repeatCount))

                    if repeatCount > 0 {
                        invocation.buffer.lines.replaceObject(at: index, with: line.replacingOccurrences(of: ":", with: "\(whiteSpaces):"))
                    } else {
                        invocation.buffer.lines.replaceObject(at: index, with: line.replacingOccurrences(of: "\(whiteSpaces):", with: ":"))
                    }
                }
            }
        }
    }
}
