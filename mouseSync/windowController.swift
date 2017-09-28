//
//  windowController.swift
//  mouseSync
//
//  Created by Chih-Hao on 2017/9/27.
//  Copyright © 2017年 Chih-Hao. All rights reserved.
//

import Cocoa

class windowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.toggleFullScreen(self.window)
        
    }

}
