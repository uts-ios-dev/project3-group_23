//
//  SearchViewController.swift
//  LotusCook
//
//  Created by Luochun on 2018/5/25.
//  Copyright © 2018年 Elase. All rights reserved.
//

import UIKit

class SearchViewController: MTBaseViewController {
    var datas: [Recipe] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    var myMeals = Meals.getMealsBy(User.shared().email!)
    
    @IBOutlet weak var table: UITableView!
    
    let searchBar: UIView =  {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF5F5F8)
        view.cornerRadius  = 5
        return view
    }()
    
    let searchField: UITextField =  {
        let textField = UITextField()
        textField.returnKeyType = .search
        textField.font = pingFang_SC.regular(14)
        textField.textColor = MTColor.title111
        textField.backgroundColor = .clear
        return textField
    }()
    
    func setupSearchBar()  {
        searchBar.frame = CGRect(x: 60, y: 0, width: view.frame.width - 20, height: 32)
        searchField.frame = CGRect(x: 10, y: 0, width: searchBar.frame.width - 20, height: 32)
        searchBar.addSubview(searchField)
        view.addSubview(searchBar)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchField.becomeFirstResponder()
        searchField.delegate = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addNavigationBarLeftButton(self)
        
        setupSearchBar()
        navigationItem.titleView = searchBar
        
        table.registerNib(cellClass: RecipesCell.self)
        
    }
    

    func searchRecipes(_ keys: String) {
        datas = Recipe.getAllRecipesBy(keys)
    }
}

extension SearchViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RecipesCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard.Scene.recipeDetail
        vc.recipe = datas[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SearchViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return datas.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView[indexPath] as! RecipesCell
        
        cell.info = datas[indexPath.row]
        
        let have = myMeals.filter({$0.recipe == datas[indexPath.row].name})
        cell.button.isSelected = have.count > 0
        
        cell.action = {
            self.myMeals = Meals.getMealsBy(User.shared().email!)
            tableView.reloadData()
        }
        return cell
        
    }
}


extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchText = searchField.text, searchText.count > 0 else {
            showMessage("Please enter keywords")
            return false
        }
        
        
        searchRecipes(searchText)
        textField.resignFirstResponder()
        return true
    }
}

