//
//  UploadImageCell.swift
//  iDrag
//
//  Created by runforever on 16/9/30.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Cocoa

class UploadImageCell: NSTableCellView {

    @IBOutlet var uploadImage: NSImageView!
    @IBOutlet var filenameLable: NSTextField!
    var imageUrl: String!

    @IBAction func copyUrlAction(_ sender: NSButton) {
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(imageUrl, forType: NSPasteboardTypeString)
    }

    @IBAction func copyMarkdownAction(_ sender: NSButton) {
        let markdownUrl = "![](\(imageUrl!))"
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(markdownUrl, forType: NSPasteboardTypeString)
    }
}
