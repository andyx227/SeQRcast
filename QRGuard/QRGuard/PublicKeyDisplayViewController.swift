//
//  PublicKeyDisplayViewController.swift
//  QRGuard
//
//  Created by WizardMK on 5/27/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit



class PublicKeyDisplayViewController: UIViewController {
    
    @IBOutlet weak var publicKeyQRCode: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayPublicKeyQRCode()
    }
    
    func displayPublicKeyQRCode() {
        let myPublicKey = Storage.publicKey
        let context = CIContext.init(options: nil)
        guard let qr = QRCode.generateQRCode(message: myPublicKey), let cgImage = context.createCGImage(qr, from: qr.extent) else {
            showAlert(withTitle: "Public Key QR Code Generation Error", message: "There was an error generating the Public Key QR Code. Please try again.")
            return
        }
        
        publicKeyQRCode.image = UIImage.init(cgImage: cgImage)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
        }
        alert.addAction(action)
        self.present(alert, animated: true)
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
