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
    private static var songsUrlELow = [MusicSongs]();
    private static var songsUrlLow = [MusicSongs]();
    private static var songsUrlMid = [MusicSongs]();
    private static var songsUrlHigh = [MusicSongs]();
    private static let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate);
    private static let context:NSManagedObjectContext = ViewController.appDelegate.managedObjectContext;
    
    // BPM counter
    private static let detector : BPMDetector = BPMDetector.init();

    var pulse = [Int]();
//    var firstAvg : Bool = true;
    
    var bleHandler : BLEHandler?;
    var appModel : AppModel = AppModel();
    
    var index = 0;

    
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
    
    /*
    
    *** Music player actions ***
    
    */
  
    @IBAction func backButtonClick(sender: AnyObject) {
        print("back button clicked");
    }
    
    
    @IBAction func rewindMusic(sender: AnyObject) {
        if(ViewController.player!.playing) {
            playMusicByIndex("back", playing: true);
        } else {
            playMusicByIndex("back", playing: false);
        }
    }
    
    
    @IBAction func fastForwardMusic(sender: AnyObject) {
        if(ViewController.player!.playing) {
            playMusicByIndex("forward", playing: true);
        } else {
            playMusicByIndex("forward", playing: false);
        }
    }
    
    
    @IBAction func playAndPauseMusic(sender: AnyObject) {        
        if( ViewController.player!.playing ) {
            ViewController.player!.delegate = self;
            ViewController.player!.pause();
            
            imageControls.image = UIImage(named: "play");
            
        } else {
            ViewController.player!.delegate = self;
            ViewController.player!.play();
            
            imageControls.image = UIImage(named: "pause");
        }
    }
    
    
    /*
    
    *** Segue varuable for view title ***
    
    */
    
    // Segue variable
    var controllerTitle = "";
 
    /*
    
    *** Default "view did load" functions ***
    
    */
    
    // The view loads
    override func viewDidLoad() {
        super.viewDidLoad();
        appModel.calculatePenalization();
        
        // hide controls until first play
        imageControls.hidden = true;
        forwardImage.hidden = true;
        rewindImage.hidden = true;
        
        // define control events
        
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
        
        bleHandler = BLEHandler();
        
        navigationTitle.title = BLEHandler.choosenDevice as? String;
        bleHandler?.connectToPeripheral();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.computeAvgBpm(_:)), name: "bpm", object: nil);

        ViewController.player = AudioPlayer.getAudioPlayer();
        
        if(appModel.getFirstAvg()) {
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
            if( index >= returnSongsArrayCount(ViewController.state!) - 1 ) { index = 0; }
            else { index += 1; }
        } else if(type == "back") {
            if( index == 0 ) { index = returnSongsArrayCount(ViewController.state!) - 1; }
            else { index -= 1; }
        }
        
        do {
            try ViewController.player = AVAudioPlayer(contentsOfURL: returnUrlOfActualItem(index));
            ViewController.player!.delegate = self;
            print("playing ", playing);
            if(playing || type == "") {
                ViewController.player!.play();
            };
            //ViewController.player?.peakPowerForChannel(<#T##channelNumber: Int##Int#>)
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
        print("sum ", sum);
        print("penalization");
        print("avg ", sum/pulseArray.count);
        let avg : Int = sum/pulseArray.count - appModel.getPenalization();
        
        if(avg < 70) {
            ViewController.state = 3;
        } else if(avg >= 70 && avg < 100) {
            ViewController.state = 2;
        } else if(avg >= 100 && avg < 140) {
            ViewController.state = 1;
        } else if(avg >= 140) {
            ViewController.state = 0;
        }
        
        print( "\n AVG : ", avg);
        print( "\n VIEWCONTROLLER STATE : ", ViewController.state, "\n" );
        
        if(appModel.getFirstAvg()) {
            playMusicByIndex("", playing: false);
            imageControls.hidden = false;
            forwardImage.hidden = false;
            rewindImage.hidden = false;
            loadingLabel.hidden = true;
        };
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
            songLabel.text = ViewController.songsUrlELow[index].songUrl;
            break;
        case 1:
            url = NSBundle.mainBundle().URLForResource("Music/\(ViewController.songsUrlLow[index].songUrl)", withExtension: ViewController.songsUrlLow[index].songType)!;
            songLabel.text = ViewController.songsUrlLow[index].songUrl;
            break;
        case 2:
            url = NSBundle.mainBundle().URLForResource("Music/\(ViewController.songsUrlMid[index].songUrl)", withExtension: ViewController.songsUrlMid[index].songType)!;
            songLabel.text = ViewController.songsUrlMid[index].songUrl;
            break;
        case 3:
            url = NSBundle.mainBundle().URLForResource("Music/\(ViewController.songsUrlHigh[index].songUrl)", withExtension: ViewController.songsUrlHigh[index].songType)!;
            songLabel.text = ViewController.songsUrlHigh[index].songUrl;
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
        
        print("\(currentSongArtist): \(currentSongTitle)");
        
        return "\(currentSongArtist[0].value): \(currentSongTitle[0].value)";
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playMusicByIndex("forward", playing: true);
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
    
    func categorizeMusic(url: String, type: String, bpm: Float) {
        var song : MusicSongs = MusicSongs(songUrl: url, songType: type, songBpm: bpm);
        
        switch(song.category!) {
            case "ELow" :
                ViewController.songsUrlELow.append(song);
                print("push this song EL", url, bpm);
                break;
            case "Low" :
                ViewController.songsUrlLow.append(song);
                print("push this song L", url, bpm);
                break;
            case "Mid":
                ViewController.songsUrlMid.append(song);
                print("push this song M", url, bpm);
                break;
            case "High":
                ViewController.songsUrlHigh.append(song);
                print("push this song H", url, bpm);
                break;
            default:
                print("Error value!");
                break;
        }
    }
    
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
                        
                        categorizeMusic(songName, type: "mp3", bpm: res.valueForKey("bpm") as! Float);
                        
                        break;
                    }
                }
            }
            
        } catch {
            print("RESULT ERROR");
        }
        
        if(newSong) {
            print("ano nerovnaju sa", songName);
            var newSongBpm = ViewController.detector.getBPM(path);
            
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

