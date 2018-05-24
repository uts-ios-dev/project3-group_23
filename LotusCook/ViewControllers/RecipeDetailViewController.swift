//
//  RecipeDetailViewController.swift
//  LotusCook
//
//  Created by Luochun on 2018/5/20.
//  Copyright © 2018年 Elase. All rights reserved.
//

import UIKit

class RecipeDetailViewController: MTBaseViewController {

    var recipe: Recipe!
    
    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var methedtitleLabel: UILabel!
    //@IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addNavigationBarLeftButton(self)
        title = "recipe detail"
        
        iconImgView.image = UIImage(named: recipe.image)
        titleLabel.text = recipe.name
        
        ingredientLabel.text = recipe.ingredients.map({ $0.0 + $0.1 }).joined(separator: "\n")
        methedtitleLabel.text = recipe.steps
    }

    


}
