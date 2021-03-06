//
//  FlickrPhotoSearchController.m
//  Photo Pool
//
//  Created by Michael Pulsifer on 9/12/10.

//  The following copyright notice and license applies to all code within the PhotoPool application except where noted in specific
//    source files and/or the About View.  
//    
//  Copyright (c) 2010, Mike Pulsifer
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//  
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following 
//    disclaimer in the documentation and/or other materials provided with the distribution.
//  * Neither the name of the Mike Pulsifer nor the names of its contributors may be used to endorse or promote products derived 
//    from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
//  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "FlickrPhotoSearchController.h"


@implementation FlickrPhotoSearchController

@synthesize context, plistDictionary, flickrRequest;
@synthesize perPageAsInt, photoSearchBar, groupPhotoList;
@synthesize photoArray, photoThumbArray, photoURL, photoData, activityView;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
	//Group state
	sharedGroupState = [SingletonFlickrGroup sharedGroupStateInstance];
	
	// Read the flickr API Key and Shared Secret from flickr.plist
	
	loadingPhotos = [sharedGroupState loadingPhotos];
	downloadCount = 0;
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:@"flickr.plist"];
	plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
	NSString *flickrKey = [plistDictionary objectForKey:@"flickr_key"];
	NSString *flickrSecret = [plistDictionary objectForKey:@"flickr_secret"];
	
	context = [[OFFlickrAPIContext alloc] initWithAPIKey:flickrKey sharedSecret:flickrSecret];
	
	flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];
	
	NSLog(@"%@", [sharedGroupState groupPhotoCount]);
	//	perPageDict = [[NSDictionary alloc] initWithObjectsAndKeys: perPage, @"perPage", perPageAsInt, @"perPageAsInt", nil ];
	
	perPageAsInt = [sharedGroupState groupPhotoCountAsInt];
	NSMutableString *groupCountAsText = [NSMutableString stringWithFormat:@"%i", [sharedGroupState groupPhotoCountAsInt]];
	[sharedGroupState setGroupPhotoCount:groupCountAsText];
	
	// get a list of the most recent photos
	[flickrRequest setDelegate:self];
	NSLog(@"Sending getRecent request to flickr...!");
	
	
	//	if ([sharedGroupState groupTag] != nil) {
	//	[flickrRequest callAPIMethodWithGET:@"flickr.groups.pools.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupID], @"group_id", [sharedGroupState groupTag], @"tags", perPage, @"per_page", nil]];
	//} else {
	//		[flickrRequest callAPIMethodWithGET:@"flickr.groups.pools.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupID], @"group_id", perPage, @"per_page", nil]];
	//}
	
	NSLog(@"Shared Group State before querying flickr: Loading Photos: %@", ([sharedGroupState loadingPhotos] ? @"YES" : @"NO"));
	if ([sharedGroupState loadingPhotos]) {
		if ([sharedGroupState searchContext] == 0) {
			[flickrRequest callAPIMethodWithGET:@"flickr.groups.pools.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupID], @"group_id", [sharedGroupState groupPhotoCount], @"per_page", nil]];
			
		} else {
			[flickrRequest callAPIMethodWithGET:@"flickr.people.getPublicPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupID], @"user_id", [sharedGroupState groupPhotoCount], @"per_page", nil]];
			
		}
	} else {
		[self setGroupPhotoList:[sharedGroupState groupPhotoList]];
	}
	
	
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)setPopover:(UIPopoverController *)aPopover
{
	popover = aPopover;
}


-(void)setMainImage:(UIImageView *)aImage
{
	mainDisplayImage = aImage;
}

-(void)setMirrorImage:(UIImageView *)aImage
{
	mirrorDisplayImage = aImage;
}

-(void)setMirrorState:(BOOL)aMirrorState
{
	mirrorState = aMirrorState;
}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
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
    // Return the number of rows in the section.
	if (loadingPhotos) {
		return 1;
	} else {
		if (downloadCount = 0) {
			// If there are no photos in the group, alert the user and dismiss the popover
			NSString *groupAlertMessage = [[NSString alloc] initWithString:@"No photos were found in this group."];
			UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No Photos Found" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[groupAlert show];
			[groupAlert release];
			[groupAlertMessage release];
			if (popover != nil) {
				NSLog(@"Dismissing the popover .... now");
				[popover dismissPopoverAnimated:YES];
			} else {
				NSLog(@"Nothing to dismiss");
			}
			
		}
		else {
			return [groupPhotoList count];
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
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	
	if (loadingPhotos) {
		//Add activity monitor
		/* [spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		 [spinner setCenter:CGPointMake([self.view bounds].size.width/2, [self.view bounds].size.height/2)];
		 [self.view addSubview:spinner];
		 [spinner startAnimating];
		 */
		NSLog(@"waiting while loading photos for %@", [sharedGroupState groupID]);
		cell.textLabel.text = @"Loading...";
		UIActivityIndicatorView *newActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self setActivityView:newActivity];
		[newActivity release], newActivity = nil;
		[activityView setHidesWhenStopped:YES];
		[activityView retain];
		
		
		[activityView startAnimating];
		cell.accessoryView = activityView;
	} else {
		
		//hide the activity indicator
		
		NSUInteger row = [indexPath row];
		NSLog(@"Create the dictionary");
		//		NSDictionary *photoDetailDict = [[[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:groupPhotoList]] objectAtIndex:row];
		//		NSDictionary *photoThumbDict = [[sharedGroupState groupPhotoDataList] objectAtIndex:row];
		UIImage *thumbImage = [[UIImage alloc] initWithData:[[[sharedGroupState groupPhotoDataList] objectAtIndex:row] objectForKey:@"thumbData"]];
		cell.imageView.image = thumbImage;
		NSLog(@"Set the label");
		cell.textLabel.text = [[groupPhotoList objectAtIndex:row] objectForKey:@"title"];
		cell.detailTextLabel.text = [[groupPhotoList objectAtIndex:row] objectForKey:@"ownername"];
		//		NSLog(@"Owner Name = %@", [photoDetailDict objectForKey:@"ownername"]);
		
		// clean up
		//		photoThumbDict = nil;
		[thumbImage release];
	}
	
	return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	// Get the URL and data for the large image
	NSUInteger row = [indexPath row];
	[sharedGroupState setSelectedPhoto:row];
	//	NSURL *photoURL = [[NSURL alloc] init];
	NSLog(@"dict count: %i", [groupPhotoList count]);
	NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[groupPhotoList objectAtIndex:row]];
	[self setPhotoURL:[context photoSourceURLFromDictionary:tempDict size:OFFlickrLargeSize]];
	NSLog(@"URL: %@", photoURL);
	//	NSData *photoData = [[NSData alloc] init];
	[self setPhotoData:[NSData dataWithContentsOfURL:photoURL]];
	[tempDict release];
	UIImage *tempFlickrPhoto = [[UIImage alloc] initWithData:photoData];
	
	CGSize tempPhotoImageSize = tempFlickrPhoto.size;
	
	CGFloat photoHeight = tempPhotoImageSize.height;
	CGFloat photoWidth = tempPhotoImageSize.width;
	
	NSLog(@"Height:  %f, Width:  %f", photoHeight, photoWidth);
	
	
	if (popover != nil) {
		NSLog(@"Dismissing the popover .... now");
		mainDisplayImage.image = tempFlickrPhoto;
		mainDisplayImage.contentMode = UIViewContentModeScaleAspectFit;
		
		if (mirrorState) {
			mirrorDisplayImage.image = tempFlickrPhoto;
			mirrorDisplayImage.contentMode = UIViewContentModeScaleAspectFit;
		}
		
		[sharedGroupState setPhotoSelected:1];
		[sharedGroupState setSelectedPhotoID:[[groupPhotoList objectAtIndex:row] objectForKey:@"id"]];
		[sharedGroupState setSelectedPhotoTitle:[[groupPhotoList objectAtIndex:row] objectForKey:@"title"]];
		[sharedGroupState setSelectedPhotoArtistID:[[groupPhotoList objectAtIndex:row] objectForKey:@"owner"]];
		[popover dismissPopoverAnimated:YES];
	} else {
		NSLog(@"Nothing to dismiss");
	}
	
	[tempFlickrPhoto release];
	
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80;
}

