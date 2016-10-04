//
//  Models.swift
//  iDrag
//
//  Created by runforever on 16/10/3.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Foundation
import Cocoa

struct UploadFileRow{
    var imageUrl: String
    var filename: String
    var image: NSImage

    init(image: NSImage, url: String, filename: String) {
        self.image = image
        self.imageUrl = url
        self.filename = filename
    }
}
