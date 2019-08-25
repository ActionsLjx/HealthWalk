//
//  ViewController.swift
//  healthWalk
//
//  Created by _Ljx on 2019/8/22.
//  Copyright © 2019 _Ljx. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    var isHealthAuthorize: Bool = false
    var healthManager: HealthManager = HealthManager()
    let cellID = "cellID"
    var stepCount: Double = 0.00
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: Const.kScreenWidth, height: Const.kScreenHeight), style: .plain)
        tableView.register(HealthTableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        if healthManager.authorizeHealthKit() {
            healthManager.stepRead()
            healthManager.stepHandle = {[weak self] step in
                self?.stepCount = step
                self?.tableView.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }

    private func configUI() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HealthTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! HealthTableViewCell
            cell.h_titleLable.text = "步数"
            cell.h_detailLable.text = String.init(format: "%0.0f", stepCount)
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alertVC = UIAlertController.init(title: "修改步数", message: "输入需要增加/减少的步数", preferredStyle: UIAlertController.Style.alert)
            alertVC.addTextField { (textField) in
                textField.keyboardType = .numberPad
                textField.placeholder = "请输入步数"
            }
            let action1 = UIAlertAction.init(title: "确认", style: UIAlertAction.Style.default) { (action) in
//                healthManager.stepWirte(nextStep: <#T##Double#>)
            }
            alertVC.addAction(action1)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}

