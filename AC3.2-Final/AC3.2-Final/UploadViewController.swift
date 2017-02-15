//
//  UploadViewController.swift
//  AC3.2-Final
//
//  Created by Madushani Lekam Wasam Liyanage on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    var imagePickerController: UIImagePickerController!
    
    var capturedImage: UIImage!
    var user: FIRUser!
    var databaseRef: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.user = FIRAuth.auth()?.currentUser
        self.databaseRef = FIRDatabase.database().reference().child("posts")
        commentTextView.delegate = self
        commentTextView.text = "Add a description.."
        commentTextView.textColor = UIColor.lightGray
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @IBAction func pickImageTapped(_ sender: UIButton) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [String(kUTTypeImage)]
        
        self.imagePickerController = imagePickerController
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        shareToFirebase()
    }
    
    func shareToFirebase() {
        
        let postRef = self.databaseRef.childByAutoId()
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        let storage = FIRStorage.storage()
        let storageRef = storage.reference(forURL: "gs://ac-32-final.appspot.com")
        let imageNameRef = storageRef.child("images/\(postRef.key)")
        
        let metadata = FIRStorageMetadata()
        metadata.cacheControl = "public,max-age=300"
        metadata.contentType = "image/jpeg"
        if capturedImage != nil {
            let jpeg = UIImageJPEGRepresentation(capturedImage, 0.5)
            
            let _ = imageNameRef.put(jpeg!, metadata: metadata, completion: { (metadata, error) in
                guard metadata != nil else {
                    print("put error: \(error?.localizedDescription)")
                    return
                }
            })
            
            let post = Post(key: postRef.key, comment: self.commentTextView.text!, userId: currentUserId!)
            let dict = post.addDictionary
            
            postRef.setValue(dict) { (error, ref) in
                if let error = error {
                    print("Set value error: \(error.localizedDescription)")
                    let alertController = showAlert(title: "Upload Failed", message: "Uploading Failed! Please Try Again!")
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let fvc = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                    let alertController = UIAlertController(title: "Photo Uploaded!", message: nil, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        self.present(fvc, animated: true, completion: nil)
                    }))
                    
                }
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        switch info[UIImagePickerControllerMediaType] as! String {
        case String(kUTTypeImage):
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.capturedImage = image
                selectedImageView.image = nil
                selectedImageView.backgroundColor = .clear
                selectedImageView.contentMode = .scaleAspectFit
                selectedImageView.image = capturedImage
            }
            
        default:
            print("Bad Media Type")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if commentTextView.textColor == UIColor.lightGray {
            commentTextView.text = nil
            commentTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a description.."
            textView.textColor = UIColor.lightGray
        }
    }
    
}
