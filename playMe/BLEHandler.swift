//
//  BLEHandler.swift
//  playMe
//
//  Created by Szabolcs Tacman on 16/03/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit


// SPRAV SINGLETON - TREBA PRIVATE KONSTRUKTOR
class BLEHandler : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var nameOfDevices = Array<NSString>();
    static var choosenDevice : NSString?;
    private static var globalBpm : Int?;
    
    private let HeartRateService = CBUUID(string: "180D"); // UUID for the heart rate service devices
    private let HeartRateMeasurement = CBUUID(string: "2A37"); // UUID for the data packeges from the heart rate
    
    private static var centralManager : CBCentralManager!; // Used to manage the discovered sensors
    private static var mioLinkPeripheral : CBPeripheral! // Used to access the peripherals services
    
    override init() {
        super.init();
    }
    
    internal func getCentralManager() -> CBCentralManager {
        return BLEHandler.centralManager;
    }
    
    internal func getMioLinkPeripheral() -> CBPeripheral {
        return BLEHandler.mioLinkPeripheral;
    }
    
    // We are looking for all devices, that are in our area
    internal func isCentralManagerOn() {
        BLEHandler.choosenDevice = nil;
        BLEHandler.centralManager = CBCentralManager(delegate: self, queue: nil);
    }
    
    // We connect to the choosen preipheral, and we send datas to the ViewController
    internal func connectToPeripheral() {
        BLEHandler.centralManager.connectPeripheral(BLEHandler.mioLinkPeripheral, options: nil);
    }
    
    // if the state of our CentralManager is on then we are looking for peripherals to connect
    func centralManagerDidUpdateState(central: CBCentralManager) {
        central.scanForPeripheralsWithServices(nil, options: nil);    }
    
    
    // We scan for peripheral devices, the user can choose
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        let nameOfDevice = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString;
        print(nameOfDevice);
        if(( nameOfDevice ) != nil && BLEHandler.choosenDevice == nil) {
            if( !nameOfDevices.contains(nameOfDevice!)) {
                print(nameOfDevice);
                print("je nil?", BLEHandler.choosenDevice);
                nameOfDevices.append(nameOfDevice!)
            }
            BLEHandler.centralManager.stopScan();
            BLEHandler.mioLinkPeripheral = peripheral;
            BLEHandler.mioLinkPeripheral.delegate = self;
            
            // notification for TableView, where we present founded devices
            NSNotificationCenter.defaultCenter().postNotificationName("refreshMyTableView", object: nil);
        }
        
    }

    
    // After discovering the peripheral device
    // In this function is called a method, which is looking for datas from the peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Discovering peripheral services");
        BLEHandler.mioLinkPeripheral.discoverServices(nil);
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Looking at peripheral services");
        for services in peripheral.services! {
            let thisService = services as CBService;
            if services.UUID == HeartRateService {
                peripheral.discoverCharacteristics(nil, forService: thisService);
            }
        }
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("enabling sensors");
        
        var enableValue = 1;
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8));
        
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic;
            if( thisCharacteristic.UUID == HeartRateMeasurement ) {
                BLEHandler.mioLinkPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic);
                BLEHandler.mioLinkPeripheral.writeValue(enablyBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse);
            }
        }
    }

    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if( characteristic.UUID == HeartRateMeasurement ) {
            
            let data = characteristic.value;
            let reportData = UnsafePointer<UInt8>(data!.bytes);
            var bpm : UInt16;
            if (reportData[0] & 0x01) == 0 {
                bpm = UInt16(reportData[1]);
            } else {
                bpm = UnsafePointer<UInt16>(reportData + 1)[0];
                bpm = CFSwapInt16LittleToHost(bpm);
            }
            
            // sending actual bpm to the ViewController
            NSNotificationCenter.defaultCenter().postNotificationName("bpm", object: nil, userInfo: ["data": Int(bpm)]);

        }
    }

    
}