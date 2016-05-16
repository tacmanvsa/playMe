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
    var buttonText : String
}


class IntroViewController: UIViewController {
    
    private static var text = [
        pages(header: "Test reakčných\nschopností", text: "Otestuj svoje reakcie, aby sme ti mohli zabezpečiť ešte lepšie šoférovanie!", buttonText: "Poďme na to!"),
        pages(header: "Test ospalosti", text: "Prezraď nám viac o tvojej ospalosti a zabezpečíme Ti bezpečnú jazdu!", buttonText: "Do toho!"),
        pages(header: "Monitorovanie pulzu", text: "Pozorujeme tvoj pulz v reálnom čase, aby sme dokázali reagovať na stratu tvojej bdelosti!",buttonText: "Zajazdime si bezpečne!")
    ];

    // Outlets
    @IBOutlet var textHeader: UILabel!
    @IBOutlet var textArea: UITextView!
    @IBOutlet var pageCtrl: UIPageControl!
    @IBOutlet var buttonTxt: UIButton!
    
    
    // Action
    @IBAction func changeScreen(sender: AnyObject) {
        textArea.text = IntroViewController.text[pageCtrl.currentPage].text;
        textHeader.text = IntroViewController.text[pageCtrl.currentPage].header;
        buttonTxt.setTitle(IntroViewController.text[pageCtrl.currentPage].buttonText, forState: .Normal);
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonTxt.layer.cornerRadius = 5;
        textArea.editable = false;
        textArea.userInteractionEnabled = false;
        
        textArea.text = IntroViewController.text[pageCtrl.currentPage].text;
        textHeader.text = IntroViewController.text[pageCtrl.currentPage].header;
        buttonTxt.setTitle(IntroViewController.text[pageCtrl.currentPage].buttonText, forState: .Normal);
        
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
