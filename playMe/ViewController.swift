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

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    /*
                        ** Variables **
    */
    
    // Core Model variables
    private static let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate);
    private static let context:NSManagedObjectContext = ViewController.appDelegate.managedObjectContext;
    
    // BPM counter
    private static let detector : BPMDetector = BPMDetector.init();

    var pulse = [Int]();
    var bleHandler : BLEHandler?;
    var appModel : AppModel = AppModel();
    var player : AudioPlayer = AudioPlayer();

    
    /*
    
                        *** Outlets ***
    
    */
    
    
    @IBOutlet var navigationTitle: UINavigationItem!; // The navigation bar title - which is the label of the choosen device
    @IBOutlet var heartRateLabel: UILabel!; // Label in the navigation tab for the heart rate
    @IBOutlet var songImage: UIImageView!;
    @IBOutlet var songLabel: UILabel!;
    @IBOutlet var imageControls: UIImageView!
    @IBOutlet var forwardImage: UIImageView!
    @IBOutlet var rewindImage: UIImageView!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var progressBar: UISlider!
    @IBOutlet var timerLabel: UILabel!
    
    /*
    
                    *** Music player actions ***
    
    */
    
    @IBAction func rewindMusic(sender: AnyObject) {
        if(player.getAudioPlayer().playing) {
            playMusicByIndex("back", playing: true);
        } else {
            playMusicByIndex("back", playing: false);
        }
    }
    
    
    @IBAction func fastForwardMusic(sender: AnyObject) {
        if(player.getAudioPlayer().playing) {
            playMusicByIndex("forward", playing: true);
        } else {
            playMusicByIndex("forward", playing: false);
        }
    }
    
    
    @IBAction func playAndPauseMusic(sender: AnyObject) {        
        if( player.getAudioPlayer().playing ) {
            player.getAudioPlayer().delegate = self;
            player.getAudioPlayer().pause();
            
            imageControls.image = UIImage(named: "play");
            
        } else {
            player.getAudioPlayer().delegate = self;
            player.getAudioPlayer().play();
            
            imageControls.image = UIImage(named: "pause");
        }
    }
    
    
    /*
    
                    *** Segue varuable for view title ***
    
    */
    
    var controllerTitle = "";
 
    /*
    
                    *** Default "view did load" functions ***
    
    */
    
    // The view loads
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // calculate penalization
        appModel.calculatePenalization();
        
        loadingLabel.hidden = true;
        progressBar.userInteractionEnabled = false;
        
        // define control events on player images
        
        // play image
        let imageView = imageControls;
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ViewController.playAndPauseMusic(_:)))
        imageView.userInteractionEnabled = true;
        imageView.addGestureRecognizer(tapGestureRecognizer);
        
        // forward image
        let imageView2 = forwardImage;
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(ViewController.fastForwardMusic(_:)))
        imageView2.userInteractionEnabled = true;
        imageView2.addGestureRecognizer(tapGestureRecognizer2);
        
        // rewind image
        let imageView3 = rewindImage;
        let tapGestureRecognizer3 = UITapGestureRecognizer(target:self, action:#selector(ViewController.rewindMusic(_:)))
        imageView3.userInteractionEnabled = true;
        imageView3.addGestureRecognizer(tapGestureRecognizer3);
        
        
        // Connecting to peripheral, capture the notification with actual heart rate data and call a function to deal with it
        bleHandler = BLEHandler();
        navigationTitle.title = BLEHandler.choosenDevice as? String;
        bleHandler?.connectToPeripheral();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.computeAvgBpm(_:)), name: "bpm", object: nil);

        // if it's the first heart rate analysis, then load all songs
        if(appModel.getFirstAvg()) {
            loadingLabel.hidden = false;
            
            // hide controls until first play
            imageControls.hidden = true;
            forwardImage.hidden = true;
            rewindImage.hidden = true;
            backButton.enabled = false;
            progressBar.hidden = true;
            
            let resourcePath : NSString = NSBundle.mainBundle().resourcePath!
            let documentsPath : NSString = resourcePath.stringByAppendingPathComponent("Music");
        
            let fm = NSFileManager.defaultManager()
            do {
                let items = try fm.contentsOfDirectoryAtPath(documentsPath as String)
                for item in items {
                
                    var itemArr = item.componentsSeparatedByString(".");
                
                    let path : NSURL = NSBundle.mainBundle().URLForResource("Music/\(itemArr[0])", withExtension: itemArr[1])!;
                
                    insertSongIfNotExists(itemArr[0], path: path);
                }
            } catch {
                // failed to read directory – bad permissions, perhaps?
            }
        } else {
            songLabel.text = returnSongNameOfActualItem();
            
            let displayLink = CADisplayLink(target: self, selector: (#selector(ViewController.updateSliderProgress)))
            displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        }
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
    func playMusicByIndex(type : String, playing: Bool) {
        if(type == "forward") {
            if( appModel.getSongIndex() >= returnSongsArrayCount(appModel.getUserState()) - 1 ) {
                appModel.setSongIndex(0);
            }
            else {
                appModel.setSongIndex(appModel.getSongIndex() + 1);
            }
        } else if(type == "back") {
            if( appModel.getSongIndex() == 0 ) {
                appModel.setSongIndex(returnSongsArrayCount(appModel.getUserState()) - 1);
            }
            else {
                appModel.setSongIndex(appModel.getSongIndex() - 1);
            }
        }
        
        do {
            try player.setAudioPlayer(AVAudioPlayer(contentsOfURL: returnUrlOfActualItem(appModel.getSongIndex())));
            player.getAudioPlayer().delegate = self;
            if(playing || type == "") {
                player.getAudioPlayer().play();
                
                let displayLink = CADisplayLink(target: self, selector: (#selector(ViewController.updateSliderProgress)))
                displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            };
        } catch {
            print("Audio player nefunguje");
        }
    }
    
    // updating song progress bar
    func updateSliderProgress() {
        let progress = player.getAudioPlayer().currentTime / player.getAudioPlayer().duration;
        timerLabel.text = updateTime(player.getAudioPlayer().currentTime);
        progressBar.setValue(Float(progress), animated: false);
    }
    
    // update time and return it's value in m:ss format
    func updateTime(time: NSTimeInterval) -> String {
        let current: Int = Int(time)
        let minutes = current / 60
        let seconds = abs(current) % 60
        let minutesString = "\(minutes)"
        let secondsString = String(format: "%02d", arguments: [seconds])
        
        return minutesString + ":" + secondsString
    }
    
    // return the count of song array by user state - input: type
    func returnSongsArrayCount(type : Int) -> Int {
        switch(type) {
        case 0:
            return appModel.getSongELowSize();
        case 1:
            return appModel.getSongLowSize();
        case 2:
            return appModel.getSongMidSize();
        case 3:
            return appModel.getSongHighSize();
        default:
            return 0;
        }
    }
    
    func computeAvgBpm(notifications: NSNotification) {
        let userInfo:Dictionary<String,Int!> = notifications.userInfo as! Dictionary<String,Int!>;
        let bpm = userInfo["data"];

        if let strBpm = bpm {
            heartRateLabel.text = "\(strBpm)";
        }
        
        if(appModel.getFirstAvg()) {
            if(pulse.count  >= 5) {
                let pulseArray = pulse;
                pulse.removeAll();
                calcAvgPulse(pulseArray);
                appModel.setFirstAvg(false);
            }
        } else {
            if(pulse.count  >= 240) {
                let pulseArray = pulse;
                pulse.removeAll();
                calcAvgPulse(pulseArray);
            }
        }
        
        pulse.append(bpm!);
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
        
        let avg : Int = sum/pulseArray.count - appModel.getPenalization();
        
        if(avg < 70) {
            appModel.setUserState(3);
        } else if(avg >= 70 && avg < 100) {
            appModel.setUserState(2)
        } else if(avg >= 100 && avg < 140) {
            appModel.setUserState(1);
        } else if(avg >= 140) {
            appModel.setUserState(0);
        }
        
        // if it's the first analysis play music
        if(appModel.getFirstAvg()) {
            playMusicByIndex("", playing: false);
            imageControls.hidden = false;
            forwardImage.hidden = false;
            rewindImage.hidden = false;
            loadingLabel.hidden = true;
            backButton.enabled = true;
            progressBar.hidden = false;
            
            appModel.setFirstAvg(false);
        }
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
    
    // Returns the actual song name
    func returnSongNameOfActualItem() -> String {
        var songName : String?;
        switch(appModel.getUserState()) {
        case 0:
            songName = appModel.getSongELowByIndex(appModel.getSongIndex()).songUrl;
            break;
        case 1:
            songName = appModel.getSongLowByIndex(appModel.getSongIndex()).songUrl;
            break;
        case 2:
            songName = appModel.getSongMidByIndex(appModel.getSongIndex()).songUrl;
            break;
        case 3:
            songName = appModel.getSongHighByIndex(appModel.getSongIndex()).songUrl;
            break;
        default:
            songName = ""
            break;
            
        }
        
        return songName!;
    }
    
    // Returns the url of actual played song
    func returnUrlOfActualItem(index: Int) -> NSURL {
        var url : NSURL?;
        
        switch(appModel.getUserState()) {
        case 0:
            let song = appModel.getSongELowByIndex(appModel.getSongIndex());
            url = NSBundle.mainBundle().URLForResource("Music/\(song.songUrl)", withExtension: song.songType)!;
            songLabel.text = song.songUrl;
            break;
        case 1:
            let song = appModel.getSongLowByIndex(appModel.getSongIndex());
            url = NSBundle.mainBundle().URLForResource("Music/\(song.songUrl)", withExtension: song.songType)!;
            songLabel.text = song.songUrl;
            break;
        case 2:
            let song = appModel.getSongMidByIndex(appModel.getSongIndex());
            url = NSBundle.mainBundle().URLForResource("Music/\(song.songUrl)", withExtension: song.songType)!;
            songLabel.text = song.songUrl;
            break;
        case 3:
            let song = appModel.getSongHighByIndex(appModel.getSongIndex());
            url = NSBundle.mainBundle().URLForResource("Music/\(song.songUrl)", withExtension: song.songType)!;
            songLabel.text = song.songUrl;
            break;
        default:
            url = NSBundle.mainBundle().URLForResource("Music/AdeleChasingPavements", withExtension: "mp3")!;
            break;

        }
        
        return url!;
    }
    
    
    // Meta data about current song
    func getInformation() -> String {
        let url = player.getAudioPlayer().url;
        let urlAsset = AVURLAsset.init(URL: url!);
        let metadata = urlAsset.commonMetadata
        let currentSongTitle = AVMetadataItem.metadataItemsFromArray(metadata, filteredByIdentifier: AVMetadataCommonIdentifierTitle);
        let currentSongArtist = AVMetadataItem.metadataItemsFromArray(metadata, filteredByIdentifier: AVMetadataCommonIdentifierArtist);
        
        print("\(currentSongArtist): \(currentSongTitle)");
        
        return "\(currentSongArtist[0].value): \(currentSongTitle[0].value)";
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playMusicByIndex("forward", playing: true);
    }

    
    // Core data function to delete all records from entity Songs
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
    
    // create arrays of songs ("playlists") depending on the song category
    func categorizeMusic(url: String, type: String, bpm: Float) {
        let song : MusicSongs = MusicSongs(songUrl: url, songType: type, songBpm: bpm);
        
        switch(song.category!) {
            case "ELow" :
                appModel.addSongELow(song);
                break;
            case "Low" :
                appModel.addSongLow(song);
                break;
            case "Mid":
                appModel.addSongMid(song);
                break;
            case "High":
                appModel.addSongHigh(song);
                break;
            default:
                break;
        }
    }
    
    // function adds new songs to database
    func insertSongIfNotExists(songName : String, path : NSURL) {
        var newSong : Bool = true;
        
        let request = NSFetchRequest(entityName: "Songs");
        request.returnsObjectsAsFaults = false;
        
        do {
            let results:NSArray = try ViewController.context.executeFetchRequest(request);
            if(results.count > 0) {
                for res in results {
                    if( songName == res.valueForKey("song_name") as! String ) {
                        newSong = false;
                        
                        categorizeMusic(songName, type: "mp3", bpm: res.valueForKey("bpm") as! Float);
                        
                        break;
                    }
                }
            }
            
        } catch {
            print("RESULT ERROR");
        }
        
        if(newSong) {
            let newSongBpm = ViewController.detector.getBPM(path);
            
            let newSong = NSEntityDescription.insertNewObjectForEntityForName("Songs", inManagedObjectContext: ViewController.context) as NSManagedObject;
            
            newSong.setValue(songName, forKey: "song_name");
            newSong.setValue(newSongBpm, forKey: "bpm");
            
            categorizeMusic(songName, type: "mp3", bpm: newSongBpm);
            
            do {
                try ViewController.context.save();
            } catch {
                print("Error in saving");
            }
        }
    }
    
}

