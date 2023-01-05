//
//  ViewController.swift
//  VisionKitBeginner
//
//  Created by Jim Thorton on 2020/07/04.
//  Copyright © 2020 Jim Thorton. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    // MARK: - IBOutlet
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - IBAction
    @IBAction func selectTapped(_ sender: UIButton) {
        displayScanningController()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupVision()
    }
    
    func setupVision() {
        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                print("text \(topCandidate.string) has confidence \(topCandidate.confidence)")
                detectedText += topCandidate.string
                detectedText += "\n"
            }
            
            DispatchQueue.main.async {
                self.textView.text = detectedText
                self.textView.flashScrollIndicators()
            }
        }
        textRecognitionRequest.recognitionLevel = .accurate
    }
    
    func displayScanningController() {
        guard VNDocumentCameraViewController.isSupported else { return }
        let controller = VNDocumentCameraViewController()
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func processImage(_ image: UIImage) {
        imageView.image = image
        recognizeTextInImage(image)
    }
    
    func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Oh, no...")
            return
        }
        textView.text = ""
        textRecognitionWorkQueue.async {
            print("Okay, hold on...")
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        dismiss(animated: true) {
            for i in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: i)
                self.imageView.image = image
                self.processImage(image)
                return
            }
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss(animated: true) {
            print("Dismissed")
        }
    }
}

