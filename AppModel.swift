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
        AppModel.quizIndex = avg;
    }
    
}