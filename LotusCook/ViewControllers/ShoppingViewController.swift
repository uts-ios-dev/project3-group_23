
import UIKit

class ShoppingViewController: MTBaseViewController {
    @IBOutlet weak var tableview: UITableView!
    
    
    var ingredients: [(String, String)] = [] {
        didSet {
            tableview.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let meals = Meals.getMealsBy(User.shared().email!)
        
        var items: [String: Float] = [:]
        for m in meals {
            
            if let rec = Recipe.getRecipes(m.recipe!) {
                
                let xx = rec.ingredients.map({(Float($0.0)! * Float(m.copies), $0.1) })
                xx.forEach({
                    if Array(items.keys).contains($0.1), let number = items[$0.1] {
                        items[$0.1] = number + $0.0
                    } else {
                        items[$0.1] = $0.0
                    }
                })
                
            }
        }
        
        ingredients = items.map({ (String($0.value), $0.key) })
        
        
        
        if ingredients.count == 0 {
            placeholder {
                (AppDelegate.root as! ESTabBarController).selectedIndex = 1
            }
        } else {
            self.hideStatus()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shopping"

    }
    

}





extension ShoppingViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CartCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension ShoppingViewController : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ingredients.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CartCell
        
        cell.titleLabel.text = ingredients[indexPath.row].0 + " " + ingredients[indexPath.row].1
        
        cell.action = { copies in
            
        }
        return cell
        
    }
}


class CartCell: UITableViewCell {
    
    @IBOutlet weak var checkbox: M13Checkbox!
    
    @IBOutlet weak var titleLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        checkbox.setCheckState(.checked, animated: false)
        checkbox.stateChangeAnimation = .fill
        checkbox.tintColor = MTColor.main
        
    }
    
    var action: ((_ copies: Int)->())? = nil
    

    
    static var  height: CGFloat {
        return 55
    }
    
    @IBAction func checkboxValueChanged(_ sender: M13Checkbox) {
        
    }
}
