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
    var isFromBackGround = false
    var totalTime = 60
    
    @IBOutlet weak var messageLabel: UILabel!
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
        messageLabel.isHidden = true
        pickerView.isHidden = true
        setCirclePath()
        createBackProgressLayer()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // pause when app move to back ground(when user tap the home button)
    @objc func appMovedToBackground() {
        print("App moved to background!")
        isFromBackGround = true
        doPause()
        pauseAnimation()
    }
    
    // decide when start new timer, when continue old one
    override func viewDidAppear(_ animated: Bool) {
        self.foreProgressLayer = passforeProgressLayer
        self.animation = passanimation
        
        // begin a new start
        if(passTime == 0){
            timeLabel.text = formatTime(time: 0)
            startButton.setTitle("Start", for: .normal)
            startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
            pickerView.isHidden = false
        }
        // continue with last timer and animation
        else{
            time = passTime
            timeLabel.text = formatTime(time: time)
            doPause() // pause previous timer and animation
            pickerView.isHidden = true
            messageLabel.isHidden = false
            isFromBackGround = false
        }
    }
    
    // MARK: - set up timer
    
    // when start/pause Button is tapped
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
    
    // start timer and animation
    func doStart(){
        startResumeAnimation()
        startTimer()
        timerMode = .running
        startButton.setTitle("Pause", for: .normal)
        startButton.setTitleColor(UIColor.orange, for: .normal)
        pickerView.isHidden = true
        messageLabel.isHidden = false
    }
    
     // pause timer and animation
    func doPause(){
        pauseAnimation()
        timer.invalidate()
        timerMode = .initial
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
    }
    
    // stop timer
    func doStop(){
        timer.invalidate()
        timerMode = .initial
        time = 0
        timeLabel.text = "00:00"
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
        pickerView.isHidden = false
         messageLabel.isHidden = true
    }
    
    // cancel current timer and progress animation
    @IBAction func cancel(_ sender: Any) {
        stopAnimation()
        doStop()
    }
    
    // start timer, begin to count down
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    // timer count down every seconds
    @objc func updateTimer(){
        if(time <= 0){
            doStop()
            stopAnimation()
        }
        else{
            time -= 1
            timeLabel.text = formatTime(time: time)
        }
    }
    
    // display time format
    func formatTime(time: Int)->String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    // MARK: - set progress animation
    
    // draw the circle
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
    
    // whether start or resume animation
    func startResumeAnimation(){
        if(!isAniationStarted){
            startAnimation()
        }
        else{
            resumeAnimation()
        }
    }
    
    // start animation
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
    
    // pause animation
    func pauseAnimation(){
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 0.0
        foreProgressLayer.timeOffset = pausedTime
    }
    
    // resume an animation
    func resumeAnimation(){
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        let timeSincePaused = foreProgressLayer.convertTime(CACurrentMediaTime(), from:nil) - pausedTime
        foreProgressLayer.beginTime = timeSincePaused
    }
    
    // reset an animation
    func resetAnimation() {
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAniationStarted = false
    }
    
    // stop an animation
    func stopAnimation(){
        resetAnimation()
        foreProgressLayer.removeAllAnimations()
    }
    
    // when animation is called to stop
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // if the stop is not cause by view change or app move to back ground
        // means that timer's time is up, need to stop
        if(!isViewChange && !isFromBackGround){
            doStop()
            stopAnimation()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    // pass the current timer and animation to next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
