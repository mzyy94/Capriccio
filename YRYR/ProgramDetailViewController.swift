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
import BFPaperButton
import Facade
import HMSegmentedControl

class ProgramDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Instance fileds
	
	var program: PVRProgram! = nil
	var musicTracks: [MusicTrackInformation] = []
	enum viewType: NSNumber {
		case detail = 0
		case music = 1
		case service = 2
	}
	var currentViewType: viewType = .detail
	var playButton: BFPaperButton!
	
	
	// MARK: - Interface Builder outlets
	
	@IBOutlet weak var previewImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var channelLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var summaryView: UIView!
	@IBOutlet weak var informationTable: UITableView!
	
	
	// MARK: - View initialization
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let titleText = NSMutableAttributedString(string: program.fullTitle,attributes: [NSFontAttributeName: UIFont.systemFontOfSize(19.0, weight: 6.0)])
		
		// Add episode and subtitle
		if program.subTitle != "" || program.episode > 0 {
			titleText.appendAttributedString(NSAttributedString(string: "\n"))
			
			if  program.episode > 0 {
				titleText.appendAttributedString(NSMutableAttributedString(string: "#\(program.episode!) ", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSForegroundColorAttributeName: UIColor.paperColorRedA200()]))
			}
			if program.subTitle != "" {
				titleText.appendAttributedString(NSMutableAttributedString(string: program.subTitle, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSForegroundColorAttributeName: UIColor.paperColorGray400()]))
			}
		}
		
		titleLabel.attributedText = titleText
		channelLabel.text = program.channel.name
		durationLabel.text = "\(Int(program.duration / 60)) min."
		detailLabel.text = program.detail
		
		summaryView.sizeToFit()
		
		
		// Place play button
		self.playButton = BFPaperButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 56, height: 56)), raised: true)
		self.playButton.cornerRadius = self.playButton.frame.size.width / 2
		self.playButton.backgroundColor = UIColor.paperColorLightBlue600()
		self.playButton.setImage(UIImage(named: "play_arrow_white"), forState: .Normal)
		self.playButton.tintColor = UIColor(white: 0.9, alpha: 0.9)
		self.playButton.addTarget(self, action: Selector("playVideo:"), forControlEvents: .TouchUpInside)
		
		self.view.addSubview(self.playButton)
		
		// Place informationSegment
		let informationSegment = HMSegmentedControl(sectionTitles: ["Detail", "Music", "Service"])
		informationSegment.frame = CGRect(x: 0, y: 0, width: 600, height: 32)
		informationSegment.addTarget(self, action: Selector("informationSegmentChanged:"), forControlEvents: .ValueChanged)
		informationSegment.backgroundColor = UIColor.paperColorBlueGray400()
		informationSegment.selectionIndicatorColor = UIColor.paperColorCyan100()
		informationSegment.segmentEdgeInset = UIEdgeInsetsZero
		informationSegment.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.paperColorGray300(), NSFontAttributeName: UIFont.systemFontOfSize(14)]
		informationSegment.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
		informationSegment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
		informationSegment.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
		informationSegment.selectionIndicatorHeight = 2
		
		self.informationTable.tableHeaderView = informationSegment
		
		// Force layout to use Facade layouting
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		

		// Thumbnail loader
		let imageLoadingIndicatorView = MRActivityIndicatorView()
		imageLoadingIndicatorView.tintColor = UIColor.paperColorAmber500()
		imageLoadingIndicatorView.startAnimating()
		imageLoadingIndicatorView.hidesWhenStopped = true

		imageLoadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		previewImageView.addSubview(imageLoadingIndicatorView)
		
		imageLoadingIndicatorView.addConstraint(NSLayoutConstraint(item: imageLoadingIndicatorView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 60))
		imageLoadingIndicatorView.addConstraint(NSLayoutConstraint(item: imageLoadingIndicatorView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 60))
		previewImageView.addConstraint(NSLayoutConstraint(item: imageLoadingIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: previewImageView, attribute: .CenterX, multiplier: 1.0, constant: 0))
		previewImageView.addConstraint(NSLayoutConstraint(item: imageLoadingIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: previewImageView, attribute: .CenterY, multiplier: 1.0, constant: 0))

		let manager = ChinachuPVRManager.sharedManager
		SDWebImageManager.sharedManager().downloadImageWithURL(manager.getPreviewImageUrl(program.id),
			options: .CacheMemoryOnly,
			progress: {(received, expected) in
				return
			},
			completed: {(image, error, cacheType, finished, imageURL) in
				imageLoadingIndicatorView.stopAnimating()
				
				self.previewImageView.image = image
		})
		
		// Setup table view
		self.informationTable.delegate = self
		self.informationTable.dataSource = self

		let programCellNib = UINib(nibName: "MusicTrackTableViewCell", bundle: nil)
		self.informationTable.registerNib(programCellNib, forCellReuseIdentifier: "MusicTrackCell")
		
		self.setupTableViewHeight()

		self.informationTable.reloadData()
		
		// Setup file download button
		if manager.fileDownloaded(self.program.id) {
			let deleteFileButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: Selector("confirmToDeleteFile:"))
			self.navigationItem.rightBarButtonItem = deleteFileButton

		} else {
			let circularProgressView = FFCircularProgressView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
			circularProgressView.tintColor = UIColor.paperColorGray50()
			let downloadButton = UIBarButtonItem(customView: circularProgressView)
			self.navigationItem.rightBarButtonItem = downloadButton
			if let request: AnyObject = self.program.userData {
				manager.setDownloadVideoHandler(request, inProgress: { progress in
					dispatch_async(dispatch_get_main_queue(), {
						circularProgressView.progress = CGFloat(progress)
					})
					}, onComplete: {
						let currentGestureRecognizer = circularProgressView.gestureRecognizers![0]
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
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		func generateGradient(size: CGSize) -> UIImage {
			let startColor = UIColor(white: 0, alpha: 0.5).CGColor
			let endColor = UIColor(white: 0, alpha: 0.0).CGColor
			let colors = [startColor, endColor]
			let locations = [0, 0.8] as [CGFloat]
			let space = CGColorSpaceCreateDeviceRGB()
			let gradient = CGGradientCreateWithColors(space, colors, locations)
			
			UIGraphicsBeginImageContextWithOptions(size, false, 0)
			let context = UIGraphicsGetCurrentContext()
            CGContextDrawLinearGradient(context, gradient, .zero, CGPointMake(0, size.height), [])
			let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return gradientImage
		}
		
		let portraitImage = generateGradient(CGSize(width: 1, height: 40))
		let landscapeImage = generateGradient(CGSize(width: 1, height: 20))
		
		// Set navigation bar gradient background
		self.navigationController?.navigationBar.translucent = true
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(CGImage: portraitImage.CGImage!), forBarMetrics: .Default)
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(CGImage: landscapeImage.CGImage!), forBarMetrics: .Compact)
	}
	
	
	// MARK: - View deinitialization
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopAllPreviewTrack(nil)

		// Put back original navigation bar style
		self.navigationController?.navigationBar.translucent = false
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Compact)
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	
	// MARK: - View layout
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		self.layoutFacade()
	}
	
	func layoutFacade() {
		playButton?.alignUnder(self.previewImageView, withRightPadding: 16, topPadding: -28, width: 56, height: 56)
	}
	
	
	// MARK: - Memory/resource management
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	// MARK: - Segmented controller event
	
	func informationSegmentChanged(sender: UISegmentedControl) {
		currentViewType = viewType(rawValue: sender.selectedSegmentIndex)!
		switch currentViewType {
		case .detail:
			self.informationTable.separatorStyle = .None
			self.informationTable.reloadData()
		case .music:
			self.informationTable.separatorStyle = .SingleLine
			self.informationTable.reloadData()
			MusicStoreManager.sharedManager.getRelatedMusicTracks(self.program.title,
				success: {tracks in
					self.musicTracks = tracks
					self.informationTable.reloadData()

					self.setupTableViewHeight()
				}, failure: {error in
			})
		case .service:
			return
		}
		setupTableViewHeight()
	}
	
	
	// MARK: - Table View height
	
	func setupTableViewHeight() {
		let cellHeight = self.tableView(self.informationTable, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
		let cellCount = self.tableView(self.informationTable, numberOfRowsInSection: 0)
		if cellCount == 0 {
			return
		}
		self.informationTable.removeConstraints((self.informationTable.constraints))
		self.informationTable.addConstraint(NSLayoutConstraint(item: self.informationTable, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: cellHeight * CGFloat(cellCount) + 44))
	}
	
	
	// MARK: - Video download
	
	func downloadWillStart(sendor: AnyObject) {
		let circularProgressView = self.navigationItem.rightBarButtonItem?.customView as! FFCircularProgressView
		circularProgressView.startSpinProgressBackgroundLayer()
		
		let downloadRequest = ChinachuPVRManager.sharedManager.startDownloadVideo(program.id, inProgress: { (progress) in
			dispatch_async(dispatch_get_main_queue(), {
				circularProgressView.stopSpinProgressBackgroundLayer()
				circularProgressView.progress = CGFloat(progress)
			})
			
			}, onComplete: {
				let currentGestureRecognizer = circularProgressView.gestureRecognizers![0]
				circularProgressView.removeGestureRecognizer(currentGestureRecognizer)
		})
		
		self.program.userData = downloadRequest as AnyObject
		
		let navigationViewControllers = self.navigationController!.viewControllers
		let recordingTableViewController = navigationViewControllers[0] as! ProgramTableViewController
		recordingTableViewController.programsById[self.program.id] = self.program
		
		let currentGestureRecognizer = circularProgressView.gestureRecognizers![0]
		circularProgressView.removeGestureRecognizer(currentGestureRecognizer)
		let downloadButtonTapGesture = UITapGestureRecognizer(target: self, action: Selector("downloadWillCancel:"))
		circularProgressView.addGestureRecognizer(downloadButtonTapGesture)
	}
	
	func downloadWillCancel(sendar: AnyObject) {
		let circularProgressView = self.navigationItem.rightBarButtonItem?.customView as! FFCircularProgressView
		ChinachuPVRManager.sharedManager.cancelDownloadVideo(self.program.userData)
		
		self.program.userData = nil
		
		let navigationViewControllers = self.navigationController!.viewControllers
		let recordingTableViewController = navigationViewControllers[0] as! ProgramTableViewController
		recordingTableViewController.programsById[self.program.id] = self.program

		let currentGestureRecognizer = circularProgressView.gestureRecognizers![0]
		circularProgressView.removeGestureRecognizer(currentGestureRecognizer)
		let downloadButtonTapGesture = UITapGestureRecognizer(target: self, action: Selector("downloadWillStart:"))
		circularProgressView.addGestureRecognizer(downloadButtonTapGesture)
		circularProgressView.progress = 0
	}
	
	
	// MARK: - Local downloaded file management
	
	func confirmToDeleteFile(sendar: AnyObject) {
		let confirmAlertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete downloaded file?", preferredStyle: .Alert)
		confirmAlertView.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: {alertAction in
			let manager = ChinachuPVRManager.sharedManager
			
			manager.removeDownloadedFile(self.program.id, onComplete: {
				let circularProgressView = FFCircularProgressView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
				let downloadButton = UIBarButtonItem(customView: circularProgressView)
				self.navigationItem.rightBarButtonItem = downloadButton
				let downloadButtonTapGesture = UITapGestureRecognizer(target: self, action: Selector("downloadWillStart:"))
				circularProgressView.addGestureRecognizer(downloadButtonTapGesture)
			})
		}))
		confirmAlertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {alertAction in }))
		
		self.parentViewController?.presentViewController(confirmAlertView, animated: true, completion: nil)

	}
	
	
	// MARK: - Video play
	
	func playVideo(sendar: AnyObject) {
		let videoPlayViewController = self.storyboard!.instantiateViewControllerWithIdentifier("VideoPlayView") as! VideoPlayViewController
		videoPlayViewController.program = program
		
		self.presentViewController(videoPlayViewController, animated: true, completion: nil)
	}
	
	
	// MARK: - Preview track control
	
	func stopAllPreviewTrack(sender: AnyObject?) {
		for i in 0..<musicTracks.count {
			let musicTrackCell = self.informationTable.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? MusicTrackTableViewCell
			musicTrackCell?.audioTrackDidFinished(nil)
		}
	}

	
	// MARK: - Open iTunes Store view
	
	func openStoreView(notification: NSNotification) {
		let trackId = notification.userInfo!["trackId"]! as! Int
		self.informationTable.reloadData()
		MusicStoreManager.sharedManager.openStoreView(trackId, inViewController: self)
	}
	
	
	// MARK: - Table view data source
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch currentViewType {
		case .detail:
			return 5
		case .music:
			return musicTracks.count
		case .service:
			return 0
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch currentViewType {
		case .detail:
			return 44
		case .music:
			return 63
		case .service:
			return 44
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch currentViewType {
		case .detail:
			let cell = tableView.dequeueReusableCellWithIdentifier("programInfoCell", forIndexPath: indexPath)
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Genre"
				cell.detailTextLabel?.text = program.genre.capitalizedString
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
				cell.detailTextLabel?.text = "\(Int(program.duration/60)) min."
			case 4:
				cell.textLabel?.text = "ID"
				cell.detailTextLabel?.text = program.id.uppercaseString
			default:
				return cell
			}
			
			return cell
		case .music:
			let cell = tableView.dequeueReusableCellWithIdentifier("MusicTrackCell", forIndexPath: indexPath) as! MusicTrackTableViewCell
			let track = musicTracks[indexPath.row]
			cell.trackNameLabel.text = track.trackName
			if let collectionName = track.collectionName {
				cell.trackInfoLabel.text = "\(track.artistName) - \(collectionName)"
			} else {
				cell.trackInfoLabel.text = track.artistName
			}
			cell.buyMusicButton.setTitle("¥\(Int(track.trackPrice))", forState: .Normal)
			cell.previewUrl = track.previewUrl
			cell.trackId = track.trackId
			
			SDWebImageManager.sharedManager().downloadImageWithURL(track.artworkUrl,
				options: .CacheMemoryOnly,
				progress: {(received, expected) in
					return
				},
				completed: {(image, error, cacheType, finished, imageURL) in
					cell.artworkImage.image = image
			})
			NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stopAllPreviewTrack:"), name: "startPreviewTrackPlaying", object: cell)
			NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("openStoreView:"), name: "openStoreView", object: nil)
			
			return cell
		case .service:
			let cell = tableView.dequeueReusableCellWithIdentifier("programInfoCell", forIndexPath: indexPath)
			return cell
		}
	}
	
}
