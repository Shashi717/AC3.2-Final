//
//  FeedTableViewController.swift
//  AC3.2-Final
//
//  Created by Madushani Lekam Wasam Liyanage on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class FeedTableViewController: UITableViewController {
    
    var databaseRef: FIRDatabaseReference!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.databaseRef = FIRDatabase.database().reference().child("posts")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.posts.removeAll()
        getPosts()
    }
    
    func getPosts() {
        databaseRef.observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let snap = child as? FIRDataSnapshot,
                    let valueDict = snap.value as? [String:String] {
                    let post = Post(key: snap.key, comment: valueDict["comment"] ?? "", userId: valueDict["userId"] ?? "")
                    self.posts.append(post)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifier", for: indexPath) as! FeedTableViewCell
        
        cell.feedImageView.image = nil
        let post = posts[indexPath.row]
        cell.commentLabel.text = post.comment
        
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(post.key)")
        
        imageRef.data(withMaxSize: 1*1024*1024) { (data, error) in
            if let error = error {
                print(error)
            }
            else {
                let image = UIImage(data: data!)
                cell.feedImageView.image = image
            }
        }
        
        return cell
    }
    
}
