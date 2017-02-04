//
//  CallScriptViewController.swift
//  FiveCalls
//
//  Created by Patrick McCarron on 2/3/17.
//

import UIKit
import CoreLocation

class CallScriptViewController : UIViewController {
    
    var issuesManager: IssuesManager!
    var issue: Issue!
    var contact: Contact!
    var contacted: Set<Contact> = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var resultUnavailableBtn: UIButton!
    @IBOutlet weak var resultVoicemailBtn: UIButton!
    @IBOutlet weak var resultContactedBtn: UIButton!
    @IBOutlet weak var resultSkipBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func callButtonPressed(_ button: UIButton) {
        if let dialURL = URL(string: "telprompt:\(contact.phone)") {
            UIApplication.shared.open(dialURL) { success in
                //Log the result
            }
        }
    }

    @IBAction func resultButtonPressed(_ button: UIButton) {
        switch button {
        case resultContactedBtn:
            print("call connected, log this")
            break
        case resultSkipBtn:
            print("call skipped, log this")
            break
        case resultVoicemailBtn:
            print("got voicemail, log this")
            break
        case resultUnavailableBtn:
            print("unavailable, log this")
            break
        default:
            print("unknown button pressed")
        }
        
        // Struct passing around problems. This needs to be refactored / cleaned up.
        contact.hasContacted = true
        let oldContact: Contact! = contact
        for i in 0..<issuesManager.issuesList!.issues.count {
            if issuesManager.issuesList!.issues[i].id == self.issue.id {
                for j in 0..<issuesManager.issuesList!.issues[i].contacts.count {
                    if issuesManager.issuesList!.issues[i].contacts[j].id == oldContact.id {
                        issuesManager.issuesList!.issues[i].contacts[j].hasContacted = true
                    }
                    if issuesManager.issuesList!.issues[i].contacts[j].hasContacted == false {
                        contact = issuesManager.issuesList!.issues[i].contacts[j]
                        tableView.reloadData()
                    }
                }
            }
        }
        if (contact.hasContacted) {
            for i in 0..<issuesManager.issuesList!.issues.count {
                if issuesManager.issuesList!.issues[i].id == self.issue.id {
                    issuesManager.issuesList!.issues[i].madeCalls = true
                }
            }
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
}

enum CallScriptRows : Int {
    case contact
    case script
    case count
}

extension CallScriptViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CallScriptRows.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case CallScriptRows.contact.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactDetailCell
            cell.callButton.setTitle(contact.phone, for: .normal)
            cell.callButton.addTarget(self, action: #selector(callButtonPressed(_:)), for: .touchUpInside)
            cell.nameLabel.text = contact.name
            cell.callingReasonLabel.text = contact.reason
            return cell
        case CallScriptRows.script.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "scriptCell", for: indexPath) as! IssueDetailCell
            cell.issueLabel.text = issue.script
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension IssueDetailViewController : UITableViewDelegate {

}
