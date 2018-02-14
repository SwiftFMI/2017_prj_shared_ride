//
//  ChatViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 24.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import Alamofire

private let reuseIdentifier = "MessagesCell"

//TODO: make userMessageLabel accept multiline
//TODO: push VC to top when keyboad is shown
//TODO: handle scroll to bottom when new messeges arrived
//TODO: handle push notifications
//TODO: set chat title
//TODO: make some image cache in order to not make image blink
//TODO: add some cell styling
//TODO: add loaders ask if there is a way to have base VC with loader in it
//TODO: unsubscribe observables in deInit
//TODO make round bubles on chant message labels
class ChatViewController: BaseViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var userMessageLabel: UITextField!
    
    var groupId: String?
    var userId = ""
    var participents = [String: String]()
    var messages = [Message]()
    var messagesRef: DatabaseReference?
    
    var newMessageRefHandle: DatabaseHandle?
    var addMessageRefHandle: DatabaseHandle?
    let chatImagesRef = Storage.storage().reference().child(Constants.Storage.CHAT_IMAGES)
    
    var images = [IndexPath:UIImage] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.hideKeyboardWhenTappedAround()
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
//        chatTableView.estimatedRowHeight = 65.0
//        chatTableView.rowHeight = UITableViewAutomaticDimension
        
        if let uid = Auth.auth().currentUser?.uid {
            userId = uid
        }
        
        let cellNib = UINib(nibName: "ChatMessageTableViewCell", bundle: nil)
        chatTableView.register(cellNib, forCellReuseIdentifier: reuseIdentifier)
        
