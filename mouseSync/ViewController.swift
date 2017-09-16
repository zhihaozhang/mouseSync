//
//  ViewController.swift
//  mouseSync
//
//  Created by Chih-Hao on 2017/9/16.
//  Copyright © 2017年 Chih-Hao. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var mouseLocation: CGPoint = .zero
    override func viewDidLoad() {
        super.viewDidLoad()
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
            self.mouseLocation = NSEvent.mouseLocation()
            print(String(format: "%.0f, %.0f", self.mouseLocation.x, self.mouseLocation.y))
            return $0
        }
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { _ in
            self.mouseLocation = NSEvent.mouseLocation()
            print(String(format: "%.0f, %.0f", self.mouseLocation.x, self.mouseLocation.y))
        }
        
        
       
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func move(_ dx:CGFloat , _ dy:CGFloat){
        let mouseLoc = NSEvent.mouseLocation()
        let newLoc = CGPoint(x: mouseLoc.x-CGFloat(dx), y: mouseLoc.y+CGFloat(dy))
        CGDisplayMoveCursorToPoint(0, newLoc)
    }


}

