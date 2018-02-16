//
//  ChatDetailViewController.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 15.02.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class ChatDetailViewController: UIViewController {

    @IBOutlet weak var chatPartiipantsTableView: UITableView!
    @IBOutlet weak var getNotificationSwitch: UISwitch!
    
    var data = [ChatMember]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatPartiipantsTableView.delegate = self
        chatPartiipantsTableView.dataSource = self
        
        let cellNib = UINib(nibName: "ChatDetailTableViewCell", bundle: nil)
        chatPartiipantsTableView.register(cellNib, forCellReuseIdentifier: ChatDetailTableViewCell.cellIdentifier)
        // Do any additional setup after loading the view.
    }
}

extension ChatDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: ChatDetailTableViewCell.cellIdentifier, for: indexPath) as! ChatDetailTableViewCell
        
        let chatMember = data[indexPath.row]
        
        cell.configure(name: chatMember.name ?? "", phone: chatMember.phoneNumber ?? "")
        cell.delegate = self
        return cell
    }
}

extension ChatDetailViewController: ChatDetailCallTap {
    func callTapped(cell: ChatDetailTableViewCell) {
        guard let index = chatPartiipantsTableView.indexPath(for: cell)?.row else { return }
        guard let phoneNumber = data[index].phoneNumber else { return }
        guard let number = URL(string: "tel://\(phoneNumber)") else { return }
        
        UIApplication.shared.open(number)
    }
}
