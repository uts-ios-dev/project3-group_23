
import UIKit

class MineViewController: MTBaseViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var dietLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mine"
        addNavigationBarRightButton(self, action: #selector(editUserInfo), image: #imageLiteral(resourceName: "edit"))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = User.shared().name
        emailLabel.text = User.shared().email
        passwordLabel.text = User.shared().password
        dietLabel.text = User.shared().diet
    }
    
    @objc func editUserInfo() {
        let vc = UIStoryboard.Scene.userEdit
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func logout(_ sender: UIButton) {
        MTAlert(title: "Are you sure log out?", message: "", preferredStyle: .alert)
            .addAction(title: "Cancel", style: .cancel) { (_) in
                
            }.addAction(title: "Confirm", style: .default) { (_) in
                AppDelegate.shared.logout()
            }.show()
        
    }
    
    
}
