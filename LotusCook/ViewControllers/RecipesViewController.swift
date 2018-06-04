

import UIKit

class RecipesViewController: MTBaseViewController {
    
    var datas: [Recipe] = Recipe.getAllRecipes()
    
    var myMeals = Meals.getMealsBy(User.shared().email!)
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes"
        
        addNavigationBarRightButton(self, action: #selector(toSearch), image: #imageLiteral(resourceName: "search"))
        
        
        table.registerNib(cellClass: RecipesCell.self)
        
//        Meals.getMealsBy(User.shared().email!).forEach({$0.delete()})
//        myMeals = Meals.getMealsBy(User.shared().email!)
    }
    
    @objc func toSearch() {
        let vc = UIStoryboard.Scene.search
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
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


