//
//  ReceberVC.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 10/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Firebase
import Alamofire
import SwiftKeychainWrapper


class ReceberVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var qrView: UIView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let locationManger = CLLocationManager()
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: topView)
        //view.bringSubview(toFront: topbar)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func voltarBtnPressed(_ sender: UIButton) {
        self.captureSession.stopRunning()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
}

extension ReceberVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                var myStringArr = metadataObj.stringValue?.components(separatedBy: ";")
                let valor = myStringArr![0].replacingOccurrences(of: "valor=", with: "")
                let origin = myStringArr![3].replacingOccurrences(of: "origin=", with: "")
                if let lat = Double(myStringArr![1].replacingOccurrences(of: "lat=", with: "")), let lon = Double(myStringArr![2].replacingOccurrences(of: "lon=", with: "")) {
                    let coordinate = CLLocation(latitude: lat, longitude: lon)
                    let coordinate1 = CLLocation(latitude: (locationManger.location?.coordinate.latitude)!, longitude: (locationManger.location?.coordinate.longitude)!)
                    
                    let distanceInMeters = coordinate.distance(from: coordinate1) // result is in meters
                    if (distanceInMeters >= 1000) {
                        let refreshAlert = UIAlertController(title: "Alerta", message: "Vendedor está a mais de 1km, confirma a compra?", preferredStyle: UIAlertControllerStyle.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction!) in
                            print("Handle Ok logic here")
                            self.captureSession.stopRunning()
                            self.confirmar(valor: valor, origin: origin)
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                        refreshAlert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: { (action: UIAlertAction!) in
                            self.dismiss(animated: true, completion: nil)
                            return
                        }))
                        present(refreshAlert, animated: true, completion: nil)
                    }
                    self.captureSession.stopRunning()
                    confirmar(valor: valor, origin: origin)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Alerta", message: "QRCódigo inválido!", preferredStyle: .alert)
                    //We add buttons to the alert controller by creating UIAlertActions:
                    let actionOk = UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil) //You can use a block here to handle a press on this button
                    
                    alertController.addAction(actionOk)
                    self.captureSession.stopRunning()
                    self.present(alertController, animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
    func confirmar(valor: String, origin: String) {
        let target = KeychainWrapper.standard.string(forKey: KEY_UID)!
        let cost2 = (valor as NSString).doubleValue
        
        let param2 = [
            "origin":origin,
            "target":target,
            "value": cost2
            ] as [String : Any]
        print(param2)
        let url = "http://fddcdf7e.ngrok.io/users/transaction"
        Alamofire.request(url, method:.post, parameters:param2,encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                print("Transferencia com sucesso")
            case .failure(let error):
                print("Erro na transferencia", error)
            }
        }
    }
}
