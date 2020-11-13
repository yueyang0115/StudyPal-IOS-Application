//
//  CounterViewController.swift
//  ECE564project
//
//  Created by 杨越 on 11/9/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit
import UserNotifications

class CounterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CAAnimationDelegate{

    var circlePath: UIBezierPath!
    var foreProgressLayer: CAShapeLayer!
    var passforeProgressLayer: CAShapeLayer!
    let backProgressLayer = CAShapeLayer()
    var animation: CABasicAnimation!
    var passanimation: CABasicAnimation!
    var isAniationStarted = false
    var isViewChange = false
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var selectPickerIndex = 0
    
    var timer = Timer()
    var time:Int = 0
    var passTime:Int = 0
    var timerMode: TimerMode = .initial
    let availableMinutes = Array(1...60)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isViewChange = false
        timeLabel.text = ""
        setCirclePath()
        createBackProgressLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.foreProgressLayer = passforeProgressLayer
        self.animation = passanimation
        
        // begin a new start
        if(passTime == 0){
            timeLabel.text = formatTime(time: 0)
            startButton.setTitle("Start", for: .normal)
            startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
        }
        // continue with last timer and animation
        else{
            time = passTime
            timeLabel.text = formatTime(time: time)
            doPause() // pause previous timer and animation
            pickerView.isHidden = true
        }
    }
    
    // MARK: - set up timer
    @IBAction func controlTimer(_ sender: Any) {
        if(timerMode == .initial){
            if(time != 0){ // start new timer and progress animation
                createForeProgressLayer()
                doStart()
            }
        }
        else{ // pause timer and progress animation
            doPause()
        }
    }
    
    func doStart(){
        startResumeAnimation()
        startTimer()
        timerMode = .running
        startButton.setTitle("Pause", for: .normal)
        startButton.setTitleColor(UIColor.orange, for: .normal)
        pickerView.isHidden = true
    }
    
    func doPause(){
        pauseAnimation()
        timer.invalidate()
        timerMode = .initial
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
    }
    
    func doStop(){
        timer.invalidate()
        timerMode = .initial
        time = 0
        timeLabel.text = "00:00"
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
        pickerView.isHidden = false
    }
    
    // cancel current timer and progress animation
    @IBAction func cancel(_ sender: Any) {
        stopAnimation()
        doStop()
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        if(time <= 0){
            doStop()
        }
        else{
            time -= 1
            timeLabel.text = formatTime(time: time)
        }
    }
    
    func formatTime(time: Int)->String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    // MARK: - set progress animation
    
    func setCirclePath(){
        circlePath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    }
    
    // draw progress circle background circle
    func createBackProgressLayer(){
        backProgressLayer.path = circlePath.cgPath
        backProgressLayer.strokeColor = UIColor.trackStrokeColor.cgColor
        backProgressLayer.lineWidth = 20
        backProgressLayer.fillColor = UIColor.clear.cgColor
        backProgressLayer.lineCap = .round
        backProgressLayer.position = view.center
        view.layer.addSublayer(backProgressLayer)
    }
        
     // draw progress circle foreground circle
    func createForeProgressLayer() {
        foreProgressLayer.path = circlePath.cgPath
        foreProgressLayer.strokeColor = UIColor.outlineStrokeColor.cgColor
        foreProgressLayer.lineWidth = 20
        foreProgressLayer.fillColor = UIColor.clear.cgColor
        foreProgressLayer.lineCap = .round
        foreProgressLayer.position = view.center
        foreProgressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        view.layer.addSublayer(foreProgressLayer)
    }
    
    func startResumeAnimation(){
        if(!isAniationStarted){
            startAnimation()
        }
        else{
            resumeAnimation()
        }
    }
    
    func startAnimation() {
        resetAnimation()
        foreProgressLayer.strokeEnd = 0.0
        animation.keyPath = "strokeEnd"
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = CFTimeInterval(time)
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        foreProgressLayer.add(animation, forKey: "strokeEnd")
        isAniationStarted = true
    }
    
    func pauseAnimation(){
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 0.0
        foreProgressLayer.timeOffset = pausedTime
    }
    
    func resumeAnimation(){
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        let timeSincePaused = foreProgressLayer.convertTime(CACurrentMediaTime(), from:nil) - pausedTime
        foreProgressLayer.beginTime = timeSincePaused
    }
    
    func resetAnimation() {
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAniationStarted = false
    }
    
    func stopAnimation(){
        resetAnimation()
        foreProgressLayer.removeAllAnimations()
    }
    
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if(!isViewChange){
            doStop()
            stopAnimation()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        isViewChange = true
        pauseAnimation()
        timer.invalidate()
        timerMode = .initial
    }

     // MARK: - set up pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let res: String = "\(availableMinutes[row]) min"
        //time = availableMinutes[row] * 60
        return NSAttributedString(string: res, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableMinutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        time = availableMinutes[row] * 60
        timeLabel.text = formatTime(time: availableMinutes[row] * 60)
    }
}
