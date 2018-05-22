

import UIKit
import Foundation
import EasyPeasy

extension UIViewController {
    
    func showDateSelecter(_ title: String, year: Int? = nil, month: Int? = nil, day: Int? = nil, compeleted: DateSelectedBlock?) {
        
        let vc = DateLinkageViewController.init(year, month, day)
        vc.title = title
        vc.completedCallBack = compeleted
        
        let popupController = STPopupController(rootViewController: vc)
        popupController.hidesCloseButton = true
        let blurEffect = UIBlurEffect(style: .dark)
        popupController.backgroundView = UIVisualEffectView(effect: blurEffect)
        popupController.backgroundView?.alpha = 0.5
        popupController.navigationBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: MTColor.main, NSAttributedStringKey.font: pingFang_SC.medium(16)]
        
        popupController.style = .bottomSheet
        popupController.present(in: self)
        
    }
}

typealias DateSelectedBlock = ((_ year: Int, _ month: Int, _ day: Int) -> ())

class DateLinkageViewController: UIViewController {
    
    fileprivate var headView = UIView()
    fileprivate var titleButtons : [UIButton] = []
    fileprivate var lineView: UIView = {
        let view = UIView()
            view.backgroundColor = MTColor.main
        return view
    }()
    
    fileprivate var contentScrollView :UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        view.bounces = false
        return view
    }()
    
    fileprivate var YearsTable = UITableView()
    fileprivate var MonthsTable = UITableView()
    fileprivate var DaysTable = UITableView()
    
    var years: [Int] = (2017...Date().year).map({$0}).reversed()
    var months: [Int] = (1...12).map({$0})
    var days: [Int] = (1...31).map({$0})
    
    var selectYear: Int!
    var selectMonth: Int!
    var selectDay: Int!
    
    
    var completedCallBack: DateSelectedBlock?
    
    
    public convenience init(_ year: Int? = nil, _ month: Int? = nil, _ day: Int? = nil) {
        self.init()
        
        if year != nil &&  month != nil && day != nil {
            selectYear = year
            selectMonth = month
            selectDay = day
        }
        
        contentSizeInPopup = CGSize(width: view.frame.width, height: 373 + kTabbarSafeBottomMargin )
    }
    
    private func setup() {
        YearsTable.tag = 1
        MonthsTable.tag = 2
        DaysTable.tag = 3
        [YearsTable, MonthsTable, DaysTable].forEach {
            $0.separatorStyle = .none
            $0.delegate = self
            $0.dataSource = self
            $0.register(DateCell.self, forCellReuseIdentifier: "Cell")
        }
        
        view.addSubview(headView)
        
        headView.addSubview(lineView)
        
        (0 ..< 3).forEach {index in
            let btn = UIButton(type: .custom)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            btn.setTitle("请选择", for: .selected)
            btn.setTitleColor(MTColor.title333, for: .normal)
            btn.setTitleColor(MTColor.main, for: .selected)
            btn.tag = index
            btn.addTarget(self, action: #selector(changeSelecter(_:)), for: .touchUpInside)
            titleButtons.append(btn)
            headView.addSubview(btn)
        }
        
        contentScrollView.delegate = self
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(YearsTable)
        contentScrollView.addSubview(MonthsTable)
        contentScrollView.addSubview(DaysTable)
        
        contentScrollView.contentSize = CGSize(width: view.frame.width, height: contentScrollView.frame.height)
        
        titleButtons[1].isHidden = (selectMonth == nil)
        titleButtons[2].isHidden = (selectDay == nil)
        
    }
    
    private func layout() {
        headView.easy.layout(Left(0), Top(0), Height(36), Right(0))
        
        lineView.easy.layout(Left(0), Bottom(0), Width(view.frame.width*0.25), Height(2))
        
        titleButtons[0].easy.layout(Left(0), Top(0), Height(36), Width(view.frame.width*0.25))
        titleButtons[1].easy.layout(Left(0).to(titleButtons[0]), Top(0), Height(36), Width().like(titleButtons[0]))
        titleButtons[2].easy.layout(Left(0).to(titleButtons[1]), Top(0), Height(36), Width().like(titleButtons[1]))
        
        contentScrollView.easy.layout(Left(0), Top(0).to(headView, .bottom), Bottom(0), Right(0))
        
        YearsTable.easy.layout(Left(0), Top(0), Width().like(contentScrollView), Height().like(contentScrollView))
        MonthsTable.easy.layout(Left(0).to(YearsTable, .right), Top(0), Width().like(view), Height().like(contentScrollView))
        DaysTable.easy.layout(Left(0).to(MonthsTable, .right), Top(0), Width().like(view), Height().like(contentScrollView), Right(0))
        
    }
    
    var isClickingCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setup()
        layout()
        
        if selectYear != nil {
            titleButtons[0].setTitle(String(selectYear), for: .normal)
            titleButtons[1].setTitle(String(selectMonth), for: .normal)
            titleButtons[2].setTitle(String(selectDay), for: .normal)
        }
        
        titleBtnClick(titleButtons[0])
        
    }
    
    
    @objc func changeSelecter(_ sender: UIButton) {
        isClickingCell = false
        switch sender.tag {
        case 0:
            contentScrollView.contentOffset = CGPoint(x: 0, y: 0)
        case 1:
            contentScrollView.contentOffset = CGPoint(x: view.frame.width, y: 0)
        case 2:
            contentScrollView.contentOffset = CGPoint(x: view.frame.width * 2, y: 0)
        default:
            break
        }
        titleBtnClick( sender)
    }
    
    @objc func titleBtnClick(_ titleBtn: UIButton)  {
        titleButtons.forEach{$0.isSelected = false}
        titleBtn.isSelected = true
        titleBtn.isHidden = false
        let x = CGFloat(titleBtn.tag) * view.frame.width
        if isClickingCell {
            isClickingCell = false
            self.contentScrollView.contentOffset = CGPoint(x: x, y: 0)
        }
        UIView.animate(withDuration: 0.5) {
            self.lineView.easy.layout(Left(0).to(titleBtn, .left))
            self.lineView.layoutIfNeeded()
        }
    }
    
}

