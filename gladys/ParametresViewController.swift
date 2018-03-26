//
//  ParametresViewController.swift
//  gladys
//
//  Created by utilisateur on 05/06/2017.
//  Copyright © 2017 SVInfo. All rights reserved.
//

import UIKit
import SwiftyPlistManager

class ParametresViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var urlGladysText: UITextField!
    @IBOutlet weak var portGladysText: UITextField!
    @IBOutlet weak var keyAPIGladys: UITextField!
    @IBOutlet weak var swichAudioServeur: UISwitch!
    @IBOutlet weak var swichAudioApplication: UISwitch!
    @IBOutlet weak var sizeFontBubble: UITextField!
    @IBOutlet weak var sizeFontBubbleGladys: UITextField!
    @IBOutlet weak var sizeFontBubbleStepper: UIStepper!
    @IBOutlet weak var sizeFontBubbleGladysStepper: UIStepper!

    @IBOutlet weak var taillePoliceText: UITextField!
    @IBOutlet weak var taillePoliceGladysText: UITextField!
    
    @IBOutlet weak var labelUrl: UILabel!
    @IBOutlet weak var labelPort: UILabel!
    @IBOutlet weak var labelAPIKey: UILabel!
    @IBOutlet weak var labelAudioServer: UILabel!
    @IBOutlet weak var labelAudioApplication: UILabel!
    @IBOutlet weak var labelFont: UILabel!
    @IBOutlet weak var labelFontGladys: UILabel!
    @IBOutlet weak var imageGladysParam: UIImageView!
    @IBOutlet var GlobalView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        urlGladysText.text = ViewController.urlgladys
        portGladysText.text = ViewController.portgladys
        swichAudioServeur.setOn(ViewController.audioServeur, animated: false)
        swichAudioApplication.setOn(ViewController.audioApplication, animated: false)
        sizeFontBubble.text = String(ViewController.fontSize)
        sizeFontBubbleGladys.text = String(ViewController.fontSizeGladys)
        sizeFontBubbleStepper.value = Double(ViewController.fontSize)
        sizeFontBubbleGladysStepper.value = Double(ViewController.fontSizeGladys)
        keyAPIGladys.text = ViewController.keyAPIGladys
        
        labelUrl.text = NSLocalizedString("ParamLabelUrl", comment: "Enter URL")
        labelPort.text = NSLocalizedString("ParamLabelPort", comment: "Enter port number")
        labelAPIKey.text = NSLocalizedString("ParamLabelAPIKey", comment: "Enter API Key for Gladys")
        labelAudioServer.text = NSLocalizedString("ParamLabelAudioServeur", comment: "enabling audio on the server")
        labelAudioApplication.text = NSLocalizedString("ParamLabelAudioAppli", comment: "enabling audio in the application")
        labelFont.text = NSLocalizedString("ParamFont", comment: "font size in the bubble")
        labelFontGladys.text = NSLocalizedString("ParamFontGladys", comment: "font size in the gladys bubble")
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = GlobalView.bounds
        imageGladysParam.addSubview(blurEffectView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HelpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
//        if UIDevice.current.model == "iPad" {
//            //on adapte la taille de police au format tablette
//            let ajustement: CGFloat = 10
//            labelUrl.font = labelUrl.font.withSize(labelUrl.font.pointSize + ajustement)
//            labelPort.font = labelPort.font.withSize(labelPort.font.pointSize + ajustement)
//            labelAPIKey.font = labelAPIKey.font.withSize(labelAPIKey.font.pointSize + ajustement)
//            labelAudioServer.font = labelAudioServer.font.withSize(labelAudioServer.font.pointSize + ajustement)
//            labelAudioApplication.font = labelAudioApplication.font.withSize(labelAudioApplication.font.pointSize + ajustement)
//            labelFont.font = labelFont.font.withSize(labelFont.font.pointSize + ajustement)
//            labelFontGladys.font = labelFontGladys.font.withSize(labelFontGladys.font.pointSize + ajustement)
//            
//            urlGladysText.font = urlGladysText.font?.withSize((urlGladysText.font?.pointSize)! + ajustement)
//            portGladysText.font = portGladysText.font?.withSize((portGladysText.font?.pointSize)! + ajustement)
//            keyAPIGladys.font = keyAPIGladys.font?.withSize((keyAPIGladys.font?.pointSize)! + ajustement)
//            taillePoliceText.font = taillePoliceText.font?.withSize((taillePoliceText.font?.pointSize)! + ajustement)
//            taillePoliceGladysText.font = taillePoliceGladysText.font?.withSize((taillePoliceGladysText.font?.pointSize)! + ajustement)
//        }
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateAudioServeur(_ sender: UISwitch) {
        ViewController.audioServeur = sender.isOn
        updatePlistParametres(key: "audioServeur", valeur: ViewController.audioServeur)
    }
    @IBAction func updateAudioApplication(_ sender: UISwitch) {
        ViewController.audioApplication = sender.isOn
        updatePlistParametres(key: "audioApplication", valeur: ViewController.audioApplication)
    }
    
    @IBAction func updateUrlGladys(_ sender: UITextField) {
        ViewController.urlgladys = sender.text
        updatePlistParametres(key: "urlGladys", valeur: ViewController.urlgladys)
    }

    @IBAction func updatePortGladys(_ sender: UITextField) {
        ViewController.portgladys = sender.text
        updatePlistParametres(key: "portGladys", valeur: ViewController.portgladys)
    }
    
    @IBAction func updateKeyApiGladys(_ sender: UITextField) {
        ViewController.keyAPIGladys = sender.text
        updatePlistParametres(key: "keyApiGladys", valeur: ViewController.keyAPIGladys ?? "")
    }
    
    func updatePlistParametres(key: String, valeur: Any){
        
        SwiftyPlistManager.shared.save(valeur, forKey: key, toPlistWithName: "parametres") { (err) in
            if err == nil {
                print("Value successfully saved into plist.")
            }
        }
       
    }
    
    @IBAction func updateFontSizeBubble(_ sender: UIStepper) {
        sizeFontBubble.text = String(Int(sender.value))
        ViewController.fontSize = Int(sender.value)
        updatePlistParametres(key: "fontSize", valeur: ViewController.fontSize)
    }
    
    @IBAction func updateFontSizeBubbleGladys(_ sender: UIStepper) {
        sizeFontBubbleGladys.text = String(Int(sender.value))
        ViewController.fontSizeGladys = Int(sender.value)
        updatePlistParametres(key: "fontSizeGladys", valeur: ViewController.fontSizeGladys)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
