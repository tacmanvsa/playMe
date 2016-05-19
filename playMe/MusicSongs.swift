//
//  MusicSongs.swift
//  playMe
//
//  Created by Szabolcs Tacman on 20/02/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import UIKit

class MusicSongs {
    var songUrl: String = "";
    var songType: String = "";
    var songBpm: Float = 0;
    var category: String?
    
    init(songUrl : String, songType : String, songBpm : Float) {
        self.songUrl = songUrl;
        self.songType = songType;
        self.songBpm = songBpm;
        self.category = addCategory(self.songBpm);
    }
    
    func addCategory(bpm : Float) -> String {
    
        if(bpm < 70) {
            return "ELow";
        } else if(bpm >= 70 && bpm < 100) {
            return "Low";
        } else if(bpm >= 100 && bpm < 140) {
            return "Mid";
        } else {
            return "High";
        }
    }
    
}