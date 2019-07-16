import UIKit

class DetailContentViewController: UIViewController {
//
//    private static let CellIdentifier = "CellIdentifier"
//
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TableViewController.CellIdentifier)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    init() {
        super.init(nibName: "DetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 500
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewController.CellIdentifier, for: indexPath)
//        cell.textLabel?.text = "Title"
//        return cell
//    }
//    
}
