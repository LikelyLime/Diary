//
//  DiaryCell.swift
//  Diary
//
//  Created by 백시훈 on 2022/08/19.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    /**
     Cell의 테두리를 만들어주는 Method
     통상적으로 init이기 때문에 객체가 만들어질때 실행 됨
     */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
}
