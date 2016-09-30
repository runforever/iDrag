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

class DragAppController: NSObject, NSWindowDelegate, NSDraggingDestination {

    @IBOutlet weak var dragMenu: NSMenu!
    @IBOutlet weak var uploadImageView: UploadImageView!

    let dragApp = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    override func awakeFromNib() {
        let imageItem = dragMenu.item(withTitle: "Image")!
        imageItem.view = uploadImageView

        dragApp.title = "iDrag"
        dragApp.menu = dragMenu

        dragApp.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
        dragApp.button?.window?.delegate = self
    }

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        print("drop")
        let pasteBoard = sender.draggingPasteboard()
        let filePaths = pasteBoard.propertyList(forType: NSFilenamesPboardType) as! NSArray
        let domain = NSUserDefaultsController.shared().defaults.string(forKey: "domain")!

        let qiNiu = QNUploadManager()!

        for path in filePaths {
            let token = getQiniuToken()
            let filePath = path as! String
            let filename = NSUUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
            let suffix = filePath.components(separatedBy: ".").last!
            let key = "\(filename).\(suffix)"
            print(key)
            print(token)

            qiNiu.putFile(filePath, key: key, token: token, complete: {info, key, resp -> Void in
                print(info)
                let image = NSImage(contentsOfFile: filePath)
                let imageUrl = "\(domain)/\(key!)"
                let uploadImageRow = UploadImageRowStruct(image: image!, url: imageUrl)
                self.uploadImageView.uploadImageRows.append(uploadImageRow)
                self.uploadImageView.uploadImageTable.reloadData()
                print("reload")
                }, option: nil)
        }
        return true
    }

    func getQiniuToken() -> String {
        let userDefaults = NSUserDefaultsController.shared().defaults
        let accessKey = userDefaults.string(forKey: "accessKey")!
        let secretKey = userDefaults.string(forKey: "secretKey")!
        let bucket = userDefaults.string(forKey: "bucket")!

        let deadline = round(NSDate(timeIntervalSinceNow: 3600).timeIntervalSince1970)
        let putPolicyDict:JSON = [
            "scope": bucket,
            "deadline": deadline,
            "returnBody": "",
        ]
        let encodePutPolicy = QNUrlSafeBase64.encode(putPolicyDict.rawString())!
        let secretSign =  try! HMAC(key: (secretKey.utf8.map({$0})), variant: .sha1).authenticate((encodePutPolicy.utf8.map({$0}))).toBase64()!

        let putPolicy:String = [accessKey, secretSign, encodePutPolicy].joined(separator: ":")
        return putPolicy
    }

    @IBAction func quitApp(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
