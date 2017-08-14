//
//  ViewController.swift
//  CanidateProject
//
//  Created by Admin on 8/14/17.
//  Copyright © 2017 Binary Bros. All rights reserved.
//

import UIKit
import ReactiveJSON
import ReactiveSwift
import Result
import Kingfisher
class ViewController: UIViewController {
    @IBOutlet var usersCollectionView: UICollectionView!
    @IBOutlet var postsCollectionView: UICollectionView!
    @IBOutlet var picturesCollectionView: UICollectionView!

    var users = [User]()
    var posts = [Post]()
    var photos = [Picture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
        loadPosts()
        loadPhotos()
    }
    
    //MARK: Load Data
    
    func loadPosts() {
        ReactiveModel.request(endpoint: "posts")
            .startWithResult { (result: Result<[[String:Any]], NetworkError>) in
                
                for post in result.value! {
                    let id = post["id"] as! Int
                    let title = post["title"] as! String
                    let body = post["body"] as! String
                    self.posts.append(Post(id: id, title: title, body: body))
                }
                
                DispatchQueue.main.async {
                    self.postsCollectionView.reloadData()
                }
        }
    }
    
    func loadUsers() {
        ReactiveModel.request(endpoint: "users")
            .startWithResult { (result: Result<[[String:Any]], NetworkError>) in
                
                for post in result.value! {
                    let id = post["id"] as! Int
                    let name = post["name"] as! String
                    let username = post["username"] as! String
                    let email = post["email"] as! String
                    
                    self.users.append(User(id: id, name: name, username: username, email: email))
                }
                
                DispatchQueue.main.async {
                    self.usersCollectionView.reloadData()
                }
        }
    }
    
    func loadPhotos() {
        ReactiveModel.request(endpoint: "photos")
            .startWithResult { (result: Result<[[String:Any]], NetworkError>) in
                
                for post in result.value! {
                    let albumId = post["albumId"] as! Int
                    let id = post["id"] as! Int
                    let title = post["title"] as! String
                    let url = post["url"] as! String
                    let thumbURL = post["thumbnailUrl"] as! String
                    
                    let pic = Picture(albumID: albumId, id: id, title: title, url: url, thumbnailUrl: thumbURL)
                    
                    if self.photos.count < 15 {
                    self.photos.append(pic)
                    }
                }
                
                DispatchQueue.main.async {
                    self.picturesCollectionView.reloadData()
                    
                }
        }
    }
    
    

    
}
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}


extension ViewController :UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //  MARK: UICollectionView Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == usersCollectionView{
            return users.count
        }
        if collectionView == postsCollectionView{
            return posts.count
        }
        if collectionView == picturesCollectionView{
            return photos.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == usersCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UsersCollectionViewCell
            let user = self.users[indexPath.row]
            
            cell.nameLabel.text = user.username
            
            return cell
        }
        if collectionView == postsCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostsCollectionViewCell
            let post = self.posts[indexPath.row]
            
            cell.titleLabel.text = post.title
            cell.bodyLabel.text = post.body
            
            return cell
        }
        if collectionView == picturesCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
            let photo = self.photos[indexPath.row]
            cell.photoView.kf.setImage(with: URL(string: photo.thumbnailUrl)!)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    //  MARK: UICollectionView Flow Layout Delgate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height * 2 - 10, height: collectionView.bounds.height - 10)
    }
    
}

