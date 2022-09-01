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
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let diary = diary else { return }
        
        viewController.diaryEditMode = .edit(indexPath, diary)
        
        /**
         NotificationCenter 옵저빙 하기
         */
        NotificationCenter.default.addObserver(
            self,//대상 인스턴스
            selector: #selector(editDiaryNorification(_:)),//옵저빙을하다 대상을 발견하면 발생하는 이벤트
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    /**
     NotificationCenter 발생시 실행되는 이벤트 method
     */
    @objc func editDiaryNorification(_ notification: Notification){
        guard let diary = notification.object as? Diary else {
            return
        }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else{ return }
        
        self.diary = diary
        self.configueView()
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
    
    /**
     종료시 실행되는 method
     */
    deinit{
        /**
         종료시 가지고있는 모든 옵저버를 제거하는 method
         */
        NotificationCenter.default.removeObserver(self)
    }
}
