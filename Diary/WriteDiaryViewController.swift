//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 백시훈 on 2022/08/19.
//

import UIKit

/**
 일기 수정을 위한 enum
 */
enum DiaryEditMode {
    case new
    case edit(IndexPath, Diary)
}
/**
    구조체를 가져오는 protocol
 */
protocol WriteDiaryViewDelegate: AnyObject{
    func didSelectReigster(diary: Diary)
}

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!     //제목 입력 textfield란
    @IBOutlet weak var contentsTextView: UITextView!    //내용 입력란
    @IBOutlet weak var dateTextField: UITextField!      // 날짜 선택란
    @IBOutlet weak var confirmButton: UIBarButtonItem!  //등록 버튼
    
    private let datePicker = UIDatePicker()             //datePicker생성 프로퍼티
    private var diaryDate: Date?                    //datePicker의 데이터를 담을 변수
    
    //구조체에 데이터를 담을 변수 선언
    weak var delegeate: WriteDiaryViewDelegate?
    
    //일기 수정을 위한 변수enum
    var diaryEditMode: DiaryEditMode = .new
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditMode()
        self.confirmButton.isEnabled = false
    }
     
    
    /**
            내용의 TextField 란의 테두리를 생성하기 위한 함수
     */
    private func configureContentsTextView(){
        let boardColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)//alpha는 0.0~1.0사이값을 넣어주어야 하며 투명도를 나타냄
        self.contentsTextView.layer.borderColor = boardColor.cgColor//Layer관련 컬러는 cgColor로 나타낸다.
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    /**
            DatePicker 구성 함수
     */
    private func configureDatePicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)//UI컴퍼넌트에서 이벤트로 동작하게 해주는 메서드
        self.dateTextField.inputView = self.datePicker
    }
    /**
        datePicker.addTarget의 Select함수(datePicker의 속성등 을 설정)
     */
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker){
         let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR ")
        self.diaryDate = datePicker.date
        self.dateTextField.text = formatter.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged)//날짜가 변경 될때마다 editingChanged가 발생하도록한다.
    }
    
    /**
     일기를 수정하는 method
     */
    private func configureEditMode(){
        switch self.diaryEditMode{
        case let .edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
            
        default:
            break
        }
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
        등록버튼을 누르면 구조체에 데이터를 담아 전달
     */
    @IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        
       
        
        /**
        수정버튼일 때
         */
        switch self.diaryEditMode{
        case .new: 
            let diary = Diary(title: title, contents: contents, date: date, isStar: false, uuidString: UUID().uuidString)
            self.delegeate?.didSelectReigster(diary: diary)
            
        case let .edit(indexPath, diary):
            let diary = Diary(title: title, contents: contents, date: date, isStar: diary.isStar, uuidString: UUID().uuidString)
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),//NSNotification의 아이디
                object: diary,//전달 할 객체
                userInfo: nil)
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }
    /**
            유저가 빈화면을 터치했을때 실행되는 Method
        빈 화면을 클릭했을때 키보드나 dataPicker를 닫아줌
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /**
            제목, 내용, 날짜의 작성을 확인하는 메서드
                3가지 전부 내용이 있을 경우 등록 버튼 활성화
     */
    private func configureInputField(){
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func dateTextFieldDidChange(_ textField: UITextField){
        self.vaildateInputField()
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField ){
        self.vaildateInputField()
    }
    /**
            제목, 내용, 날짜의 작성을 확인하는 메서드
                3가지 전부 내용이 있을 경우 등록 버튼 활성화
     */
    private func vaildateInputField(){
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
        
    }
}

/**
    configureInputField의 delegate구현
 */
extension WriteDiaryViewController: UITextViewDelegate{
    //textView에 text가 입력될때마다 적용
    func textViewDidChange(_ textView: UITextView) {
        self.vaildateInputField()
    }
}
