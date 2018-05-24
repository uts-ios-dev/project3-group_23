//
//  RecipesViewController.swift
//  HealthBot
//
//  Created by Luochun on 2018/5/15.
//  Copyright © 2018年 SpiderMan. All rights reserved.
//

import UIKit

class RecipesViewController: MTBaseViewController {
    
    var datas: [Recipe] = Recipe.getAllRecipes()
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes"
        
    }
}



extension RecipesViewController : UITableViewDelegate {
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

extension RecipesViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return datas.count
        
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecipesCell
        
        cell.info = datas[indexPath.row]
        
        return cell
        
    }
}

class RecipesCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientNumberLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var info: Recipe? {
        didSet {
            if let info = info {
                iconImageView.image = UIImage(named: info.image)
                titleLabel.text  = info.name
                ingredientNumberLabel.text  = String(format: "%d ingredients",  info.ingredients.count)
                energyLabel.text  = info.energy
                timeLabel.text  = info.time
            }
        }
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        
    }
    
    static var  height: CGFloat {
        return 150
    }
    
}
