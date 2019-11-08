//
//  SwipingNewVC.swift
//  identaxy
//
//  Created by Paul Purifoy on 11/6/19.
//  Copyright © 2019 amir. All rights reserved.
//

import UIKit
import Shuffle_iOS
import PopBounceButton
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

enum Response : String {
    case REAL
    case FAKE
    case UNSPECIFIED
}

class SwipingNewVC: UIViewController {
    let path: String = "images/"
    static let kLoadCount: Int = 6
    
    private let cardStack = SwipeCardStack()
    let alertService = AlertService()
    let storage = Storage.storage()
    
    
    @IBOutlet weak var identaxyLabel: UILabel!
    @IBOutlet weak var nopeButton: UIButton!
    var database: DatabaseReference!
    
    var images: Array<IdentaxyImage> = Array<IdentaxyImage>(repeating: IdentaxyImage(), count: kLoadCount)
    var responses: [String : Response] = [:]
    var numLoaded: Int = 0
    var imagesLoaded: Bool = false {
        didSet {
            cardStack.reloadData()
        }
    }
    let bgTaskQueue = DispatchQueue(label: "responseStoring", qos: .background)
    
    
    private let cardModels = [
        CardModel(image: UIImage(named: "User Pic")),
        CardModel(image: UIImage(named: "User Pic1")),
        CardModel(image: UIImage(named: "User Pic2")),
        CardModel(image: UIImage(named: "User Pic3")),
        CardModel(image: UIImage(named: "User Pic4")),
        CardModel(image: UIImage(named: "User Pic5")),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = Database.database().reference()
        cardStack.delegate = self
        cardStack.dataSource = self
        
        layoutCardStackView()
        overrideUserInterfaceStyle = .dark
        identaxyLabel.textColor = UIColor.white
        // Do any additional setup after loading the view.
        print("LOADING IMAGES")
        loadImages()
    }
    
    func loadImages() {
        let storageRef = storage.reference()

        for i in 0..<SwipingNewVC.kLoadCount {
            let picRef = storageRef.child("\(path)\(i).png")
            picRef.getData(maxSize: INT64_MAX) { (data, error) in
                if let error = error {
                    print("***ERROR*** PIC:\(i) " + error.localizedDescription)
                } else {
                    print("***SUCCESS*** PIC:\(i)")
                    self.numLoaded += 1
                    let image = UIImage(data: data!)
                    self.images[i] = IdentaxyImage(imageObject: image!, imageId: "\(i)")
                    if (self.numLoaded == self.images.count) {
                        self.imagesLoaded = true
                        self.numLoaded = 0
                    }
                }
            }
        }
    }
    
    func storeResponses() {
        print("STORING")
        let mapCopy = responses
        let uid = Auth.auth().currentUser?.uid
        for (imageId, response) in mapCopy {
            let json = ["response": response.rawValue] as [String : String]
            self.database.child("responses").child(uid!).child(imageId).setValue(json)
        }
    }
    
    private func layoutCardStackView() {
        view.addSubview(cardStack)
        cardStack.anchor(top: identaxyLabel.bottomAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: nopeButton.topAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        let alertVC = alertService.alert(title: "Information", message: "Identaxy Information Popup", button: "OK")
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func nopePressed(_ sender: Any) {
        cardStack.swipe(.left, animated: true)
    }
    
    @IBAction func undoPressed(_ sender: Any) {
        cardStack.undoLastSwipe(animated: true)
    }
    
    @IBAction func yepPressed(_ sender: Any) {
        cardStack.swipe(.right, animated: true)
    }
}

extension SwipingNewVC: SwipeCardStackDataSource, SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        return Card(model: CardModel(image: images[index].getImage()))
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return cardModels.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("RELOAD")
        bgTaskQueue.async {
            self.storeResponses()
        }
        loadImages()
        cardStack.reloadData()
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(images[index].getId())")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        print("Swiped \(direction) on \(images[index].getId())")
        let imageId = images[index].getId()
        var response = Response.UNSPECIFIED
        switch direction {
        case .right:
            response = .REAL
        case .left:
            response = .FAKE
        default:
            response = .UNSPECIFIED
        }
        print("ID: \(imageId): \(response.rawValue)")
        responses[imageId] = response
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("Card tapped")
    }
    
}
