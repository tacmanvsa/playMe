//
//  StanfordSleepinessScaleViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 09/05/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import UIKit

/*
                ** Struct holding "Quiz" variables **
*/

struct Quiz {
    var question : String
    var point : Int
}

class StanfordSleepinessScaleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Outlets
    @IBOutlet var pickerView: UIPickerView!
    
    // Data model
    var appModel : AppModel = AppModel();
    
    // Data for UIPickerView of type Quiz
    private var pickerData : [Quiz] = [];
    private var selected : Quiz?;

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        
        // Adding answers
        pickerData.append(Quiz(question: "Byť aktívny, vitálny, ostražitý, pohotový", point: 1));
        pickerData.append(Quiz(question: "Fungovať na vysokej úrovni ale nie na maxime, schopnosť koncentrovať sa", point: 2));
        pickerData.append(Quiz(question: "Byť pri vedomí, ale relaxovaný; strácanie bdelosti", point: 3));
        pickerData.append(Quiz(question: "Akási popletenosť", point: 4));
        pickerData.append(Quiz(question: "Byť popletený, strácanie záujmu ostať hore/pri vedomí, byť spomalený", point: 5));
        pickerData.append(Quiz(question: "Byť ospalý, mdlý, bojovanie so spánkom", point: 6));
        pickerData.append(Quiz(question: "Už nebojuješ so spánkom, zachvílu zaspíš, myšlienky blízko sna", point: 7));
        pickerData.append(Quiz(question: "Spánok", point: 0));
        
        
        selected = pickerData[0];
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
                ** UIPickerView functions **
    */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }
    
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60;
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel(frame: CGRectMake(0, 0, 300, 44));
        label.lineBreakMode = .ByWordWrapping;
        label.textColor = UIColor.whiteColor();
        label.numberOfLines = 0;
        label.text = pickerData[row].question;
        label.textAlignment = .Center;
        
        return label;
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selected = pickerData[row];
    }
    
    // Action, we are going to the next view and before that we save the sleepiness score to AppModel variable
    @IBAction func nextView(sender: AnyObject) {
        appModel.setSSSIndex((selected?.point)!);
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