#pragma mark -
#pragma mark Custom Methods
-(void) resetSearch {
	// do stuff?
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	// Read the flickr API Key and Shared Secret from flickr.plist
	
	
	NSMutableString *mutString = [NSMutableString stringWithString:searchBar.text];
	mutString = (NSMutableString *)[mutString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	
	if ([sharedGroupState searchContext] == 0) {
		[flickrRequest callAPIMethodWithGET:@"flickr.groups.pools.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupID], @"group_id", mutString, @"tags", [sharedGroupState groupPhotoCount], @"per_page", nil]];
		
	} else {
		if ([searchBar selectedScopeButtonIndex] == 0) { 
	[flickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupID], @"user_id", mutString, @"text", [sharedGroupState groupPhotoCount], @"per_page", nil]];
//	[flickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupID], @"user_id", @"puertorico", @"text", [sharedGroupState groupPhotoCount], @"per_page", nil]];
	} else {
			[flickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupID], @"user_id", mutString, @"tags", [sharedGroupState groupPhotoCount], @"per_page", nil]];
		}
		
	}
	mutString = nil;
}
// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.context = nil;
	self.plistDictionary = nil;
	self.flickrRequest = nil;
	self.photoSearchBar = nil;
	self.groupPhotoList = nil;
	self.photoArray = nil;
	self.photoThumbArray = nil;
	self.photoURL = nil;
	self.photoData = nil;
	self.activityView = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[context release];
	[plistDictionary release];
	[flickrRequest release];
	[photoSearchBar release];
	[groupPhotoList release];
	//[photoArray release];
	//[photoThumbArray release];
	[photoURL release];
	[photoData release];
	//	[activityView release];
    [super dealloc];
}

