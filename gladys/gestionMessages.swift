//
//  gestionMessages.swift
//  gladys
//
//  Created by utilisateur on 04/06/2017.
//  Copyright © 2017 SVInfo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Speech

var montexte: UITextView!
var reponseGladys: UITextView!
var imageGladys: UIImageView!
var bulle: UITextView!

let distanceApresBulleGladys = 30.0
let distanceApresBulleUser = 10.0

let speechSynthesizer = AVSpeechSynthesizer()

public func TraiterDemande(bulleText: String, containerVue: UIView, scrollVue: UIScrollView, messageVue: UIView){
    if !bulleText.isEmpty {
        AjouterBulle(gladys: false, bulleText: bulleText, containerVue: containerVue, scrollVue: scrollVue, messageVue: messageVue)
        
        let URL_GET = ViewController.urlgladys + ":" + ViewController.portgladys + "/brain/classify"
        var PARAMS : Parameters = [:]
        PARAMS["q"] = bulleText
//        if !ViewController.audioServeur {
//            PARAMS["mute"] = "true"
//        } else {
//            PARAMS["mute"] = "false"
//        }
        if let keyApiGladys = ViewController.keyAPIGladys {
            if !(keyApiGladys.isEmpty) {
                PARAMS["token"] = ViewController.keyAPIGladys
            }
        }
  
        var reponseGladysOK = false
        Alamofire.request(URL_GET, parameters: PARAMS).responseJSON { response in
            
            if response.result.isSuccess {
                reponseGladysOK = true
                if response.result.value is NSArray {
                    if let retour = response.result.value as? NSArray
                    {
                        if retour.count > 0 {
                            let JSON = retour[0] as! NSDictionary
                            if let answer = JSON["response"] as? NSDictionary{
                                
                                AjouterBulle(gladys: true, bulleText: answer["text"]! as! String, containerVue: containerVue, scrollVue: scrollVue, messageVue: messageVue)
                                if ViewController.audioApplication {
                                    ReponseAudioDevice(reponse: answer["text"]! as! String)
                                }
                            }
                        } else {
                            let messageGladys: String = NSLocalizedString("APIReponseEmptyArray", comment: "APIReponseEmptyArray")
                            AjouterBulle(gladys: true, bulleText: messageGladys, containerVue: containerVue, scrollVue: scrollVue, messageVue: messageVue)
                            if ViewController.audioApplication {
                                ReponseAudioDevice(reponse: messageGladys)
                            }
                        }
                    }
                } else {
                    //print("le retour n'a pas la forme d'un tableau")
                    let JSON = response.result.value as! NSDictionary
                    let messageGladys: String = NSLocalizedString("APIReponseNotArray", comment: "APIReponseNotArray") + (JSON["error"] as! String)
                    AjouterBulle(gladys: true, bulleText: messageGladys, containerVue: containerVue, scrollVue: scrollVue, messageVue: messageVue)
                    if ViewController.audioApplication {
                        ReponseAudioDevice(reponse: messageGladys)
                    }
                }
            } else {
                print("Requete invalide")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            if !reponseGladysOK {
                //pas de wifi - requete KO
                let messageGladys = NSLocalizedString("technicalError", comment: "Technical error")
                AjouterBulle(gladys: true, bulleText: messageGladys, containerVue: containerVue, scrollVue: scrollVue, messageVue: messageVue)
                if ViewController.audioApplication {
                    ReponseAudioDevice(reponse: messageGladys)
                }
            }
        })
    }
}

public func ReponseAudioDevice(reponse: String){
    
    let speechUtterance = AVSpeechUtterance(string: reponse)
    speechUtterance.voice=AVSpeechSynthesisVoice(language: NSLocalizedString("codeLangue", comment: "code langue"))
    //speechUtterance.volume = 10
    speechSynthesizer.speak(speechUtterance)
}

