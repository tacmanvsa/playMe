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
    
    private static var avgRt : Int = Int();
    private static var sssPoint : Int = Int();
    private static var epsPoint = [Int]();
    private static var penalization : Int = 0;
    private static var firstAvg : Bool = true;
    private static var userState : Int = -1;
    
    private static var songsUrlELow = [MusicSongs]();
    private static var songsUrlLow = [MusicSongs]();
    private static var songsUrlMid = [MusicSongs]();
    private static var songsUrlHigh = [MusicSongs]();
    private static var songIndex : Int = 0;
//    private static var player = AudioPlayer.getAudioPlayer();
    
    
    // Get audio player
    
//    internal func getPlayer() -> AVAudioPlayer {
//        return AppModel.player;
//    }
    
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
    
    
    // Getters - Setters
    
    internal func getSongIndex() -> Int {
        return AppModel.songIndex;
    }
    
    internal func setSongIndex(index: Int) {
        AppModel.songIndex = index;
    }
    
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
    
    // Penalization
    
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