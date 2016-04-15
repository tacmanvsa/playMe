//
//  ViewController.swift
//  playMe
//
//  Created by Szabolcs Tacman on 21/11/15.
//  Copyright © 2015 Szabolcs Tacman. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreData

// Dorob funkciu na pocitanie primeru
// Najprv zober priemer 5 sekund, potom minutu

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    private static var player : AVAudioPlayer?;
    private static var songsUrl = [MusicSongs]();
    
    private static let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate);
    private static let context:NSManagedObjectContext = ViewController.appDelegate.managedObjectContext;
    
    // BPM counter
    private static let detector : BPMDetector = BPMDetector.init();
    
    var avgPulseMin = [Int]();
    var pulse = [Int]();
    
    
    var bleHandler : BLEHandler?;
    
    /*
    
    *** Media collections ***
    
    */
    
    var mediaCollection1 = [];
    var mediaCollection2 = [];
    var mediaCollection3 = [];
    
    
    var mediaItems : [MPMediaItem] = MPMediaQuery.songsQuery().items!;
    var mediaCollection : MPMediaItemCollection?
    
    var index = 0;
    

    
    
    
    /*
    
    *** All music songs on the used iPhone ***
    
    */
    
    
    
    
    /*
    
    *** Outlets ***
    
    */
    
    
    @IBOutlet var navigationTitle: UINavigationItem!; // The navigation bar title - which is the label of the choosen device
    @IBOutlet var heartRateLabel: UILabel!; // Label in the navigation tab for the heart rate
    
    @IBOutlet var songImage: UIImageView!;
    
    @IBOutlet var songLabel: UILabel!;
    
    @IBOutlet var playButton: UIBarButtonItem!;
    
    @IBOutlet var toolbar: UIToolbar!;
    
    
    /*
    
    *** Music player destroy ***
    
    */
    
    
    
    
    
    /*
    
    *** Music player actions ***
    
    */
    
    
    @IBAction func rewindMusic(sender: AnyObject) {
        print("index \(index)");
        if( index == 0 ) { index = ViewController.songsUrl.count - 1; }
        else { index -= 1; }
        
        do {
            try ViewController.player = AVAudioPlayer.init(contentsOfURL: returnUrlOfActualItem(index));
            ViewController.player!.delegate = self;
            ViewController.player!.play();
        } catch {
            print("rewindMusic error");
        }
    }
    
    
    @IBAction func fastForwardMusic(sender: AnyObject) {
        if( index == ViewController.songsUrl.count - 1 ) { index = 0; }
        else { index += 1; }
        
        do {
            try ViewController.player = AVAudioPlayer.init(contentsOfURL: returnUrlOfActualItem(index));
            ViewController.player!.delegate = self;
            ViewController.player!.play();
        } catch {
            print("rewindMusic error");
        }
    }
    
    
    @IBAction func playAndPauseMusic(sender: AnyObject) {
        let request = NSFetchRequest(entityName: "Songs");
        request.returnsObjectsAsFaults = false;
        
        do {
            let results:NSArray = try ViewController.context.executeFetchRequest(request);
            if(results.count > 0) {
                print("kolko", results.count);
                for res in results {
                    print(res);
                }
            }
            
        } catch {
            print("RESULT ERROR");
        }
        
        if( ViewController.player!.playing ) {
            ViewController.player!.delegate = self;
            ViewController.player!.pause();
            
            getInformation();
            
            playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: #selector(ViewController.playAndPauseMusic(_:)));
            
            toolbar.items![1] = playButton; //apply for first toolbar item
        } else {
            ViewController.player!.delegate = self;
            ViewController.player!.play();
            
            playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: #selector(ViewController.playAndPauseMusic(_:)));
            
            toolbar.items![1] = playButton; //apply for first toolbar item

        }
    }
    
    
    
    
    
    
    /*
    
    *** Segue varuable for view title ***
    
    */
    
    // Segue variable
    var controllerTitle = "";
    
    
    
    /*
    
    *** The player variable ***
    
    */
    
    
    // Player variable
    
//    var player = MPMusicPlayerController.applicationMusicPlayer();
//    var player = AudioPlayer.getAudioPlayer();
    
    
    
    /*
    
    *** Default "view did load" functions ***
    
    */
    
    // The view loads
    override func viewDidLoad() {
        // Initializing the centralManager

        
        super.viewDidLoad();
//        bleHandler = BLEHandler();
        
        navigationTitle.title = BLEHandler.choosenDevice as? String;
        bleHandler?.connectToPeripheral();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "computeAvgBpm:", name: "bpm", object: nil);
        
        if((ViewController.player?.playing) != nil) {
            print("YES ITS PLAYING");
        } else {
            ViewController.player = AudioPlayer.getAudioPlayer();
        
        
        
            // get Notifications
//            let detector : BPMDetector = BPMDetector.init();
            var avItems = [AVPlayerItem]();
        
            let resourcePath : NSString = NSBundle.mainBundle().resourcePath!
            let documentsPath : NSString = resourcePath.stringByAppendingPathComponent("Music");
        
            let fm = NSFileManager.defaultManager()
            do {
                let items = try fm.contentsOfDirectoryAtPath(documentsPath as String)
                for item in items {
                
                    var itemArr = item.componentsSeparatedByString(".");
                
                    let path : NSURL = NSBundle.mainBundle().URLForResource("Music/\(itemArr[0])", withExtension: itemArr[1])!;
                
                    avItems.append(AVPlayerItem.init(URL: path));
                
                    ViewController.songsUrl.append(MusicSongs(songUrl: itemArr[0], songType: itemArr[1]));

                    insertSongIfNotExists(itemArr[0], path: path);
                }
            } catch {
                // failed to read directory – bad permissions, perhaps?
            }
        
        
            do {
                try ViewController.player = AVAudioPlayer(contentsOfURL: returnUrlOfActualItem(index));
                ViewController.player!.delegate = self;
                ViewController.player!.play();
            } catch {
                print("Audio player nefunguje");
            }
        
        }
