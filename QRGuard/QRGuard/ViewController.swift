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

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let qr = QRCode()  // Create QRCode object
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qr.scanQRCode(view: self.view, delegate: self)
        
        //to test sha256
        /*
        if let someData = "Random string".data(using: .utf8) {
            let hash = someData.hash(for: .sha256)
            print("hash=\(hash.base64EncodedString()).")
        }
        */
        
        swipeDetector()
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
    
    // digital signature
    func test() {
        let string: String = "encrypted text"
        let keyPair: (publicKey: SecKey?, privateKey: SecKey?) = generateKeyPair()
        let signature: NSData? = signString(string, privateKey: keyPair.privateKey!)
        let result: Bool = verifyString(string, signature: signature!, publicKey: keyPair.publicKey!)
        print(result)
    }
    
    func generateKeyPair () -> (publicKey: SecKey?, privateKey: SecKey?) {
        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048
        ]
        var publicKey: SecKey?
        var privateKey: SecKey?
        let osStatus: OSStatus = SecKeyGeneratePair(parameters, &publicKey, &privateKey)
        
        switch osStatus {
        case noErr:
            return (publicKey, privateKey)
        default:
            return (nil, nil)
        }
    }
    
    func signString(string: String, privateKey: SecKey) -> NSData? {
        let digest = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))!
        let stringData: NSData = string.dataUsingEncoding(NSUTF8StringEncoding)!
        CC_SHA256(stringData.bytes, CC_LONG(stringData.length), UnsafeMutablePointer<UInt8>(digest.mutableBytes))
        let signedData: NSMutableData = NSMutableData(length: SecKeyGetBlockSize(privateKey))!
        var signedDataLength: Int = signedData.length
        
        let err: OSStatus = SecKeyRawSign(
            privateKey,
            SecPadding.PKCS1SHA256,
            UnsafePointer<UInt8>(digest.bytes),
            digest.length,
            UnsafeMutablePointer<UInt8>(signedData.mutableBytes),
            &signedDataLength
        )
        
        switch err {
        case noErr:
            return signedData
        default:
            return nil
        }
        
    }
    
    func verifyString(string: String, signature: NSData, publicKey: SecKey) -> Bool {
        let digest = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))!
        let stringData: NSData = string.dataUsingEncoding(NSUTF8StringEncoding)!
        CC_SHA256(stringData.bytes, CC_LONG(stringData.length), UnsafeMutablePointer<UInt8>(digest.mutableBytes))
        
        let err: OSStatus = SecKeyRawVerify(
            publicKey,
            SecPadding.PKCS1SHA256,
            UnsafePointer<UInt8>(digest.bytes),
            digest.length,
            UnsafeMutablePointer<UInt8>(signature.bytes),
            signature.length
        )
        
        switch err {
        case noErr:
            return true
        default:
            return false
        }
    }
}

extension Data {
    enum Algorithm {
        case sha256
        
        var digestLength: Int {
            switch self {
                case .sha256: return Int(CC_SHA256_DIGEST_LENGTH)
            }
        }
    }
    
    func hash(for algorithm: Algorithm) -> Data {
        let hashBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: algorithm.digestLength)
        defer { hashBytes.deallocate() }
        switch algorithm {
        case .sha256:
            withUnsafeBytes { (buffer) -> Void in
                CC_SHA256(buffer.baseAddress!, CC_LONG(buffer.count), hashBytes)
            }
        }
        
        return Data(bytes: hashBytes, count: algorithm.digestLength)
    }
}

extension UIViewController {
    @objc func swipeHandler(swipe: UISwipeGestureRecognizer) {
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
    }
}
