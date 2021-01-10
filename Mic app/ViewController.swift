//
//  ViewController.swift
//  Mic app
//
//  Created by admin on 1/8/21.
//  Copyright © 2021 admin. All rights reserved.
//

import UIKit
import Speech
class ViewController: UIViewController {
  @IBOutlet weak var lblTapToGetStarted:UILabel!
  @IBOutlet weak var hiddenview: UIView!
  @IBOutlet weak var texttobesearched: UILabel!
  var textt = ""

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  @IBAction func btnClic(_ sender: UIButton){
//    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//    let vc = storyboard.instantiateViewController(withIdentifier: "webVC") as! webVC
//    vc.texttobeSearched = textt
//    self.navigationController?.pushViewController(vc, animated: true)
//
    
  }
  @IBAction func btnClick(_ sender: UIButton){
   
    startSpeechRecognition()
    
    
  }
  
  
  private func startSpeechRecognition() {
    requestVoicePermission(completion: { (granted) in
      if granted {
        self.hiddenview.isHidden = false
        self.recordAndRecognizeSpeec()
        self.lblTapToGetStarted.text = "Listening ...."
        
        //searchBar.isUserInteractionEnabled = false
       
        
      }
    })
  }
  
  
    var speechRecognized = false // simple veriable
    //First, an instance of the AVAudioEngine class.
    // This will process the audio stream. It will give updates when the mic is receiving audio.
    var audioEngine = AVAudioEngine()
    //second, an instance of the speech recognizer.This will do the actual speech recognition. It can fail to recognize speech and return nil, so it’s best to make it an optional
    var speechReocognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    // By default, the speech recognizer will detect the devices locale and in response recognize the language appropriate to that geographical location
    // The default language can also be set by passing in a locale argument and identifier. Like this: let speechRecognizer: SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) .
    
    //Third, recognition request as SFSpeechAudioBufferRecognitionRequest. This allocates speech as the user speaks in real-time and controls the buffering. If the audio was pre-recorded and stored in memory you would use a SFSpeechURLRecognitionRequest instead.
    
    var request = SFSpeechAudioBufferRecognitionRequest()
    //Fourth, an instance of recognition task. This will be used to manage, cancel, or stop the current recognition task.
    var recognitionTask: SFSpeechRecognitionTask?
    
    //5. will perform the speech recognition. It will record and process the speech as it comes in.
    
