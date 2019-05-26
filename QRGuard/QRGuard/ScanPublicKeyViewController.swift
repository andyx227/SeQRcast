//
//  ScanPublicKeyViewController.swift
//  QRGuard
//
//  Created by Andy Xue on 5/25/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import AVFoundation

class ScanPublicKeyViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    static var scanned = false  // Keep track of whether the channel qr code has been scanned
    var channelData: MyChannel?  // Passed from MyChannelsTableVC
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QRCode.scanQRCode(view: self.view, delegate: self)
        view.bringSubviewToFront(backBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ScanPublicKeyViewController.scanned = false  // Set to false so user can scan public key
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {  // If scanning public key qr code
                    if let publicKey = object.stringValue {
                        if checkPublicKeyFormat(publicKey) == true && ScanPublicKeyViewController.scanned == false {
                            ScanPublicKeyViewController.scanned = true
                            // Encrypt channel data and get the encrypted QR code
                            let channelQRCode = generateChannelQRCode(withChannelData: channelData, publicKey)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let channelQRVC = storyboard.instantiateViewController(withIdentifier: "channelQRViewController") as! ChannelQRViewController
                            
                            channelQRVC.channelQR = channelQRCode  // Pass the qr code to view controller
                            navigationController?.pushViewController(channelQRVC, animated: true)
                        } else if checkPublicKeyFormat(publicKey) == false {
                            createAlert(withTitle: "Not Public Key", withMessage: "The code you scanned is not a public key. Please try again.")
                        }
                    }
                }
            }
        }
    }
    
    func createAlert(withTitle title:String, withMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkPublicKeyFormat(_ key: String) -> Bool {
        if key.count == 360 {  // Public key has 360 characters
            return true
        } else {
            return false
        }
    }
    
    func generateChannelQRCode(withChannelData channel: MyChannel?, _ publicKey: String) -> CIImage? {
        if let channel = channel {
            do {
                let channelQR = try channel.encrypt(with: publicKey)
                return channelQR
            } catch {
                createAlert(withTitle: "Error", withMessage: "This channel's encrpyted QR code could not be generated. Please try again.")
                return nil
            }
        } else {
            createAlert(withTitle: "Error", withMessage: "A problem arised when retrieving the channel info. Please try again.")
            return nil
        }
    }
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
