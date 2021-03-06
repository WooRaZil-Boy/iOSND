//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 1..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import Photos
import CoreData

class MemeEditorViewController: UIViewController {
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
    
    weak var parentTabBarViewController: TabBarViewController!
    var selectedImage: UIImage? {
        didSet {
            updateUI(selectedImage != nil)
        }
    }
    var coreDataStack: CoreDataStack!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(textField: topTextField, text: defaultText(topTextField), defaultAttributes: setTextFieldAttributes())
        configure(textField: bottomTextField, text: defaultText(bottomTextField), defaultAttributes: setTextFieldAttributes())
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
}

//MARK: - Actions
extension MemeEditorViewController {
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
            if complete {
                self.save(memedImage: memedImage)
            }
        }
        
        present(activityViewController, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Cancel", message: "Remove all progress on your current project", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            
        })
        let cancelAction = UIAlertAction(title: "Keep editing", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

//MARK: - HelperMethods 
extension MemeEditorViewController {
    func generateMemedImage() -> UIImage {
        
        updateBars()
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        updateBars(false)
        
        return memedImage
    }
    
    func updateUI(_ hidden: Bool = true) {
        imagePlaceholerLabel.isHidden = hidden
        shareButton.isEnabled = hidden
    }
    
    func updateBars(_ hidden: Bool = true) {
        navigationBar.isHidden = hidden
        toolBar.isHidden = hidden
    }
    
    func save(memedImage: UIImage) {
        let meme = Meme(context: coreDataStack.managedContext)
        
        meme.topText = topTextField.text
        meme.bottomText = bottomTextField.text
        let originalImageRepresentation = UIImagePNGRepresentation(selectedImage!)!
        meme.originalImage = NSData(data: originalImageRepresentation)
        let memedImageRepresentation = UIImagePNGRepresentation(memedImage)!
        meme.memedImage = NSData(data: memedImageRepresentation)
        meme.regsterDate = NSDate()
        
        coreDataStack.saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    func setTextFieldAttributes() -> [String: Any] {
        let memeTextAttributes: [String: Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: -1.0]
        
        return memeTextAttributes
    }
    
    func defaultText(_ textField: UITextField) -> String {
        return textField == topTextField ? "TOP" : "BOTTOM"
    }
    
    func configure(textField: UITextField, text: String, defaultAttributes: [String:Any]){
        textField.text = text
        textField.defaultTextAttributes = defaultAttributes
        textField.textAlignment = .center
    }
}

//MARK: - UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        selectedImage = image
        imageView.image = selectedImage
        
        dismiss(animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension MemeEditorViewController: UITextFieldDelegate {
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
extension MemeEditorViewController {
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
        
        return keyboardSize.cgRectValue.height
    }
}
