//
//  ViewController.swift
//  corujaVirtual
//
//  Created by Israel Tavares on 6/24/15.
//  Copyright © 2015 Coruja Virtual. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import CoreMedia
import AVKit

class HomeCtrl: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var player_ctrl_container: UIView!
    @IBOutlet weak var player_ctrl_prog_indicator: UIImageView!
    @IBOutlet weak var player_ctrl_prog_container: UIImageView!
    @IBOutlet weak var player_ctrl_stop: UIButton!
    @IBOutlet weak var player_ctrl_play: UIButton!
    
    let player_ctrl_prog_bar_width: Float = 334
    var player_ctrl_prog_indicator_current = 47
    let player_ctrl_prog_indicator_initPos = 47
    let player_ctrl_prog_indicator_finalPos = 373
    
    var player_video_total_duration = 0.0
    
    var playerAsset: AVAsset?
    var player: AVPlayer? = AVPlayer()
    var avLayer: AVPlayerLayer? = AVPlayerLayer()
    var playerItem: AVPlayerItem?
    var timeObserver: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerInit()
    }
    
    func playerInit()
    {
        self.playerAsset = AVAsset(URL: NSURL(string: "https://github.com/ismalakazel/ios-custom-video-player/raw/master/assets/sample.mp4")!)
        self.playerItem = AVPlayerItem(asset: self.playerAsset!)
        self.player = AVPlayer(playerItem: self.playerItem!)
        self.avLayer = AVPlayerLayer(player: self.player)
        self.avLayer!.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.avLayer!.backgroundColor = UIColor.blackColor().CGColor
        self.view.layer.addSublayer(self.avLayer!)
        self.config()
        self.registerObservers()
        self.play()
    }
    
    func config() {
        self.view.bringSubviewToFront(player_ctrl_container)
        self.player_ctrl_play.hidden = false
        self.player_ctrl_stop.hidden = true
        self.player_ctrl_prog_container.userInteractionEnabled = true
        self.player_ctrl_play.addTarget(self, action: "play", forControlEvents: .TouchUpInside)
        self.player_ctrl_stop.addTarget(self, action: "pause", forControlEvents: .TouchUpInside)
        self.player_ctrl_prog_indicator_current = self.player_ctrl_prog_indicator_initPos
        self.player_video_total_duration = CMTimeGetSeconds(self.player!.currentItem!.asset.duration)
    }
    
    func registerObservers() {
        timeObserver = player!.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.1, 100), queue: nil) { (time: CMTime) -> Void in self.trackPlayerTimeline()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishPlaying", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
    
    func play() {
        self.player_ctrl_play.hidden = true
        self.player_ctrl_stop.hidden = false
        self.player!.play()
    }
    
    func pause() {
        self.player_ctrl_stop.hidden = true
        self.player_ctrl_play.hidden = false
        self.player!.pause()
    }
    

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let indicator_init_position_x: CGFloat = 10
        let indicator_max_position: CGFloat = 365
        let indicator_min_position: CGFloat = 47
        
        let location: CGPoint = (touches.first?.locationInView(self.player_ctrl_prog_container))!
        
        var destination = CGPointMake(player_ctrl_prog_container.frame.origin.x + location.x,
            player_ctrl_prog_container.center.y);
        
        if let touch = touches.first {
            if touch.view == self.player_ctrl_prog_container {
                
                self.pause()
                
                if(destination.x > indicator_max_position + 15) {
                    destination.x = indicator_max_position + 15
                }
                
                if(destination.x < indicator_min_position + indicator_init_position_x) {
                    destination.x = indicator_min_position + indicator_init_position_x
                }
                
                self.player_ctrl_prog_indicator.center = destination;
            }
        }

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.player_ctrl_prog_container {
                let location: CGPoint = (touches.first?.locationInView(self.player_ctrl_prog_container))!
                self.seekToTime(Float(location.x))
            }
        }
    }
    
    func seekToTime(toPoint: Float)
    {
        let percentage = toPoint * 100 / player_ctrl_prog_bar_width
        let convert = percentage * Float(CMTimeGetSeconds((self.player!.currentItem?.duration)!)) / 100
        let toTime = CMTimeMakeWithSeconds(Float64(convert), 6000000)
        self.player!.seekToTime(toTime, completionHandler: { (value: Bool) -> Void in
            self.play()
        })
    }
    
    func trackPlayerTimeline()
    {
        if CMTimeGetSeconds(self.playerItem!.currentTime()) != 0 {
            if(!isnan(CMTimeGetSeconds(self.playerItem!.duration))){
                let progress = Double(CMTimeGetSeconds(self.playerItem!.currentTime()) / CMTimeGetSeconds(self.playerItem!.duration)) * Double(self.player_ctrl_prog_bar_width - 5)
                moveProgressIndicator(progress)
            }
        }
    }
    
    func moveProgressIndicator(progress: Double) {
            player_ctrl_prog_indicator_current = Int(progress) + player_ctrl_prog_indicator_initPos
            player_ctrl_prog_indicator.frame = CGRectMake(CGFloat(player_ctrl_prog_indicator_current), self.player_ctrl_prog_indicator.frame.origin.y, self.player_ctrl_prog_indicator.frame.width, self.player_ctrl_prog_indicator.frame.height)
    }
    
    func didFinishPlaying() {
        // Remove observers
        // Do whatever
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