//        deleteSongs();
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    
    *** Functions ***
    
    */
    
    // Notifications of current bpm
    func computeAvgBpm(notifications: NSNotification) {
        let userInfo:Dictionary<String,Int!> = notifications.userInfo as! Dictionary<String,Int!>;
        let bpm = userInfo["data"];

        if let strBpm = bpm {
            heartRateLabel.text = "\(strBpm)";
        }
        
        if(pulse.count  >= 60) {
            let pulseArray = pulse;
            pulse.removeAll();
            calcAvgPulse(pulseArray);
        }
        
        pulse.append(bpm!);
        
        print("notification", bpm);
    }
    
    
    // calculate avg bpm from 1 minute bpm datas
    func calcAvgPulse(pulseArray : [Int]) {
        var sum = 0;
        for i in 0 ..< pulseArray.count {
            sum += pulseArray[i];
        }
        print("sum ", sum);
        print("avg ", sum/pulseArray.count);
        avgPulseMin.append(sum/pulseArray.count);
    }
    
    
    // Function to load all songs from a given directory    
    func contentsOfDirectoryAtPath(path: String) -> (filenames: [String]?, error: NSError?) {
        let fileManager = NSFileManager.defaultManager();
        do {
            let contents = try fileManager.contentsOfDirectoryAtPath(path);
            let filenames = contents as [String];
            return (filenames, nil);
        } catch {
            print("nejaky error");
            return (nil, error as NSError);
        }
        
    }
    
    
    // Is the queeplayer playing
    func isPlaying() -> Bool {
        return ViewController.player!.rate > 0;
    }
    
    
    // Returns the url of actual played song
    func returnUrlOfActualItem(index: Int) -> NSURL {
        let url : NSURL = NSBundle.mainBundle().URLForResource("Music/\(ViewController.songsUrl[index].songUrl)", withExtension: ViewController.songsUrl[index].songType)!;
        print(url);
        return url;
    }
    
    
    // Meta data about current song
    func getInformation() -> String {
        let url = ViewController.player!.url;
        let urlAsset = AVURLAsset.init(URL: url!);
        let metadata = urlAsset.commonMetadata
        let currentSongTitle = AVMetadataItem.metadataItemsFromArray(metadata, filteredByIdentifier: AVMetadataCommonIdentifierTitle);
        let currentSongArtist = AVMetadataItem.metadataItemsFromArray(metadata, filteredByIdentifier: AVMetadataCommonIdentifierArtist);
        
//        print("\(currentSongArtist): \(currentSongTitle)");
        
        return "\(currentSongArtist): \(currentSongTitle)";
    }
    
    
    // If the nowplaying song is changed, this function is called, which updates the label
    func nowPlayingItemChanged() {
        print("changed");
//        songLabel.text = (player.nowPlayingItem?.artist)! + ": " + (player.nowPlayingItem?.title)!;
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        fastForwardMusic(UIBarButtonItem);
    }

    
    /*
                *** CORE DATA FUNKCTIONS ***
    */
    
    func deleteSongs() {
        let coord = ViewController.appDelegate.persistentStoreCoordinator;
        
        let fetchRequest = NSFetchRequest(entityName: "Songs");
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest);
        
        do {
            try coord.executeRequest(deleteRequest, withContext: ViewController.context);
        } catch let error as NSError {
            debugPrint(error);
        }
    }
    
    // IDENTIFIKUJE NOVEHO, TREBA HO UZ LEN PRIDAT A VYRATAT BPM
    func insertSongIfNotExists(songName : String, path : NSURL) {
        var newSong : Bool = true;
        
        let request = NSFetchRequest(entityName: "Songs");
        request.returnsObjectsAsFaults = false;
        
        do {
            let results:NSArray = try ViewController.context.executeFetchRequest(request);
            if(results.count > 0) {
                print("kolko", results.count);
                for res in results {
                    if( songName == res.valueForKey("song_name") as! String ) {
                        newSong = false;
                    }
                }
            }
            
        } catch {
            print("RESULT ERROR");
        }
        
        if(newSong) {
            print("ano nerovnaju sa", songName);
        }
    }
    
}

