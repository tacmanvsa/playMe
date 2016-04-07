//
//  QuizViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 21/02/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import UIKit


struct Question {
    var question : String
    var answers : [String]
    var answer : Int
    var last : Bool
}


class QuizViewController: UIViewController {
    
    // Data model
    var appModel : AppModel = AppModel();
    
    // Questions
    var Questions = [Question]();
    var answers = [Int]();
    var questionIndex = 0;
    
    
    // Outlets
    @IBOutlet var quizLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var nextButton: UIButton!
    
    
    // Button actions
    @IBAction func firstOption(sender: AnyObject) {
        answers.append(0);
        
        if( questionIndex < Questions.count ) {
            updateQuestion();
        } else {
            print("end of quiz");
            print("answers\(answers)");
            endOfQuiz();

        }
    }
    
    @IBAction func secondOption(sender: AnyObject) {
        answers.append(1);
        
        if( questionIndex < Questions.count ) {
            updateQuestion();
        } else {
            print("end of quiz");
            print("answers\(answers)");
            endOfQuiz();

        }
    }
    
    
    @IBAction func thirdOption(sender: AnyObject) {
        answers.append(2);
        
        if( questionIndex < Questions.count ) {
            updateQuestion();
        } else {
            print("end of quiz");
            print("answers\(answers)");
            endOfQuiz();

        }
    }
    
    @IBAction func fourthOption(sender: AnyObject) {
        answers.append(3);
        
        if( questionIndex < Questions.count ) {
            updateQuestion();
        } else {
            print("end of quiz");
            print("answers\(answers)");
            endOfQuiz();
        }
    }
    
    // Next button
    @IBAction func nextView(sender: AnyObject) {
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // not visible nxt button
        nextButton.hidden = true;
        
        // 1 question
        Questions.append(Question(question: "Ako sa mas?", answers: ["Dobre", "Zle", "Napicu", "Nechaj ma"], answer: 0, last: false));
        // 2 question
        Questions.append(Question(question: "Sex?", answers: ["Ano", "Nie", "Lol", "Nechaj ma"], answer: 1, last: true));
        
        updateQuestion();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // function for picking a question and updating the view
    func updateQuestion() {
        
        print(Questions[0]);
        quizLabel.text = Questions[questionIndex].question;
        
        for i in 0 ..< buttons.count {
            buttons[i].setTitle(Questions[questionIndex].answers[i], forState: UIControlState.Normal);
        }
        questionIndex += 1;
    }
    
    // function disable buttons
    func endOfQuiz() {
        for i in 0 ..< buttons.count {
            buttons[i].enabled = false;
        }
        
        nextButton.hidden = false;
        quizLabel.text = "Tap next to continue!";
        quizLabel.textColor = UIColor.redColor();
        
    }
    
}
