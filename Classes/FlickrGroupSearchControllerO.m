    //
//  FlickrGroupSearchController.m
//  Photo Pool
//
//  Created by Michael Pulsifer on 8/17/10.
//  Copyright 2010 Mike Pulsifer. All rights reserved.
//

#import "FlickrGroupSearchController.h"


@implementation FlickrGroupSearchController
@synthesize flickrRequest;
@synthesize context;
@synthesize plistDictionary;
@synthesize resultsTable;
@synthesize groupSearchBar;
@synthesize groupSearchResults;
@synthesize groupKeys, groupArray;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//Group state
	sharedGroupState = [SingletonFlickrGroup sharedGroupStateInstance];
	
	
	loadingGroups = YES;
    [super viewDidLoad];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (loadingGroups) {
		NSLog(@"Array count: %i for %@", [[sharedGroupState groupList] count], section);
		return 1;
	} else {
		if (downloadCount = 0) {
			// If there are no groups in the results, alert the user and dismiss the popover
			NSString *groupAlertMessage = [[NSString alloc] initWithString:@"No groups were found."];
			UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No Photos Found" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[groupAlert show];
			[groupAlert release];
			[groupAlertMessage release];
		/*	if (popover != nil) {
				NSLog(@"Dismissing the popover .... now");
				[popover dismissPopoverAnimated:YES];
			} else {
				NSLog(@"Nothing to dismiss");
			}
			*/
		}
		else {
			return [[sharedGroupState groupList] count];
		}
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Entering cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	
	if (loadingGroups) {
		//Add activity monitor
		/* [spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		 [spinner setCenter:CGPointMake([self.view bounds].size.width/2, [self.view bounds].size.height/2)];
		 [self.view addSubview:spinner];
		 [spinner startAnimating];
		 */
	
		/* IMPORTED CODE
		NSLog(@"waiting while loading photos");
		cell.textLabel.text = @"Loading...";
		UIActivityIndicatorView *newActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self setActivityView:newActivity];
		[newActivity release], newActivity = nil;
		[activityView retain];
		
		
		[activityView startAnimating];
		cell.accessoryView = activityView;
		 */
	} else {
		
		//hide the activity indicator
		
		NSLog(@"Configure the cell... %i", [[sharedGroupState groupList] count]);
		NSUInteger row = [indexPath row];
		NSLog(@"Create the dictionary");
		NSDictionary *groupDetailDict = [[NSDictionary alloc] init];
		groupDetailDict = [[sharedGroupState groupList] objectAtIndex:row];
	//	NSDictionary *photoThumbDict = [[NSDictionary alloc] init];
	//	photoThumbDict = [[sharedGroupState groupPhotoDataList] objectAtIndex:row];
	//	UIImage *thumbImage = [[UIImage alloc] initWithData:[photoThumbDict objectForKey:@"thumbData"]];
	//	cell.imageView.image = thumbImage;
		NSLog(@"Set the label");
		cell.textLabel.text = [groupDetailDict objectForKey:@"name"];
//		cell.detailTextLabel.text = [photoDetailDict objectForKey:@"ownername"];
		NSLog(@"Group Name = %@", [groupDetailDict objectForKey:@"name"]);
	}
	
	return cell;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark Custom Methods
-(void) resetSearch {
	// do stuff?
}

-(void)handleSearchForTerm:(NSString *)searchTerm {
	// Read the flickr API Key and Shared Secret from flickr.plist
	
	NSMutableString *mutString = [NSMutableString stringWithString:searchTerm];
	mutString = (NSMutableString *)[mutString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	//[groupName setText:mutString];
	
	if ([mutString isEqualToString:@""]) {
		NSString *groupAlertMessage = [[NSString alloc] initWithString:@"No group name was entered and none was selected."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No Results" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[groupAlertMessage release];
	/*
		if (popover != nil) {
			[popover dismissPopoverAnimated:YES];
			
		} else {
			NSLog(@"Nothing to dismiss");
		}
	*/	
	} else {
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"flickr.plist"];
		plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
		NSString *flickrKey = [plistDictionary objectForKey:@"flickr_key"];
		NSString *flickrSecret = [plistDictionary objectForKey:@"flickr_secret"];
		
		context = [[OFFlickrAPIContext alloc] initWithAPIKey:flickrKey sharedSecret:flickrSecret];
		
		flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];
		[flickrRequest setDelegate:self];
		[flickrRequest callAPIMethodWithGET:@"flickr.groups.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:searchTerm, @"text", @"20", @"per_page", nil]];
	}
}

#pragma mark -
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	NSLog(@"Sucessful response");
	if ([[inResponseDictionary valueForKeyPath:@"groups.group"] objectAtIndex:0] != nil)
	{
	
		groupArray = [NSMutableArray array];
		//photoThumbArray = 	[NSMutableArray array];
		
		//int photoBatchCount = perPageAsInt;
		
		int photoBatchCount = 20;
		
		/*		if (downloadCount < [sharedGroupState groupPhotoCountAsInt]) {
		 NSLog(@"the number of photos downloaded was %i.  The number desired was %i.", downloadCount, [sharedGroupState groupPhotoCountAsInt]);
		 [sharedGroupState setGroupPhotoCountAsInt:downloadCount];
		 }
		 */		
		
		NSLog(@"Going into loop with %i items", photoBatchCount);
		for (int i = 0; i < photoBatchCount; i++) {
			@try {
				NSDictionary *groupDict = [[inResponseDictionary valueForKeyPath:@"groups.group"] objectAtIndex:i];
			}
			@catch (NSException * e) {
				i = photoBatchCount;
				break;
			}
			NSDictionary *groupDict = [[inResponseDictionary valueForKeyPath:@"groups.group"] objectAtIndex:i];
			[groupArray addObject:groupDict];
			// Get the URL and data for the thumbnail (square, actually)
//			[self setPhotoURL:[context photoSourceURLFromDictionary:photoDict size:OFFlickrSmallSquareSize]];
//			NSLog(@"URL: %@", photoURL);
//			[self setPhotoData:[NSData dataWithContentsOfURL:photoURL]];
			// Combine the URL and data into a dictionary object
//			NSDictionary *photoThumbDict = [[NSDictionary alloc] initWithObjectsAndKeys:photoURL, @"thumbURL", photoData, @"thumbData", nil];
//			[photoThumbArray addObject:photoThumbDict];
		}
	} else {
		NSLog(@"FAIL!");
	}
	
	loadingGroups = NO;
//	[activityView stopAnimating];
//	[activityView release];
	
	
	//UIImage *tempFlickrPhoto = [[UIImage alloc] initWithData:photoData];
	//PPimageView.image = tempFlickrPhoto;
	//PPimageView.contentMode = UIViewContentModeScaleAspectFit;
	
	NSData *groupArrayBuffer = [NSKeyedArchiver archivedDataWithRootObject:groupArray];
//	NSData *photoThumbArrayBuffer = [NSKeyedArchiver archivedDataWithRootObject:photoThumbArray];
	
	[sharedGroupState setGroupList:[NSKeyedUnarchiver unarchiveObjectWithData:groupArrayBuffer]];
//	[sharedGroupState setGroupPhotoDataList:[NSKeyedUnarchiver unarchiveObjectWithData:photoThumbArrayBuffer]];
	
	NSLog(@"The number of entries: %i", [[sharedGroupState groupList] count]);
	downloadCount = [[sharedGroupState groupList] count];
	[self.tableView reloadData];
	
	
	
}



@end
