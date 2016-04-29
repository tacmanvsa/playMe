//
//  TouchViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 06/03/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import UIKit

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
    

    // Data model class
    var appModel : AppModel = AppModel();
    
    // Variables
    var time : NSTimeInterval = 0; // actual time for reaction
    var timeArray: [NSTimeInterval] = []; // array of reaction times
    var startTime : NSTimeInterval = 0; // is used to calculate the raction time(actual time - startTime)
    var prepared : Bool = false; // control headings and background color
    var loopCnt : Int = 0; // counting the number of loops
    var waitingForGreen : Bool = false; // Check if the user touched the screen before green screen
    var triesStr = String("Tries | 0 of 5");
    var avgStr = String("Average | 0ms");
    var sum : Double = 0;
    var avg : Double = 0;
    
    // Outlets
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var logoLabel: UILabel!
    @IBOutlet var avgLabel: UILabel!
    @IBOutlet var triesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        nextButton.hidden = true;
        avgLabel.text = avgStr;
        triesLabel.text = triesStr;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.prepared = !self.prepared;
        self.view.backgroundColor = UIColor(red: 206, green: 38, blue: 54);
        
        if(loopCnt < 5) {
            if(self.prepared) {
                loopCnt += 1;
                self.time = 0; // if the user hits the button before green, then set timer to null of
                               // and don't count it to average 
                waitingForGreen = true;
                self.timerLabel.text = "";
                self.headerLabel.text = "Ak je pozadie obrazovky zelená stlač displej!";
                
                // It's something like sleep, but its not on the main thread
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(grabRandomTime()) * Int64(NSEC_PER_SEC))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        self.startTime = NSDate.timeIntervalSinceReferenceDate();
                        NSTimer.scheduledTimerWithTimeInterval(
                            0.02,
                            target: self,
                            selector: #selector(TouchViewController.displayTime(_:)),
                            userInfo: nil,
                            repeats: true);
                    }
            } else {
                waitingForGreen = false;
                if(self.time * 1000 == 0) {
                    self.timerLabel.numberOfLines = 0;
                    self.timerLabel.text = "UPS! Počkaj na zelenú obrazovku!";
                } else {
                    self.timerLabel.text = NSString(format: "%1.0f ms", self.time*1000) as String;
                }
                self.view.backgroundColor = UIColor(red: 43, green: 135, blue: 209);
                self.headerLabel.text = "Stlač obrazovku pre ďalšie meranie!";
                timeArray.append(self.time); // append the time to array
                self.time = 0; // zero for the next loop
                self.startTime = 0; // zero for the next loop
                
                // set the Avg
                avgStr = "Priemer | " + countAverage();
                avgLabel.text = avgStr;
                
                // set the Tries
                triesStr = "Pokusy | " + String(loopCnt) + " z 5";
                triesLabel.text = triesStr;
            }
        } else { // after 5 tests, we can go to the next view
            triesStr = "Pokusy | 5 z 5";
            triesLabel.text = triesStr;
            self.timerLabel.text = NSString(format: "%1.0f ms", self.time*1000) as String;
            
            appModel.setAvgRt(Int(avg));
            nextButton.hidden = false;
        }
    }
    
    // function returning random number between 2 and 6
    func grabRandomTime() -> Int{
        let time = Int(arc4random_uniform(UInt32(6)+2));
        return time;
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
    
    // function for average counting
    func countAverage() -> String {
        if(timeArray.last != 0.0) {
            sum += timeArray.last!;
            
            avg = (sum/Double(loopCnt))*1000;
            return NSString(format: "%1.0fms", avg) as String;
        } else {
            loopCnt -= 1;
            return NSString(format: "%1.0fms", avg) as String;
        }
    }

}
