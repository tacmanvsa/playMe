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
    var answerIndex : [Int]
}


class QuizViewController: UIViewController {
    
    // Data model
    var appModel : AppModel = AppModel();
    
    // Questions
    var Questions = [Question]();
    var answers = [Int]();
    var questionIndex = 0;
    var answerIndexCnt = 0;
    
    
    // Outlets
    @IBOutlet var quizLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var nextButton: UIButton!
    
    
    // Button actions
    @IBAction func firstOption(sender: AnyObject) {
        answers.append(0);
        answerIndexCnt += Questions[questionIndex-1].answerIndex[0];
        
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
        answerIndexCnt += Questions[questionIndex-1].answerIndex[2];
        
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
        answerIndexCnt += Questions[questionIndex-1].answerIndex[2];
        
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
        answerIndexCnt += Questions[questionIndex-1].answerIndex[3];
        
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
        appModel.setQuizIndex(answerIndexCnt);
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // not visible nxt button
        nextButton.hidden = true;
        
        // 1 question
        Questions.append(Question(question: "How many hours did you slept?", answers: ["More then 8", "7-8", "6-7", "Less then 6"], answerIndex: [4, 3, 2, 1]));
        // 2 question
        Questions.append(Question(question: "Are you tired?", answers: ["No", "Little bit", "Yes", "Nechaj ma"], answerIndex:  [4, 3, 2, 1]));
        
        updateQuestion();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // function for picking a question and updating the view
    func updateQuestion() {
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
