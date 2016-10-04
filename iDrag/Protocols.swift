//
//  Protocols.swift
//  iDrag
//
//  Created by runforever on 16/10/4.
//  Copyright © 2016年 defcoding. All rights reserved.
//

import Foundation
import Cocoa

protocol CheckSettings {
    func checkSettings(userDefaults: UserDefaults, dragMenu: NSMenu) -> Void
}

extension CheckSettings {

    func checkSettings(userDefaults: UserDefaults, dragMenu: NSMenu) {
        let unSetItem = AllSettingKeys.filter({(key) -> Bool in
            let setting = userDefaults.string(forKey: key)
            return setting == nil || setting == ""
        })

        let statusMenuItem = dragMenu.item(at: 0)!
        print(statusMenuItem)
        print(dragMenu.items)
        if unSetItem.count == 0 {
            //statusMenuItem?.isHidden = true
            statusMenuItem.title = "设置完成"
        }
        else {
            //statusMenuItem?.isHidden = false
            statusMenuItem.title = "未设置"
        }
    }
}
