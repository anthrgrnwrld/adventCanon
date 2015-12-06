//
//  ViewController.swift
//  AdventCanon
//
//  Created by Masaki Horimoto on 2015/11/27.
//  Copyright © 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, AVAudioPlayerDelegate, GADBannerViewDelegate {
    
    @IBOutlet var backgroundButtonArray: [UIView]!
    @IBOutlet weak var parentVolumeView: UIView!
    
    enum playingState: Int {
        case stop
        case wait
        case play
        case mute
    }

    var instrumentArray: [AVAudioPlayer]? = []
    var instrumentStateArray: [playingState]? = []
    let filenameArray: [NSString] = ["0_cello","1_violin_patternA","2_violin_patternB","3_violin_patternC","4_violin_patternD","5_violin_patternE","0_cello","1_violin_patternA","2_violin_patternB","3_violin_patternC","4_violin_patternD","5_violin_patternE","0_cello"]
    let fileExtension: String = "m4a"
    var count: Int = 0
    let soundNumber = 6
    var playingStateArray: [playingState] = [.stop, .stop, .stop, .stop, .stop, .stop]
    let defalutVolume : Float = 0.8
    let dateFormatter = NSDateFormatter()
    var canPlayArray: [Bool] = [false, false, false, false, false]
    let strOpenDateArray: [String] = ["2015/11/29", "2015/12/06", "2015/12/13", "2015/12/20", "2015/12/24"]    //本番用
    //let strOpenDateArray: [String] = ["2015/11/29", "2015/11/29", "2015/11/29", "2015/11/29", "2015/11/29"]    //Debug用
    
    let YOUR_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let TEST_DEVICE_ID = "61b0154xxxxxxxxxxxxxxxxxxxxxxxe0" // Enter Test ID here
    let AdMobTest:Bool = true
    let SimulatorTest:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let encodeFileURLArray = getInstrumentFileURL(filenameArray)

        for (index, _) in encodeFileURLArray.enumerate() {
            
            do {
                instrumentArray?.append(try AVAudioPlayer(contentsOfURL: encodeFileURLArray[index]))
                instrumentArray![index].numberOfLoops = 0
                instrumentArray![index].volume = defalutVolume
                instrumentArray![index].prepareToPlay()
            } catch {
                fatalError("Failed to initialize a player.")
            }
            
        }
        
        let bannerView:GADBannerView = getAdBannerView()
        self.view.addSubview(bannerView)
        
        for var i = 0; i < (soundNumber - 1); i++ {
            backgroundButtonArray[i].layer.cornerRadius = 15.0
            backgroundButtonArray[i].layer.borderWidth = 2
        }
        
        getCurrectDate()

        let volumeView = MPVolumeView(frame: parentVolumeView.bounds)
        parentVolumeView.addSubview(volumeView)

        instrumentArray!.last!.delegate = self
        instrumentArray!.last!.volume = 0
        instrumentArray!.last!.numberOfLoops = 0
        instrumentArray!.last!.play()
        
        instrumentArray![0].play()
        playingStateArray[0] = .play
        
    }

    /*
    ロケールは無視
    
    */
    func getCurrectDate() {
        
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        var openDateArray: [NSDate] = []
        
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") //地域の設定
        dateFormatter.timeStyle = .NoStyle      //時刻非表示
        dateFormatter.dateStyle = .ShortStyle   //短い形式で日付を表示
        
        print("\(dateFormatter.stringFromDate(now))")
        
        for var i = 0; i < strOpenDateArray.count; i++ {
            
            openDateArray.append(dateFormatter.dateFromString(strOpenDateArray[i])!)
            let rawValue = now.compare(openDateArray[i]).rawValue

            if rawValue < 0 {
                canPlayArray[i] = false
                backgroundButtonArray[i].layer.opacity = 0.4
                backgroundButtonArray[i].backgroundColor = UIColor.grayColor()
            } else {
                canPlayArray[i] = true
                backgroundButtonArray[i].layer.opacity = 0.05
                backgroundButtonArray[i].backgroundColor = UIColor.grayColor()
            }
            
        }

    }
    
    private func getAdBannerView() -> GADBannerView {
        var bannerView: GADBannerView = GADBannerView()
        
        let myBoundSize = UIScreen.mainScreen().bounds.size  // Windowの表示領域を取得する。(広告の表示サイズのために使用する)
        if myBoundSize.width > 320 {
            bannerView = GADBannerView(adSize:kGADAdSizeFullBanner)
            bannerView.frame.origin = CGPointMake(0, self.view.frame.size.height - kGADAdSizeFullBanner.size.height)
        } else {
            bannerView = GADBannerView(adSize:kGADAdSizeBanner)
            bannerView.frame.origin = CGPointMake(0, self.view.frame.size.height - kGADAdSizeBanner.size.height)
        }
        
        bannerView.frame.size = CGSizeMake(self.view.frame.width, bannerView.frame.height)
        bannerView.adUnitID = "\(YOUR_ID)"
        bannerView.delegate = self
        bannerView.rootViewController = self
        
        let request:GADRequest = GADRequest()
        
        if AdMobTest {
            if SimulatorTest {
                request.testDevices = [kGADSimulatorID]
            } else {
                request.testDevices = [TEST_DEVICE_ID]
            }
        }
        
        bannerView.loadRequest(request)
        
        return bannerView
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        //print("\(__FUNCTION__) is called!")
        
        if player == instrumentArray!.last! {
            
            didfinishLoop()
            
        }
        
    }
    
    func judgePlayOrNot(player: AVAudioPlayer, state: playingState) -> playingState {

        var rtState: playingState = .stop
        
        switch state {
            
        case .stop:
            rtState = .stop
        case .wait:
            player.play()
            rtState = .play
        case .play:
            player.volume = defalutVolume
            player.play()
            rtState = .play
        case .mute:
            player.volume = 0
            player.play()
            rtState = .mute
            
        }
        
        return rtState
        
    }
    
    func didfinishLoop() {
        
        //print("\(__FUNCTION__) is called!")

        count++
        
        if count % 2 != 0 {
            
            for var i = 0; i < soundNumber; i++ {

                instrumentArray![i].stop()
                let rtState = judgePlayOrNot(instrumentArray![i + soundNumber], state: playingStateArray[i])
                playingStateArray[i] = rtState
                
                if i != 0 {
                    setIconBackgroudColorByLoopEnd(i)
                }
                
            }
            
        } else {
            
            for var i = 0; i < soundNumber; i++ {
                
                instrumentArray![i + soundNumber].stop()
                let rtState = judgePlayOrNot(instrumentArray![i], state: playingStateArray[i])
                playingStateArray[i] = rtState
                
                if i != 0 {
                    setIconBackgroudColorByLoopEnd(i)
                }
                
            }
            
        }

        instrumentArray!.last!.play()
        
    }
    
    func setIconBackgroudColorByLoopEnd(index: Int) {

        if playingStateArray[index] == .play {
            finishBlinkAnimationWithView(backgroundButtonArray[index - 1])
            backgroundButtonArray[index - 1].layer.opacity = 0.2
            backgroundButtonArray[index - 1].backgroundColor = UIColor.greenColor()
        } else if playingStateArray[index] == .mute {
            backgroundButtonArray[index - 1].layer.opacity = 0.05
            backgroundButtonArray[index - 1].backgroundColor = UIColor.grayColor()
        }
        
    }

    /**
     プロジェクト内に保存したファイル名からURLを作成する
     
     - parameter filenameArray: NSString型の配列で通常プロジェクト内のファイル名が入っていると想定
     - returns: NSURL型の配列を返す
    */
    func getInstrumentFileURL(filenameArray:[NSString]) -> [NSURL] {
        
        var encodeFileURLArray: [NSURL] = []
        
        for (index, _) in self.filenameArray.enumerate() {
            
            guard let encFilename = filenameArray[index].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
                
                fatalError("[L\(__LINE__)]Filename is nil.")
                
            }
            
            guard let fileURL = NSBundle.mainBundle().URLForResource(encFilename, withExtension: fileExtension) else {
                
                fatalError("[L\(__LINE__)]Url is nil.")
                
            }
            
            encodeFileURLArray.append(fileURL)
            
        }

        return encodeFileURLArray
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func pressInstrument1(sender: AnyObject) {
        
        //print("\(__FUNCTION__) is called!")
        
        let buttonNumber = 1

        pressInstrument(buttonNumber)

    }
    
    @IBAction func pressInstrument2(sender: AnyObject) {
        
        //print("\(__FUNCTION__) is called!")
        
        let buttonNumber = 2
        
        pressInstrument(buttonNumber)
        
    }
    
    @IBAction func pressInstrument3(sender: AnyObject) {
        
        //print("\(__FUNCTION__) is called!")
        
        let buttonNumber = 3
        
        pressInstrument(buttonNumber)
        
    }
    
    @IBAction func pressInstrument4(sender: AnyObject) {
        
        //print("\(__FUNCTION__) is called!")
        
        let buttonNumber = 4
        
        pressInstrument(buttonNumber)        
    }
    
    @IBAction func pressInstrument5(sender: AnyObject) {
        
        //print("\(__FUNCTION__) is called!")
        
        let buttonNumber = 5
        
        pressInstrument(buttonNumber)

    }
    
    func pressInstrument(buttonNumber :Int) {
 
        if canPlayArray[buttonNumber - 1] == false {
            showAlert(strOpenDateArray[buttonNumber - 1])
            return
        }
        
        changeStateByPressingButton(buttonNumber)
        setIconBackgroudColorByPressingButton(buttonNumber)
        
    }
    
    
    func changeStateByPressingButton(buttonNumber: Int) {
        
        //print("\(__FUNCTION__) is called! buttonNumber is \(buttonNumber)")
        
        switch playingStateArray[buttonNumber] {
            
        case .stop:
            if count % 2 != 0 {
                instrumentArray![buttonNumber + soundNumber].prepareToPlay()
            } else {
                instrumentArray![buttonNumber].prepareToPlay()
            }
            
            playingStateArray[buttonNumber] = .wait
            
            
        case .wait:
            if count % 2 != 0 {
                instrumentArray![buttonNumber + soundNumber].prepareToPlay()
            } else {
                instrumentArray![buttonNumber].prepareToPlay()
            }
            
            playingStateArray[buttonNumber] = .stop
            
        case .play:
            if count % 2 != 0 {
                instrumentArray![buttonNumber + soundNumber].volume = 0
            } else {
                instrumentArray![buttonNumber].volume = 0
            }
            
            playingStateArray[buttonNumber] = .mute
            
        case .mute:
            if count % 2 != 0 {
                instrumentArray![buttonNumber + soundNumber].volume = defalutVolume
            } else {
                instrumentArray![buttonNumber].volume = defalutVolume
            }
            
            playingStateArray[buttonNumber] = .play
            
        }
        
        print("change playingStateArray[\(buttonNumber)] to \(playingStateArray[buttonNumber])")
        
    }
    
    func setIconBackgroudColorByPressingButton(buttonNumber: Int) {
        
        switch playingStateArray[buttonNumber] {
        case .wait:
            backgroundButtonArray[buttonNumber - 1].layer.opacity = 0.2
            backgroundButtonArray[buttonNumber - 1].backgroundColor = UIColor.greenColor()
            blinkAnimationWithView(backgroundButtonArray[buttonNumber - 1])
        case .mute:
            backgroundButtonArray[buttonNumber - 1].layer.opacity = 0.05
            backgroundButtonArray[buttonNumber - 1].backgroundColor = UIColor.grayColor()
        case .play:
            backgroundButtonArray[buttonNumber - 1].layer.opacity = 0.2
            backgroundButtonArray[buttonNumber - 1].backgroundColor = UIColor.greenColor()
        case .stop:
            finishBlinkAnimationWithView(backgroundButtonArray[buttonNumber - 1])
        }
        
    }

    let alertTitle:String = NSLocalizedString("alertTitle", comment: "アラートのタイトル")
    let alertMessage1:String = NSLocalizedString("alertMessage1", comment: "アラートのメッセージ1")
    let alertMessage2:String = NSLocalizedString("alertMessage2", comment: "アラートのメッセージ2")
    let actionTitle = "OK"
    
    func showAlert(strDate: String) {

        // Style Alert
        let alert: UIAlertController = UIAlertController(
            title:alertTitle,
            message: alertMessage1 + strDate + alertMessage2,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        // Default 複数指定可
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                print("OK")
        })
        
        // AddAction 記述順に反映される
        alert.addAction(defaultAction)
        
        // Display
        presentViewController(alert, animated: true, completion: nil)
        
    }

    /**
     指定されたViewを1秒間隔で点滅させる
     
     :param: view:点滅させるView
     */
    func blinkAnimationWithView(view :UIView) {
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.Repeat, animations: { () -> Void in
            view.alpha = 0
            }, completion: nil)
    }
    
    /**
     指定されたViewの点滅アニメーションを終了する
     
     :param: view:点滅を終了するView
     */
    func finishBlinkAnimationWithView(view :UIView) {
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.animateWithDuration(0.001, animations: {
            view.alpha = 1.0
        })
        //        //こっちの方法でもOK
        //        view.layer.removeAllAnimations()
        //        view.alpha = 1.0
    }
    
