//
//  UploadImageCell.swift
//  iDrag
//
//  Created by runforever on 16/9/30.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Cocoa

struct UploadImageRowStruct {
    var imageUrl: String
    var image: NSImage

    init(image: NSImage, url: String) {
        self.image = image
        self.imageUrl = url
    }
}

class UploadImageCell: NSTableCellView {

    @IBOutlet var uploadImage: NSImageView!
    var imageUrl: String!

    @IBAction func copyUrlAction(_ sender: NSButton) {
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(imageUrl, forType: NSPasteboardTypeString)
        Swift.print(imageUrl)
    }

    @IBAction func copyMarkdownAction(_ sender: NSButton) {
        let markdownUrl = "![](\(imageUrl!))"
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(markdownUrl, forType: NSPasteboardTypeString)
        Swift.print(markdownUrl)
    }
}
