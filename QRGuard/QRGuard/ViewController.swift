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

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let qr = QRCode()  // Create QRCode object
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qr.scanQRCode(view: self.view, delegate: self)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {  // If reading a QR code
                    
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
                                ["url": object.stringValue!]
                            ]
                        ]
                    ]
                    
                    // Make http request to Google Safe Browsing
                    Alamofire.request(URL(string: "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=AIzaSyAlC7WKrIUY2S0i7RUaGDzHEfYl77_-Wp0")!,
                                      method: .post,
                                      parameters: parameters,
                                      encoding: JSONEncoding.default,
                                      headers: nil
                        ).responseJSON { (response) in
                            if let jsonresponse = response.result.value {
                                let json = JSON(jsonresponse)
                                let matches = json["matches"].arrayValue
                                
                                if matches.count == 0 {  // Zero matches means the url is deemed SAFE by Google Safe Browsing
                                    self.createAlert(withMessage: "Safe to navigate to website", isSafeURL: true, url: object.stringValue!)
                                } else {
                                    self.createAlert(withMessage: "URL is possibly unsafe! Proceed with caution.", isSafeURL: false, url: object.stringValue!)
                                }
                            }
                    }
                }
            }
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
}

