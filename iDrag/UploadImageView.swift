//
//  ImageListView.swift
//  iDrag
//
//  Created by runforever on 16/9/29.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Cocoa

class UploadImageView: NSView, NSTableViewDelegate, NSTableViewDataSource {

    let cellIdentifier = "uploadImageRowCell"

    @IBOutlet var uploadImageTable: NSTableView!

    var uploadImageRows: [UploadImageRowStruct] = []

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.uploadImageRows.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? UploadImageCell {
            let uploadImageRow = uploadImageRows[row]
            cell.imageUrl = uploadImageRow.imageUrl
            cell.uploadImage.image = uploadImageRow.image
            return cell
        }
        return nil
    }
}
