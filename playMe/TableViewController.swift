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
    
    // variable of type BLEHandler, used to scan for peripherals to connect
    var bleHandler : BLEHandler?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        super.viewDidAppear(true);
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        
        self.tableView.backgroundColor = UIColor(red: 31, green: 33, blue: 36);
        
        bleHandler = BLEHandler();
        
        // scanning for peripherals
        bleHandler?.isCentralManagerOn();
        
        // capture notification sended, when device/s has been found
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableViewController.refreshList(_:)), name:"refreshMyTableView", object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var deviceName = "";

    /*
                        ** UITableView functions **
    */

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
        cell.labelDevice.textColor = UIColor.whiteColor();
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        deviceName = bleHandler!.nameOfDevices[indexPath.row] as String;
        BLEHandler.choosenDevice = deviceName;
        
        let bpmVc: ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BpmVc") as! ViewController;
        
        bpmVc.controllerTitle = deviceName;
     
        self.presentViewController(bpmVc, animated: true, completion: nil);
    }
    
    // Reloading the tableview after the captured notification of new devices
    func refreshList(notification: NSNotification){
        tableView.reloadData();
    }

}
