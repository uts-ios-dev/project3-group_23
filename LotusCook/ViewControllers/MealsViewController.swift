//
//  MealsViewController.swift
//  HealthBot
//
//  Created by Luochun on 2018/5/15.
//  Copyright © 2018年 SpiderMan. All rights reserved.
//

import UIKit


class MealsViewController: MTBaseViewController {
    @IBOutlet weak var tableview: UITableView!
    
    var datas: [Recipe] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Meals"
        
        tableview.register(RecipesCell.self, forCellReuseIdentifier: "cell")
    }

    @IBOutlet weak var wolcomeLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wolcomeLabel.text = "Hi, " + User.shared().name!
        datas = []
        if datas.count == 0 {
            placeholder {
                (AppDelegate.root as! ESTabBarController).selectedIndex = 1
            }
        }
        tableview.reloadData()
    }

    
}



extension MealsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RecipesCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension MealsViewController : UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return datas.count
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecipesCell
        
        
        cell.info = datas[indexPath.row]
        
        return cell
        
    }
}


