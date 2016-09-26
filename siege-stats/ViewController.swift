//
//  ViewController.swift
//  siege-stats
//
//  Created by Ryan Abel on 9/25/16.
//  Copyright © 2016 Rabel Products. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var helloWorldLabel: UILabel!
    @IBOutlet weak var killsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let statsRetriever = StatsRetriever()
        statsRetriever.makeProfileRequest().flatMap { profile in
                statsRetriever.makeStatsRequest(profile: profile)
            }
            .subscribe(onNext: { profile in
                self.helloWorldLabel.text = profile.id
                self.killsLabel.text = String(profile.kills)
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

