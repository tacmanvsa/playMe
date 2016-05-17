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

    private static var player : AVAudioPlayer = AVAudioPlayer();
    
    
    internal func getAudioPlayer() -> AVAudioPlayer {
//        if(AudioPlayer.player == nil) {
//            AudioPlayer.player = AVAudioPlayer();
//        }
        print("is playing", AudioPlayer.player.playing);
        return AudioPlayer.player;
    }
    
    internal func setAudioPlayer(p : AVAudioPlayer) {
        AudioPlayer.player = p;
    }
    
}