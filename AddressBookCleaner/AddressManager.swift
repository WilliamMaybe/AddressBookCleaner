//
//  AddressManager.swift
//  AddressBookCleaner
//
//  Created by maybe on 2017/1/7.
//  Copyright © 2017年 Maybe Zh. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

private let _instance = AddressManager()

class AddressManager: NSObject {
    
    fileprivate let contactStore: CNContactStore
    
    open class var address: AddressManager {
        return _instance
    }
    
    override init() {
        contactStore = CNContactStore()
        super.init()
        requestAuthority()
    }
    
    func fetchList(closure: ([CNContact]) -> ()) {
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch())
        
        var contacts = [CNContact]()
        do {
            try contactStore.enumerateContacts(with: fetchRequest) { (contact, stop) in
                contacts.append(contact)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        closure(contacts)
    }
    
    func detailViewController(contact :CNContact) -> UIViewController {
        let contactVC = CNContactViewController(for: contact)
        contactVC.contactStore = contactStore
        contactVC.displayedPropertyKeys = keysToFetch()
        return contactVC
    }
    
    func delete(contacts: [CNContact]?) {
        let saveRequest = CNSaveRequest()
        contacts?.forEach { saveRequest.delete($0.mutableCopy() as! CNMutableContact ) }
        try? contactStore.execute(saveRequest)
    }
}

extension AddressManager {
    
    fileprivate func requestAuthority() {
        guard CNContactStore.authorizationStatus(for: .contacts) != .notDetermined else {
            // 确定状态
            return
        }
        
        contactStore.requestAccess(for: .contacts, completionHandler: { (_, error) in
            guard error == nil else {
                print(error!)
                return
                }
        })
    }
    
    fileprivate func keysToFetch() -> [CNKeyDescriptor] {
        var keysToFetch: [Any] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                  CNContactImageDataKey,
                                  CNContactPhoneNumbersKey,
                                  CNContactFamilyNameKey,
                                  CNContactGivenNameKey]
        keysToFetch.append(CNContactViewController.descriptorForRequiredKeys())
        return keysToFetch as! [CNKeyDescriptor]
    }
}
