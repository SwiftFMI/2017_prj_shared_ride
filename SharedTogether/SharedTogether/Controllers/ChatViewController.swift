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

private let reuseIdentifier = "MessagesCell"

class ChatViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var userMessageLabel: UITextField!
    
    var groupId: String?
    var userId = ""
    var participents = [String: String]()
    var messages = [Message]()
    var messagesRef: DatabaseReference?
    var newMessageRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        if let uid = Auth.auth().currentUser?.uid {
            userId = uid
        }
        
        let cellNib = UINib(nibName: "ChatMessageTableViewCell", bundle: nil)
        chatTableView.register(cellNib, forCellReuseIdentifier: reuseIdentifier)
        
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
//                        let key = Array(dictionary.keys)[0]
//                        let message = [key: dictionary[key]]
                    }
                })
            
            
            newMessageRefHandle = messagesRef?.observe(.value, with: { [weak self] (snapshot) in
                
                for item in snapshot.children {
                    let child = item as! DataSnapshot
                    let dict = child.value as! NSDictionary
                    let uuid = dict[Constants.RidesGroupChat.MESSAGESS_USER_ID] as! String
                    let text = dict[Constants.RidesGroupChat.MESSAGESS_USER_MESSAGE] as! String
                    
                    let message = Message(fromId: uuid, message: text)
                    self?.messages.append(message)
                }
                
                self?.chatTableView.reloadData()
            })
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let messagesRef = messagesRef else {
            return
        }
        
        guard let uuId = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let message = userMessageLabel.text else {
            return
        }
        
        let chiclId = messagesRef.childByAutoId()
        let newMessage =
            [Constants.RidesGroupChat.MESSAGESS_USER_ID: uuId,
             Constants.RidesGroupChat.MESSAGESS_USER_MESSAGE: message]
        
        chiclId.setValue(newMessage)
        userMessageLabel.text = ""
    }
    
    @IBAction func sendFile(_ sender: Any) {
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

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ChatMessageTableViewCell {
            let data = messages[indexPath.row]
            let name = participents[data.fromId]
            
            if data.fromId == userId {
                cell.participantMessageLabel.textColor = .white
                cell.participantMessageLabel.backgroundColor = .blue
                cell.participantMessageLabel.layer.cornerRadius = 20
            } else {
                cell.participantMessageLabel.textColor = .black
                cell.participantMessageLabel.backgroundColor = .gray
                cell.participantMessageLabel.layer.cornerRadius = 20
            }
            
            cell.prepare(participantName: name!, participantMessage: data.message)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
}
