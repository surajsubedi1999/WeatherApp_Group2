//
//  CityWeatherCell.swift
//  WeatherApp_Project2
//
//  Created by Suraj Subedi on 2025-07-27.
//

import UIKit

class CityWeatherCell: UITableViewCell {

    let weatherIcon = UIImageView()
    let cityLabel = UILabel()
    let tempLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.translatesAutoresizingMaskIntoConstraints = false

        cityLabel.font = .systemFont(ofSize: 18, weight: .bold)
        tempLabel.font = .systemFont(ofSize: 16)

        contentView.addSubview(weatherIcon)
        contentView.addSubview(cityLabel)
        contentView.addSubview(tempLabel)

        NSLayoutConstraint.activate([
            weatherIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            weatherIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 40),
            weatherIcon.heightAnchor.constraint(equalToConstant: 40),

            cityLabel.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: 15),
            cityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),

            tempLabel.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: 15),
            tempLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
