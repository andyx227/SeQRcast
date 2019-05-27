//
//  QRCode.swift
//  QRGuard
//
//  Created by Andy Xue on 5/19/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

let QR_TYPE_CHANNEL_SHARE = "CAFEDEAD"
let QR_TYPE_MESSAGE = "CAFEBABE"
let QR_TYPE_PUBLIC_KEY = "CAFED00D"

class QRCode {
    static var scanned = false  // Keep track of whether a qr code has been scanned
    
    public static func scanQRCode(view: UIView, delegate: AVCaptureMetadataOutputObjectsDelegate) {
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
        output.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        var video = AVCaptureVideoPreviewLayer()  // Will display output from the camera
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds  // Set the video output to fill the entire screen
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    public static func generateQRCode(message input: String) -> CIImage? {
        let data = input.data(using: String.Encoding.ascii)
        
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {return nil}
        qrFilter.setValue(data, forKey: "inputMessage")
        
        let qrOutput = qrFilter.outputImage
        guard let qrCode = qrOutput else {return nil}
        
        // Scale the QR code so it doesn't look blurry
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQRCode = qrCode.transformed(by: transform)
        
        return scaledQRCode
    }
    
    static func readFromImage(_ image: UIImage) -> String {
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
            let ciImage = CIImage(image: image),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
            return ""
        }
        var qrString = ""
        for feature in features {
            qrString += feature.messageString ?? ""
        }
        
        return qrString
    }
}
