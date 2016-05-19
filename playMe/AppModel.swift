//
//  AppModel.swift
//  playMe
//
//  Created by Szabolcs Tacman on 07/04/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import Foundation
import AVFoundation

// Class created to manage global variables
class AppModel {
    
    // points gained from tests(reaction time and slepiness tests)
    private static var avgRt : Int = Int();
    private static var sssPoint : Int = Int();
    private static var epsPoint = [Int]();
    
    // penalization calculated from reaction time test and sleepiness tests
    private static var penalization : Int = 0;
    
    // firstAvg variable which indicates the first heart rate frequency analysis
    private static var firstAvg : Bool = true;
    
    // actual state of the user
    private static var userState : Int = -1;
    
    // variables for audio player
    private static var songsUrlELow = [MusicSongs]();
    private static var songsUrlLow = [MusicSongs]();
    private static var songsUrlMid = [MusicSongs]();
    private static var songsUrlHigh = [MusicSongs]();
    private static var songIndex : Int = 0;

    /*
                    ** Audio Player variables getters and setters **
    */
    
    //  ELow
    internal func addSongELow(song: MusicSongs) {
        AppModel.songsUrlELow.append(song);
    }
    
    internal func getSongELowByIndex(index: Int) -> MusicSongs {
        return AppModel.songsUrlELow[index];
    }
    
    internal func getSongELowSize() -> Int {
        return AppModel.songsUrlELow.count;
    }
    
    //  Low
    internal func addSongLow(song: MusicSongs) {
        AppModel.songsUrlLow.append(song);
    }
    
    internal func getSongLowByIndex(index: Int) -> MusicSongs {
        return AppModel.songsUrlLow[index];
    }
    
    internal func getSongLowSize() -> Int {
        return AppModel.songsUrlLow.count;
    }
    
    //  Mid
    internal func addSongMid(song: MusicSongs) {
        AppModel.songsUrlMid.append(song);
    }
    
    internal func getSongMidByIndex(index: Int) -> MusicSongs {
        return AppModel.songsUrlMid[index];
    }
    
    internal func getSongMidSize() -> Int {
        return AppModel.songsUrlMid.count;
    }
    
    //  High
    internal func addSongHigh(song: MusicSongs) {
        AppModel.songsUrlHigh.append(song);
    }
    
    internal func getSongHighByIndex(index: Int) -> MusicSongs {
        return AppModel.songsUrlHigh[index];
    }
    
    internal func getSongHighSize() -> Int {
        return AppModel.songsUrlHigh.count;
    }
    
    // Index
    internal func getSongIndex() -> Int {
        return AppModel.songIndex;
    }
    
    internal func setSongIndex(index: Int) {
        AppModel.songIndex = index;
    }
    
    
    /*
                    ** Test variables getters and setters **
    */
    
    internal func getFirstAvg() -> Bool {
        return AppModel.firstAvg;
    }
    
    internal func setFirstAvg(bool: Bool) {
        AppModel.firstAvg = bool;
    }
        
    internal func getUserState() -> Int {
        return AppModel.userState;
    }
    
    internal func setUserState(state: Int) {
        AppModel.userState = state;
    }
    
    internal func getAvgRt() -> Int {
        return AppModel.avgRt;
    }
    
    internal func setAvgRt(avg : Int) {
        AppModel.avgRt = avg;
    }
    
    internal func getSSSIndex() ->  Int {
        return AppModel.sssPoint;
    }
    
    internal func setSSSIndex(point : Int) {
        AppModel.sssPoint = point;
    }
   
    internal func pushESSIndex(point: Int) {
        AppModel.epsPoint.append(point);
    }
    
    internal func getESSIndex() -> Int {
        var points : Int = 0;
        for point in AppModel.epsPoint {
            points += point;
        }
        return points;
    }
    
    
    /*
                    ** Calculate penalization and getter **
    */
    
    internal func calculatePenalization() {
        if(AppModel.avgRt >= 400) {
            AppModel.penalization += 2;
        }
    
        switch(AppModel.sssPoint) {
        case 1, 2:
            break;
        case 3:
            AppModel.penalization += 5;
            break;
        case 4,5:
            AppModel.penalization += 10;
            break;
        default:
            AppModel.penalization += 20;
            break;
        }
        
        
        switch(getESSIndex()) {
        case (0...10):
            break;
        case (11...14):
            AppModel.penalization += 5;
            break;
        case (15...17):
            AppModel.penalization += 10;
            break;
        case (18...24):
            AppModel.penalization += 20;
            break;
        default:
            break;
        }
        
    }
    
    internal func getPenalization() -> Int {
        return AppModel.penalization;
    }
    
}