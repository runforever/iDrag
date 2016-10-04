//
//  AppDelegate.swift
//  iDrag
//
//  Created by runforever on 16/9/29.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSSeguePerforming {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettingSegue" {
            let dragMenu = segue.sourceController as! NSMenu
            let settingWindowController = segue.destinationController as! NSWindowController
            let settingViewController = settingWindowController.contentViewController as! SettingViewController
            settingViewController.dragMenu = dragMenu
        }
    }
}

