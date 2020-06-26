//
//  RecordWhistleViewController.swift
//  Whats_that_whistle
//
//  Created by Levit Kanner on 25/06/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit
import AVFoundation

class RecordWhistleViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var stackView: UIStackView!
    var recordButton: UIButton!
    var playButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var whistleRecorder: AVAudioRecorder!
    var whistlePlayer: AVAudioPlayer!
    
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        view.addSubview(stackView)
        
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Record your whistle"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .plain, target: nil, action: nil)
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do{
            //Sets recording session category and activates it
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            //Requests user permission
            recordingSession.requestRecordPermission {[unowned self] success in
                DispatchQueue.main.async {
                    if success {
                        self.loadRecordingUI()
                    }else {
                        self.loadFailUI()
                    }
                }
            }
        }catch {
            self.loadFailUI()
        }
        
        
    }
    
    
    //MARK: - BUTTON ACTIONS
    
    
    @objc func recordTapped() {
        if whistleRecorder == nil {
            startRecording()
            
            //Hides play button in recording mode
            if !playButton.isHidden {
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = true
                    self.playButton.alpha = 0
                    self.recordButton.transform = .init(scaleX: 1, y: 1)
                    self.recordButton.alpha = 1
                }
            }
        }else {
            finishRecording(success: true)
        }
    }
    
    
    @objc func nextTapped() {
        let vc = SelectGenreViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func playTapped() {
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: RecordWhistleViewController.getWhistleUrl())
            whistlePlayer.delegate = self
            whistlePlayer.play()
        }catch {
           configureAlert(title: "Playback Failed", message: "There was a problem playing your whistle; please try re-recording.")
        }
    }
    
    //MARK: - METHODS
    func loadRecordingUI() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        stackView.addArrangedSubview(recordButton)
        
        
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Tap to Play", for: .normal)
        playButton.isHidden = true
        playButton.alpha = 0
        playButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        stackView.addArrangedSubview(playButton)
    }
    
    
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0
        failLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        stackView.addArrangedSubview(failLabel)
    }
    
    
    
    
    
    func startRecording() {
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        recordButton.setTitle("Tap to stop", for: .normal)
        
        let audioUrl = RecordWhistleViewController.getWhistleUrl()
        print(audioUrl)
        
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            whistleRecorder = try AVAudioRecorder(url: audioUrl, settings: settings)
            whistleRecorder.delegate = self
            whistleRecorder.record()
        }catch {
            finishRecording(success: false)
        }
    }
    
    
    
    func finishRecording(success: Bool){
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        
        whistleRecorder.stop()
        whistleRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-cord", for: .normal)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
            
            //Shows play button by animating the view
            if playButton.isHidden {
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = false
                    self.playButton.alpha = 1
                    self.recordButton.transform = .init(scaleX: 0.9, y: 0.9)
                    self.recordButton.alpha = 0.9
                }
            }
        }else {
            recordButton.setTitle("Tap to Record", for: .normal)
            configureAlert(title: "Record failed", message: "There was a problem recording your whistle. Please try again.")
        }
    }
    
    
    func configureAlert(title: String! , message: String!){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert , animated: true)
    }
    
    
    
    
    //MARK: - AUDIO STORAGE LOCATION
    class func getDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    class func getWhistleUrl() -> URL {
        getDirectory().appendingPathComponent("whistle.m4a")
    }
    
    
    //MARK: - DELEGATE METHODS
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag{
            finishRecording(success: false)
        }
    }
    
}
