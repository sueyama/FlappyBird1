//
//  StartViewController.swift
//  FlappyBird1
//
//  Created by Yuta Fujii on 2018/02/03.
//  Copyright © 2018年 Yuta Fujii. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    // スコアを表示する場所
    @IBOutlet var logoImageView: UIImageView!
    //
    var timeString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let ud = UserDefaults.standard
        
        // セーブデータがなかったら0を入れる
        if ud.object(forKey: "saveData") == nil{
            ud.set("0", forKey: "saveData")
        }
        
        // timeStringにスコアを代入
        self.timeString = ud.object(forKey: "saveData") as! String
        
        // アニメーションをつける
        UIView.animate(withDuration: 2.0, animations:{
            
            self.logoImageView.frame = CGRect(x: 16, y: 143, width: 343, height: 343)

        }, completion: nil)
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func postLine(_ sender: Any) {
        // Lineアイコンを押したとき
        shareLine()
    
    }
    
    
    func shareLine(){
        
        //
        let urlscheme: String = "line://msg/text"
        let message = timeString
        // line:/msg/text/(メッセージ)
        let urlstring = urlscheme + "/" + message
        
        // URLエンコード
        guard let  encodedURL = urlstring.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return
        }
        
        // URL作成
        guard let url = URL(string: encodedURL) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (succes) in
                    //  LINEアプリ表示成功
                })
            }else{
                UIApplication.shared.openURL(url)
            }
        }else {
            // LINEアプリが無い場合
            let alertController = UIAlertController(title: "エラー",
                                                    message: "LINEがインストールされていません",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default))
            present(alertController,animated: true,completion: nil)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // タッチしたらgamenVCに遷移する
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        
        self.navigationController?.pushViewController(gameVC, animated: true)
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
