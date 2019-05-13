//
//  ViewController.swift
//  QRGuard
//
//  Created by Andy Xue on 5/13/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanQRCode()
    }

    private func scanQRCode() {
        // Create session (requried to get input from camera)
        let session = AVCaptureSession()
        // Define capture device as user's own device
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Error — could not detect capture device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print("Error — could not add camera input to video session")
            return
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        // Set camera output to be processed by the main queue
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        var video = AVCaptureVideoPreviewLayer()  // Will display output from the camera
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds  // Set the video output to fill the entire screen
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {  // If reading a QR code
                    let alert = UIAlertController(title: "QR Code", message: object.stringValue ?? "(Error reading url)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Go", style: .default, handler: {_ in
                        let url = URL(string: object.stringValue!)!
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            // Fallback on earlier versions
                            UIApplication.shared.openURL(url)
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    /// TODO: "object.stringValue" contains the url embedded in the QR code.
                    /// Next step should be to check this url against a database of malicious urls
                    /// and displays an alert to the user if it is malicious.
                }
            }
        }
    }
}