    //audio engine uses what are called nodes to process bits of audio. Here .inputNode creates a singleton for the incoming audio. by apple "Nodes have input and output busses, which can be thought of as connection points"
    var recognizedTest = ""
    //MARK: Speech Recognition
    private func requestVoicePermission( completion: @escaping (Bool) -> () )  {
      let recordingSession = AVAudioSession()
      do {
        
        try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
        switch recordingSession.recordPermission {
        case AVAudioSessionRecordPermission.granted:
          print("Permission granted")
          SFSpeechRecognizer.requestAuthorization({ (authStatus) in
            OperationQueue.main.addOperation {
              switch authStatus {
              case .authorized:
                //self.recordButton.isEnabled = true
                completion(true)
              case .denied:
                completion(false)
                self.showToast(message: "Speech Recognition Permission not granted.")
              case .restricted:
                self.showToast(message: "Speech Recognition Permission Restricted.")
                completion(false)
              case .notDetermined:
                self.showToast(message: "Speech Recognition Permission not Determined.")
                completion(false)
              }
            }
          })
          
        //recordAndRecognizeSpeec()
        case AVAudioSessionRecordPermission.denied:
          
          print("user had denied Pemission earlier")
          let title = "Microphone permission not found"
          let mess = "Go to Settings -> Privacy -> Microphone, find Sell4Bids and tap on the switch to allow microphone to process your voice."
          let alert = UIAlertController(title: title, message: mess, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            completion(false)
          }))
          
          self.present(alert, animated: true, completion: nil)
          
        case AVAudioSessionRecordPermission.undetermined:
          
          print("Request permission here")
          
          // Handle granted
          recordingSession.requestRecordPermission(){ (allowed) in
            if allowed {
              SFSpeechRecognizer.requestAuthorization({ (authStatus) in
                OperationQueue.main.addOperation {
                  switch authStatus {
                  case .authorized:
                    //self.recordButton.isEnabled = true
                    completion(true)
                  case .denied:
                    completion(false)
                    self.showToast(message: "Speech Recognition Permission not granted.")
                  case .restricted:
                    self.showToast(message: "Speech Recognition Permission Restricted.")
                    completion(false)
                  case .notDetermined:
                    self.showToast(message: "Speech Recognition Permission not Determined.")
                    completion(false)
                  }
                }
              })
              
            } else {
              print("Denied")
              self.showToast(message: "Permission Denied.")
            }
            
          }
          
      
        }
      } catch {
        print("try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord) failed")
      }
    }
    var timer = Timer()
    private func recordAndRecognizeSpeec() {
      
      audioEngine = AVAudioEngine()
      speechReocognizer = SFSpeechRecognizer()
      request = SFSpeechAudioBufferRecognitionRequest()
      recognitionTask = SFSpeechRecognitionTask()
      let node = audioEngine.inputNode
      let recordingFormat = node.outputFormat(forBus: 0)
      //InstallTap configures the node and sets up the request instance with the proper buffer on the proper bus.
      node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
        self.request.append(buffer)
      }
      
      //When user did not speak for for seconds
      timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (timer) in
        //utilityFunctions.hide(view: self.imgFidget)
        print("4 seconds have been passed and you did not speak")
        self.lblTapToGetStarted.text = "Sorry, we did'nt get that. Tap on the microphone to try Again."
        
        //self.lblTapToGetStarted.text = ""
        //self.recognitionTask?.finish()
        self.audioEngine.stop()
  //      self.recognitionTask?.cancel()
        let node = self.audioEngine.inputNode
        node.removeTap(onBus: 0)

      }
      
      audioEngine.prepare()
      do{
        
        try audioEngine.start()
        //Then, make a few more checks to make sure the recognizer is available for the device and for the locale, since it will take into account location to get language
        guard  let myRecognizer = SFSpeechRecognizer() else {
          
          return
        }
        if !myRecognizer.isAvailable{
          //recognier not available right now
          print("recognizer not available")
          return
          
        }
        
        //Next, call the recognitionTask method on the recognizer. This is where the recognition happens.
        var timerDidFinishTalk = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
          
        })
        recognitionTask = speechReocognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
          guard let result = result else {
            print("There was an error: \(error!)")
            return
          }
          if self.timer.isValid { self.timer.invalidate() }
          timerDidFinishTalk.invalidate()
          timerDidFinishTalk = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                     let searchText = result.bestTranscription.formattedString
            
            DispatchQueue.main.async {
              self.lblTapToGetStarted.text = "Successfully recognized your speech."
              self.texttobesearched.text = searchText
              self.textt = searchText
             
              
//              self.searchBar.text = searchText
//              self.searchBar(self.searchBar, textDidChange: searchText)
              
            }
           
            self.speechRecognized = true
            self.recognitionTask?.finish()
            node.removeTap(onBus: 0)
            self.request.endAudio()
            self.recognitionTask = nil
            self.audioEngine.stop()
            
//            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//             let vc = storyboard.instantiateViewController(withIdentifier: "webVC") as! webVC
//            vc.texttobeSearched = self.textt
//             self.navigationController?.pushViewController(vc, animated: true)
//
          

          })
        })
        
      }catch{
        print("let result = result failed")
        return print(error)
      }
    }
    


}


extension UIViewController {
  
  func showToast(message : String) {
    let width :CGFloat = 250
    let font = UIFont.boldSystemFont(ofSize: 18)
    let height =  30
    let toastLabel = UILabel(frame: CGRect(x: 23, y: 40, width: 250, height: height))
    //toastLabel.center = self.view.center
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center;
    toastLabel.font = font
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
      toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
      toastLabel.removeFromSuperview()
    })
  }
  
}
