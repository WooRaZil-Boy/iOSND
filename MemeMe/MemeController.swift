//
//  MemeController.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 1..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import Photos

class MemeController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var imageView: UIImageView! 
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePlaceholerLabel: UILabel!
    @IBOutlet weak var navigationBar: UIToolbar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var selectedImage: UIImage? {
        didSet {
            updateUI(selectedImage != nil)
        }
    }
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.defaultTextAttributes = setTextFieldAttributes()
        bottomTextField.defaultTextAttributes = setTextFieldAttributes()
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setTextFieldAttributes() -> [String: Any] {
        let memeTextAttributes: [String: Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: -1.0]

        return memeTextAttributes
    }
}

//MARK: - Actions
extension MemeController {
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        
        let sourceType = sender.tag == 0 ? UIImagePickerControllerSourceType.camera : UIImagePickerControllerSourceType.photoLibrary
        let permission = sourceType == .camera ? AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied : PHPhotoLibrary.authorizationStatus() == .denied
        
        guard !permission else {
            permissionDenied()
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true)
    }
    
    func permissionDenied() {
        let alertController = UIAlertController(title: "Permission Denied", message: "MemeMe needs to access your pemission", preferredStyle: .alert)
        let permissionAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        let deniedAction = UIAlertAction(title: "No Thanks", style: .cancel)
        
        alertController.addAction(permissionAction)
        alertController.addAction(deniedAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        
        guard selectedImage != nil else {
            return
        }
        
        let memedImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        let barButtonItemView = sender.value(forKey: "view") as? UIView
        activityViewController.popoverPresentationController?.sourceView = barButtonItemView //For iPad
        activityViewController.popoverPresentationController?.sourceRect = barButtonItemView!.bounds //For iPad
        activityViewController.completionWithItemsHandler = { activity, complete, items, error in
            self.save(memedImage: memedImage)
        }
        
        present(activityViewController, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Cancel", message: "Remove all progress on your current project", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.topTextField.text = ""
            self.bottomTextField.text = ""
            self.imageView.image = nil
            self.selectedImage = nil
            
        })
        let cancelAction = UIAlertAction(title: "Keep editing", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

//MARK: - HelperMethods 
extension MemeController {
    func generateMemedImage() -> UIImage {
        
        updateBars()
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        updateBars(false)
        
        return memedImage
    }
    
    func updateUI(_ flag: Bool = true) {
        imagePlaceholerLabel.isHidden = flag
        shareButton.isEnabled = flag
        cancelButton.isEnabled = flag
    }
    
    func updateBars(_ flag: Bool = true) {
        navigationBar.isHidden = flag
        toolBar.isHidden = flag
    }
    
    func save(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectedImage!, memedImage: memedImage)
        print(meme)
    }
    
    func defaultText(_ textField: UITextField) -> String {
        return textField == topTextField ? "TOP" : "BOTTOM"
    }
}

//MARK: - UIImagePickerControllerDelegate
extension MemeController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        selectedImage = image
        imageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate
extension MemeController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == defaultText(textField) {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

//MARK: - NotificationCenter
extension MemeController {
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        guard bottomTextField.isFirstResponder else {
            return
        }
        
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        print("INFO :: \(userInfo)")
        
        return keyboardSize.cgRectValue.height
    }
}

