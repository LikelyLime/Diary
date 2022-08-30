//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by 백시훈 on 2022/08/19.
//

import UIKit

/**
 삭제구현 protocol
 */
protocol DiaryDetailViewDelegate: AnyObject{
    func didSelectDelete(indexPath: IndexPath)
    
}


class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLibel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    
    var diary: Diary? //화면에서 전달받는 프로퍼티
    var indexPath: IndexPath?
    
    weak var delegate: DiaryDetailViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configueView()
    }
    
    private func configueView(){
        guard let diary = self.diary else { return }
        self.titleLibel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = dateToString(date: diary.date)

    }
    /**
     date타입을 String타입으로 변경해주는 Method
     */
    private func dateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }
    
    /**
     수정버튼을 눌렀을때 버튼 액션
     */
    @IBAction func tabEditButton(_ sender: UIButton) {
    }
    /**
     삭제버튼 눌렀을때 버튼 액션
     */
    @IBAction func tabDeleteButton(_ sender: UIButton) {
        guard let indexPath = indexPath else {
            return
        }
        self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
}