//    /**
//     タイマー関数。1秒毎に呼び出される。
//     */
//    func updateTimer() {
//        //println("\(__FUNCTION__) is called")
//        
//        countupTimer++                                      //countupTimerをインクリメント
//        let countdownTimer = editTimerCount(countupTimer)   //カウントアップ表記をカウントダウン表記へ変換
//        updateTimerLabel(countdownTimer)                    //タイマー表示ラベルをアップデート
//        
//        if countdownTimer <= 0 {timeupFunc()}               //ゲーム開始より10秒経過後、ゲーム完了処理を実行
//        
//        print("\(__FUNCTION__) is called! \(countupTimer)")
//    }
//    
//    /**
//     ゲーム完了時に実行する関数。
//     */
//    func timeupFunc() {
//        
//        let highScoreFlag = countPushing > highScore ? true : false
//        highScore = countPushing > highScore ? countPushing : highScore
//        timerState = false
//        startState = false
//        timer.invalidate()
//        print("highScore is \(highScore)")
//        ud.setInteger(highScore, forKey: udKey)     //ハイスコアをNSUserDefaultsのインスタンスに保存
//        ud.synchronize()                            //保存する情報の反映
//        GKScoreUtil.reportScores(highScore, leaderboardid: leaderboardid)   //GameCenter Score Transration
//        
//        //ハイスコア更新の場合にはimageBeeとカウンタ表示を点滅させる & サウンドを再生する & スクリーンキャプチャ
//        if highScoreFlag {
//            capturedImage = GetImage() as UIImage     // キャプチャ画像を取得.
//            AudioServicesPlaySystemSoundWithoutVibration("alarm.caf")
//            blinkAnimationWithView(imageBee)
//            for (_, view) in self.counterDigit.enumerate() {
//                blinkAnimationWithView(view)
//            }
//        }
//        
//        
//    }
//    
//    /**
//     指定されたViewを1秒間隔で点滅させる
//     
//     :param: view:点滅させるView
//     */
//    func blinkAnimationWithView(view :UIView) {
//        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.Repeat, animations: { () -> Void in
//            view.alpha = 0
//            }, completion: nil)
//    }
//    
//    /**
//     指定されたViewの点滅アニメーションを終了する
//     
//     :param: view:点滅を終了するView
//     */
//    func finishBlinkAnimationWithView(view :UIView) {
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.animateWithDuration(0.001, animations: {
//            view.alpha = 1.0
//        })
//        //        //こっちの方法でもOK
//        //        view.layer.removeAllAnimations()
//        //        view.alpha = 1.0
//    }


}

