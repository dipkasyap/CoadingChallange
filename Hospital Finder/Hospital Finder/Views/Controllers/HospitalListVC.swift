//
//  HospitalListVC.swift
//  Hospital Finder
//
//  Created by Devi Pd Ghimire on 18/6/20.
//  Copyright © 2020 Devi Pd Ghimire. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import NotificationBannerSwift

class HospitalListVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var illnessInfoLabel: UILabel!
    @IBOutlet weak var hospitalsTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private var illnessViewModel: IllnessViewModel!
    private var painLevelViewModel: PainLevelViewModel = PainLevelViewModel()
    private var hospitalViewModel: HospitalListViewModel = HospitalListViewModel()
    
    //MARK:- init
    class func load(with illnessViewModel: IllnessViewModel, and painLevelViewModel: PainLevelViewModel)-> HospitalListVC {
        let vc: HospitalListVC = UIStoryboard(storyboard: .hospital).instantiateViewController()
        vc.illnessViewModel = illnessViewModel
        vc.painLevelViewModel = painLevelViewModel
        return vc
    }
    
    //MARK:- View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getHospitals()
    }
    
}

//MARK:- UI Setup
extension HospitalListVC {
    private func setupUI() {
        title = "Hospitals"
        titleLabel.textColor = AppConstants.Color.titleGray
        illnessInfoLabel.text = illnessViewModel.subtitleInfo + "\n" + painLevelViewModel.subtitleInfo
        hospitalsTableView.register(HospitalCell.self)
        hospitalsTableView.separatorStyle = .none
        hospitalsTableView.estimatedRowHeight = UITableView.automaticDimension
        refreshControl.addTarget(self, action: #selector(getHospitals), for: .valueChanged)
        hospitalsTableView.addSubview(refreshControl)
        hospitalsTableView.dataSource = self
        hospitalsTableView.delegate = self
    }
}


//MARK:- Service call
extension HospitalListVC {
    @objc private func getHospitals() {
        ProgressHud.showIn(self.view)
        hospitalViewModel.getHospitals{ [weak self] success, error in
            if success {
                if let painLevel = self?.painLevelViewModel.painLevel {
                    self?.hospitalViewModel.applyPainLevel(painLevel)
                }
                self?.hospitalsTableView.reloadData()
            } 
            self?.refreshControl.endRefreshing()
            ProgressHud.hide()
        }
    }
}


//MARK:- Actions
extension HospitalListVC {
    
    fileprivate func savePatientInfoOnDB(forHospital hospital: HospitalViewModel) {
        
        DataServiceHandler().save(
            illnessViewModel,
            withPainLevel: painLevelViewModel.painLevel!,
            forHospital: hospital){ [weak self] success in
                guard let self = self else {return}
                
                if success {
                    ProgressHud.showSuccessIn(self.view)
                    delay(0.3) {
                        self.showOnMap(hospital)
                    }
                } else {
                    FloatingNotificationBanner(subtitle: "Could not save to RealmDB", style: .danger).show()
                }
        }
    }
    
    
    fileprivate func showOnMap(_ hospital: HospitalViewModel  ) {
        
        guard let lat = hospital.location?.lat, let long = hospital.location?.long else {
            print("Location not found")
            return
        }
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long)))
        destination.name = hospital.name
        MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}


//MARK:- Tableview datasource
extension HospitalListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitalViewModel.numbersOfHospitals
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HospitalCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setupWith(hospitalViewModel.hospitals(forIndex: indexPath.row))
        return cell
        
    }
}

//MARK:- Tableview delegate
extension HospitalListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.zoomIn()
        delay() { [unowned self] in
            self.savePatientInfoOnDB(forHospital: self.hospitalViewModel.hospitals(forIndex: indexPath.row))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
