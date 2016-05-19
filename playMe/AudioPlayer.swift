//
//  AudioPlayer.swift
//  playMe
//
//  Created by Szabolcs Tacman on 23/03/16.
//  Copyright © 2016 Szabolcs Tacman. All rights reserved.
//

import Foundation
import AVFoundation

// Class manages the player variable and don't allow to create more then 1 in the application
class AudioPlayer {

    private static var player : AVAudioPlayer = AVAudioPlayer();
    
    
    internal func getAudioPlayer() -> AVAudioPlayer {
        return AudioPlayer.player;
    }
    
    internal func setAudioPlayer(p : AVAudioPlayer) {
        AudioPlayer.player = p;
    }
    
}