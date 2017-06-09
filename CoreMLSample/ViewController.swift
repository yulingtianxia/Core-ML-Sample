//
//  ViewController.swift
//  CoreMLSimple
//
//  Created by 杨萧玉 on 2017/6/9.
//  Copyright © 2017年 杨萧玉. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate {
    
    // Outlets to label and view
    @IBOutlet private weak var predictLabel: UILabel!
    @IBOutlet private weak var previewView: UIView!
    
    // some properties used to control the app and store appropriate values
    
    let inceptionv3model = Inceptionv3()
    private var videoCapture: VideoCapture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let spec = VideoSpec(fps: 3, size: CGSize(width: 299, height: 299))
        videoCapture = VideoCapture(cameraType: .back,
                                    preferredSpec: spec,
                                    previewContainer: previewView.layer)
        videoCapture.imageBufferHandler = {[unowned self] (imageBuffer, timestamp, outputBuffer) in
            do {
                let prediction = try self.inceptionv3model.prediction(image: self.resize(imageBuffer: imageBuffer)!)
                DispatchQueue.main.async {
                    self.predictLabel.text = prediction.classLabel
                }
            }
            catch let error as NSError {
                fatalError("Unexpected error ocurred: \(error.localizedDescription).")
            }
        }
    }
    
    func resize(imageBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        var ciImage = CIImage(cvPixelBuffer: imageBuffer, options: nil)
        let transform = CGAffineTransform(scaleX: 299.0 / CGFloat(CVPixelBufferGetWidth(imageBuffer)), y: 299.0 / CGFloat(CVPixelBufferGetHeight(imageBuffer)))
        ciImage = ciImage.applying(transform).cropping(to: CGRect(x: 0, y: 0, width: 299, height: 299))
        let ciContext = CIContext()
        var resizeBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, 299, 299, CVPixelBufferGetPixelFormatType(imageBuffer), nil, &resizeBuffer)
        ciContext.render(ciImage, to: resizeBuffer!)
        return resizeBuffer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let videoCapture = videoCapture else {return}
        videoCapture.startCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let videoCapture = videoCapture else {return}
        videoCapture.resizePreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let videoCapture = videoCapture else {return}
        videoCapture.stopCapture()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

