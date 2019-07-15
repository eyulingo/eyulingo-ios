//
//  ImagePreviewViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/15.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    func makeAlert(_ title: String, _ message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "嗯", style: .default, handler: { _ in
            completion()
        })
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.addGestureRecognizerToView(imageField)
        
        imageField.isUserInteractionEnabled = true
        imageField.isMultipleTouchEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imageField.image = mainImage
        self.indicationTextField.text = promptText
        super.viewWillAppear(animated)
    }
    var mainImage: UIImage?
    var promptText: String?
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var indicationTextField: UITextField!
    
    @IBOutlet weak var imageField: UIImageView!
    
    @IBAction func saveToAlbum(_ sender: UIBarButtonItem) {
        if mainImage != nil {
            UIImageWriteToSavedPhotosAlbum(mainImage!,
                                       self,
                                       #selector(image(image:didFinishSavingWithError:contextInfo:)),
                                       nil)
        }
    }
    
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if (error as NSError?) != nil {
            makeAlert("失败", "未能保存\(promptText ?? "原图片")到相册。", completion: { })
        } else {
            makeAlert("成功", "已将\(promptText ?? "原图片")保存到相册。", completion: { })
        }
    }
    
    @IBAction func dismissMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func addGestureRecognizerToView(_ imageView: UIImageView) {
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateView(_:)))
        imageView.addGestureRecognizer(rotationGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(_:)))
        imageView.addGestureRecognizer(pinchGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panView(_:)))
        imageView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func rotateView(_ rotationGestureRecognizer: UIRotationGestureRecognizer) {
        let view = rotationGestureRecognizer.view!
        if rotationGestureRecognizer.state == UIGestureRecognizer.State.began ||
            rotationGestureRecognizer.state == UIGestureRecognizer.State.changed {
            view.transform = view.transform.rotated(by: rotationGestureRecognizer.rotation)
            rotationGestureRecognizer.rotation = 0.0
        }
    }
    
    @objc func pinchView(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        let view = pinchGestureRecognizer.view!
        if pinchGestureRecognizer.state == .began || pinchGestureRecognizer.state == .changed {

            view.transform = CGAffineTransform(scaleX: pinchGestureRecognizer.scale,
                                               y: pinchGestureRecognizer.scale)
            pinchGestureRecognizer.scale = 1.0
        }
    }
    
    @objc func panView(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let view = panGestureRecognizer.view!
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            let translation: CGPoint = panGestureRecognizer.translation(in: view.superview)
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
        }
    }
}
