//
//  AppDelegate.swift
//  mouseSyncCentral
//
//  Created by Chih-Hao on 2017/9/19.
//  Copyright © 2017年 Chih-Hao. All rights reserved.
//

import Cocoa
import CoreBluetooth

let kServiceUUID: String = "84941CC5-EA0D-4CAE-BB06-1F849CCF8495"
let kCharacteristicUUID: String = "2BCD"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var dragFirst:Bool = true;
    var mouseLocBeforeDrag = NSEvent.mouseLocation()
    
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var serviceUUID :CBUUID{
        return CBUUID(string: kServiceUUID)
    }
    var characteristicUUID :CBUUID{
        return CBUUID(string: kCharacteristicUUID)
    }
    
    var notified: Bool {
        return true
    }
    
   
    
    func scan() {
        self.centralManager?.scanForPeripherals(withServices: [self.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        print("centralManager begin scan \(self.serviceUUID)")
    }


    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { event in
            
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension AppDelegate: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var stateDesc = "State Unknown"
        switch central.state {
        case .poweredOff:
            stateDesc = "State PoweredOff"
            break
        case .poweredOn:
            stateDesc = "State PoweredOn"
            self.scan()
            break
        case .unsupported:
            stateDesc = "State Unsupported"
            break
        case .unauthorized:
            stateDesc = "State Unauthorized"
            break
        case .resetting:
            stateDesc = "State Resetting"
            break
        default:
            break
        }
        
        print("centralManager \(stateDesc)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("didDiscover \(peripheral) advertisementData:\(advertisementData)")
        central.stopScan()
        self.peripheral = peripheral;
        
        //开始连接
        central.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
    }
    
    
    func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripherals: [CBPeripheral]) {
        print("didRetrievePeripherals")
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("didConnect")
        peripheral.delegate = self;
        peripheral.discoverServices([self.serviceUUID])
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        guard error == nil else {
            print("Error didFailToConnect: \(error!.localizedDescription)")
            return
        }
    }
    
}


extension AppDelegate: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error didDiscoverServices: \(error!.localizedDescription)")
            return
        }
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
            print("discovered service \(service)")
            print("start discovering characteristics for service \(service)")
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error didDiscoverCharacteristicsFor: \(error!.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics! {
            if(notified){
                peripheral.setNotifyValue(true, for: characteristic)
            }
            else {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else {
            print("Error didUpdateValueFor: \(error!.localizedDescription)")
            return
        }
        let data = characteristic.value
        
        
        let value = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        
       
        
        let fields = value?.components(separatedBy: .whitespaces).filter {!$0.isEmpty}
        
        
        var dx = Int((fields?[0])!)
        var dy = Int((fields?[1])!)
        var type = Int((fields?[2])!)
        
        if dx != nil{
            if dy != nil{
                if dx == -9999 && dy == -9999{
                    var mouseLoc = NSEvent.mouseLocation()
                    mouseLoc.y = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y;
                    let newLoc = CGPoint(x: mouseLoc.x, y: mouseLoc.y)

                    mouseMoveAndClickDown(onPoint: mouseLoc)
                }else if dx == -8888 && dy == -8888{
                    dragFirst = true
                    var mouseLoc = NSEvent.mouseLocation()
                    mouseLoc.y = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y;
                    let newLoc = CGPoint(x: mouseLoc.x, y: mouseLoc.y)
                    
                    mouseMoveAndClickUp(onPoint: mouseLoc)
                }
                else if dx == -7777 && dy == -7777{
                    var mouseLoc = NSEvent.mouseLocation()
                    mouseLoc.y = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y;
                    let newLoc = CGPoint(x: mouseLoc.x, y: mouseLoc.y)
                    
                    mouseMoveAndRightClick(onPoint: mouseLoc)
                }
                else if dy == -6666{
                    
                    createScrollWheelEventX(Int32((dx)!))
                    
                }else if dx == -6666{
                    createScrollWheelEventY(Float(dy!))
                }
                
                else if dx == -5555 && dy == -5555{
                    var mouseLoc = NSEvent.mouseLocation()
                    mouseLoc.y = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y;
                    let newLoc = CGPoint(x: mouseLoc.x, y: mouseLoc.y)
                    
                    doubleClick(at: newLoc)

                }else if type == 6{
                    if dragFirst == true{
                        dragFirst = false
                        mouseLocBeforeDrag = NSEvent.mouseLocation()
                        mouseLocBeforeDrag.y = NSHeight(NSScreen.screens()![0].frame) - mouseLocBeforeDrag.y;
                        mouse_left_drag_to(Float(mouseLocBeforeDrag.x)+Float(dx!),Float(mouseLocBeforeDrag.y)-Float(dy!))
                    }else{
                        mouse_left_drag_to(Float(mouseLocBeforeDrag.x)+Float(dx!),Float(mouseLocBeforeDrag.y)-Float(dy!))
                    }
                }
                else{
                    print(dx!)
                    print(dy!)
                    self.move(CGFloat(dx!), CGFloat(dy!))
                }
            }
        }
    }
    
    
    
    func doubleClick(at location: NSPoint) {
        let source = CGEventSource(stateID: .privateState)
        
        var click = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown,
                            mouseCursorPosition: location, mouseButton: .left)
        click?.setIntegerValueField(.mouseEventClickState, value: 1)
        click?.post(tap: .cghidEventTap)
        
        var release = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp,
                              mouseCursorPosition: location, mouseButton: .left)
        release?.setIntegerValueField(.mouseEventClickState, value: 1)
        release?.post(tap: .cghidEventTap)
        
        click = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown,
                        mouseCursorPosition: location, mouseButton: .left)
        click?.setIntegerValueField(.mouseEventClickState, value: 2)
        click?.post(tap: .cghidEventTap)
        
        release = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp,
                          mouseCursorPosition: location, mouseButton: .left)
        release?.setIntegerValueField(.mouseEventClickState, value: 2)
        release?.post(tap: .cghidEventTap)
    }
    
    
    
    func mouseMoveAndClickDown(onPoint point: CGPoint) {
        guard let downEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        
              guard let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }

        downEvent.post(tap: CGEventTapLocation.cghidEventTap)
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        
    }
    
    func mouseMoveAndClickUp(onPoint point: CGPoint) {

        
        guard let upEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        
        upEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    
    
    
    func mouseMoveAndRightClick(onPoint point: CGPoint) {
//        guard let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .right) else {
//            return
//        }
        guard let downEvent = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: point, mouseButton: .right) else {
            return
        }
        guard let upEvent = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: point, mouseButton: .right) else {
            return
        }
//        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        downEvent.post(tap: CGEventTapLocation.cghidEventTap)
        upEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
   
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else {
            print("Error didWriteValueFor: \(error!.localizedDescription)")
            return
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else {
            print("Error didUpdateNotificationStateFor: \(error!.localizedDescription)")
            return
        }
        
        let data = characteristic.value
        if let data = data {
            let value = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print("Notification value: \(value)")
        }
    }
    
    func move(_ dx:CGFloat , _ dy:CGFloat){
        var mouseLoc = NSEvent.mouseLocation()
        mouseLoc.y = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y;
        let newLoc = CGPoint(x: mouseLoc.x+CGFloat(dx), y: mouseLoc.y-CGFloat(dy))
        CGDisplayMoveCursorToPoint(0, newLoc)
}
}


