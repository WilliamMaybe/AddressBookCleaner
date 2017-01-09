# AddressBookCleaner
突然发现联系人的好多好多人，而且自带的竟然不支持批量删除！！！
什么鬼！！！动手写个简单版的吧
##UIContact
iOS9之后出现的库，之前使用的是AddressBook
###请求通讯录权限，生成相应参数
```
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
```
###获取所有联系人列表
权限通过之后，就可以获取联系人啦，在这里呢，`CNContactStore提供了2个接口

`
open func unifiedContacts(matching predicate: NSPredicate, keysToFetch keys: [CNKeyDescriptor]) throws -> [CNContact]
`
`
open func enumerateContacts(with fetchRequest: CNContactFetchRequest, usingBlock block: @escaping (CNContact, UnsafeMutablePointer<ObjCBool>) -> Swift.Void) throws
`
前者可以选择过滤获取联系人，所以呢，我就直接选择后者了。
在方法中又出现了一个`CNContactFetchRequest`，简单的创建一个就好了

```
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
```
*`KeysToFetch需要对应好将要显示的参数，如果显示的时候获取到没有填写的key，就会crash`*

```
fileprivate func keysToFetch() -> [CNKeyDescriptor] {
        var keysToFetch: [Any] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                  CNContactImageDataKey,
                                  CNContactPhoneNumbersKey,
                                  CNContactFamilyNameKey,
                                  CNContactGivenNameKey]
        keysToFetch.append(CNContactViewController.descriptorForRequiredKeys())
        return keysToFetch as! [CNKeyDescriptor]
    }
```
*`获取列表接口会耗费一定的时间，需要放到分线程`*
###删除联系人
系统专门提供了一个`CNSaveRequest`的类，来进行增删改查的一系列操作
`open func add(_ contact: CNMutableContact, toContainerWithIdentifier identifier: String?)`
`open func update(_ contact: CNMutableContact)`
`open func delete(_ contact: CNMutableContact)`
等等
一开始看到的时候愣了一下，怎么没有批量删除呢，这不还得一个一个删啊。想了一会醒悟过来了，我们可以一直调用delete的方法，这个方法在执行的时候并不会真的去删除，只是做了一个存储操作的过程。在最后还需要调用CNContactStore.execute

```
func delete(contacts: [CNContact]?) {
        let saveRequest = CNSaveRequest()
        contacts?.forEach { saveRequest.delete($0.mutableCopy() as! CNMutableContact ) }
        try? contactStore.execute(saveRequest)
    }
```
##打完收工，可以开开心心的删除通讯录的多余了😁