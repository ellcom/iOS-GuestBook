//
//  ViewController.swift
//  GuestBook
//
//  Created by Elliot Adderton on 20/02/2019.
//  Copyright © 2019 Elliot Adderton. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var guestbook:GuestBook?
    
    func update() {
       /* ApiController.getMessages(callback: { data,error in
            
            if let data = data {
                self.guestbook = data;
                self.tableView.reloadData()
            }
        });*/
        
        Task {
            let guestbook = await ApiController.asyncGetMessages()
            
            if guestbook != nil {
                DispatchQueue.main.async {
                    self.guestbook = guestbook
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.update()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guestbook?.data?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath)
        
        cell.textLabel?.text = self.guestbook?.data?[indexPath.row].message ?? ""
        cell.detailTextLabel?.text = self.guestbook?.data?[indexPath.row].created ?? ""
        
        return cell
    }

    @IBAction func addMessage(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Leave a message", message: nil, preferredStyle: .alert)
        alert.addTextField();
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak alert, weak self] (_) in
            if let message = alert?.textFields?.first?.text{
                
                /*ApiController.postMessage(message: message, callback: { (response, error) in
                    if error == nil && response?.code == 1
                    {
                        self?.update()
                    }
                })
                 */
                Task { [weak self] in
                    let guestbook = await ApiController.asyncPostMessage(message:message);
                
                    if( guestbook != nil )
                    {
                            self?.update();
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
}

