//
//  TestManageTableViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2018/06/14.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit

class TestManageTableViewController: UITableViewController {

    let mode = ["DCNN", "Dlib", "Vision"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mode.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = mode[indexPath.row]

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: mode[indexPath.row], sender: nil)
    }
}
