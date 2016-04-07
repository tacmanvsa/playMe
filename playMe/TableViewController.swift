//
//  TableViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 16/12/15.
//  Copyright © 2015 Szabolcs Tacman. All rights reserved.
//

import UIKit
import CoreBluetooth

class TableViewController: UITableViewController {
    
    var bleHandler : BLEHandler?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleHandler = BLEHandler();
        bleHandler?.isCentralManagerOn();
        
        print("viewdidload of tableview");
        // notifications when we found devices, these devices are then represented in the tableview
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshList:", name:"refreshMyTableView", object: nil);
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var deviceName = "";

    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (bleHandler!.nameOfDevices.count)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomCell
        
        // Configure the cell...
        //cell.imageDevice.image = UIImage(named: "heartrate.png")
        cell.labelDevice.text = bleHandler!.nameOfDevices[indexPath.row] as String;
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        deviceName = bleHandler!.nameOfDevices[indexPath.row] as String;
        BLEHandler.choosenDevice = deviceName;
        
        let bpmVc: ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BpmVc") as! ViewController;
        
        print(deviceName);
        bpmVc.controllerTitle = deviceName;
     
        self.presentViewController(bpmVc, animated: true, completion: nil);
    }
    
    func refreshList(notification: NSNotification){
        tableView.reloadData();
    }

}
