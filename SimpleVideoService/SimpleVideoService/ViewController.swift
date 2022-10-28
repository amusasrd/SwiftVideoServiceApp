//
//  ViewController.swift
//  SimpleVideoService
//
//  Created by Ahmed Musa on 29/1/17.
//  Copyright © 2017 A Moses. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, IMediaStreamerDelegate {
    
    @IBOutlet var btnPublish : UIButton!
    @IBOutlet var btnPlayback : UIButton!
    @IBOutlet var btnStopMedia : UIButton!
    @IBOutlet var btnSwapCamera : UIButton!
    @IBOutlet var preView : UIView!
    @IBOutlet var playbackView : UIImageView!
    @IBOutlet var textField : UITextField!
    @IBOutlet var lblLive : UILabel!
    @IBOutlet var switchView : UISwitch!
    @IBOutlet var netActivity : UIActivityIndicatorView!
    
    
    @IBAction func switchCamerasControl(sender: AnyObject) {
        _publisher?.switchCameras()
    }
    
    @IBAction func stopMediaControl(sender: AnyObject) {
        if(_publisher != nil) {
            _publisher?.disconnect()
            _publisher = nil;
            self.preView.isHidden = true
            self.btnStopMedia.isHidden = true
            self.btnSwapCamera.isHidden = true
        }
         else if(_player != nil) {
            _player?.disconnect()
            _player = nil;
            self.playbackView.isHidden = true
            self.btnStopMedia.isHidden = true
        }
        self.btnPublish.isHidden = false
        self.btnPlayback.isHidden = false
        self.textField.isEnabled = true
        self.switchView.isEnabled = true
        self.netActivity.stopAnimating()
    }
    
    @IBAction func playbackControl(sender: AnyObject) {
        var options: MediaPlaybackOptions
        if(switchView.isOn) {
            options = MediaPlaybackOptions.liveStream(self.playbackView) as MediaPlaybackOptions
        }
        else {
            options = MediaPlaybackOptions.recordStream(self.playbackView) as MediaPlaybackOptions
        }
        options.orientation = .Up
        options.isRealTime = switchView.isOn
        _player = backendless.mediaService.playbackStream(textField.text, tube: VIDEO_TUBE, options: options, responder: self)
        self.btnPublish.isHidden = true
        self.btnPlayback.isHidden = true
        self.textField.isEnabled = false
        self.switchView.isEnabled = false
        self.netActivity.startAnimating()
    }
    
    @IBAction func publishControl(sender: AnyObject) {
        var options: MediaPublishOptions
        if(switchView.isOn) {
            options = MediaPublishOptions.liveStream(self.preView) as MediaPublishOptions
        }
        else {
            options = mediaPublishOptions.recordStream(self.preView) as MediaPublishOptions
        }
        options.orientation = .Portrait
        options.resolution = RESOLUTION_CIF
        _publisher = backendless.mediaService.publishStream(textField.text, tube: VIDEO_TUBE, options: options, responder: self)
        self.btnPublish.isHidden = true
        self.btnPlayback.isHidden = true
        self.textField.isEnabled = false
        self.switchView.isEnabled = false
        self.netActivity.startAnimating()
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        textField.resignFirstResponder()
    }
    
    //UITextFieldDelegate protocol methods
    func textFieldShouldReturn(_textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    var backendless = Backendless.sharedInstance()
    var _publisher: MediaPublisher?
    var _player: MediaPlayer?
    let VIDEO_TUBE = "videoTube"
    
    //have a look at bottom code to analyse
    func streamStateChanged(sender: AnyObject!, state: Int32, description: String!) {
        switch state {
        case 0:
            //CONN_DISCONNECTED
            stopMediaControl(sender)
            return
        case 1:
            //CONN_CONNECTED
            return
        case 2:
            //STREAM_CREATED
            self.btnStopMedia.isHidden = false
            return
        case 3:
            //STREAM_PLAYING
            //PUBLISHER
            if(_publisher != nil) {
                if(description != "NetStream.Publish.Start") {
                    stopMediaControl(sender)
                    return
                }
                self.preView.isHidden = false
                self.btnSwapCamera.isHidden = false
                netActivity.stopAnimating()
            }
            //PLAYER
            if(_player != nil) {
                if(description == "NetStream.Play.NotFound") {
                    stopMediaControl(sender)
                    return
                }
                if(description != "NetStream.Play.Start") {
                return
            }
            self.playbackView.isHidden = false
            netActivity.stopAnimating()
        }
        return
        case 4:
        //STREAM_PAUSED
        if(description == "NetStream.Play.StreamNotFound") {
        }
        stopMediaControl(sender)
        return
        default:
        return
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

    func streamConnectFailed(sender: AnyObject!, code: Int32, description: String) {
        stopMediaControl(sender)
}

