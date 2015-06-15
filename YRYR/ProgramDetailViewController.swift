//
//  ProgramDetailViewController.swift
//  YRYR
//
//  Created by Yuki MIZUNO on 6/1/15.
//  Copyright (c) 2015 Yuki MIZUNO. All rights reserved.
//

import UIKit
import SDWebImage
import MRProgress
import FFCircularProgressView

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

		let manager = ChinachuPVRManager.sharedInstance
		
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
		

		let imageLoadingIndicatorView = MRActivityIndicatorView()
		imageLoadingIndicatorView.startAnimating()
		imageLoadingIndicatorView.hidesWhenStopped = true

		imageLoadingIndicatorView.setTranslatesAutoresizingMaskIntoConstraints(false)
		previewImageView.addSubview(imageLoadingIndicatorView)
		
		imageLoadingIndicatorView.addConstraint(NSLayoutConstraint(item: imageLoadingIndicatorView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 60))
		imageLoadingIndicatorView.addConstraint(NSLayoutConstraint(item: imageLoadingIndicatorView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 60))
		previewImageView.addConstraint(NSLayoutConstraint(item: imageLoadingIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: previewImageView, attribute: .CenterX, multiplier: 1.0, constant: 0))
		previewImageView.addConstraint(NSLayoutConstraint(item: imageLoadingIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: previewImageView, attribute: .CenterY, multiplier: 1.0, constant: 0))

		
		SDWebImageManager.sharedManager().downloadImageWithURL(manager.getPreviewImageUrl(program.id),
			options: .CacheMemoryOnly,
			progress: {(received, expected) in
				return
			},
			completed: {(image, error, cacheType, finished, imageURL) in
				imageLoadingIndicatorView.stopAnimating()
				
				self.previewImageView.image = image
				
				let playButton = UIButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
				playButton.setImage(UIImage(named: "play"), forState: .Normal)
				playButton.tintColor = UIColor(white: 0.9, alpha: 0.9)
				playButton.addTarget(self, action: Selector("playVideo:"), forControlEvents: .TouchUpInside)
				
				playButton.setTranslatesAutoresizingMaskIntoConstraints(false)
				self.view.addSubview(playButton)
				
				playButton.addConstraint(NSLayoutConstraint(item: playButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 80))
				playButton.addConstraint(NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 80))
				self.view.addConstraint(NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.previewImageView, attribute: .CenterX, multiplier: 1.0, constant: 0))
				self.view.addConstraint(NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal, toItem: self.previewImageView, attribute: .CenterY, multiplier: 1.0, constant: 0))
				
		})
		
		self.informationTable.delegate = self
		self.informationTable.dataSource = self

		self.informationTable.removeConstraints((self.informationTable.constraints()))
		self.informationTable.addConstraint(NSLayoutConstraint(item: informationTable, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44 * 5))

		self.informationTable.reloadData()
		
		if manager.fileDownloaded(self.program.id) {
			let deleteFileButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: Selector("confirmToDeleteFile:"))
			self.navigationItem.rightBarButtonItem = deleteFileButton

		} else {
			let circularProgressView = FFCircularProgressView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
			let downloadButton = UIBarButtonItem(customView: circularProgressView)
			self.navigationItem.rightBarButtonItem = downloadButton
			if let request: AnyObject = self.program.userData {
				manager.setDownloadVideoHandler(request, inProgress: { progress in
					dispatch_async(dispatch_get_main_queue(), {
						circularProgressView.progress = CGFloat(progress)
					})
					}, onComplete: {
						let currentGestureRecognizer = (circularProgressView.gestureRecognizers as! [UIGestureRecognizer])[0]
						circularProgressView.removeGestureRecognizer(currentGestureRecognizer)
					}
				)
				
				let downloadButtonTapGesture = UITapGestureRecognizer(target: self, action: Selector("downloadWillCancel:"))
				circularProgressView.addGestureRecognizer(downloadButtonTapGesture)
			} else {
				let downloadButtonTapGesture = UITapGestureRecognizer(target: self, action: Selector("downloadWillStart:"))
				circularProgressView.addGestureRecognizer(downloadButtonTapGesture)
			}
		}
		
    }
	
	func downloadWillStart(sendor: AnyObject) {
		let circularProgressView = self.navigationItem.rightBarButtonItem?.customView as! FFCircularProgressView
		circularProgressView.startSpinProgressBackgroundLayer()
		
		let downloadRequest = ChinachuPVRManager.sharedInstance.startDownloadVideo(program.id, inProgress: { (progress) in
			dispatch_async(dispatch_get_main_queue(), {
				circularProgressView.stopSpinProgressBackgroundLayer()
				circularProgressView.progress = CGFloat(progress)
			})
			
			}, onComplete: {
				let currentGestureRecognizer = (circularProgressView.gestureRecognizers as! [UIGestureRecognizer])[0]
				circularProgressView.removeGestureRecognizer(currentGestureRecognizer)
		})
		
		self.program.userData = downloadRequest as AnyObject
		
		let navigationViewControllers = self.navigationController!.viewControllers as! [UIViewController]
		let recordingTableViewController = navigationViewControllers[0] as! ProgramTableViewController
		recordingTableViewController.programsById[self.program.id] = self.program
		
		let currentGestureRecognizer = (circularProgressView.gestureRecognizers as! [UIGestureRecognizer])[0]
		circularProgressView.removeGestureRecognizer(currentGestureRecognizer)
		let downloadButtonTapGesture = UITapGestureRecognizer(target: self, action: Selector("downloadWillCancel:"))
		circularProgressView.addGestureRecognizer(downloadButtonTapGesture)
	}
	
	func downloadWillCancel(sendar: AnyObject) {
		let circularProgressView = self.navigationItem.rightBarButtonItem?.customView as! FFCircularProgressView
		ChinachuPVRManager.sharedInstance.cancelDownloadVideo(self.program.userData)
		
		self.program.userData = nil
		
		let navigationViewControllers = self.navigationController!.viewControllers as! [UIViewController]
		let recordingTableViewController = navigationViewControllers[0] as! ProgramTableViewController
		recordingTableViewController.programsById[self.program.id] = self.program

		let currentGestureRecognizer = (circularProgressView.gestureRecognizers as! [UIGestureRecognizer])[0]
		circularProgressView.removeGestureRecognizer(currentGestureRecognizer)
		let downloadButtonTapGesture = UITapGestureRecognizer(target: self, action: Selector("downloadWillStart:"))
		circularProgressView.addGestureRecognizer(downloadButtonTapGesture)
		circularProgressView.progress = 0
	}
	
	func confirmToDeleteFile(sendar: AnyObject) {
		let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete downloaded file?", preferredStyle: UIAlertControllerStyle.Alert)
		confirmAlertView.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {alertAction in
			let manager = ChinachuPVRManager.sharedInstance
			
			manager.removeDownloadedFile(self.program.id, onComplete: {
				let circularProgressView = FFCircularProgressView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
				let downloadButton = UIBarButtonItem(customView: circularProgressView)
				self.navigationItem.rightBarButtonItem = downloadButton
				let downloadButtonTapGesture = UITapGestureRecognizer(target: self, action: Selector("downloadWillStart:"))
				circularProgressView.addGestureRecognizer(downloadButtonTapGesture)
			})
		}))
		confirmAlertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {alertAction in }))
		
		self.parentViewController?.presentViewController(confirmAlertView, animated: true, completion: nil)

	}
	
	func playVideo(sendar: AnyObject) {
		self.performSegueWithIdentifier("playVideo", sender: self)
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
	
	
	
    // MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		if segue.identifier == "playVideo" {
			let videoPlayVC = segue.destinationViewController as! VideoPlayViewController
			videoPlayVC.program = program
		}
	}
	

}
