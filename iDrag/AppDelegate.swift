//
//  AppDelegate.swift
//  iDrag
//
//  Created by runforever on 16/9/29.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSSeguePerforming, NSUserNotificationCenterDelegate {

    @IBOutlet weak var dragMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettingSegue" {
            let settingWindowController = segue.destinationController as! NSWindowController
            settingWindowController.window?.level = Int(CGWindowLevelKey.floatingWindow.hashValue)

            let settingViewController = settingWindowController.contentViewController as! SettingViewController
            settingViewController.dragMenu = dragMenu
        }
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

