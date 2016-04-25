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
    
    private static var state : Int?;
    private static var player : AVAudioPlayer?;
    //    private static var songsUrl = [MusicSongs]();
    private static var songsUrlELow = [MusicSongs]();
    private static var songsUrlLow = [MusicSongs]();
    private static var songsUrlMid = [MusicSongs]();
    private static var songsUrlHigh = [MusicSongs]();
    
    private static let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate);
    private static let context:NSManagedObjectContext = ViewController.appDelegate.managedObjectContext;
    
    // BPM counter
    private static let detector : BPMDetector = BPMDetector.init();
    
    var avgPulseMin = [Int]();
    var pulse = [Int]();
    var firstAvg : Bool = true;
    
    var bleHandler : BLEHandler?;
    
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
        
        playMusicByIndex("back");
    }
    
    
    @IBAction func fastForwardMusic(sender: AnyObject) {
        
        playMusicByIndex("forward");
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
        
        firstAvg = true;
        
        super.viewDidLoad();

        bleHandler = BLEHandler();
        
        navigationTitle.title = BLEHandler.choosenDevice as? String;
        bleHandler?.connectToPeripheral();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.computeAvgBpm(_:)), name: "bpm", object: nil);
        
        if((ViewController.player?.playing) != nil) {
            print("YES ITS PLAYING");
        } else {
            ViewController.player = AudioPlayer.getAudioPlayer();
        
        
        
            // get Notifications
            let detector : BPMDetector = BPMDetector.init();
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
                    
//                    print("\(itemArr[0]) : ", detector.getBPM(path));
                    
                    insertSongIfNotExists(itemArr[0], path: path);
                }
            } catch {
                // failed to read directory – bad permissions, perhaps?
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
    
    // play Music with actual index
    func playMusicByIndex(type : String) {
        if(type == "forward") {
            if( index == returnSongsArrayCount(ViewController.state!) - 1 ) { index = 0; }
            else { index += 1; }
        } else if(type == "back") {
            if( index == 0 ) { index = returnSongsArrayCount(ViewController.state!) - 1; }
            else { index -= 1; }
        }
        
        
        do {
            try ViewController.player = AVAudioPlayer(contentsOfURL: returnUrlOfActualItem(index));
            ViewController.player!.delegate = self;
            ViewController.player!.play();
            ViewController.player?.peakPowerForChannel(<#T##channelNumber: Int##Int#>)
        } catch {
            print("Audio player nefunguje");
        }
    }
    
    // return the count of song array - input: type
    func returnSongsArrayCount(type : Int) -> Int {
        switch(type) {
        case 0:
            return ViewController.songsUrlELow.count;
        case 1:
            return ViewController.songsUrlLow.count;
        case 2:
            return ViewController.songsUrlMid.count;
        case 3:
            return ViewController.songsUrlHigh.count;
        default:
            return 0;
        }
    }
    
    // Notifications of current bpm
    func computeAvgBpm(notifications: NSNotification) {
        let userInfo:Dictionary<String,Int!> = notifications.userInfo as! Dictionary<String,Int!>;
        let bpm = userInfo["data"];

        if let strBpm = bpm {
            heartRateLabel.text = "\(strBpm)";
        }
        
        if(firstAvg) {
            if(pulse.count  >= 5) {
                let pulseArray = pulse;
                pulse.removeAll();
                calcAvgPulse(pulseArray);
                firstAvg = false;
            }
        } else {
            if(pulse.count  >= 60) {
                let pulseArray = pulse;
                pulse.removeAll();
                calcAvgPulse(pulseArray);
            }
        }
        
        pulse.append(bpm!);
        
//        print("pulse count", pulse.count);
//        print("notification", bpm);
    }
    
    
    // calculate avg bpm from 4 minute bpm datas
    // ViewController state: 0 -> 0 - 59
    //                       1 -> 60 - 89
    //                       2 -> 90 - 129
    //                       3 -> 130 -
    func calcAvgPulse(pulseArray : [Int]) {
        var sum = 0;
        for i in 0 ..< pulseArray.count {
            sum += pulseArray[i];
        }
        print("sum ", sum);
        print("avg ", sum/pulseArray.count);
//        avgPulseMin.append(sum/pulseArray.count);
        let avg : Int = sum/pulseArray.count
        
        if(avg < 60) {
            ViewController.state = 0;
        } else if(avg >= 60 && avg < 90) {
            ViewController.state = 1;
        } else if(avg >= 90 && avg < 130) {
            ViewController.state = 2;
        } else if(avg >= 130) {
            ViewController.state = 3;
        }
        
        print( "\n AVG : ", avg);
        print( "\n VIEWCONTROLLER STATE : ", ViewController.state, "\n" );
        
        if(firstAvg) { playMusicByIndex("") };
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
        var url : NSURL?;
        
        switch(ViewController.state!) {
        case 0:
            url = NSBundle.mainBundle().URLForResource("Music/\(ViewController.songsUrlELow[index].songUrl)", withExtension: ViewController.songsUrlELow[index].songType)!;
            break;
        case 1:
            url = NSBundle.mainBundle().URLForResource("Music/\(ViewController.songsUrlLow[index].songUrl)", withExtension: ViewController.songsUrlLow[index].songType)!;
            break;
        case 2:
            url = NSBundle.mainBundle().URLForResource("Music/\(ViewController.songsUrlMid[index].songUrl)", withExtension: ViewController.songsUrlMid[index].songType)!;
            break;
        case 3:
            url = NSBundle.mainBundle().URLForResource("Music/\(ViewController.songsUrlHigh[index].songUrl)", withExtension: ViewController.songsUrlHigh[index].songType)!;
            break;
        default:
            url = NSBundle.mainBundle().URLForResource("Music/AdeleChasingPavements", withExtension: "mp3")!;
            break;

        }
        
//        print(url);
        return url!;
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
            print("kolko", results.count);
            if(results.count > 0) {
                for res in results {
                    if( songName == res.valueForKey("song_name") as! String ) {
                        newSong = false;
                        
                        var song : MusicSongs = MusicSongs(songUrl: songName, songType: "mp3", songBpm: res.valueForKey("bpm") as! Float);
                        
                        switch(song.category!) {
                            case "ELow" :
                                ViewController.songsUrlELow.append(song);
                                print("push this song EL", songName, res.valueForKey("bpm") as! Float);
                                break;
                            case "Low" :
                                ViewController.songsUrlLow.append(song);
                                print("push this song L", songName, res.valueForKey("bpm") as! Float);
                                break;
                            case "Mid":
                                ViewController.songsUrlMid.append(song);
                                print("push this song M", songName, res.valueForKey("bpm") as! Float);
                                break;
                            case "High":
                                ViewController.songsUrlHigh.append(song);
                                print("push this song H", songName, res.valueForKey("bpm") as! Float);
                                break;
                            default:
                                print("Error value!");
                                break;
                        }
                        
                        break;
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

