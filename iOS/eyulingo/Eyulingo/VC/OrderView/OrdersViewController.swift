//
//  OrdersViewController.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/22.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let constantCellsCount = 5

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var defaultItemCount = constantCellsCount
        // receiver
        // receiver's phone
        // receiver's address
        // transporting method
        // create time
        if currentFlag == OrderState.unpurchased {
            defaultItemCount += unpurchasedOrders[section].items!.count
        } else if currentFlag == OrderState.pending {
            defaultItemCount += pendingOrders[section].items!.count
        } else if currentFlag == OrderState.transporting {
            defaultItemCount += transportingOrders[section].items!.count
        } else if currentFlag == OrderState.received {
            defaultItemCount += completedOrders[section].items!.count
        }
        return defaultItemCount
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if currentFlag == OrderState.unpurchased {
            return unpurchasedOrders.count
        } else if currentFlag == OrderState.pending {
            return pendingOrders.count
        } else if currentFlag == OrderState.transporting {
            return transportingOrders.count
        } else if currentFlag == OrderState.received {
            return completedOrders.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersCell", for: indexPath)

        return cell
    }

    var unpurchasedOrders: [EyOrders] = []
    var pendingOrders: [EyOrders] = []
    var transportingOrders: [EyOrders] = []
    var completedOrders: [EyOrders] = []

    var currentFlag: OrderState = .unpurchased

    @IBOutlet var ordersTableView: UITableView!
    @IBOutlet var orderTypePicker: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func orderTypePicked(_ sender: UISegmentedControl) {
        currentFlag = OrderState(rawValue: sender.selectedSegmentIndex) ?? OrderState.unpurchased
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
