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
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet var StartStopButton: UIBarButtonItem!
    @IBOutlet weak var recordingTableView: UITableView!

    var buttonIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpRecorder()
        setUpLabel()
    }
    
    func setUpRecorder(){
        // set up session
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
    
    func setUpLabel(){
        message.lineBreakMode = NSLineBreakMode.byWordWrapping
        message.numberOfLines = 2
    }
    
    // MARK: - record, play and stop
    
    @objc @IBAction func recordORstop(_ sender: Any) {
        if(audioRecorder == nil && audioPlayer == nil){
            // start recoding
            changeButtonToStop()
            numberOfRecording += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecording).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
            // start recording
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
            // stop recoding
            changeButtonToStart()
            if(audioPlayer != nil && audioPlayer.isPlaying){
                audioPlayer.stop()
                audioPlayer = nil
                message.text = "Audio playing is stopped, tap agagin to restart"
            }
            else{
                audioRecorder.stop()
                audioRecorder = nil
                UserDefaults.standard.set(numberOfRecording, forKey: "recodingNumber")
                recordingTableView.reloadData()
                message.text = "Finished recording"
            }
        }
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
    
    func changeButtonToStop(){
        StartStopButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(recordORstop(_:)))
        toolBar.items![1] = StartStopButton
    }
    
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
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
            changeButtonToStop()
            audioPlayer.numberOfLoops = 0
            audioPlayer.delegate = self
            message.text = "Audio is playing..."
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
            changeButtonToStart()
            message.text = "Finished audio playing"
        }
    }
}