#pragma mark -
#pragma mark flickr Methods
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	BOOL gotListFromFlickr = NO;
	
	NSLog(@"Sucessful response");
	NSLog(@"Response is: %@ ", inResponseDictionary);
	if ([[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:0] != nil)
	{
		//	NSArray *photoCountArray = [[NSArray alloc] initWithArray:[inResponseDictionary valueForKeyPath:@"photos"]];
		//downloadCount = 10;
		//		downloadCount = [photoCountArray count];
		
		photoArray = [NSMutableArray array];
		photoThumbArray = 	[NSMutableArray array];
		int photoBatchCount = perPageAsInt; //perPageAsInt;
		
		
		for (int i = 0; i < photoBatchCount; i++) {
			@try {
				NSDictionary *photoDict = [[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:i];
			}
			@catch (NSException * e) {
				i = photoBatchCount;
				break;
			}
			NSDictionary *photoDict = [[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:i];
			[photoArray addObject:photoDict];
			// Get the URL and data for the thumbnail (square, actually)
			[self setPhotoURL:[context photoSourceURLFromDictionary:photoDict size:OFFlickrSmallSquareSize]];
			NSLog(@"URL: %@", photoURL);
			[self setPhotoData:[NSData dataWithContentsOfURL:photoURL]];
			// Combine the URL and data into a dictionary object
			NSDictionary *photoThumbDict = [[NSDictionary alloc] initWithObjectsAndKeys:photoURL, @"thumbURL", photoData, @"thumbData", nil];
			
			NSData *tempPhotoInfoDict = [NSKeyedArchiver archivedDataWithRootObject:photoThumbDict];
			
			[photoThumbArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:tempPhotoInfoDict]];
			[photoThumbDict release], photoThumbDict = nil;
			gotListFromFlickr = YES;
		}
	} else {
		NSLog(@"FAIL!");
		NSString *groupAlertMessage = [[NSString alloc] initWithString:@"flickr did not return any results."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No Search Results" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[groupAlertMessage release];
	}
	
	loadingPhotos = NO;
	[sharedGroupState setLoadingPhotos:NO];
	NSLog(@"Shared Group State after querying flickr: Loading Photos: %@", ([sharedGroupState loadingPhotos] ? @"YES" : @"NO"));
	@try {
		[activityView stopAnimating];
	}
	@catch (NSException * e) {
		// nothing to do, really
	}
	@finally {
		// nothing to do, really
	}
	
	if (gotListFromFlickr) {
		[self setGroupPhotoList:photoArray];
		
		NSData *photoArrayBuffer = [NSKeyedArchiver archivedDataWithRootObject:photoArray];
		NSData *photoThumbArrayBuffer = [NSKeyedArchiver archivedDataWithRootObject:photoThumbArray];
		//	NSLog(@"dump: %@", photoArrayBuffer);
		[sharedGroupState setGroupPhotoList:[NSKeyedUnarchiver unarchiveObjectWithData:photoArrayBuffer]];
		
		//[sharedGroupState setGroupPhotoList:groupPhotoList];
		[sharedGroupState setGroupPhotoDataList:[NSKeyedUnarchiver unarchiveObjectWithData:photoThumbArrayBuffer]];
		
		//	NSLog(@"The number of entries: %i", [[sharedGroupState groupPhotoList] count]);
		downloadCount = [groupPhotoList count];
		
		photoArrayBuffer = nil;
		photoThumbArrayBuffer = nil;
		[self.tableView reloadData];
		
	}
	//[photoThumbArray release], photoThumbArray = nil;
	
	[self.tableView reloadData];
}

@end

