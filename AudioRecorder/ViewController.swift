//
//  ViewController.swift
//  AudioRecorder
//
//  Created by shubham Garg on 20/07/20.
//  Copyright © 2020 shubham Garg. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var stopRecordingBtn: UIButton!
    @IBOutlet weak var startRecordingBtn: UIButton!
    @IBOutlet weak var playPauseBtn: UIButton!
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var timer: Timer?
    var url:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingBtn.isEnabled = false
        playPauseBtn.isHidden = true
        progressBar.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:  player?.currentTime)
    }
    
    @objc func playerDidFinishPlaying() {
        // Your code here
        self.player?.stop()
        self.playPauseBtn.setTitle("Play", for: .normal)
    }
    
    @IBAction func startRecordingBtn(_ sender: Any) {
        player?.stop()
        self.playPauseBtn.setTitle("Play", for: .normal)
        if let recorder = self.recorder{
            if recorder.isRecording{
                self.recorder?.pause()
                startRecordingBtn.setTitle("Restart Recording ...", for: .normal)
            }
            else{
                startRecordingBtn.setTitle("Pause Recording ...", for: .normal)
                self.recorder?.record()
            }
        }
        else{
            stopRecordingBtn.isEnabled = true //enables stopRecording button
            startRecordingBtn.setTitle("Pause Recording ...", for: .normal)
            initializeRecorder()
        }
        
    }
    
    @IBAction func StopRecordingBtn(_ sender: Any) {
        stopRecordingBtn.isEnabled = false
        startRecordingBtn.setTitle("Start Recording", for: .normal)
        playPauseBtn.isHidden = false
        self.recorder?.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
        self.url = self.recorder?.url
        self.recorder = nil
    }
    
    
    @IBAction func playPauseBtn(_ sender: Any) {
        progressBar.isHidden = false
        if player?.isPlaying ?? false{
            player?.stop()
            self.playPauseBtn.setTitle("Play", for: .normal)
        }
        else{
            playSound()
        }
    }
    
    func playSound() {
        if !(recorder?.isRecording ?? false), let url = self.url {
              player = nil
              player = try? AVAudioPlayer(contentsOf: url)
              try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .defaultToSpeaker)
              player?.delegate = self
              player?.play()
            self.playPauseBtn.setTitle("Pause", for: .normal)
            self.startTimer()
          }
      }
    
    func startTimer() {
         timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateRecordingProgress), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func updateRecordingProgress() {
        //update your UIProgressView here
        if player != nil && (player?.duration ?? TimeInterval(0)) > TimeInterval(0) {
            self.progressBar.progress = Float(((player?.currentTime ?? 0) / (player?.duration ?? 1)))
        }
    }
    
    func initializeRecorder() {
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        let directory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var recordSetting = [AnyHashable: Any]()
        recordSetting[AVFormatIDKey] = kAudioFormatMPEG4AAC
        recordSetting[AVSampleRateKey] = 16000.0
        recordSetting[AVNumberOfChannelsKey] = 1
        if let filePath = directory.first?.appendingPathComponent("MyAudioMemo.m4a"), let audioRecorder = try? AVAudioRecorder(url: filePath, settings: (recordSetting as? [String : Any] ?? [:])){
            print(filePath)
            
            self.recorder = audioRecorder
            self.recorder?.delegate = self
            self.recorder?.isMeteringEnabled = true
            self.recorder?.prepareToRecord()
            self.recorder?.record()
        }
        //filepath is an optional URL
        
        
        
    }
    
}

extension ViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    
}
