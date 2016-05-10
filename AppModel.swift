//
//  AppModel.swift
//  playMe
//
//  Created by Szabolcs Tacman on 07/04/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import Foundation

// Class created to manage global variables
class AppModel {
    
    private static var avgRt : Int = Int();
    private static var quizIndex : Int = Int();
    private static var sssPoint : Int = Int();
    private static var epsPoint = [Int]();
    
    internal func getAvgRt() -> Int {
        return AppModel.avgRt;
    }
    
    internal func setAvgRt(avg : Int) {
        AppModel.avgRt = avg;
    }
    
    internal func getQuizIndex() -> Int {
        return AppModel.quizIndex;
    }
    
    internal func setQuizIndex(avg : Int) {
        print("setQuiz", avg);
        AppModel.quizIndex = avg;
    }
    
    internal func getSSSIntex() ->  Int {
        return AppModel.sssPoint;
    }
    
    internal func setSSSIndex(point : Int) {
        print("set point sss", point);
        AppModel.sssPoint = point;
    }
   
    internal func pushESSIndex(point: Int) {
        print("points ESS", point);
        AppModel.epsPoint.append(point);
    }
    
}