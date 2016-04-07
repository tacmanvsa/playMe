//
//  AudioPlayer.swift
//  playMe
//
//  Created by Szabolcs Tacman on 23/03/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {

    private static var player : AVAudioPlayer?;
    
    
    internal static func getAudioPlayer() -> AVAudioPlayer {
        if(player == nil) {
            player = AVAudioPlayer();
        }
        
        return player!;
    }
    
}