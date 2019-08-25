//
//  HealthTableViewCell.swift
//  healthWalk
//
//  Created by _Ljx on 2019/8/23.
//  Copyright © 2019 _Ljx. All rights reserved.
//

import UIKit

class HealthTableViewCell: UITableViewCell {
    static let rowHeight: CGFloat = 99.5
    var h_backgroundView = UIView.init(frame: CGRect(x: 0, y: 0, width: Const.kScreenWidth, height: HealthTableViewCell.rowHeight))
    var h_titleLable = UILabel.init(frame: CGRect(x: 15, y: 10, width: Const.kScreenWidth - 20, height: 30))
    var h_detailLable = UILabel(frame: CGRect(x: 10, y: 50, width: Const.kScreenWidth - 20 , height: 40))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buildViews()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func buildViews() {
        self.selectionStyle = .none
        self.addSubview(h_backgroundView)
        self.addSubview(h_titleLable)
        self.addSubview(h_detailLable)
        h_detailLable.textColor = UIColor.red
        h_detailLable.textAlignment  = .right
        h_detailLable.font = UIFont.init(name: "AvenirNext-UltraLight", size: 30)
    }

}
