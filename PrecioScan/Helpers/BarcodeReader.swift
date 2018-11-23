//
//  BarcodeReader.swift
//  PrecioScan
//
//  Created by Félix Olivares on 16/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeReader: UIView, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var codeAnimatedControl: AnimatedInputControl!
    
    func setupReader(codeAnimatedControl: AnimatedInputControl){
        self.codeAnimatedControl = codeAnimatedControl
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            guard captureDevice != nil else {return}
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.aztec, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.itf14, AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.code39Mod43, AVMetadataObject.ObjectType.dataMatrix, AVMetadataObject.ObjectType.interleaved2of5]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = self.layer.bounds
            self.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
//            view.bringSubview(toFront: messageLabel)
//            view.bringSubview(toFront: topbar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                self.addSubview(qrCodeFrameView)
                self.bringSubviewToFront(qrCodeFrameView)
            }
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if  metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
        qrCodeFrameView?.frame = barCodeObject!.bounds
        
        if metadataObj.stringValue != nil {
            let codeDict: [String:String] = ["code": metadataObj.stringValue!]
            NotificationCenter.default.post(name: Notification.Name(Identifiers.Notifications.idArticleFound), object: nil, userInfo: codeDict)
        }
    }
}
