//
//  FlickrGroupSearchController.m
//  Photo Pool
//
//  Created by Michael Pulsifer on 8/17/10.

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

#import "FlickrGroupSearchController.h"


@implementation FlickrGroupSearchController

@synthesize flickrRequest, context, plistDictionary;
@synthesize resultsTable;
@synthesize groupSearchBar;
@synthesize groupSearchResults;
@synthesize groupKeys, groupArray;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
	//Group state
	sharedGroupState = [SingletonFlickrGroup sharedGroupStateInstance];

	loadingGroups = YES;
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
		NSDictionary *groupDetailDict = [[sharedGroupState groupList] objectAtIndex:row];
		//	NSDictionary *photoThumbDict = [[NSDictionary alloc] init];
		//	photoThumbDict = [[sharedGroupState groupPhotoDataList] objectAtIndex:row];
		//	UIImage *thumbImage = [[UIImage alloc] initWithData:[photoThumbDict objectForKey:@"thumbData"]];
		//	cell.imageView.image = thumbImage;
		NSLog(@"Set the label");
		if ([sharedGroupState searchContext] == 0) {
			cell.textLabel.text = [groupDetailDict objectForKey:@"name"];
			//		cell.detailTextLabel.text = [photoDetailDict objectForKey:@"ownername"];
			NSLog(@"Group Name = %@", [groupDetailDict objectForKey:@"name"]);
		} else {
			cell.textLabel.text = [groupDetailDict valueForKeyPath:@"user.username._text"];
			//		cell.detailTextLabel.text = [photoDetailDict objectForKey:@"ownername"];
			NSLog(@"Flickr User Name = %@", [groupDetailDict valueForKeyPath:@"user.username._text"]);
			
		}
		
		groupDetailDict = nil;

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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
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
//	[sharedGroupState setSelectedPhoto:row];
	//	NSURL *photoURL = [[NSURL alloc] init];
//	NSDictionary *tempDict = [[sharedGroupState groupList] objectAtIndex:row];
//	[self setPhotoURL:[context photoSourceURLFromDictionary:tempDict size:OFFlickrLargeSize]];
//	NSLog(@"URL: %@", photoURL);
	//	NSData *photoData = [[NSData alloc] init];
//	[self setPhotoData:[NSData dataWithContentsOfURL:photoURL]];
	
//	UIImage *tempFlickrPhoto = [[UIImage alloc] initWithData:photoData];
	
	if (popover != nil) {
		NSLog(@"Dismissing the popover .... now");
		
		[sharedGroupState setValidGroupName:1];
		if ([sharedGroupState searchContext] == 0) {
			[sharedGroupState setGroupID:[[[sharedGroupState groupList] objectAtIndex:row] objectForKey:@"nsid"]];
		} else {
			[sharedGroupState setGroupID:[[[sharedGroupState groupList] objectAtIndex:row] valueForKeyPath:@"user.nsid"]];
		}
		
		//		[sharedGroupState setGroupName:[[[sharedGroupState groupList] objectAtIndex:row] objectForKey:@"nsid"]];
		NSLog(@"Setting group to %@", [sharedGroupState groupID]);
		[popover dismissPopoverAnimated:YES];
	} else {
		NSLog(@"Nothing to dismiss");
	}
	
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}
-(void)setGroupPop:(UIPopoverController *)aPopover
{
	popover = aPopover;
}



#pragma mark -
#pragma mark Custom Methods
-(void) resetSearch {
	// do stuff?
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	// Read the flickr API Key and Shared Secret from flickr.plist
	
	NSLog(@"Context Index is: %i", [searchBar selectedScopeButtonIndex]);
	[sharedGroupState setSearchContext:[searchBar selectedScopeButtonIndex]];
	
	NSMutableString *mutString = [NSMutableString stringWithString:searchBar.text];
	mutString = (NSMutableString *)[mutString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	[searchBar resignFirstResponder];
	
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
		if ([searchBar selectedScopeButtonIndex] == 0) {
			[flickrRequest callAPIMethodWithGET:@"flickr.groups.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:mutString, @"text", @"20", @"per_page", nil]];
		} else {
			[flickrRequest callAPIMethodWithGET:@"flickr.people.findByUsername" arguments:[NSDictionary dictionaryWithObjectsAndKeys:mutString, @"username", nil]];
		}

	}
}

#pragma mark -
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	NSLog(@"Sucessful response");
	if ([sharedGroupState searchContext] == 0) {
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
		} else{
			NSLog(@"GROUP FAIL!");
		}
	} else if ([sharedGroupState searchContext] == 1) {
		NSLog(@"user.username is: %@", [inResponseDictionary valueForKeyPath:@"user.username._text"]);
		NSLog(@"%@", inResponseDictionary);
		NSLog(@"Keys: %@", [[inResponseDictionary valueForKeyPath:@"user"] allKeys]);
		if ([inResponseDictionary valueForKeyPath:@"user.nsid"] != nil)
		{
			groupArray = [NSMutableArray array];
			int photoBatchCount = 20;
			NSLog(@"Going into person loop with %i items", photoBatchCount);
	//		for (int i=0; i < photoBatchCount; i++) {
				@try {
					NSDictionary *groupDict = inResponseDictionary; //[[inResponseDictionary valueForKeyPath:@"user"] objectAtIndex:i];
				}
				@catch (NSException * e) {
	//				i = photoBatchCount;
	//				break;
				}
			@finally {
				NSDictionary *groupDict = inResponseDictionary; //[[inResponseDictionary valueForKeyPath:@"user"] objectAtIndex:i];
				[groupArray addObject:groupDict];
			}
	//		}
		} else{
			NSLog(@"PERSON FAIL!");
		}
	}

	
	loadingGroups = NO;
	[sharedGroupState setLoadingPhotos:YES];
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

-(void)flickrRequest:(OFFlickrAPIContext *)inRequest didFailWithError:(NSError *)inError; {
	NSLog(@"Error Encountered with flickr!");
}

@end

