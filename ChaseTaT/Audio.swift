//
//  Audio.swift
//  ChaseTaT
//
//  Created by Oyedepo, Boluwatifemito on 11/11/2024.
//
// Global Methods based off of Phil's used to handle all audio throught the project

import UIKit
import AVFoundation

var audioClips = [String:AVAudioPlayer?]()

func playAudio(_ name: String, restart: Bool = true) {
    // play a given audio [Adapted from Phil's]
    let audioPlayer = findAudio(name)
    if (audioPlayer == nil) || (audioPlayer?.isPlaying == false) {
        if restart {audioPlayer?.currentTime = 0}
        audioPlayer?.play()
    }
}

func findAudio(_ name: String) -> AVAudioPlayer? {
    // linear search and find AudioPLayer Object
    for (key,AVAP) in audioClips{
        if key == name {
            return AVAP
        }
    }
    return nil
}

func stopAllAudio() {
    // Loop through and stop all audio
    for (key,_) in audioClips{
        stopAudio(key)
    }
}

func setupAudioPlayers(toPlay audioFileURL:URL) -> AVAudioPlayer? {
    // Setup Audio Player obeject [Adapted from Phil's]
    var audioPlayer: AVAudioPlayer?
    do {
        try audioPlayer = AVAudioPlayer(contentsOf: audioFileURL)
        audioPlayer?.prepareToPlay()
    } catch {
        print("Can't play the audio \(audioFileURL.absoluteString)")
        print(error.localizedDescription)
    }
    return audioPlayer
}
 
func stopAudio(_ name: String) {
    // stop a given audio [Adapted from Phil's]
    let audioPlayer = findAudio(name)
     if audioPlayer?.isPlaying == true {
         audioPlayer?.stop()
     }
 }

func getAllMP3Players() -> [String:AVAudioPlayer?] {
    // Get all MP3 Files [Given by Phil]
    var filePaths = [URL]() //URL array
    var audioFileNames = [String]() //String array
    var theResult = [String:AVAudioPlayer?]()

    let bundlePath = Bundle.main.bundleURL
    do {
        try FileManager.default.createDirectory(atPath: bundlePath.relativePath, withIntermediateDirectories: true)
        // Get the directory contents urls (including subfolders urls)
        let directoryContents = try FileManager.default.contentsOfDirectory(at: bundlePath, includingPropertiesForKeys: nil, options: [])
        
        // filter the directory contents
        filePaths = directoryContents.filter{ $0.pathExtension == "mp3" }
        
        //get the file names, without the extensions
        audioFileNames = filePaths.map{ $0.deletingPathExtension().lastPathComponent }
    } catch {
        print(error.localizedDescription) //output the error
    }
    //print(audioFileNames) //for debugging purposes only
    for loop in 0..<filePaths.count { //Build up the dictionary.
        theResult[audioFileNames[loop]] = setupAudioPlayers(toPlay: filePaths[loop])
    }
    return theResult
}

func muteAll(){
    stopAllAudio()
    audioClips = [:]
}

func unmuteAll(){
    audioClips = getAllMP3Players()
}
