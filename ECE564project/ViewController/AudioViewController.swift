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
    
    @IBOutlet weak var recordingTableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
    
    @IBAction func record(_ sender: Any) {
        if(audioRecorder == nil){
            numberOfRecording += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecording).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
            // start recording
            do{
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                startButton.setTitle("stop Recording", for: .normal)
            }
            catch{
                displayAlert(title: "Ups!", message: "Recording failed!")
            }
        }
        else{
            // stop recoding
            audioRecorder.stop()
            audioRecorder = nil
            
            UserDefaults.standard.set(numberOfRecording, forKey: "recodingNumber")
            recordingTableView.reloadData()
            startButton.setTitle("start Recording", for: .normal)
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
    
    // MARK: - table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecording
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1) // name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row+1).m4a")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
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
