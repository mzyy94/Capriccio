//
//  ProgramDetailViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/1/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit

class ProgramDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var program: PVRProgram! = nil
	
	enum viewType {
		case detail
		case service
	}
	
	var currentViewType: viewType = .detail
	
	@IBOutlet weak var previewImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var channelLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var summaryView: UIView!
	@IBOutlet weak var informationTable: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		
		let userDefault = NSUserDefaults()
		let manager = ChinachuPVRManager(remoteHost: NSURL(string: userDefault.stringForKey("pvrUrl")!)!)
		
		self.title = program.title
		let titleText = NSMutableAttributedString(string: program.fullTitle,attributes: [NSFontAttributeName: UIFont.systemFontOfSize(19.0, weight: 6.0)])
		
		if program.subTitle != "" || program.episode > 0 {
			
			titleText.appendAttributedString(NSAttributedString(string: "\n"))
			
			if  program.episode > 0 {
				titleText.appendAttributedString(NSMutableAttributedString(string: "#\(program.episode!) ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSForegroundColorAttributeName: UIColor.redColor()]))
			}
			
			if program.subTitle != "" {
				titleText.appendAttributedString(NSMutableAttributedString(string: program.subTitle, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSForegroundColorAttributeName: UIColor.grayColor()]))
			}
			
		}
		
		titleLabel.attributedText = titleText
		channelLabel.text = program.channel.name
		durationLabel.text = "\(Int(program.duration / 60)) min."
		detailLabel.text = program.detail
		
		summaryView.sizeToFit()
		
		manager.getPreviewImage(program.id, success: { data in
			self.previewImageView.image = UIImage(data: data)

			}, failure: { error in
				
		})
		
		
		self.informationTable.delegate = self
		self.informationTable.dataSource = self

		self.informationTable.removeConstraints((self.informationTable.constraints()))
		self.informationTable.addConstraint(NSLayoutConstraint(item: informationTable, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44 * 5))

		self.informationTable.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	
	// MARK: - Table view data source
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch currentViewType {
		case .detail:
			return 5
		case .service:
			return 0
		}
	}

	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch currentViewType {
		case .detail:
			let cell = tableView.dequeueReusableCellWithIdentifier("programInfoCell", forIndexPath: indexPath) as! UITableViewCell
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Genre"
				cell.detailTextLabel?.text = program.genre
			case 1:
				let dateFormatter = NSDateFormatter()
				dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
				
				cell.textLabel?.text = "Date"
				cell.detailTextLabel?.text = dateFormatter.stringFromDate(program.startTime)
			case 2:
				cell.textLabel?.text = "Channel"
				cell.detailTextLabel?.text = "\(program.channel.name) [\(program.channel.channel)]"
			case 3:
				cell.textLabel?.text = "Duration"
				cell.detailTextLabel?.text = "\(Int((program.duration/60)%60)) min."
			case 4:
				cell.textLabel?.text = "ID"
				cell.detailTextLabel?.text = program.id
			default:
				return cell
			}
			
			return cell
		case .service:
			let cell = tableView.dequeueReusableCellWithIdentifier("programInfoCell", forIndexPath: indexPath) as! UITableViewCell
			
			
			return cell
		}
	}
	
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
