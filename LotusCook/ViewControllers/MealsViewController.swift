
import UIKit


class MealsViewController: MTBaseViewController {
    @IBOutlet weak var tableview: UITableView!
    
    
    var myMeals = Meals.getMealsBy(User.shared().email!) {
        didSet {
            tableview.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Meals"
        
    }

    @IBOutlet weak var wolcomeLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wolcomeLabel.text = "Hi, " + User.shared().name!
        
        myMeals = Meals.getMealsBy(User.shared().email!)
        
        if myMeals.count == 0 {
            placeholder {
                (AppDelegate.root as! ESTabBarController).selectedIndex = 1
            }
        } else {
            self.hideStatus()
        }
    }

    
}



extension MealsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MealsCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension MealsViewController : UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return myMeals.count
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MealsCell
        
        cell.info = myMeals[indexPath.row]
        
        cell.action = { copies in
            let item = self.myMeals[indexPath.row]
            let new = Meals()
            new.createdTime = item.createdTime
            new.email = item.email
            new.recipe = item.recipe
            new.copies = copies
            new.update()
            
        }
        return cell
        
    }
}


class MealsCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientNumberLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var stepper: GMStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var action: ((_ copies: Int)->())? = nil
    
    var info: Meals? {
        didSet {
            if let info = info {
                if let rec = Recipe.getRecipes(info.recipe!) {
                iconImageView.image = UIImage(named: rec.image)
                titleLabel.text  = rec.name
                ingredientNumberLabel.text  = String(format: "%d ingredients",  rec.ingredients.count)
                energyLabel.text  = rec.energy
                timeLabel.text  = rec.time
                    stepper.value = Double(info.copies)
                }
            }
        }
    }
    
    
    
    @IBAction func valueChanged(_ sender: GMStepper) {
        action?(Int(sender.value))
    }
    
    static var  height: CGFloat {
        return 150
    }
    
}

