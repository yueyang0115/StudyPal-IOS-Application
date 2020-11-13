//
//  AudioViewController.swift
//  ECE564project
//
//  Created by 杨越 on 11/8/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
   
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecording: Int = 0
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var leftTime: UILabel!
    @IBOutlet weak var recordTime: UILabel!
    var recordTimer : Timer?
    var playTimer: Timer?
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet var StartStopButton: UIBarButtonItem!
    @IBOutlet weak var recordingTableView: UITableView!

    var buttonIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRecorder()
        setUpView()
    }
    
    // set up audio recorder
    func setUpRecorder(){
        recordingSession = AVAudioSession.sharedInstance()
        // get previous numOfRecording
        if let number:Int = UserDefaults.standard.object(forKey: "recodingNumber") as? Int{
            numberOfRecording = number
        }
        AVAudioSession.sharedInstance().requestRecordPermission{ (hasPermission) in
            if hasPermission{
                print("ACCEPTED")
            }
        }
    }
    
    func setUpView(){
        message.lineBreakMode = NSLineBreakMode.byWordWrapping
        message.numberOfLines = 2
        clearPlayTime()
        clearRecordTime()
    }
    
    func clearPlayTime(){
        startTime.text = ""
        leftTime.text = ""
    }
    
    func clearRecordTime(){
        recordTime.text = ""
    }
    
    // MARK: - record, play and stop
    
    // start or stop audio, play or record
    @objc @IBAction func recordORstop(_ sender: Any) {
        if(audioRecorder == nil && audioPlayer == nil){
            // start recoding
            clearPlayTime()
            startRecordingTimer()
            changeButtonToStop()
            
            numberOfRecording += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecording).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
            do{
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                message.text = "Audio is recording..."
            }
            catch{
                displayAlert(title: "Ups!", message: "Recording failed!")
            }
        }
        else{
            changeButtonToStart()
            // stop playing
            if(audioPlayer != nil){
                audioPlayer.stop()
                audioPlayer = nil
                stopPlayingTimer()
                message.text = "Audio playing is stopped, click cell to restart"
            }
            // stop recording
            else{
                audioRecorder.stop()
                audioRecorder = nil
                stopRecordingTimer()
                UserDefaults.standard.set(numberOfRecording, forKey: "recodingNumber")
                recordingTableView.reloadData()
                message.text = "Finished recording"
            }
        }
    }
    
    // pause audio
    @IBAction func pause(_ sender: Any) {
        if(audioRecorder != nil && audioRecorder.isRecording){
            audioRecorder.pause()
            message.text = "Recording is paused, tap again to continue"
        }
        else if(audioRecorder != nil && !audioRecorder.isRecording){
            audioRecorder.record()
            message.text = "Continue recording..."
        }
        else if(audioPlayer != nil && audioPlayer.isPlaying){
            audioPlayer.pause()
            message.text = "Audio playing is paused, tap again to continue"
        }
        else if(audioPlayer != nil && !audioPlayer.isPlaying){
            audioPlayer.play()
            message.text = "Continue playing..."
        }
    }
    
    // MARK: - update slider
    // change audio time
    @IBAction func slideAudioTime(_ sender: Any) {
        if(audioPlayer != nil){
            audioPlayer.stop()
            audioPlayer.currentTime = TimeInterval(slider.value)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    // fastforwad a audio
    @IBAction func playFast(_ sender: Any) {
        if(audioPlayer != nil){
            audioPlayer.stop()
            if(audioPlayer.currentTime + TimeInterval(5) < audioPlayer.duration){
                audioPlayer.currentTime = audioPlayer.currentTime + TimeInterval(5)
            }
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    // rewind an audio
    @IBAction func playSlow(_ sender: Any) {
        if(audioPlayer != nil){
            audioPlayer.stop()
            if(audioPlayer.currentTime - TimeInterval(5) > 0){
                audioPlayer.currentTime = audioPlayer.currentTime - TimeInterval(5)
            }
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    // timer which keep updating playing time and slider
    func startPlayingTimer(){
        guard playTimer == nil else { return }
        playTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePlayingTime), userInfo: nil, repeats: true)
    }
    
    func stopPlayingTimer() {
      playTimer?.invalidate()
      playTimer = nil
    }
    
    // timer which keep updating recording time and slider
    func startRecordingTimer(){
        guard recordTimer == nil else { return }
        recordTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateRecordingTime), userInfo: nil, repeats: true)
    }
    
    func stopRecordingTimer() {
      recordTimer?.invalidate()
      recordTimer = nil
    }
    
    // update time during playing a audio
    @objc func updatePlayingTime(){
        if(audioPlayer != nil){
            slider.value = (Float)(audioPlayer.currentTime)
            startTime.text = transformTime(time: audioPlayer.currentTime)
            leftTime.text = transformTime(time: audioPlayer.duration - audioPlayer.currentTime)
        }
    }
    
    // update time during recording a audio
    @objc func updateRecordingTime(){
        if(audioRecorder != nil){
            //recordTime.text = (String)(audioRecorder.currentTime)
            recordTime.text = transformTime(time: audioRecorder.currentTime)
        }
    }
    
    // get time format
    func transformTime(time : TimeInterval) -> String{
        let min:Int = (Int)(time/60)
        let sec:Int = (Int)(time) - min * 60
        return NSString(format: "%02d:%02d", min,sec) as String
    }
    
    // get path to directory
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    // display alert
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - button view
    
    // change button image to stop
    func changeButtonToStop(){
        StartStopButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(recordORstop(_:)))
        toolBar.items![1] = StartStopButton
    }
    
    // change button image to start
    func changeButtonToStart(){
        StartStopButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(recordORstop(_:)))
        toolBar.items![1] = StartStopButton
    }
    
    // MARK: - table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecording
    }
    
    // return cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! RecordingCell
        let num = indexPath.row + 1
        cell.setCell(name: "Audio No.\(num)")
        return cell
    }
    
    // when cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row+1).m4a")
        do{
            startPlayingTimer()
            clearRecordTime()
            changeButtonToStop()
            
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
            audioPlayer.numberOfLoops = 0
            audioPlayer.delegate = self
            message.text = "Audio is playing..."
            slider.maximumValue = Float(audioPlayer.duration)
        }
        catch{
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AudioViewController: AVAudioPlayerDelegate {
    // stop audioPlayer when audio is finished
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio player finished playing")
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            stopPlayingTimer()
            changeButtonToStart()
            message.text = "Finished audio playing"
        }
    }
}
