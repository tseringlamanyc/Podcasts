//
//  ViewController.swift
//  Podcasts
//
//  Created by Alex Paul on 12/17/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

class PodcastSearchController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  var podcasts = [Podcast]() {
    didSet {
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  
  var  isSearchinng = false

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    
    // TODO: register Podcast nib here
    tableView.register(UINib(nibName: "PodcastCell", bundle: nil), forCellReuseIdentifier: "podcastCell")
    searchBar.delegate = self
    searchBar.autocapitalizationType = .none
  }

  @objc private func searchPodcasts(with name: String) {
    podcasts.removeAll()
    PodcastAPIClient.searchPodcast(for: name) { [weak self] (result) in
      self?.isSearchinng = false
      switch result {
      case .failure(let appError):
        DispatchQueue.main.async {
          self?.showAlert(title: "Searching error", message: "\(appError)")
        }
      case .success(let podcasts):
        self?.podcasts = podcasts
      }
    }
  }
}

extension PodcastSearchController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "podcastCell", for: indexPath) as? PodcastCell else {
      fatalError("could not downcast to PodcastCell")
    }
    guard podcasts.count > 0 else { return UITableViewCell() }
    let podcast = podcasts[indexPath.row]
    cell.configureCell(for: podcast)
    return cell
  }
}

extension PodcastSearchController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 180
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if searchBar.isFirstResponder {
      searchBar.resignFirstResponder()
    }
  }
  
  // TODO: implemnet didSelectRowAt to pass podcast data to the detail view
  //       we need to add an identifier to the PodcastDetailController scene in the Main storyboard in order to get an instance of it
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(identifier: "PodcastDetailController") as? PodcastDetailController else {
            fatalError()
        }
        detailVC.podcast = podcasts[indexPath.row]
        guard (navigationController?.pushViewController(detailVC, animated: true)) != nil else {
            fatalError()
        }
    }
}

extension PodcastSearchController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if isSearchinng { return }
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.02) {
      self.isSearchinng = true
      self.searchPodcasts(with: searchText)
    }
  }
}
