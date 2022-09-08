//
//  StarViewController.swift
//  Diary
//
//  Created by 백시훈 on 2022/08/19.
//

import UIKit

class StarViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //diary데이터를 받을 객체 생성 및 초기화
    private var diaryList = [Diary]()
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionview()
        self.laodStarDiaryList()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.laodStarDiaryList()
//    }
    
    /**
     Diary를 CollectionView에 저장하기
     */
    private func configureCollectionview(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    /**
     userdefualts에서 즐겨찾기를 지정한 데이터만 가져오기
     */
    private func laodStarDiaryList(){
        let userDefualts = UserDefaults.standard
        guard let data = userDefualts.object(forKey: "DiaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap{
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(title: title, contents: contents, date: date, isStar: isStar, uuidString: uuidString)
        }.filter({
            $0.isStar == true
        }).sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
//        self.collectionView.reloadData()
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
    
    @objc func editDiaryNotification(_ notification: Notification){
        guard let diary = notification.object as? Diary else { return }
//        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == diary.uuidString } ) else { return }
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    @objc func starDiaryNotification(_ notification: Notification){
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let diary = starDiary["diary"] as? Diary else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        
        if isStar {
            self.diaryList.append(diary)
            self.diaryList = self.diaryList.sorted(by: {
                $0.date.compare($1.date) == .orderedDescending
            })
            self.collectionView.reloadData()
        }else{
            guard let index = self.diaryList.firstIndex(where: {$0.uuidString == uuidString }) else { return }
            self.diaryList.remove(at: index)
            self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    @objc func deleteDiaryNotification(_ notification: Notification){
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == uuidString }) else { return }
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
}

extension StarViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath ) as? StarCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = dateToString(date: diary.date)
        return cell
    }
}
 
extension StarViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height:80  )
    }
}

extension StarViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
