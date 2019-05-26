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
    var channelQR: CIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayChannelQRCode()
    }
    
    func displayChannelQRCode() {
        if let channelQR = channelQR {
            imageView.image = UIImage(ciImage: channelQR)
        } else {
            let alert = UIAlertController(title: "Error", message: "A problem arised when trying to display the channel's QR code. Please try again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
