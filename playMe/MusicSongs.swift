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
        
        print("songBpm", songBpm);
        print("category", self.category);
    }
    
    func addCategory(bpm : Float) -> String {
    
        if(bpm < 95) {
            return "Low";
        } else if(bpm >= 95 && bpm < 130) {
            return "Mid";
        } else {
            return "High";
        }
    }
    
}