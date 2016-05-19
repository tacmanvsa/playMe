//
//  EpworthSleepinessScaleViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 10/05/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import UIKit

class EpworthSleepinessScaleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Outlets
    @IBOutlet var situationLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    // Data model
    var appModel : AppModel = AppModel();
    
    // Data for tableview
    var situations = ["Sedenie a čítanie", "Pozeranie televízora", "Sedenie neaktívne na verejnosti(napr. divadlo alebo stretnutie)", "Cestovanie v aute ako pasažier hodinu bez prestávky", "Ľahnúť  si oddychovať poobede, keď  to okolnosti dovolia", "Sedenie a vedenie rozhovoru s niekým", "Sedenie poobede bez alkoholu", "Sedenie v zastavenom aute na pár minút kvôli premávke"];
    var options = ["0 - nulová", "1 - malá", "2 - mierna", "3 - veľká"];
    var index = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.tableView.backgroundColor = UIColor(red: 31, green: 33, blue: 36);
        
        self.situationLabel.text = situations[index];
        index += 1;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
                    ** UITableView functions **
    */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath);
        
        let bgColorView = UIView();
        bgColorView.backgroundColor = UIColor(red: 43, green: 135, blue: 209);
        cell.selectedBackgroundView = bgColorView;
        
        cell.textLabel?.textColor = UIColor.whiteColor();
        cell.textLabel?.text = options[indexPath.row];
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if is true, when are at the last situation -> we are going to the next view
        if(index == situations.count) {
            appModel.pushESSIndex(indexPath.row);
            let vc: TableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChooseYourDevice") as! TableViewController;
            
            let navController = UINavigationController(rootViewController: vc)
            self.presentViewController(navController, animated: true, completion: nil);
        } else {
            situationLabel.text = situations[index];
            appModel.pushESSIndex(indexPath.row);
            index += 1;
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