//        let cellNib2 = UINib(nibName: "ChatImageMessageTableViewCell", bundle: nil)
//        chatTableView.register(cellNib2, forCellReuseIdentifier: ChatImageMessageTableViewCell.identifier)
        
        // Do any additional setup after loading the view.
        if let groupId = groupId {
            let ref = Database.database().reference()
            messagesRef = ref
                .child(Constants.RidesGroupChat.ROOT)
                .child(groupId)
                .child(Constants.RidesGroupChat.MESSAGESS)
            
            ref
                .child(Constants.RidesGroupChat.ROOT)
                .child(groupId)
                .child(Constants.RidesGroupChat.CHAT_MEMBERS).observe(.value, with: { [weak self] (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: String] {
                        self?.participents = dictionary
                    }
                })
            
            
//            newMessageRefHandle = messagesRef?.observe(.value, with: { [weak self] (snapshot) in
//
//                for item in snapshot.children {
//                    let child = item as! DataSnapshot
//                    let dict = child.value as! NSDictionary
//                    let uuid = dict[Constants.RidesGroupChat.MESSAGESS_USER_ID] as! String
//                    let text = dict[Constants.RidesGroupChat.MESSAGESS_USER_MESSAGE] as! String
//
//                    let message = Message(fromId: uuid, message: text)
//                    self?.messages.append(message)
//                }
//
//                self?.messagesRef?.removeAllObservers()
//                self?.chatTableView.reloadData()
//            })
            
            addMessageRefHandle = messagesRef?.observe(.childAdded, with: { [weak self] (snapshot) in
                guard let dictionary = snapshot.value as? NSDictionary else { return }
                
                let message = Message(dictionary: dictionary)
                self?.messages.append(message)
                
                self?.chatTableView.reloadData()
                self?.scrollToBottom()
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let message = userMessageLabel.text else {
            return
        }
        
        sendMessage(message: message, url: "")
    }
    
    func sendMessage(message: String, url: String){
        guard let messagesRef = messagesRef else {
            return
        }
        
        guard let uuId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let chiclId = messagesRef.childByAutoId()
        let newMessage =
            [Constants.RidesGroupChat.MESSAGESS_USER_ID: uuId,
             Constants.RidesGroupChat.MESSAGESS_USER_MESSAGE: message,
             Constants.RidesGroupChat.MESSAGES_IMAGE_URL: url]
        
        chiclId.setValue(newMessage)
        userMessageLabel.text = ""
    }
    
    @IBAction func sendFile(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
//        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
//            picker.sourceType = UIImagePickerControllerSourceType.camera
//        } else {
//            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        }
        present(picker, animated: true, completion:nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion:nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        guard let chatId = groupId else { return }
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: CGFloat(300), height: (300)))
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.8)
        let imagePath = "\(chatId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        self.chatImagesRef.child(imagePath)
            .putData(imageData!, metadata: nil) { [weak self] (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                guard let strongSelf = self else { return }
                let url = strongSelf.chatImagesRef.child((metadata?.path)!).description
                
//                strongSelf.sendMessage(message: "", url: metadata?.path ?? "")
                strongSelf.sendMessage(message: "", url: metadata?.downloadURL()?.absoluteString ?? "")
//                strongSelf.sendMessage(withData: [Constants.MessageFields.imageURL: strongSelf.storageRef.child((metadata?.path)!).description])
        }
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async { [weak self] in
            if let count = self?.messages.count {
                let indexPath = IndexPath(row: count-1, section: 0)
                self?.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let data = messages[indexPath.row]
//        if data.imageURI.isEmpty {
//            return UITableViewAutomaticDimension
////            return 60
//        } else {
//            return 300
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ChatMessageTableViewCell {
            let data = messages[indexPath.row]
            let name = participents[data.fromId]
            
            if data.fromId == userId {
                cell.participantMessageLabel.textColor = .white
                cell.participantMessageLabel.backgroundColor = .blue
                cell.participantMessageLabel.layer.cornerRadius = 6
            } else {
                cell.participantMessageLabel.textColor = .black
                cell.participantMessageLabel.backgroundColor = .gray
                cell.participantMessageLabel.layer.cornerRadius = 6
            }
            
            if !data.imageURI.isEmpty {
                let imageRef = Storage.storage().reference(forURL: data.imageURI)
                cell.chatImageImageView.layer.cornerRadius = 6
                
                if let image = images[indexPath] {
                    cell.chatImageImageView.image = image
                } else {
                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                    imageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
                        if (data == nil) {
                            return
                        }
                        let image = UIImage(data: data!)
                        self?.images[indexPath] = image
                        (self?.chatTableView.cellForRow(at: indexPath) as? ChatMessageTableViewCell)?.chatImageImageView.image = image
                        self?.chatTableView.beginUpdates();
                        self?.chatTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                        self?.chatTableView.endUpdates();
                    }
                }
                
//                Alamofire.download(data.imageURI).responseData { response in
//                    if let data = response.result.value {
//                        let image = UIImage(data: data)
//                        cell.chatImageImageView.image = image
//                    }
//                }
                
//                let imageRef = chatImagesRef.child(data.imageURI)
                
//                cell.chatImageImageView.sd_setImage(with: URL(string: data.imageURI), completed: <#T##SDExternalCompletionBlock?##SDExternalCompletionBlock?##(UIImage?, Error?, SDImageCacheType, URL?) -> Void#>)
//                cell.chatImageImageView.sd_setImage(with: URL(string: data.imageURI), completed: nil)
            } else {
                cell.chatImageImageView.image = nil
            }
            
            cell.prepare(participantName: name!, participantMessage: data.message)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.layoutIfNeeded()
//    }
    
}

//if  data.imageURI.isEmpty {
//    if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ChatMessageTableViewCell {
//
//
//        if data.fromId == userId {
//            cell.participantMessageLabel.textColor = .white
//            cell.participantMessageLabel.backgroundColor = .blue
//            cell.participantMessageLabel.layer.cornerRadius = 20
//        } else {
//            cell.participantMessageLabel.textColor = .black
//            cell.participantMessageLabel.backgroundColor = .gray
//            cell.participantMessageLabel.layer.cornerRadius = 20
//        }
//
//        cell.chatImageImageView.image = nil
//
//        cell.prepare(participantName: name!, participantMessage: data.message)
//        return cell
//    } else {
//        return UITableViewCell()
//    }
//} else {
//    if let cell = tableView.dequeueReusableCell(withIdentifier: ChatImageMessageTableViewCell.identifier) as? ChatImageMessageTableViewCell {
//
//
//        cell.imageMessage.image = nil
//        if !data.imageURI.isEmpty {
//
//            //                let islandRef = chatImagesRef.child(data.imageURI)
//
//            let islandRef = Storage.storage().reference(forURL: data.imageURI)
//
//            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//            islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                // Data for "images/island.jpg" is returned
//                let image = UIImage(data: data!)
//                cell.imageMessage.image = image
//            }
//
//            //                Alamofire.download(data.imageURI).responseData { response in
//            //                    if let data = response.result.value {
//            //                        let image = UIImage(data: data)
//            //                        cell.chatImageImageView.image = image
//            //                    }
//            //                }
//
//            //                let imageRef = chatImagesRef.child(data.imageURI)
//
//            //                cell.chatImageImageView.sd_setImage(with: URL(string: data.imageURI), completed: <#T##SDExternalCompletionBlock?##SDExternalCompletionBlock?##(UIImage?, Error?, SDImageCacheType, URL?) -> Void#>)
//            //                cell.chatImageImageView.sd_setImage(with: URL(string: data.imageURI), completed: nil)
//        }
//        return cell
//    } else {
//        return UITableViewCell()
//}

