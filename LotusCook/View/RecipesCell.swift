//
//  RecipesCell.swift
//  LotusCook
//
//  Created by Luochun on 2018/5/25.
//  Copyright © 2018年 Elase. All rights reserved.
//

import UIKit

class RecipesCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientNumberLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    
    var action: (()->())? = nil
    
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
        if sender.isSelected {
            Meals.deleteBy(info!.name)
        } else {
            Meals.save(User.shared().email!, recipe: info!.name, copies: User.shared().service)
        }
        
        action?()
    }
    
    static var  height: CGFloat {
        return 150
    }
    
}
