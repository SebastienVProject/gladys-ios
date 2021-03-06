//
//  ViewController.swift
//  gladys
//
//  Created by utilisateur on 04/06/2017.
//  Copyright © 2017 SVInfo. All rights reserved.
//

import UIKit
import Speech
import SwiftyPlistManager

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    static var urlgladys: String!
    static var portgladys: String!
    static var audioServeur: Bool!
    static var audioApplication: Bool!
    static var fontSize: Int!
    static var fontSizeGladys: Int!
    static var fontStyle: String!
    static var fontStyleGladys: String!
    static var keyAPIGladys: String?
    static var gitAPIKey: String!
    var EnregEnCours: Bool! = false
    
    static var heightContainer: Double!
    
    @IBOutlet weak var imageGladys: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var scrollVue: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var MessageVue: UIView!
    
    @IBOutlet weak var labelMenuHelp: UIBarButtonItem!
    @IBOutlet weak var labelMenuParameter: UIBarButtonItem!
    
    var HandleDeleteAllBubble: ((UIAlertAction?) -> Void)!
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: NSLocalizedString("fr-FR", comment: "Language code for speech recognizer")))!
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var whatIwant = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelMenuParameter.title = NSLocalizedString("labelMenuParameter", comment: "Parameter label")
        
        microphoneButton.isEnabled = false
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        
        //on recupere les parametres de l'applicatif
        SwiftyPlistManager.shared.getValue(for: "urlGladys", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.urlgladys = result as? String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "portGladys", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.portgladys = result as? String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "audioApplication", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.audioApplication = result as? Bool
            }
        }
        SwiftyPlistManager.shared.getValue(for: "audioServeur", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.audioServeur = result as? Bool
            }
        }
        SwiftyPlistManager.shared.getValue(for: "fontSize", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.fontSize = result as? Int
            }
        }
        SwiftyPlistManager.shared.getValue(for: "fontSizeGladys", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.fontSizeGladys = result as? Int
            }
        }
        SwiftyPlistManager.shared.getValue(for: "fontStyle", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.fontStyle = result as? String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "fontStyleGladys", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.fontStyleGladys = result as? String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "keyApiGladys", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.keyAPIGladys = result as? String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "keyApiGit", fromPlistWithName: "parametresGit") { (result, err) in
            if err == nil {
                ViewController.gitAPIKey = result as? String
            }
        }

        ViewController.heightContainer = 10
        /*
         let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
         let blurEffectView = UIVisualEffectView(effect: blurEffect)
         blurEffectView.frame = imageGladys.bounds
         imageGladys.addSubview(blurEffectView)
         */
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 1.2
        scrollVue.addGestureRecognizer(lpgr)
        
        HandleDeleteAllBubble = { (action: UIAlertAction!) -> Void in
            while self.containerView.subviews.count > 0 {
                self.containerView.subviews.first?.removeFromSuperview()
            }
            ViewController.heightContainer = 10
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state != .began { return }
        let alert = UIAlertController(title: NSLocalizedString("deletePopupTitle", comment: "title of the popup to delete conversation"), message: NSLocalizedString("deletePopupMessage", comment: "message of the popup to delete conversation"), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("actionDelete", comment: "Delete action"), style: UIAlertAction.Style.destructive, handler: HandleDeleteAllBubble))
        alert.addAction(UIAlertAction(title: NSLocalizedString("actionCancel", comment: "Cancel action"), style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func microphoneTapped(_ sender: AnyObject) {
        ClicMicrophone()
    }
    
    func ClicMicrophone() {
        if EnregEnCours == true {
            microphoneButton.setTitle("Start Recording", for: .normal)
            microphoneButton.setImage(UIImage(named: "micro2.png"), for: .normal)
            print("3" + String(audioEngine.isRunning))
            audioEngine.stop()
            print("4" + String(audioEngine.isRunning))
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            EnregEnCours = false
        } else {
            microphoneButton.setTitle("Stop Recording", for: .normal)
            microphoneButton.setImage(UIImage(named: "micro2ON.png"), for: .normal)
            print("1" + String(audioEngine.isRunning))
            startRecording()
            print("2" + String(audioEngine.isRunning))
            EnregEnCours = true
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [ .defaultToSpeaker ])
            //try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            // Define the recorder setting
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        print(2.1)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        print(2.2)
        let audioEngineInputNode: AVAudioInputNode? = audioEngine.inputNode
        guard let inputNode = audioEngineInputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        print(2.3)
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
        print(2.8)
            var isFinal = false
            print(2.9)
            //print(result.debugDescription)
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                //self.whatIwant = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            print("2.10")
//print (error.debugDescription + " / " + String(isFinal))
            if error != nil || isFinal {
                print(2.11)
                self.audioEngine.stop()
                print(2.12)
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
                TraiterDemande(bulleText: self.textView.text, containerVue: self.containerView, scrollVue: self.scrollVue, messageVue: self.MessageVue)
            }
        })
        print(2.4)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        print(2.5)
        audioEngine.prepare()
        print(2.6)
        
        do {
            print("2.7.1" + String(audioEngine.isRunning))
            try audioEngine.start()
            print("2.7.2" + String(audioEngine.isRunning))
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = ""
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
