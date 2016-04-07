//
//  TouchViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 06/03/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import UIKit
//import FontAwesome_swift

// UIColor extension
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}


class TouchViewController: UIViewController {
    

    // Variables
    var time : NSTimeInterval = 0; // actual time for reaction
    var timeArray: [NSTimeInterval] = []; // array of reaction times
    var startTime : NSTimeInterval = 0; // is used to calculate the raction time(actual time - startTime)
    var prepared : Bool = false; // control headings and background color
    var loopCnt : Int = 0; // counting the number of loops
    var waitingForGreen : Bool = false; // Check if the user touched the screen before green screen
    var penalty : Int = 0;
    
    
    // Outlets
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var logoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        nextButton.hidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // function returning random number between 2 and 6
    func grabRandomTime() -> Int{
        let time = Int(arc4random_uniform(UInt32(6)+2));
        return time;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.prepared = !self.prepared;
        self.view.backgroundColor = UIColor(red: 206, green: 38, blue: 54);
        
        if(loopCnt <= 5) {
            
            if(self.prepared) {
                loopCnt += 1;
                self.time = 0.6; // if the user hits the button before green, then penalization in form of
                                 // time
                waitingForGreen = true;
//                self.logoLabel.font = UIFont.fontAwesomeOfSize(200);
//                self.logoLabel.text = String.fontAwesomeIconWithCode("fa-clock-o");
                self.timerLabel.text = "";
                self.headerLabel.text = "If the screen is green touch!";
                
                // It's something like sleep, but its not on the main thread
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(grabRandomTime()) * Int64(NSEC_PER_SEC))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        self.view.backgroundColor = UIColor.redColor();
                        
                        self.startTime = NSDate.timeIntervalSinceReferenceDate();
                
                        NSTimer.scheduledTimerWithTimeInterval(
                            0.02,
                            target: self,
                            selector: "displayTime:",
                            userInfo: nil,
                            repeats: true);
                    }
            } else {
                waitingForGreen = false;
                self.timerLabel.text = NSString(format: "%1.0f ms", self.time*1000) as String;
                self.view.backgroundColor = UIColor(red: 43, green: 135, blue: 209);
                self.headerLabel.text = "Touch to begin again!";
                timeArray.append(self.time); // append the time to array
                self.time = 0; // zero for the next loop
                self.startTime = 0; // zero for the next loop
            }
            
        } else { // after 5 tests, we count the average and we go to the next view
            var sum : Double = 0;
            for i in 0..<timeArray.count {
                print("casy: ", timeArray[i]);
                sum += timeArray[i];
            }
            print("avg", sum/Double(timeArray.count));
            print("penalty", penalty);

            nextButton.hidden = false;
        }
        
        
    }
    
    
    // function for displaying time
    func displayTime(timer: NSTimer) {
        
        if(waitingForGreen && self.prepared) {
            self.view.backgroundColor = UIColor(red: 75, green: 219, blue: 106);
        }
        
        if(!self.prepared) {
            timer.invalidate();
        } else {
            self.time = NSDate.timeIntervalSinceReferenceDate() - startTime;
        }
        
    }

}
