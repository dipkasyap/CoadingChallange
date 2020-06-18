//
//  SelectPainLevelVC.swift
//  Hospital Finder
//
//  Created by Devi Pd Ghimire on 18/6/20.
//  Copyright © 2020 Devi Pd Ghimire. All rights reserved.
//

import UIKit

class SelectPainLevelVC: UIViewController {
    
    @IBOutlet var painLevelButtons: [PainLevelButton]!
    @IBOutlet weak var illnessLabel: UILabel!
    
    private var illnessViewModel: IllnessViewModel!
    private var painLevelViewModel: PainLevelViewModel = PainLevelViewModel()

    //MARK:- init
      class func load(with illnessViewModel: IllnessViewModel)-> SelectPainLevelVC {
          let vc: SelectPainLevelVC = UIStoryboard(storyboard: .hospital).instantiateViewController()
          vc.illnessViewModel = illnessViewModel
          return vc
      }
    
    //MARK:- View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}


//MARK:- UI Setup
extension SelectPainLevelVC {
    private func setupUI() {
        title = "Pain Level"
        illnessLabel.text = illnessViewModel.name
    }
}


//MARK:- Actions
extension SelectPainLevelVC {
    
    @IBAction func didSelectPainLevel(_ sender: PainLevelButton) {
        painLevelButtons.forEach { (btn) in
            btn.isSelected = btn == sender
        }
        painLevelViewModel.painLevel = PainLevel(rawValue: sender.tag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            self.showHospitals()
        }
        
    }
    
    fileprivate func showHospitals() {
        let hospitalListVC = HospitalListVC.load(with: illnessViewModel, and: painLevelViewModel)
        navigationController?.pushViewController(hospitalListVC, animated: true)
    }
}