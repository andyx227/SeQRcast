//
//  MessageQRViewController.swift
//  SeQRcast
//
//  Created by user149673 on 5/26/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import CoreLocation

class MessageQRViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var exportImageButton: UIButton!
    
    var message = Message()
    var exportImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exportImageButton.layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        exportImageButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        exportImageButton.layer.shadowOpacity = 1.0
        exportImageButton.layer.shadowRadius = 10.0
        exportImageButton.layer.masksToBounds = false
        displayChannelQRCode()
    }
    
    func displayChannelQRCode() {
        let logoLength = imageView.frame.width * 0.3
        guard let qr = try? message.encrypt(),
            let encoded = try? message.encryptedString(),
            let exportLogo = UIImage(named: "seqrcast_white")?.resizeTo(size: CGSize(width: logoLength, height: logoLength)).withBackground(color: UIColor.black),
            let exportCI = QRCode.generateExportableQRCode(qr, withLogo: exportLogo),
            let cgImage = CIContext().createCGImage(exportCI, from: exportCI.extent),
            let logo = UIImage(named: "seqrcast_white")?.resizeTo(size: CGSize(width: logoLength, height: logoLength)).withBackground(color: UIColor.black),
            let custom = QRCode.generateCustomizedQRCode(qr, in: UIColor.black, withLogo: logo) else {
            showAlert(withTitle: "QR Code Generation Error", message: "There was an error generating the QR code. Please try again.")
            return
        }
        
        let log = MessageLog(for: message, withString: encoded, at: Date())
        Database.shared.storeLog(log)
        exportImage = UIImage(cgImage: cgImage)
        imageView.image = UIImage(ciImage: custom)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    @IBAction func exportImage(_ sender: UIButton) {
        if let image = exportImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else {
            showAlert(withTitle: "QR Code Export Error", message: "There is no QR code to be exported.")
        }
    }
    
    @IBAction func returnToMain(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            showAlert(withTitle: "QR Code Export Error", message: "There was an error exporting QR code. Please try again.")
        }
        showAlert(withTitle: "QR Code Exported", message: "The QR code was successfully exported.")
    }
    
}

/*
 let locationManager = CLLocationManager()
 locationManager.delegate = self
 locationManager.requestLocation()
extension MessageQRViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first, let encoded = try? message.encryptedString() else {
            return
        }
        let log = MessageLog(for: message, withLatitude: location.coordinate.latitude, andLongitude: location.coordinate.longitude, withString: encoded, at: Date())
        Database.shared.storeLog(log)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let encoded = try? message.encryptedString() else {
            return
        }
        let log = MessageLog(for: message, withString: encoded, at: Date())
        Database.shared.storeLog(log)
    }
}
*/
