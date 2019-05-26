//
//  ChannelQRViewController.swift
//  QRGuard
//
//  Created by Andy Xue on 5/25/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit

class ChannelQRViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var exportImageButton: UIButton!
    
    var channelQR: CIImage?
    
    var channel = MyChannel()
    var data: String = ""
    
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
        guard let qr = try? channel.encrypt(with: data), let image = CIContext().createCGImage(qr, from: qr.extent) else {
            showAlert(withTitle: "QR Code Generation Error", message: "There was an error generating the QR code. Please try again.")
            return
        }
        
        imageView.image = UIImage(cgImage: image)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    @IBAction func exportImage(_ sender: UIButton) {
        if let image = imageView.image {
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
        if let error = error {
            showAlert(withTitle: "QR Code Export Error", message: error.localizedDescription)
        }
        showAlert(withTitle: "QR Code Exported", message: "The QR code was successfully exported.")
    }
    
}


