//
//  DropDownView.UITableView.swift
//  BlackCat
//
//  Created by SeYeong on 2022/11/02.
//

import UIKit

extension GenrePaperView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: GenreListTableViewCell.identifier,
            for: indexPath
        ) as? GenreListTableViewCell else { return UITableViewCell() }

        cell.configure(with: items[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hidePresentationView()
        genreTitleLabel.text = items[indexPath.row]
    }
}
