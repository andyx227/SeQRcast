//
//  PublicKeyDisplayViewController.swift
//  SeQRcast
//
//  Created by WizardMK on 5/27/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import Pulley


class PublicKeyDisplayViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var exportImageButton: UIButton!
    
    var exportImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setShadowForButton(exportImageButton)

        displayPublicKeyQRCode()
    }
    
    func displayPublicKeyQRCode() {
        let myPublicKey = QR_TYPE_PUBLIC_KEY + Storage.publicKey
        let context = CIContext()
        let logoLength = imageView.frame.width * 0.3
        guard let qr = QRCode.generateQRCode(message: myPublicKey),
            let dummy = QRCode.generateQRCode(message: "CAFEBABEjySa8fR3TZbu6cy3C9a1BsMEG5Au0tJ56Y0rt1X2QBk=" + String(repeating: "A", count: 344) + "FNlVl0xYxuu1p6nXR50GtT6oBYlaXOCmON5qmfOd92YcZsmH0fozD2ruNM8x5RMXE6jeTsEN51ahWACS4I9G4iyUfLi+EWQYk8U4MzS5h40="),
            let exportLogo = UIImage(named: "seqrcast_white")?.resizeTo(size: CGSize(width: logoLength, height: logoLength)).withBackground(color: UIColor.black),
            let exportCI = QRCode.generateExportableQRCode(dummy, withLogo: exportLogo),
            let cgImage = context.createCGImage(exportCI, from: exportCI.extent),
            let logo = UIImage(named: "seqrcast")?.resizeTo(size: CGSize(width: logoLength, height: logoLength)).withBackground(color: UIColor.white),
            let image = QRCode.generateCustomizedQRCode(qr, in: UIColor.white, withLogo: logo) else {
            showAlert(withTitle: "QR Code Generation Error", message: "There was an error generating the QR Code. Please try again.")
            return
        }
        exportImage = UIImage(cgImage: cgImage)
        imageView.image = UIImage(ciImage: image)
    }
    
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
        }
        alert.addAction(action)
        self.present(alert, animated: true)
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
        self.pulleyViewController?.view.transform = CGAffineTransform(rotationAngle: .pi)
        self.view.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    @IBAction func exportImage(_ sender: UIButton) {
        if let image = exportImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else {
            showAlert(withTitle: "QR Code Export Error", message: "There is no QR code to be exported.")
        }
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            showAlert(withTitle: "QR Code Export Error", message: "There was an error exporting QR code. Please try again.")
        }
        showAlert(withTitle: "QR Code Exported", message: "The QR code was successfully exported.")
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension PublicKeyDisplayViewController: PulleyDrawerViewControllerDelegate {
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed, .open]
    }
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return self.view.safeAreaInsets.top + 50.0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        
        return self.view.safeAreaInsets.top + 150.0
    }
}
