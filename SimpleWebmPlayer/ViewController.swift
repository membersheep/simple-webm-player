//
//  ViewController.swift
//  SimpleWebmPlayer
//
//  Created by Alessandro Maroso on 25/02/2018.
//  Copyright © 2018 membersheep. All rights reserved.
//

import UIKit

// TODO: Allow to open an url directly from a dialog
// TODO: Show instructions in the background. Hide when a media is loaded.

class ViewController: UIViewController, VLCMediaPlayerDelegate {
    
    let movieView = UIView()
    let leftLabel = UILabel()
    let rightLabel = UILabel()
    let progressSlider = UISlider()
    let mediaPlayer = VLCMediaPlayer()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.movieView.frame = UIScreen.screens[0].bounds
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.movieViewTapped(_:)))
        self.movieView.addGestureRecognizer(tapGesture)
    
        self.view.addSubview(self.movieView)
        self.movieView.translatesAutoresizingMaskIntoConstraints = false
        self.movieView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.movieView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.movieView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.movieView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.progressSlider.tintColor = .white
        self.view.addSubview(self.progressSlider)
        self.progressSlider.translatesAutoresizingMaskIntoConstraints = false
        self.progressSlider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.progressSlider.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.progressSlider.addTarget(self, action: #selector(ViewController.sliderTouchBegan), for: .touchDown)
        self.progressSlider.addTarget(self, action: #selector(ViewController.sliderMoved), for: .valueChanged)
        self.progressSlider.addTarget(self, action: #selector(ViewController.sliderTouchEnded), for: .touchUpInside)

        self.leftLabel.textColor = .white
        self.leftLabel.text = "00:00"
        self.view.addSubview(self.leftLabel)
        self.leftLabel.translatesAutoresizingMaskIntoConstraints = false
        self.leftLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        self.leftLabel.centerYAnchor.constraint(equalTo: self.progressSlider.centerYAnchor).isActive = true
        self.leftLabel.rightAnchor.constraint(equalTo: self.progressSlider.leftAnchor, constant: 16).isActive = true
        
        self.rightLabel.textColor = .white
        self.rightLabel.text = "00:00"
        self.view.addSubview(self.rightLabel)
        self.rightLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        self.rightLabel.centerYAnchor.constraint(equalTo: self.progressSlider.centerYAnchor).isActive = true
        self.rightLabel.leftAnchor.constraint(equalTo: self.progressSlider.rightAnchor, constant: 16).isActive = true
    }
    
    func openFile(with url: URL) {
        let media = VLCMedia(url: url)
        self.mediaPlayer.media = media
        self.mediaPlayer.delegate = self
        self.mediaPlayer.drawable = self.movieView
        self.mediaPlayer.play()
    }
    
    func updateLabels(for time: Int32) {
        let minutes = time / 1000 / 60
        let seconds = time / 1000 % 60
        let totalMinutes = (self.mediaPlayer.time.intValue - self.mediaPlayer.remainingTime.intValue)  / 1000 / 60
        let totalSeconds = (self.mediaPlayer.time.intValue - self.mediaPlayer.remainingTime.intValue)  / 1000 % 60
        DispatchQueue.main.async {
            self.leftLabel.text = "\(String(format:"%02d", minutes)):\(String(format:"%02d", seconds))"
            self.rightLabel.text = "\(String(format:"%02d", totalMinutes)):\(String(format:"%02d", totalSeconds))"
        }
    }
    
    @objc func rotated() {
        let orientation = UIDevice.current.orientation
        if (UIDeviceOrientationIsLandscape(orientation)) {
            print("Switched to landscape")
        }
        else if(UIDeviceOrientationIsPortrait(orientation)) {
            print("Switched to portrait")
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        let totalTime = self.mediaPlayer.time.intValue - self.mediaPlayer.remainingTime.intValue
        DispatchQueue.main.async {
            self.progressSlider.setValue(Float(self.mediaPlayer.time.intValue)/Float(totalTime), animated: false)
        }
        self.updateLabels(for: self.mediaPlayer.time.intValue)
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if self.mediaPlayer.state == .ended {
            self.mediaPlayer.stop()
            self.mediaPlayer.play()
        }
    }
    
    @objc func sliderTouchBegan() {
        self.mediaPlayer.pause()
    }
    
    @objc func sliderMoved() {
        let totalTime = self.mediaPlayer.time.intValue - self.mediaPlayer.remainingTime.intValue
        let targetTime = self.progressSlider.value * Float(totalTime)
        self.mediaPlayer.time = VLCTime(int: Int32(targetTime))
        self.updateLabels(for: Int32(targetTime))
    }
    
    @objc func sliderTouchEnded() {
        self.mediaPlayer.play()
    }
    
    @objc func movieViewTapped(_ sender: UITapGestureRecognizer) {
        if self.mediaPlayer.isPlaying == true {
            self.mediaPlayer.pause()
            print("Paused")
        } else {
            self.mediaPlayer.play()
            print("Playing")
        }
    }
}
