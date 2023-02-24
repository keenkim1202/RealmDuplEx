//
//  ViewController.swift
//  RealmDuplRemoveEx
//
//  Created by KeenKim on 2023/02/24.
//

import UIKit
import RealmSwift

// MARK: Realm에 중복된 데이터를 저장하지 못하도록 하는 예제

/// Realm에 사용할 데이터 모델
class ItemModel: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var listTableView: UITableView!
    
    /// local realm 선언
    let realm = try! Realm()
    /// realm에 저장된 데이터 목록을 가져와 저장할 ItemModel타입의 Results
    var itemList: Results<ItemModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self
        /// 앱 처음 실행 시 realm에 저장된 데이터 목록을 가져오도록 함
        itemList = realm.objects(ItemModel.self)
    }
    
    /// 필요시 realm데이터를 갱신해서 가져오고,  tableView를 갱신하는 함수
    func reloadRealmData() {
        itemList = realm.objects(ItemModel.self)
        listTableView.reloadData()
    }
    
    /// realm에 데이터를 저장하는 함수
    /// 이미 같은 객체가 존재한다면 저장하지 않고 alert을 띄운다.
    func save(name: String) {
        let item = ItemModel(name: name)
        
        if isItemAlreadyExist(name: name) {
            let alert = UIAlertController(title: "⚠️ 추가 불가", message: "같은 아이템이 존재합니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: false)

        } else {
            try! realm.write {
                realm.add(item)
            }
        }
    }
    
    /// 같은 name 값을 가진 객체가 있는지 체크하여 Bool 값을 리턴하는 함수
    /// 존재하면 true, 존재하지 않으면 false
    func isItemAlreadyExist(name: String) -> Bool {
        if let itemList = itemList {
            let sameObject = itemList.where { $0.name == name }
            
            return sameObject.isEmpty ? false : true
        }
        
        return false
    }
    
    /// 저장 버튼을  눌렀을 때 실행되는 IBAction 함수
    @IBAction func saveButton(_ sender: UIButton) {
        save(name: inputTextField.text!)
        reloadRealmData()
        inputTextField.text = ""
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let itemList = itemList {
            return itemList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {return UITableViewCell() }
        if let itemList = itemList {
            cell.titleLabel.text = itemList[indexPath.row].name
        }
        return cell
    }
}

/// listTableView의 Cell 클래스
class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

