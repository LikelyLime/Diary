//
//  ViewController.swift
//  Diary
//
//  Created by 백시훈 on 2022/08/19.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //구조체 추가
    private var diaryList = [Diary](){
        //DiaryList에 데이터가 추가되거나 변경이 일어날 때마다 저장을 해준다.
        didSet{
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.laodDiaryData()
    }
    
    /**
     콜랙션 뷰에 데이터 표시하기
     */
    private func configureCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        //collectionView의 컨텐츠들의 간격이 상하좌우10만큼 유지된다.
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    
    /**
        일기쓰기 화면에서 등록 버튼 후 데이터를 받는 메서드
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let witeDiaryViewController = segue.destination as? WriteDiaryViewController{
            witeDiaryViewController.delegeate = self
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
     userDefaults 사용해서 데이터 저장하기
     */
    private func saveDiaryList(){
        let data = self.diaryList.map{
            [
                "title" : $0.title,
                "contents" : $0.contents,
                "date" : $0.date,
                "isStar" : $0.isStar
            ]
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "DiaryList")
    }
    
    /**
     userDefaults 데이터 불러오기
     */
    private func laodDiaryData(){
        let userDefaults = UserDefaults.standard
        guard let Data = userDefaults.object(forKey: "DiaryList") as? [[String: Any]] else{ return }
        self.diaryList = Data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }
        //날짜별로 정렬시키기
        self.diaryList = self.diaryList.sorted(by:{
            $0.date.compare($1.date) == .orderedDescending
        })
        
    }
}
/**
    컬렉션 뷰의 컨텐츠를 관리하는 객체
    numberOfItemsInSection : 셀의 갯수
    cellForItemAt : 필수 작성요소로
 */
extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else {return UICollectionViewCell()}
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dataLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

/**
 콜랙션뷰를 UI로 보여주는 메서드
 */
extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20 , height: 200)
    }
}
/**
    일기쓰기 화면에서 등록 버튼 후 데이터를 받는 prepare를 채택하기 위한 메서드
 */
extension ViewController: WriteDiaryViewDelegate{
    func didSelectReigster(diary: Diary){
        self.diaryList.append(diary)
        //날짜별로 정렬시키기
        self.diaryList = self.diaryList.sorted(by:{
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
}

/**
 콜랙션뷰를 선택했을때 발생되는 extension
 */
extension ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "DiaryDetailViewController") as? DiaryDetailViewController else {return}
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        
        viewController.delegate = self//>>??뭔지 이해안됨
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

/**
 diaryDetailViewController의 삭제버튼을 눌렀을 때 발생
 */
extension ViewController: DiaryDetailViewDelegate{
    func didSelectDelete(indexPath: IndexPath) {
        self.diaryList.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
    }
}
