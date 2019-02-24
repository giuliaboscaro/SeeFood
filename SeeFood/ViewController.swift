//
//  ViewController.swift
//  SeeFood
//
//  Created by Giulia Boscaro on 23/02/19.
//  Copyright © 2019 Giulia Boscaro. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraTapped))
        setupImagePicker()
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let hotDogView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.init(named: "hotdogBackground")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let resultView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    func setupScreen() {
        view.backgroundColor = UIColor.init(red: 38/255, green: 160/255, blue: 196/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 34/255, green: 127/255, blue: 155/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.strokeWidth: -3.0]
        title = "Is this a Hotdog?"
        view.addSubview(imageView)
        view.addSubview(hotDogView)
        view.addSubview(resultView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        hotDogView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hotDogView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        hotDogView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        hotDogView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        resultView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        resultView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resultView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        resultView.heightAnchor.constraint(equalToConstant: 85).isActive = true
    }
    
    func isHotDog() {
        resultView.image = UIImage(named: "hotdog")
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 42/255, green: 253/255, blue: 0/255, alpha: 1)
    }
    
    func notHotDog() {
        resultView.image = UIImage(named: "not-hotdog")
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 231/255, green: 62/255, blue: 50/255, alpha: 1)
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func cameraTapped() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            hotDogView.removeFromSuperview()
            imageView.image = selectedImage
            
            guard let ciImage = CIImage(image: selectedImage) else {
                fatalError("Could not convert image to CIImage")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Failed loading CoreML model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Failed getting CoreML results")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog"
                    self.isHotDog()
                } else {
                    self.navigationItem.title = "Not Hotdog"
                    self.notHotDog()
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    
}

