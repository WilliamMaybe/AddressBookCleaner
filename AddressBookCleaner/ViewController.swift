//
//  ViewController.swift
//  AddressBookCleaner
//
//  Created by maybe on 2017/1/7.
//  Copyright © 2017年 Maybe Zh. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var confirmItem: UIBarButtonItem!
    @IBOutlet var editItem: UIBarButtonItem!
    
    var contacts: [CNContact]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func fetchAddressList(_ sender: Any) {
        AddressManager.address.fetchList { (contacts) in
            self.contacts = contacts
            tableView.reloadData()
        }
    }

    @IBAction func editAction(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        tableView.allowsMultipleSelectionDuringEditing = true
        if self.navigationItem.rightBarButtonItem == editItem {
            self.navigationItem.rightBarButtonItem = confirmItem
        } else {
            self.navigationItem.rightBarButtonItem = editItem
        }
    }
    @IBAction func confirmAction(_ sender: Any) {
        
        let endEditing = {
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem = self.editItem
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            endEditing()
        }
        
        let confirmAction = UIAlertAction(title: "Done", style: .default) { (_) in
            AddressManager.address.delete(contacts: self.selectedContacts())
            self.fetchAddressList(0)
            endEditing()
        }
        
        let alert = UIAlertController(title: "Delete Confirm?", message: "", preferredStyle: .alert)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectedContacts() -> [CNContact]? {
        var tmpContacts: [CNContact]?
        
        let indexs = tableView.indexPathsForSelectedRows!.map { $0.row }
        tmpContacts = contacts?.filter { indexs.contains((contacts?.index(of: $0))!) }
        
        return tmpContacts
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contacts = contacts {
            return contacts.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let contact = contacts![indexPath.row]
        cell?.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        var numbersArray = [String]()
        for number in contact.phoneNumbers {
            numbersArray.append(number.value.stringValue)
        }
        cell?.detailTextLabel?.text = numbersArray.joined(separator: ", ")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
}
