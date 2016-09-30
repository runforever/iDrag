//
//  SettingViewController.swift
//  iDrag
//
//  Created by runforever on 16/9/29.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {

    @IBOutlet var accessKeyInput: NSTextField!
    @IBOutlet var secretKeyInput: NSTextField!
    @IBOutlet var bucketInput: NSTextField!
    @IBOutlet var domainInput: NSTextField!

    var userDefaults: UserDefaults!
    var settingMeta: [String: NSTextField]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        settingMeta = [
            "accessKey": accessKeyInput,
            "secretKey": secretKeyInput,
            "bucket": bucketInput,
            "domain": domainInput,
        ]
        userDefaults = NSUserDefaultsController.shared().defaults
        displaySettings()
    }

    func displaySettings() {
        for (key, input) in settingMeta {
            if let value = userDefaults.string(forKey: key) {
                input.stringValue = value
            }
        }
    }

    @IBAction func confirmAction(_ sender: NSButton) {
        for (key, input) in settingMeta {
            let setting = input.stringValue
            userDefaults.set(setting, forKey: key)
        }

        userDefaults.synchronize()
        self.view.window?.close()
    }

    @IBAction func cancelAction(_ sender: NSButton) {
        self.view.window?.close()
    }
}
