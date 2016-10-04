//
//  DragAppController.swift
//  iDrag
//
//  Created by runforever on 16/9/29.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Cocoa

import Qiniu
import CryptoSwift
import SwiftyJSON
import PromiseKit

class DragAppController: NSObject, NSWindowDelegate, NSDraggingDestination, CheckSettings {

    @IBOutlet weak var dragMenu: NSMenu!
    @IBOutlet weak var uploadImageView: UploadImageView!

    let dragApp = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let userDefaults = NSUserDefaultsController.shared().defaults

    var dragUploadManager:DragUploadManager!

    override func awakeFromNib() {
        dragApp.menu = dragMenu
        let imageItem = self.dragMenu.item(withTag: 1)!
        imageItem.isHidden = true
        
        setCompressMenuState()
        checkSettings(userDefaults: userDefaults, dragMenu: dragMenu)

        dragApp.button?.title = "iDrag"
        dragApp.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
        dragApp.button?.window?.delegate = self

        dragUploadManager = DragUploadManager(
            dragApp: dragApp,
            uploadImageView: uploadImageView,
            userDefaults: userDefaults
        )
    }

    func setCompressMenuState() {
        let compressState = userDefaults.integer(forKey: CompressSettingKey)
        let compressMenuItem = dragMenu.item(withTitle: "压缩图片")
        if [NSOnState, NSOnState].contains(compressState) {
            compressMenuItem?.state = compressState
        }
    }

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteBoard = sender.draggingPasteboard()
        let filePaths = pasteBoard.propertyList(forType: NSFilenamesPboardType) as! NSArray
        dragUploadManager.uploadFiles(filePaths: filePaths)
        return true
    }

    @IBAction func setImageCompress(_ sender: NSMenuItem) {
        let compressMenuItem = dragMenu.item(withTag: 2)
        let setState: Int = { () -> Int in
            let compressState = userDefaults.integer(forKey: CompressSettingKey)
            if compressState == NSOnState {
                return NSOffState
            }
            else {
                return NSOnState
            }
        }()

        compressMenuItem?.state = setState
        userDefaults.set(setState, forKey: CompressSettingKey)
        userDefaults.synchronize()
    }

    @IBAction func quitApp(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func showSettings(_ sender: NSMenuItem) {
        // let settingViewController = SettingViewController()
    }
}
