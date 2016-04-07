//
//  IntroViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 25/03/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import UIKit

struct pages {
    var header : String
    var text : String
}

class IntroViewController: UIViewController {
    
    private static var text = [
        pages(header: "Reaction time test", text: "Check your reaction time and gave us feedback to make your experience even better. Let's go!"),
        pages(header: "Quiz", text: "Give us some infos about your sleep and current mood. Let's go!"),
        pages(header: "Heart rate monitor", text: "Real time monitoring of your current mental and      psychological state. Let's go!")
    ];

    // Outlets
    @IBOutlet var textHeader: UILabel!
    @IBOutlet var textArea: UITextView!
    @IBOutlet var pageCtrl: UIPageControl!
    
    
    // Action
    @IBAction func changeScreen(sender: AnyObject) {
        textArea.text = IntroViewController.text[pageCtrl.currentPage].text;
        textHeader.text = IntroViewController.text[pageCtrl.currentPage].header;
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textArea.text = IntroViewController.text[pageCtrl.currentPage].text;
        textHeader.text = IntroViewController.text[pageCtrl.currentPage].header;
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
