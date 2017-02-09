//
//  ViewController.swift
//  XcodeSourceEditorExtension-Alignment
//
//  Created by Atsushi Kiwaki on 6/16/16.
//  Copyright © 2016 Atsushi Kiwaki. All rights reserved.
//

import Cocoa

struct ConfigurationKey {
    static let EnableAssignment  = "KEY_ENABLE_ASSIGNMENT"
    static let EnableTypeDeclaration = "KEY_ENABLE_TYPE_DECLARATION"
}

let linkToGitHub = "https://github.com/tid-kijyun/XcodeSourceEditorExtension-Alignment"

extension NSButton {
    var isChecked: Bool {
        return self.state == NSOnState ? true : false
    }
}

class ViewController: NSViewController {
    @IBOutlet weak var checkAlignAssignment: NSButton!
    @IBOutlet weak var checkAlignTypeDeclaration: NSButton!
    @IBOutlet weak var warning: NSTextField!
    @IBOutlet weak var version: NSTextField! {
        didSet {
            version.stringValue = "Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0")"
        }
    }
    @IBOutlet weak var link: NSTextField! {
        didSet {
            link.isSelectable = true
            link.attributedStringValue = link_string(text: linkToGitHub, url: NSURL(string: linkToGitHub)!)
        }
    }

    func link_string(text:String, url:NSURL) -> NSMutableAttributedString {
        // initially set viewable text
        let attrString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attrString.length)
        attrString.beginEditing()
        attrString.addAttributes([
                NSLinkAttributeName: url.absoluteString!,
                NSForegroundColorAttributeName: NSColor.blue,
                NSUnderlineStyleAttributeName:NSUnderlineStyle.styleSingle.rawValue
            ], range: range)

        attrString.endEditing()
        return attrString
    }

    private let def = UserDefaults(suiteName: "group.com.tid.Alignment-for-Xcode")

    private var isAlignAssignment: Bool = true {
        didSet {
            checkAlignAssignment.state = isAlignAssignment ? NSOnState : NSOffState
            def?.set(isAlignAssignment, forKey: ConfigurationKey.EnableAssignment)
            validateSettings()
        }
    }

    private var isAlignTypeDeclaration: Bool = false {
        didSet {
            checkAlignTypeDeclaration.state = isAlignTypeDeclaration ? NSOnState : NSOffState
            def?.set(isAlignTypeDeclaration, forKey: ConfigurationKey.EnableTypeDeclaration)
            validateSettings()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        load()
    }

    func load() {
        isAlignAssignment      = def?.object(forKey: ConfigurationKey.EnableAssignment) as? Bool ?? true
        isAlignTypeDeclaration = def?.object(forKey: ConfigurationKey.EnableTypeDeclaration) as? Bool ?? false
    }

    func validateSettings() {
        warning.isHidden = isAlignAssignment || isAlignTypeDeclaration
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func onCheckAlignAssignment(_ sender: NSButton) {
        isAlignAssignment = sender.isChecked

    }
    @IBAction func onCheckAlignTypeDeclaration(_ sender: NSButton) {
        isAlignTypeDeclaration = sender.isChecked
    }
}
