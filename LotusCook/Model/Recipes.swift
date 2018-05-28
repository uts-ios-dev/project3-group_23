//
//  Recipes.swift
//  LotusCook
//
//  Created by Luochun on 2018/5/20.
//  Copyright © 2018年 Elase. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Recipe {
    var name: String = ""
    var tag: String = ""
    var energy: String = ""
    var time: String = ""
    var ingredients: [(String, String)] = []
    var steps: String = ""
    var image: String = ""
    
}

extension Recipe {
    static func getAllRecipes() -> [Recipe] {
        let filePath = Bundle.main.path(forResource: "recipes.plist", ofType: nil)!
        
        let infos = NSArray(contentsOfFile: filePath) as! [JSONMap]
        var res :[Recipe] = []
        infos.forEach({
            let recipe = Recipe()
            recipe.name = $0["name"] as! String
            recipe.tag = $0["tag"] as! String
            recipe.energy = $0["energy"] as! String
            recipe.time = $0["time"] as! String
            recipe.ingredients = ($0["ingredients"] as! [String]).map({
                let a = $0.components(separatedBy: ",")
                return (a[0], a[1])
            })
            recipe.steps = $0["steps"] as! String
            recipe.image = $0["image"] as! String + ".png"
            res.append(recipe)
        })
        
        return res
    }
    
    /// 名字搜索
    static func getRecipes(_ name: String) -> Recipe? {
        var items = Recipe.getAllRecipes()
        items = items.filter({
            $0.name == name
        })
        return items.count > 0 ? items[0] : nil
    }
    
    /// 关键字搜索
    static func getAllRecipesBy(_ words: String) -> [Recipe] {
        var items = Recipe.getAllRecipes()
        items = items.filter({
            $0.name.contains(words) || $0.tag == words
        })
        return items
    }
    
}

func == (lhs: Recipe, rhs: Recipe) -> Bool
{
    return lhs.name == rhs.name
}


class Meals: Object {
    @objc dynamic var email: String?
    @objc dynamic var recipe: String?
    @objc dynamic var copies: Int = 1
    
    /// 主键
    @objc dynamic var createdTime: String = ""
    
    override public static func primaryKey() -> String? {
        return "createdTime"
    }
    
    
}

func == (lhs: Meals, rhs: Meals) -> Bool
{
    return lhs.email == rhs.email && lhs.recipe == rhs.recipe
}


extension Meals {
    @discardableResult
    static func save(_ email: String, recipe: String, copies: Int = 1) -> Meals {
        let item = Meals()
        item.createdTime = String(Date().timeIntervalSince1970)
        
        item.email = email
        item.recipe = recipe
        item.copies = copies
        
        var exsit = false
        for go in Meals.getAllMeals() {
            if go == item {
                exsit = true
                break
            }
        }
        
        if !exsit {
            item.writeToDB()
        }
        
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
    
    static func deleteBy(_ recipe: String) {
        let all = Meals.getAllMeals()
        all.forEach({
            if $0.recipe == recipe {
                $0.delete()
            }
        })
    }
    
    
    static func getMealsBy(_ email: String) -> [Meals] {
        let realm = try! Realm() // Create realm pointing to default file
        let results = realm.objects(Meals.self).sorted(byKeyPath: "createdTime", ascending: false).filter("email == '\(email)'")
        let array = results.get(offset: 0, limit: results.count)
        
        
        return array as! [Meals]
        
    }

    
    /// 获取所有
    static func getAllMeals() -> [Meals] {
        let realm = try! Realm() // Create realm pointing to default file
        let results = realm.objects(Meals.self).sorted(byKeyPath: "createdTime", ascending: false)
        let array = results.get(offset: 0, limit: results.count)
        return array as! [Meals]
    }
}

extension Results {
    
    func get <T:Object> (offset: Int = 0, limit: Int ) -> Array<T> {
        //create variables
        var lim = 0 // how much to take
        var off = 0 // start from
        var l: Array<T> = Array<T>() // results list
        
        //check indexes
        if off<=offset && offset<self.count - 1 {
            off = offset
        }
        if limit > self.count {
            lim = self.count
        } else {
            lim = limit
        }
        
        //do slicing
        for i in off..<lim{
            let dog = self[i] as! T
            l.append(dog)
        }
        
        //results
        return l
    }
}
