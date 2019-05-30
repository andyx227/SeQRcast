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
    var channelData = MyChannel()  // Passed from MyChannelsTableVC
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var instructionText: UITextView!
    @IBOutlet weak var importImageButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setShadowForButton(importImageButton)
        setShadowForButton(backBtn)

        QRCode.scanQRCode(view: cameraView, delegate: self)
        
        view.bringSubviewToFront(instructionText)
        view.bringSubviewToFront(importImageButton)
        view.bringSubviewToFront(backBtn)
    }
    
    func setShadowForButton(_ button: UIButton) {
        button.layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 10.0
        button.layer.masksToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        QRCode.scanned = false  // Set to false so user can scan public key
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {  // If scanning public key qr code
                    if let publicKey = object.stringValue {
                        if checkPublicKeyFormat(publicKey) && QRCode.scanned == false {
                            if String(publicKey.dropFirst(QR_TYPE_PUBLIC_KEY.count)) == Storage.publicKey {
                                showAlert(withTitle: "Channel Share Error", message: "You cannot share a channel with yourself.")
                                return
                            }
                            QRCode.scanned = true
                            // Encrypt channel data and get the encrypted QR code
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let channelQRVC = storyboard.instantiateViewController(withIdentifier: "channelQRViewController") as! ChannelQRViewController
                            channelQRVC.channel = channelData
                            channelQRVC.data = publicKey
                            navigationController?.pushViewController(channelQRVC, animated: true)
                        } else if checkPublicKeyFormat(publicKey) == false {
                            createAlert(withTitle: "Key Read Error", withMessage: "The QR code you scanned does not contain a device key.")
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
        return key.prefix(QR_TYPE_PUBLIC_KEY.count) == QR_TYPE_PUBLIC_KEY && key.count == Channel.PUBLIC_KEY_LENGTH + QR_TYPE_PUBLIC_KEY.count
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
            return
        }
        if !checkPublicKeyFormat(qrString) {
            createAlert(withTitle: "Key Read Error", withMessage: "The imported QR code does not contain a device key.")
            return
        }
        /*
        if String(qrString.dropFirst(QR_TYPE_PUBLIC_KEY.count)) == Storage.publicKey {
            showAlert(withTitle: "Channel Share Error", message: "You cannot share a channel with yourself.")
            return
        }*/
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "channelQRViewController") as! ChannelQRViewController
        viewController.channel = channelData
        viewController.data = qrString
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}


extension ScanPublicKeyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
