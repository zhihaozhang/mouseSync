//
//  AppDelegate.swift
//  mouseSync
//
//  Created by Chih-Hao on 2017/9/16.
//  Copyright © 2017年 Chih-Hao. All rights reserved.
//

import Cocoa
import CoreBluetooth


let kServiceUUID: String = "84941CC5-EA0D-4CAE-BB06-1F849CCF8495"
let kCharacteristicUUID: String = "2BCD"
var LastTimeStamp: NSDate = NSDate()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var peripheralManager: CBPeripheralManager?
    var characteristic :CBMutableCharacteristic?
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        var previousX = NSEvent.mouseLocation().x;
        var previousY = NSEvent.mouseLocation().y;
        
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
            self.mouseLocation = NSEvent.mouseLocation()
            
            self.notifyValueAction(Int(NSEvent.mouseLocation().x-previousX),Int(NSEvent.mouseLocation().y-previousY))
            
            previousX = NSEvent.mouseLocation().x;
            previousY = NSEvent.mouseLocation().y;
            
            return $0
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { _ in
            self.mouseLocation = NSEvent.mouseLocation()
            self.notifyValueAction(Int(NSEvent.mouseLocation().x-previousX),Int(NSEvent.mouseLocation().y-previousY))
            
            previousX = NSEvent.mouseLocation().x;
            previousY = NSEvent.mouseLocation().y;
            
        }
        
       
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) {event in
            
            if event.clickCount >= 2{
                self.notifyValueAction(-5555, -5555)
                
            }else{
                self.mouseLocation = NSEvent.mouseLocation()
                self.notifyValueAction(-9999, -9999)
            }
        }
        
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) {_ in
            self.mouseLocation = NSEvent.mouseLocation()
            self.notifyValueAction(-8888, -8888)
        }
        
        
        
        NSEvent.addGlobalMonitorForEvents(matching: [.rightMouseDown]) {_ in
            self.mouseLocation = NSEvent.mouseLocation()
            
            var mouseLoc = NSEvent.mouseLocation()
            mouseLoc.y = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y;
            
            self.notifyValueAction(-7777, -7777)
            
        }
        
