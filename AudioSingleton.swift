//
//  AudioSingleton.swift
//  beacon-test
//
//  Created by iago salomon on 26/08/19.
//  Copyright © 2019 iago salomon. All rights reserved.
//

import Foundation
import  AVFoundation
import UIKit

final class AudioSingleton: NSObject {
    
    static let shared = AudioSingleton()
    
    private var isMicAccessGranted = false
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var fileName: String?
    
    private let recordSettings = [AVFormatIDKey: kAudioFormatAppleLossless,
                                  AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                                  AVEncoderBitRateKey: 320000,
                                  AVNumberOfChannelsKey: 2 ,
                                  AVSampleRateKey: 44100.2] as [String : Any]
    
    override init() {
        super.init()
    }
    
    
    private func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
        
    }
    
    
    public func setFile(name: String) {
        self.fileName = name + ".m4a"
        
        
    }
    
    public func getFileName() -> String {
        guard let fileName = fileName else {return String()}
        return fileName
        
    }
    
    public func haveFileName() -> Bool {
        if (fileName != nil){
            return true
        }
        return false
        
    }
    
    public func deleteAudioFile(name: String) {
        let audio = name + ".m4a"
        let documentsPath: URL = getDocumentDirectory()
        let audioPath = documentsPath.appendingPathComponent(audio)
        do {
            try FileManager.default.removeItem(at: audioPath)
            
        } catch {
            print(error)
        }
        
    }
    
    
    public func setupRecorder() {
        guard let fileName = fileName else{return}
        let audioFileName = getDocumentDirectory().appendingPathComponent(fileName)
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: recordSettings)
            guard let audioRecorder = audioRecorder else {return}
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            
        } catch {
            print(error)
        }
    }
    
    
    public func setupPlayer(){
        guard let fileName = fileName else{return}
        let audioFileName = getDocumentDirectory().appendingPathComponent(fileName)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileName)
            guard let audioPlayer = audioPlayer else{return}
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            
            
        } catch {
            print(error)
        }
        
    }
    
    
    
    
    public func record() {
        guard let audioRecorder = audioRecorder else {return}
        audioRecorder.record(forDuration: 3600)
        
    }
    public func stopRecord() {
        guard let audioRecorder = audioRecorder else {return}
        audioRecorder.stop()
        
    }
    
    public func play() {
        guard let audioPlayer = audioPlayer else {return}
        audioPlayer.play()
    }
    
    public func stopPlaying() {
        guard let audioPlayer = audioPlayer else {return}
        audioPlayer.stop()
    }
    
    
    
    
    
    
    
    
    public func checkMicrophonePermission() -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission{
        case .granted:
            isMicAccessGranted = true
            break
        case .denied:
            isMicAccessGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
                if allowed {
                    self.isMicAccessGranted = true
                }else{
                    self.isMicAccessGranted = false
                }
            }
        default:
            break
        }
        return isMicAccessGranted
        
    }
    
    //Have to add into info.plist
    // The information property list- Microphone Usage Description and and description $(PRODUCT_NAME) needs to use microphone tho record audio
    
    
    
    
}


extension AudioSingleton : AVAudioPlayerDelegate {
    
}


extension AudioSingleton : AVAudioRecorderDelegate {
    
}
