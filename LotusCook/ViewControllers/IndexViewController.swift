

import UIKit

class IndexViewController: MTBaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func goLogin() {
        let vc = UIStoryboard.Scene.login
        navigationController?.pushViewController(vc, animated: true)
    }

    
    @IBAction func goRegister() {
        let vc = UIStoryboard.Scene.register
        navigationController?.pushViewController(vc, animated: true)
    }

}
