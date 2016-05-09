//
//  StanfordSleepinessScaleViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 09/05/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import UIKit

struct Quiz {
    var question : String
    var point : Int
}

class StanfordSleepinessScaleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var pickerView: UIPickerView!
    
    private var pickerData : [Quiz] = [];

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        
        pickerData.append(Quiz(question: "Byť aktívny, vitálny, ostražitý, pohotový", point: 1));
        pickerData.append(Quiz(question: "Fungovať na vysokej úrovni ale nie na maxime, schopnosť koncentrovať sa", point: 2));
        pickerData.append(Quiz(question: "Byť pri vedomí, ale relaxovaný; strácanie bdelosti", point: 3));
        pickerData.append(Quiz(question: "Akási popletenosť", point: 4));
        pickerData.append(Quiz(question: "Byť popletený, strácanie záujmu ostať hore/pri vedomí, byť spomalený", point: 5));
        pickerData.append(Quiz(question: "Byť ospalý, mdlý, bojovanie so spánkom", point: 6));
        pickerData.append(Quiz(question: "Už nebojuješ so spánkom, zachvílu zaspíš, myšlienky blízko sna", point: 7));
        pickerData.append(Quiz(question: "Spánok", point: 0));
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }
    
    
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pickerData[row].question;
//    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row].question;
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        
        return myTitle;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].question;
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected row", pickerData[row].question);
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
