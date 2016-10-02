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

class DragAppController: NSObject, NSWindowDelegate, NSDraggingDestination {

    @IBOutlet weak var dragMenu: NSMenu!
    @IBOutlet weak var uploadImageView: UploadImageView!

    let dragApp = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let userDefaults = NSUserDefaultsController.shared().defaults

    let shareWorkspace = NSWorkspace.shared()
    let fileManager = FileManager()
    let domain = NSUserDefaultsController.shared().defaults.string(forKey: "domain")!
    let qiNiu = QNUploadManager()!
    let compressFileTypes = ["public.jpeg", "public.png"]
    let imageFileTypes = ["public.jpeg", "public.png", "public.gif"]
    let maxImageSize:uint64 = 409600

    override func awakeFromNib() {
        dragApp.menu = dragMenu
        let imageItem = self.dragMenu.item(withTag: 1)!
        imageItem.isHidden = true
        setCompressMenuState()
        checkQiniuSetting()

        dragApp.button?.title = "iDrag"
        dragApp.button?.window?.registerForDraggedTypes([NSFilenamesPboardType])
        dragApp.button?.window?.delegate = self
    }

    func setCompressMenuState() {
        let stateKey = "compressState"
        let compressState = userDefaults.integer(forKey: stateKey)
        let compressMenuItem = dragMenu.item(withTitle: "压缩图片")
        if [NSOnState, NSOnState].contains(compressState) {
            compressMenuItem?.state = compressState
        }
    }

    func checkQiniuSetting() {
        let settingKeys = ["accessKey", "secretKey", "bucket", "domain"]
        let unSetItem = settingKeys.filter({(key) -> Bool in
            let setting = userDefaults.string(forKey: key)
            return setting == nil || setting == ""
        })

        let statusMenuItem = dragMenu.item(withTag: 0)
        if unSetItem.count == 0 {
            statusMenuItem?.isHidden = true
        }
        else {
            statusMenuItem?.isHidden = false
        }
    }

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteBoard = sender.draggingPasteboard()
        let filePaths = pasteBoard.propertyList(forType: NSFilenamesPboardType) as! NSArray
        var uploadFiles: [Promise<UploadFileRow>] = []

        for path in filePaths {
            let filePath = path as! String
            uploadFiles.append(uploadFile(filePath: filePath))
        }
        dragApp.title = "Up"
        when(fulfilled: uploadFiles).then { uploadRows -> Void in
            let maxDisplayCount = 9
            self.uploadImageView.uploadImageRows += uploadRows
            self.uploadImageView.uploadImageRows = self.uploadImageView.uploadImageRows.reversed()
            if self.uploadImageView.uploadImageRows.count > maxDisplayCount {
                self.uploadImageView.uploadImageRows = Array(self.uploadImageView.uploadImageRows[0..<maxDisplayCount])
            }
            self.uploadImageView.uploadImageTable.reloadData()
            let imageItem = self.dragMenu.item(withTag: 1)!
            imageItem.view = self.uploadImageView
            imageItem.isHidden = true
        }.always {
            self.dragApp.button?.title = "iDrag"
            self.dragApp.button?.performClick(nil)
        }
        return true
    }

    func uploadFile(filePath: String) -> Promise<UploadFileRow> {
        return Promise {fulfill, reject in
            let fileType = try! shareWorkspace.type(ofFile: filePath)
            let fileAttr = try! fileManager.attributesOfItem(atPath: filePath) as NSDictionary
            let fileSize = fileAttr.fileSize()
            let filename = NSURL(fileURLWithPath: filePath).lastPathComponent!
            let compressState = userDefaults.integer(forKey: "compressState")

            let token = getQiniuToken(filename: filename)
            let imageNeedCompress = compressFileTypes.contains(fileType) && fileSize > maxImageSize && compressState == NSOnState

            if imageNeedCompress {
                let imageData = getCompressImageData(filePath: filePath)
                qiNiu.put(imageData, key: filename, token: token, complete: {info, key, resp -> Void in
                    switch info?.statusCode {
                    case Int32(200)?:
                        let uploadFileRow = self.getUploadFileRow(filename: key!, filePath: filePath, fileType: fileType)
                        fulfill(uploadFileRow)
                    default:
                        reject((info?.error)!)
                    }
                    }, option: nil)
            }
            else {
                qiNiu.putFile(filePath, key: filename, token: token, complete: {info, key, resp -> Void in
                    switch info?.statusCode {
                    case Int32(200)?:
                        let uploadFileRow = self.getUploadFileRow(filename: key!, filePath: filePath, fileType: fileType)
                        fulfill(uploadFileRow)
                    default:
                        reject((info?.error)!)
                    }
                    }, option: nil)
            }

        }
    }

    func getCompressImageData(filePath: String) -> Data {
        let image = NSImage(contentsOfFile: filePath)!
        let bitmapImageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
        let compressOption:NSDictionary = [NSImageCompressionFactor: 0.3]
        let imageData = bitmapImageRep?.representation(using: NSJPEGFileType, properties: compressOption as! [String : Any])
        return imageData!
    }

    func getQiniuToken(filename: String) -> String {
        let userDefaults = NSUserDefaultsController.shared().defaults
        let accessKey = userDefaults.string(forKey: "accessKey")!
        let secretKey = userDefaults.string(forKey: "secretKey")!
        let bucket = userDefaults.string(forKey: "bucket")!
        let deadline = round(NSDate(timeIntervalSinceNow: 3600).timeIntervalSince1970)
        let putPolicyDict:JSON = [
            "scope": "\(bucket):\(filename)",
            "deadline": deadline,
        ]

        let b64PutPolicy = QNUrlSafeBase64.encode(putPolicyDict.rawString()!)!
        let secretSign =  try! HMAC(key: (secretKey.utf8.map({$0})), variant: .sha1).authenticate((b64PutPolicy.utf8.map({$0})))
        let b64SecretSign = QNUrlSafeBase64.encode(Data(bytes: secretSign))!

        let putPolicy:String = [accessKey, b64SecretSign, b64PutPolicy].joined(separator: ":")
        return putPolicy
    }

    func getUploadFileRow(filename: String, filePath: String, fileType: String) -> UploadFileRow {
        let imageUrl = "\(self.domain)/\(filename)"
        let fileIcon = { () -> NSImage in
            if self.imageFileTypes.contains(fileType) {
                return NSImage(contentsOfFile: filePath)!
            }
            else {
                return self.shareWorkspace.icon(forFile: filePath)
            }
        }()

        let uploadFileRow = UploadFileRow(image: fileIcon, url: imageUrl, filename: filename)
        return uploadFileRow
    }

    @IBAction func setImageCompress(_ sender: NSMenuItem) {
        let stateKey = "compressState"
        let compressMenuItem = dragMenu.item(withTitle: "压缩图片")
        let setState: Int = { () -> Int in
            let compressState = userDefaults.integer(forKey: stateKey)
            if compressState == NSOnState {
                return NSOffState
            }
            else {
                return NSOnState
            }
        }()

        compressMenuItem?.state = setState
        userDefaults.set(setState, forKey: stateKey)
        userDefaults.synchronize()
    }

    @IBAction func quitApp(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
