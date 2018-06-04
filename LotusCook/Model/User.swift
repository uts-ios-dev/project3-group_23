
import Foundation
import Realm
import RealmSwift

let kUserInfo = "loginedUser"

public typealias JSONMap = [String : Any]

public class User: Object {
    private static let _sharedInstance = User()
    
    static func shared() -> User {
        return _sharedInstance
    }

    
    
    /*用户信息*/
    @objc dynamic  var email: String?
    @objc dynamic var name: String?
    @objc dynamic var password: String?
    @objc dynamic var diet: String?     //["normal", "vegeterian"]
    @objc dynamic var service: Int = 1
    
    
    /// 主键
    @objc dynamic var createdTime: String = ""
    
    override public static func primaryKey() -> String? {
        return "createdTime"
    }
    

    
    ///  绑定用户信息
    func setUserInfo(_ userInfo: (String, String, String, String, Int)) {

        self.email = userInfo.0
        self.name = userInfo.1
        
        self.password = userInfo.2
        self.diet = userInfo.3
        self.service = userInfo.4
        let data = ["name": name!, "email": email!, "password": password!, "diet": diet!, "service": String(service)]
        UserDefaults.standard.set(data, forKey: kUserInfo)
    }
    
    
    static func logout() {
        UserDefaults.standard.removeObject(forKey: kUserInfo)
        
        User.shared().email = nil
        User.shared().name = nil
        User.shared().password = nil
        User.shared().diet = nil
        User.shared().service = 1
        
    }

    static var isLogined: Bool {
        if let data = UserDefaults.standard.dictionary(forKey: kUserInfo) as? [String: String] {
            let user = (data["email"]!, data["name"]!, data["password"]!, data["diet"]!, Int(data["service"]!)!)
            User.shared().setUserInfo( user )
            return true
        }

        return false
    }

}


func == (lhs: User, rhs: User) -> Bool
{
    return lhs.name == rhs.name && lhs.email == rhs.email
}


extension User {
    @discardableResult
    static func save(_ name: String, email: String, password: String, diet: String, service: Int = 1) -> User {
        let item = User()
        item.createdTime = String(Date().timeIntervalSince1970)
        
        item.name = name
        item.email = email
        item.password = password
        item.diet = diet
        item.service = service
        
        var exsit = false
        for go in User.getAllUsers() {
            if go == item {
                exsit = true
                break
            }
        }
        
        if !exsit {
            item.writeToDB()
        }
        User.shared().setUserInfo( (email, name, password, diet, service) )
        return item
    }
    
    func update()  {
        let realm = try! Realm() // Create realm pointing to default file
        try! realm.write {
            realm.add(self, update: true)
        }
    }
    
    func writeToDB() {
        // Realms are used to group data together
        let realm = try! Realm() // Create realm pointing to default file
        
        // Persist your data easily
        try! realm.write {
            realm.add(self)
        }
        
    }
    
    func delete() {
        let realm = try! Realm() // Create realm pointing to default file
        
        // Persist your data easily
        try! realm.write {
            realm.delete(self)
        }
        
    }
    
    
    static func getUserBy(_ email: String, pwd: String) -> User? {
        let realm = try! Realm() // Create realm pointing to default file
        let results = realm.objects(User.self).sorted(byKeyPath: "createdTime", ascending: false).filter("email == '\(email)' and password == '\(pwd)'")
        let array = results.get(offset: 0, limit: results.count)
        
        if array.count > 0 {
            return array[0] as? User
        }
        return nil
        
    }
    
    /// 获取某一类型的
    static func getAllUserBy(_ diet: String) -> [User] {
        let realm = try! Realm() // Create realm pointing to default file
        let results = realm.objects(User.self).sorted(byKeyPath: "createdTime", ascending: false)
        let array = results.get(offset: 0, limit: results.count) as! [User]
        return array.filter{$0.diet == diet}
        
    }
    
    /// 获取所有
    static func getAllUsers() -> [User] {
        let realm = try! Realm() // Create realm pointing to default file
        let results = realm.objects(User.self).sorted(byKeyPath: "createdTime", ascending: false)
        let array = results.get(offset: 0, limit: results.count)
        return array as! [User]
    }
}