extension DateLinkageViewController :UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {

            let leftI = NSInteger(scrollView.contentOffset.x / view.frame.width)
            if CGFloat(scrollView.contentOffset.x / view.frame.width) == CGFloat(leftI)  {
                let titleBtn = titleButtons[leftI]
                titleBtnClick( titleBtn)
                
            }
        }
    }
}

extension DateLinkageViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        isClickingCell = true
        switch tableView.tag {
        case 1:
            selectYear = years[indexPath.row]
            titleButtons[0].setTitle(String(selectYear), for: .normal)
            titleButtons[0].isSelected = false
            contentScrollView.contentOffset = CGPoint(x: view.frame.width, y: 0)
            MonthsTable.reloadData()
        case 2:
            selectMonth = months[indexPath.row]
            titleButtons[1].setTitle(String(selectMonth), for: .normal)
            titleButtons[1].isSelected = false
            contentScrollView.contentOffset = CGPoint(x: view.frame.width * 2, y: 0)
            DaysTable.reloadData()
        case 3:
            selectDay = days[indexPath.row]
            titleButtons[2].setTitle(String(selectDay), for: .normal)
            titleButtons[2].isSelected = false
            if let handle = completedCallBack {
                handle(selectYear, selectMonth, selectDay)
                self.st_dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
}

extension DateLinkageViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1:
            return years.count
        case 2:
            return months.count
        case 3:
            return days.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DateCell
        
        //cell.accessoryType = .disclosureIndicator
        cell.accessoryType = .none
        
        switch tableView.tag {
        case 1:
            let title = String(years[indexPath.row])
            cell.titleLabel.text = title
            if let xx = selectYear {
                cell.titleLabel.textColor =  title == String(xx) ? MTColor.main : MTColor.des666
                cell.markImageView.isHidden = title != String(xx)
            } else {
                cell.titleLabel.textColor = MTColor.des666
                cell.markImageView.isHidden = true
            }
        case 2:
            let title = String(months[indexPath.row])
            cell.titleLabel.text = title
            if let xx = selectMonth {
                cell.titleLabel.textColor =  title == String(xx) ? MTColor.main : MTColor.des666
                cell.markImageView.isHidden = title != String(xx)
            } else {
                cell.titleLabel.textColor = MTColor.des666
                cell.markImageView.isHidden = true
            }
        case 3:
            let title =  String(days[indexPath.row])
            cell.titleLabel.text = title
            if let xx = selectDay {
                cell.titleLabel.textColor =  title == String(xx) ? MTColor.main : MTColor.des666
                cell.markImageView.isHidden = title != String(xx)
            } else {
                cell.titleLabel.textColor = MTColor.des666
                cell.markImageView.isHidden = true
            }
        default:
            break
        }
        
        return cell
        
    }
    
}


fileprivate class DateCell: UITableViewCell {
    
    var titleLabel: UILabel = UILabel()
    
    var markImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(titleLabel)
        self.addSubview(markImageView)
        
        titleLabel.textColor = MTColor.des666
        titleLabel.font = pingFang_SC.medium(14)
        
        markImageView.image = #imageLiteral(resourceName: "g勾")
        markImageView.easy.layout(Right(30), CenterY(0), Width(15.5), Height(11.5))
        titleLabel.easy.layout(Left(30), Top(0), Right(20).to(markImageView), Bottom(0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

