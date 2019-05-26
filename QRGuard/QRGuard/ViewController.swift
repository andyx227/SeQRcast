//
//  ViewController.swift
//  QRGuard
//
//  Created by Andy Xue on 5/13/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import CryptoSwift
import CommonCrypto
import SwiftyRSA

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var importImageButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QRCode.scanQRCode(view: self.view, delegate: self)
        //swipeDetector()
        setShadowForButton(importImageButton)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        //QRCode.scanQRCode(view: self.view, delegate: self)
        //swipeDetector()
    }
    
    func setShadowForButton(_ button: UIButton) {
        button.layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 10.0
        button.layer.masksToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func importImage(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
            picker.delegate = self
            self.present(picker, animated: true)
        }
    }
    
    
    func checkImportedImage(_ image: UIImage) {
        let qrString = QRCode.readFromImage(image)
        
        if qrString.count == 0 {
            self.showAlert(withTitle: "QR Code Import Error", message: "The imported image does not contain a QR code.")
        }
        
        switch String(qrString.prefix(QR_TYPE_MESSAGE.count)) {
        case QR_TYPE_MESSAGE:
            ()
        case QR_TYPE_CHANNEL_SHARE: registerNewChannel(with: qrString)
        default: ()
        }
    }
    
    func registerNewChannel(with data: String) {
        do {
            let result = try SubscribedChannel.subscribe(with: data)
            
            switch result {
            case (nil, .alreadySubscribed):
                showAlert(withTitle: "Channel Subscription Error", message: "You are already subscribed to this channel.")
            case (nil, .isMyChannel):
                showAlert(withTitle: "Channel Subscription Error", message: "You cannot be subscribed to a channel you manage.")
            case (nil,.invalid):
                showAlert(withTitle: "QR Code Read Error", message: "The scanned QR Code is not a valid SeQRcast code.")
            case (.some(let channel), .none):
                showAlert(withTitle: "Subscribed", message: "You have successfully subscribed to \(channel.name).")
            default: ()
            }
        } catch {
            showAlert(withTitle: "QR Code Read Error", message: "The scanned QR Code is not a valid SeQRcast code.")
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {  // If reading a QR code
                    checkURL(object.stringValue!)
                }
            }
        }
    }

    public func swipeDetector() {
        let directionsList: [UISwipeGestureRecognizer.Direction] = [.left, .right, .down, .up]
        
        for dir in directionsList {
            let directionalSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(swipe:)))
            directionalSwipe.direction = dir
            self.view.addGestureRecognizer(directionalSwipe)
        }
    }

    private func createAlert(withMessage message: String, isSafeURL safe: Bool, url: String) {
        let alert = UIAlertController(title: "QR Code", message: message, preferredStyle: .alert)
        
        let goButtonTitle = safe ? "Go" : "Go (Not Safe)"  // If URL is unsafe, let the user know before they press the "Go" button
        alert.addAction(UIAlertAction(title: goButtonTitle, style: .default, handler: {_ in
            let url = URL(string: url)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func checkURL(_ url: String) {
        // Build the http request body
        let parameters: [String: Any] = [
            "client" : [
                "clientId": "groundzero",
                "clientVersion": "alpha"
            ],
            "threatInfo" : [
                "threatTypes": ["MALWARE", "SOCIAL_ENGINEERING", "POTENTIALLY_HARMFUL_APPLICATION"],
                "platformTypes": ["ANY_PLATFORM"],
                "threatEntryTypes": ["URL"],
                "threatEntries": [
                    ["url": url]
                ]
            ]
        ]
        
        // Make http request to Google Safe Browsing
        Alamofire.request(URL(string: "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=AIzaSyAlC7WKrIUY2S0i7RUaGDzHEfYl77_-Wp0")!,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: nil)
            .responseJSON { (response) in
                if let jsonresponse = response.result.value {
                    let json = JSON(jsonresponse)
                    let matches = json["matches"].arrayValue
                    
                    if matches.count == 0 {  // Zero matches means the url is deemed SAFE by Google Safe Browsing
                        self.createAlert(withMessage: "Safe to navigate to website", isSafeURL: true, url: url)
                    } else {
                        self.createAlert(withMessage: "URL is possibly unsafe! Proceed with caution.", isSafeURL: false, url: url)
                    }
                }
            }
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

extension UIViewController {
    @objc func swipeHandler(swipe: UISwipeGestureRecognizer) {
        /*
        switch swipe.direction.rawValue {
        case 1: // if right swipe
            //performSegue(withIdentifier: "switchLeft", sender: self)
            print("PlaceholderRight")
        case 2: // if left swipe
            //performSegue(withIdentifier: "switchRight", sender: self)
            print("PlaceholderLeft")
        case 4: // if up swipe
            //performSegue(withIdentifier: "switchDown", sender: self)
            print("PlaceholderUp")
        case 8: // if down swipe
            //performSegue(withIdentifier: "switchUp", sender: self)
            print("PlaceholderDown")
        default:
            break
        }
 */
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let importedImage = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        dismiss(animated: true) {
            self.checkImportedImage(importedImage)
        }
    }
}
