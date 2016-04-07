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
    
    init(songUrl : String, songType : String/*, songBpm : Float*/) {
        self.songUrl = songUrl;
        self.songType = songType;
//        self.songBpm = songBpm;
//        print("songBpm", songBpm);
    }
}