//        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged]) {_ in
//            self.mouseLocation = NSEvent.mouseLocation()
//            self.notifyValueAction(-6666, -6666)
//        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) {event in
            
            var dx = abs(Int(event.deltaX))
            var dy = abs(Int(event.deltaY))
            if (dx == 0 && dy == 0) {
                
            }else if dx>dy {
                print("flag1 \(dx) \(dy)")
                self.notifyValueAction(Int(event.deltaX), -6666)
            }else{
                print("flag2 \(dx) \(dy)")
                self.notifyValueAction(-6666, Int(event.deltaY))
            }
        }
        

        
        var peripheralManager: CBPeripheralManager?
        var characteristic :CBMutableCharacteristic?
        
        self.configCharacteristic()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    
    let SCREEN_WIDTH = NSScreen.main()!.frame.width
    let SCREEN_HEIGHT = NSScreen.main()!.frame.height
    
    var mouseLocation: CGPoint = .zero
    
    
    func mouseDown(with event: NSEvent) {
        self.mouseMoveAndClick(onPoint: self.mouseLocation)
    }
    
    
    
    
    func move(_ dx:CGFloat , _ dy:CGFloat){
        var mouseLoc = NSEvent.mouseLocation()
        mouseLoc.y = NSHeight(NSScreen.screens()![0].frame) - mouseLoc.y;
        let newLoc = CGPoint(x: mouseLoc.x-CGFloat(dx), y: mouseLoc.y+CGFloat(dy))
        CGDisplayMoveCursorToPoint(0, newLoc)
    }
    
    func mouseMoveAndClick(onPoint point: CGPoint) {
        guard let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        guard let downEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        guard let upEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        downEvent.post(tap: CGEventTapLocation.cghidEventTap)
        upEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    var notified: Bool {
        return true
    }
    
    var serviceUUID :CBUUID{
        return CBUUID(string: kServiceUUID)
    }
    
    var serviceUUIDs: [CBUUID] {
        let serviceUUIDs = [self.serviceUUID]
        return serviceUUIDs
    }
    
    var characteristicUUID :CBUUID{
        return CBUUID(string: kCharacteristicUUID)
    }
    
    
    var service :CBMutableService{
        let s = CBMutableService(type: serviceUUID, primary: true)
        s.characteristics = [self.characteristic!]
        return s
    }
    
    func configCharacteristic() {
        
        let data = "Start Data".data(using:String.Encoding.utf8)
        if(self.notified){
            self.characteristic =  CBMutableCharacteristic(type: self.characteristicUUID, properties:[.notify,.write], value:nil , permissions:.writeable )
        }
        else {
            self.characteristic =  CBMutableCharacteristic(type: self.characteristicUUID, properties: .read, value: data, permissions: .readable)
        }
    }
    
    
    func notifyValueAction(_ dx:Int, _ dy:Int) {
        
        let dxStr = String(dx)
        let dyStr = String(dy)
        
        let notifyStr =  "\(dxStr) \(dyStr)" //self.textFiled.stringValue
        
        let data = notifyStr.data(using:String.Encoding.utf8)
        
        let didSendValue = self.peripheralManager?.updateValue(data!, for: self.characteristic!, onSubscribedCentrals: nil)
        
        
        if (didSendValue != nil) {
            print("notify ok!")
        }
    }
    
    func publishService() {
        self.peripheralManager?.remove(self.service)
        self.peripheralManager?.add(self.service)
    }
    
    func advertiseService() {
        var advertisementData: [String: Any] = [ CBAdvertisementDataServiceUUIDsKey: serviceUUIDs ]
        advertisementData[CBAdvertisementDataLocalNameKey] = "RadioChannel"
        self.peripheralManager?.startAdvertising(advertisementData)
    }
}



extension AppDelegate: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var stateDesc: String = "Bluetooth State Unknown"
        switch peripheral.state {
        case .unauthorized:
            stateDesc = "The platform/hardware doesn't support Bluetooth Low Energy"
            break
        case .unsupported:
            stateDesc = "The app is not authorized to use Bluetooth Low Energy"
            break
        case .poweredOff:
            stateDesc = "Bluetooth is currently powered off"
            break
        case .poweredOn:
            stateDesc = "Bluetooth is currently powered on"
            self.publishService()
            break
        default: break
            
        }
        print("\(stateDesc)")
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard error == nil else {
            print("Error didAddService: \(error!.localizedDescription)")
            return
        }
        self.advertiseService()
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        guard error == nil else {
            print("Error startAdvertising: \(error!.localizedDescription)")
            return
        }
        print("peripheralManager did advertising !")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        if request.characteristic.uuid != self.characteristic?.uuid {
            return
        }
        print("didReceiveReadRequest\(peripheral)")
        
        if request.offset > (self.characteristic?.value?.count)! {
            peripheral.respond(to: request, withResult: .invalidAttributeValueLength)
            return
        }
        
        let start = request.offset
        let end = (self.characteristic?.value!.count)! - request.offset
        let range = Range(start...end)
        
        request.value = self.characteristic?.value?.subdata(in: range)
        peripheral.respond(to: request, withResult: .success)
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        let request = requests[0]
        if request.characteristic.uuid != self.characteristic?.uuid {
            return
        }
        
        self.characteristic?.value = request.value
        
        peripheral.respond(to: request, withResult: .success)
        
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        let data = "Update Data".data(using: String.Encoding.utf8)
        let didSendValue = peripheral.updateValue(data!, for: self.characteristic!, onSubscribedCentrals: nil)
        if didSendValue {
            print("didSubscribeToCharacteristic");
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
    
    
}