public func AjouterBulle(gladys: Bool, bulleText: String, containerVue: UIView, scrollVue: UIScrollView, messageVue: UIView){
    
    let bulleFontSize = ViewController.fontSize
    let bulleFontSizeGladys = ViewController.fontSizeGladys
    let bulleFontName = ViewController.fontStyle
    let bulleFontNameGladys = ViewController.fontStyleGladys
    
    var positionBulleSuivante = 10.0
    
    if containerVue.subviews.count > 0 {
        if let lastComponent = containerVue.subviews[containerVue.subviews.count - 1] as? UITextView{
            if gladys {
                positionBulleSuivante = Double(lastComponent.frame.maxY) + distanceApresBulleUser
            } else  {
                positionBulleSuivante = Double(lastComponent.frame.maxY) + distanceApresBulleGladys
            }
        }
    } else {
        if gladys {
            positionBulleSuivante = distanceApresBulleUser
        } else  {
            positionBulleSuivante = distanceApresBulleGladys
        }
    }
    
    let bulleLargeur : Double = (Double(UIScreen.main.bounds.size.width)*70.0)/100.0
    var bulleLeft : Double
    if gladys {
        bulleLeft = 45.0
    } else {
        bulleLeft = Double(UIScreen.main.bounds.size.width) - bulleLargeur - 25
    }
    
    //gestion de l'avatar
    if gladys {
        imageGladys = UIImageView(image: UIImage(named: "gladysWhite.png"))
        imageGladys.frame = CGRect(x: 3, y: positionBulleSuivante, width: 47, height: 48)
        //self.view.addSubview
        containerVue.addSubview(imageGladys)
    } else {
        imageGladys = UIImageView(image: UIImage(named: "blueBulle.png"))
        imageGladys.frame = CGRect(x: Double(UIScreen.main.bounds.size.width) - 30, y: positionBulleSuivante, width: 8, height: 14)
        containerVue.addSubview(imageGladys)
    }
    
    //gestion de la bulle à afficher
    //couleurBulle = UIColor(red: 241/255, green: 23/255, blue: 193/255, alpha: 1)      couleur verte sympa
    //couleurBulle = UIColor(red: 1/255, green: 144/255, blue: 146/255, alpha: 1)       couleur fushia
    var couleurBulle : UIColor
    var policeBulle : String
    var policeSizeBulle : Int
    var couleurTexte : UIColor
    if gladys {
        couleurBulle = UIColor.white
        policeBulle = bulleFontNameGladys!
        policeSizeBulle = bulleFontSizeGladys!
        couleurTexte = UIColor(red: 241/255, green: 23/255, blue: 193/255, alpha: 1)
    } else {
        couleurBulle = UIColor(red: 1/255, green: 144/255, blue: 146/255, alpha: 1)
        policeBulle = bulleFontName!
        policeSizeBulle = bulleFontSize!
        couleurTexte = UIColor.white
    }
    bulle = UITextView()
    bulle.backgroundColor = couleurBulle
    bulle.textColor = couleurTexte
    bulle.layer.cornerRadius = 10
    bulle.font = UIFont(name: policeBulle, size: CGFloat(policeSizeBulle))
    bulle.text = bulleText
    bulle.frame = CGRect(x: bulleLeft, y: positionBulleSuivante, width: bulleLargeur, height: 80.0)
    bulle.isScrollEnabled = false
    bulle.isEditable = false
    
    //ajustement de la hauteur de la bulle en fonction de son contenu
    let fixedWidth = bulle.frame.size.width
    bulle.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    let newSize = bulle.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    var newFrame = bulle.frame
    newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    bulle.frame = newFrame;
    
    containerVue.addSubview(bulle)

    let fixedWidthContainer = containerVue.frame.size.width
    containerVue.sizeThatFits(CGSize(width: fixedWidthContainer, height: CGFloat.greatestFiniteMagnitude))
    
    containerVue.frame.size.height = CGFloat(ViewController.heightContainer) + 30 + newFrame.size.height
    ViewController.heightContainer = Double(containerVue.frame.size.height)
    
    scrollVue.contentSize = containerVue.frame.size    

    let ecartY = containerVue.frame.size.height - messageVue.frame.size.height

    if ecartY > 0 {
        let scrollPoint = CGPoint(x: 0, y: ecartY+40)
        scrollVue.setContentOffset(scrollPoint, animated: false)//Set false if you doesn't want animation
    }
}
