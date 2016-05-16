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
    private static var sssPoint : Int = Int();
    private static var epsPoint = [Int]();
    private static var penalization : Int = 0;
    private static var firstAvg : Bool = true;
    
    internal func getFirstAvg() -> Bool {
        return AppModel.firstAvg;
    }
    
    internal func setFirstAvg(bool: Bool) {
        AppModel.firstAvg = bool;
    }
    
    internal func getAvgRt() -> Int {
        return AppModel.avgRt;
    }
    
    internal func setAvgRt(avg : Int) {
        AppModel.avgRt = avg;
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
    
    internal func getESSIndex() -> Int {
        var points : Int = 0;
        for point in AppModel.epsPoint {
            points += point;
        }
        return points;
    }
    
    internal func calculatePenalization() {
        if(AppModel.avgRt >= 400) {
            print("AVG rt", AppModel.avgRt);
            AppModel.penalization += AppModel.penalization + 2;
            print("penalization", AppModel.penalization);
        }
    
        switch(AppModel.sssPoint) {
        case 1, 2:
            print("sss 1-2 : 0");
            break;
        case 3:
            print("sss 3 : 5");
            AppModel.penalization += AppModel.penalization + 5;
            break;
        case 4,5:
            print("sss 4-5 : 10");
            AppModel.penalization += AppModel.penalization + 10;
        default:
            print("sss def > 5 : 20");
            AppModel.penalization += AppModel.penalization + 20;
        }
        
        print("ess index", getESSIndex());
        switch(getESSIndex()) {
        case (0...10):
            print("ess 0-10 : 0");
            break;
        case (11...14):
            print("ess 11-14 : 5");
            AppModel.penalization += AppModel.penalization + 5;
        case (15...17):
            print("ess 15-17 : 10");
            AppModel.penalization += AppModel.penalization + 10;
        case (18...24):
            print("sss 18-24 : 20");
            AppModel.penalization += AppModel.penalization + 20;
        default:
            break;
        }
        
    }
    
    internal func getPenalization() -> Int {
        return AppModel.penalization;
    }
    
}