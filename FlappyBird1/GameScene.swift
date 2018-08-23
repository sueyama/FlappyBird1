 //
//  GameScene.swift
//  FlappyBird1
//
//  Created by Yuta Fujii on 2018/02/02.
//  Copyright © 2018年 Yuta Fujii. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    // SKPhysicsContactDelegate
    // モノとモノがぶつかったときに動くDelegate　衝突判定をさせる
    
    // 鳥を定義
    var bird = SKSpriteNode()
    // gameover時に表示される画像の定義
    var gameOverImage = SKSpriteNode()
    // タップ時のジャンプした際の音を定義
    let jumpSound = SKAction.playSoundFileNamed("sound.mp3", waitForCompletion:false)
    // バックミュージックの音を定義(魔王魂というサイトから取得)
    let backSound = SKAction.playSoundFileNamed("backSound.mp3", waitForCompletion:false)
    
    // 衝突したらパイプが止まるようにする為の変数
    // SKNode = 物体のみ、画像は使わない
    var blockingObjects = SKNode()

    // スコア用の変数
    var score = Int(0)
    // スコアを表示するラベル
    var scoreLbl = SKLabelNode()
    
    // 上のパイプ用の定義
    var pipeTop = SKSpriteNode()

    // タイマー用の定義(上の表示用)
    var timer:Timer = Timer()
    // タイマー用の定義(ゲームの進行用)
    var gameTimer:Timer = Timer()
    
    // Line用の定義
    var timeString = String()
    
    override func didMove(to view: SKView) {
    
        // バックミュージックとジャンプ音を流す
        self.run(backSound, withKey: "backSound")
        self.run(jumpSound, withKey: "jumpSound")
        // 鳥、背景、障害物を書く
        createParts()
    }
    
    func createParts(){
        
        // 背景を描く
        let backView = SKSpriteNode(imageNamed: "bg.png")
        backView.position = CGPoint(x: 0, y: 0)
        // 背景画像をリピートさせる
        backView.run(SKAction.repeatForever(SKAction.sequence([
                // 背景を動かす(13秒かけてxを幅分動かす)(で元に戻る)
                SKAction.moveTo(x: -self.size.width, duration: 13.0),
                SKAction.moveTo(y: 0, duration: 0.0)
            
            ])))
        // 画面につける
        self.addChild(backView)
        
        let backView2 = SKSpriteNode(imageNamed: "bg.png")
        // ポジションを変えて同じものを作る
        backView2.position = CGPoint(x: self.frame.width, y: 0)
        backView2.run(SKAction.repeatForever(SKAction.sequence([
            
            SKAction.moveTo(x: 0, duration: 13.0),
            SKAction.moveTo(y: self.frame.width, duration: 0.0)
            
            ])))

        
        self.addChild(backView2)
        
        // 鳥とゲームオーバーイメージを初期化
        bird = SKSpriteNode()
        gameOverImage = SKSpriteNode()
        // 障害物を止めるため
        blockingObjects = SKSpriteNode()
        
        // スコア系の初期化
        score = Int(0)
        scoreLbl = SKLabelNode()
        scoreLbl = self.childNode(withName: "scoreLbl") as! SKLabelNode
        scoreLbl.text = "\(score)"
        scoreLbl.color = UIColor.white
        scoreLbl.zPosition = 14
        scoreLbl.fontSize = 50
        scoreLbl.fontName = "HelveticaNeue-Bold"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 0, y: 0)
        // scoreBgを丸くする
        scoreBg.path = CGPath(roundedRect: CGRect(x: CGFloat(-50), y: CGFloat(-30), width: CGFloat(100), height: CGFloat(100)), cornerWidth: 50, cornerHeight: 50, transform: nil)
        // 色などの定義
        let scoreBgColor = UIColor.gray
        scoreBg.alpha = 0.5
        // strokeColorは縁の色
        scoreBg.strokeColor = UIColor.clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = 13
        scoreLbl.addChild(scoreBg)
        
        
        // タイマーを初期化する
        timer = Timer()
        gameTimer = Timer()
        
        // 自分が物理世界を定義するということを書く
        self.physicsWorld.contactDelegate = self
        // 物理世界の重力を定義する。CGVector y方向に-6
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        
        // 再スタートするときに障害物を一旦すべて除去
        blockingObjects.removeAllChildren()
        // 再スタートするときにgameoverイメージを初期化
        gameOverImage = SKSpriteNode()
        self.addChild(blockingObjects)
        
        // ゲームオーバーイメージを作っていく
        // 画像をつける
        let gameOverTexture = SKTexture(imageNamed: "GameOverImage.jpg")
        // textureを取り込む
        gameOverImage = SKSpriteNode(texture: gameOverTexture)
        // 位置を決める(真ん中にする)
        gameOverImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        // zpositionを決める　値が大きいほど手前にくる
        gameOverImage.zPosition = 11
        self.addChild(gameOverImage)
        // まずは消しておく
        gameOverImage.isHidden = true
        
        // 鳥のイメージを作成していく
        let birdTexture = SKTexture(imageNamed: "bird.png")
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        // 物理的ボディを丸くさせる
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        // 動かす対象のものはtrueにする
        bird.physicsBody?.isDynamic = true
        // 回るのを許可するかどうか
        bird.physicsBody?.allowsRotation = false
        
        // 鳥にカテゴリーづけする(ドカンとかと区別をする)
        bird.physicsBody?.categoryBitMask = 1
        
        // この鳥がどのようなものをあたったときに衝突判定をするか定義する
        bird.physicsBody?.collisionBitMask = 2
        bird.physicsBody?.contactTestBitMask = 2
        
        bird.zPosition = 10
        
        self.addChild(bird)
        
        // 地面を定義する
        let ground = SKNode()
        ground.position = CGPoint(x: -325, y: -700)
        
        // groundの幅と高さを決めてる
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        // 動かせない
        ground.physicsBody?.isDynamic = false
        // 地面のカテゴリーは2
        ground.physicsBody?.categoryBitMask = 2
        blockingObjects.addChild(ground)

        // timerを使ってメソッドを繰り返し呼ぶ(createPipeを呼ぶ)
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(createPipe), userInfo: nil, repeats: true)

        //　ゲームタイマーを定義　繰り返しupdateScoreを呼ぶ
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        
    }

    @objc func updateScore(){
        
        score += 1
        scoreLbl.text = "\(score)"
        
    }

    
    @objc func createPipe(){
        
        //パイプ生成
        // 高さはランダムなので、乱数を用いてパイプの長さを決める　arc4random
        let randamLength = arc4random() % UInt32(self.frame.size.height/2)
        // randomLengthが０の時に1/4のサイズにしている
        let offset = CGFloat(randamLength) - self.frame.size.height/4
        // パイプとパイプの間を開ける
        let gap = bird.size.height*3
        // パイプの画像を定義
        let pipeTopTexture = SKTexture(imageNamed: "pipeTop.png")
        pipeTop = SKSpriteNode(texture: pipeTopTexture)
        // パイプの位置を決めている
        pipeTop.position = CGPoint(x: self.frame.midX + self.frame.width/2, y: self.frame.midY + pipeTop.size.height/2 + gap/2 + offset)
        // パイプにphysicBodyをつけて長方形にする
        pipeTop.physicsBody = SKPhysicsBody(rectangleOf: pipeTop.size)
        pipeTop.physicsBody?.isDynamic = false
        
        // 衝突判定するためにカテゴリーわける２
        pipeTop.physicsBody?.categoryBitMask = 2
        blockingObjects.addChild(pipeTop)
        
        
        
        //下のパイプ用の定義
        let pipeBottomTexture = SKTexture(imageNamed: "pipeBottom.png")
        let pipeBottom = SKSpriteNode(texture: pipeBottomTexture)
        pipeBottom.position = CGPoint(x: self.frame.midX + self.frame.width/2, y: self.frame.midY - pipeBottom.size.height/2 - gap/2 + offset)
        pipeBottom.physicsBody = SKPhysicsBody(rectangleOf: pipeBottom.size)
        pipeBottom.physicsBody?.isDynamic = false
        
        pipeBottom.physicsBody?.categoryBitMask = 2
        blockingObjects.addChild(pipeBottom)
        
        // パイプに動きをつけていく
        // 右から左に４秒かけて画面の幅分だけ移動する
        let pipeMove = SKAction.moveBy(x: -self.frame.size.width - 70, y: 0, duration: 4)
        pipeTop.run(pipeMove)
        pipeBottom.run(pipeMove)
    
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 衝突した際に呼ばれるメソッド
        // スピードをゼロにする
        blockingObjects.speed = 0
        // ゲームオーバーの画像を非表示から表示にする
        gameOverImage.isHidden = false
        // タイマーをストップする
        timer.invalidate()
        gameTimer.invalidate()
        // スコアをゼロにしてスコアのラベルをremoveする
        score = 0
        scoreLbl.removeAllChildren()
        // 障害物についているアクションを取っ払う
        blockingObjects.removeAllActions()
        // 障害物を全部removeする
        blockingObjects.removeAllChildren()
        
        // アプリ内に保存されたスコアと比較して大きければ更新する
        let ud = UserDefaults.standard
        // timeStringにアプリ内のデータを格納する
        self.timeString = ud.object(forKey: "saveData") as! String
        
        if Int(self.timeString)! < Int(scoreLbl.text!)!{
           
            ud.set(scoreLbl.text!, forKey: "saveData")
            
        }
        
        // 音楽を止める
        self.removeAction(forKey: "backSound")
        self.removeAction(forKey: "jumpSound")

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチした時に鳥が跳ねるアクションを定義する
        // ゲームオーバーイメージが出ている状態であれば
        if gameOverImage.isHidden == false{
            
            // ゲームオーバーイメージを隠す
            gameOverImage.isHidden = true
            bird.removeFromParent()
            // ゲームをもう一度はじめから始める
            createParts()
        }else{
            
            // ゲームプレイ中であれば
            // 鳥の動きを一旦止める
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            // 上向きの力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
            // ジャンプサウンドを呼び出す
            run(jumpSound)
        
        }
        
    }
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
