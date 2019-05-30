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
        qrFilter.setValue("L", forKey: "inputCorrectionLevel")
        
        let qrOutput = qrFilter.outputImage
        guard let qrCode = qrOutput else {return nil}
        
        // Scale the QR code so it doesn't look blurry
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQRCode = qrCode.transformed(by: transform)
        
        return scaledQRCode
    }
    
    static func generateExportableQRCode(_ image: CIImage, withLogo logo: UIImage) -> CIImage? {
        guard let cgImage = logo.cgImage else {
            return nil
        }
        return image.combinedWith(CIImage(cgImage: cgImage))
    }
    
    static func generateCustomizedQRCode(_ image: CIImage, in color: UIColor, withLogo logo: UIImage) -> CIImage? {
        guard let cgImage = logo.cgImage else {
            return nil
        }
        return image.imageWithColor(as: color)?.combinedWith(CIImage(cgImage: cgImage))
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

extension CIImage {
    var inverted: CIImage? {
        guard let invertedColorFilters = CIFilter(name: "CIColorInvert") else {
            return nil
        }
        invertedColorFilters.setValue(self, forKey: "inputImage")
        return invertedColorFilters.outputImage
    }
    
    var blackTransparent: CIImage? {
        guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else {
            return nil
        }
        blackTransparentFilter.setValue(self, forKey: "inputImage")
        return blackTransparentFilter.outputImage
    }
    
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }
    
    func imageWithColor(as color: UIColor) -> CIImage? {
        guard let transparent = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else {
            return nil
        }
        colorFilter.setValue(CIColor(color: color), forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage
        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparent, forKey: kCIInputBackgroundImageKey)
        return filter.outputImage
    }
    
    func combinedWith(_ image: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else {
            return nil
        }
        let centerTransform = CGAffineTransform(translationX: extent.midX - (extent.size.width * 0.2 / 2), y: extent.midY - (extent.size.height * 0.2 / 2))
        let scaleTransform = CGAffineTransform(scaleX: extent.size.width * 0.2 / image.extent.size.width, y: extent.size.height * 0.2 / image.extent.size.height)
        combinedFilter.setValue(image.transformed(by: scaleTransform).transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(self, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage!
    }
}

extension UIImage {
    func resizeTo(size: CGSize) -> UIImage {
        /*
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { (_) in
            self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        }
 */
        return self
    }
    
    func withBackground(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return self
        }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(cgImage!, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
