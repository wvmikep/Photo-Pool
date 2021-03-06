//
//  ExifViewController.m
//  Photo Pool
//
//  Created by Michael Pulsifer on 7/6/10.

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

#import "ExifViewController.h"


@implementation ExifViewController
@synthesize flickrRequest, context, plistDictionary, activityView, exifTimer;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
 	//Group state
	sharedGroupState = [SingletonFlickrGroup sharedGroupStateInstance];
	
	loadingEXIF = YES;

	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:@"flickr.plist"];
	plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
	NSString *flickrKey = [plistDictionary objectForKey:@"flickr_key"];
	NSString *flickrSecret = [plistDictionary objectForKey:@"flickr_secret"];
	
	context = [[OFFlickrAPIContext alloc] initWithAPIKey:flickrKey sharedSecret:flickrSecret];
	
	flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];
	
	
	// playing around to get a feel for the flickr api
	// get a list of the most recent photos
	[flickrRequest setDelegate:self];
	
	NSString *flickrPhotoID = [NSString stringWithFormat: @"%@", [sharedGroupState selectedPhotoID]];
	[flickrRequest callAPIMethodWithGET:@"flickr.photos.getExif" arguments:[NSDictionary dictionaryWithObjectsAndKeys:flickrPhotoID, @"photo_id", nil]];
	NSLog(@"Asked Flickr for the EXIF data");
	
	exifTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(noExifAlertMethod:) userInfo:nil repeats:NO];
	
	
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

-(void)noExifAlertMethod:(NSTimer *)theTimer {
	if (loadingEXIF) {
		NSString *groupAlertMessage = [[NSString alloc] initWithString:@"flickr did not respond with any EXIF data. The photographer may not have enabled sharing of it."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No EXIF Data" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[groupAlertMessage release];
	}

}	


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if (loadingEXIF) {
		return 1;
	}
    return [[sharedGroupState exifKeys] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

	if (loadingEXIF) {
		return 1;
	}
	
	NSString *key = [[sharedGroupState exifKeys] objectAtIndex:section];
	NSArray *exifSection = [[sharedGroupState photoEXIFData] objectForKey:key];
	//NSLog(@"%i rows in the %@ section", [exifSection count],key);

	return [exifSection count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	
	NSUInteger section = [indexPath section];
	NSLog(@"section %i", section);
	NSUInteger row = [indexPath row];
	NSLog(@"attempting row: %i", row);
    
	NSString *key = [[sharedGroupState exifKeys] objectAtIndex:section];
	NSLog(@"Attempting tagspace: %@", key);
	
	NSArray *exifSection = [[sharedGroupState photoEXIFData] objectForKey:key];
	
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

	if (loadingEXIF) {
//		if (row == 0) {
			cell.textLabel.text = @"Loading...";
			UIActivityIndicatorView *newActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[self setActivityView:newActivity];
			[newActivity release], newActivity = nil;
			[activityView retain];
			
			
			[activityView startAnimating];
			cell.accessoryView = activityView;
			
	/*	} else {
			cell.textLabel.text = @"Note:";
			cell.detailTextLabel.text = @"EXIF data may not be available";
		}
*/
	} else {
		
    
		// Configure the cell...
		NSDictionary *cellExif = [[exifSection objectAtIndex:row] objectForKey:key];
		
		
		cell.textLabel.text = [cellExif objectForKey:@"label"];
		if ([cellExif objectForKey:@"clean"] != nil) {
			NSDictionary *cleanExif = [cellExif objectForKey:@"clean"]; 
			cell.detailTextLabel.text = [cleanExif objectForKey:@"_text"];
			cleanExif = nil;
		} else {
			NSDictionary *rawExif = [cellExif objectForKey:@"raw"];
			cell.detailTextLabel.text = [rawExif objectForKey:@"_text"];
			rawExif = nil;
		}
		cellExif = nil;

	}
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *key = [[sharedGroupState exifKeys] objectAtIndex:section];
	return key;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (loadingEXIF) {
		return @"Depending on the photographer's permissions settings, EXIF data may not be available.";
	}
	return nil;
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
	self.flickrRequest = nil;
	self.context = nil;
	self.plistDictionary = nil;
	self.activityView = nil;
}


- (void)dealloc {
	[flickrRequest release];
	[context release];
	[plistDictionary release];
	[activityView release];
    [super dealloc];
}
#pragma mark -
#pragma mark flickr Methods
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	NSLog(@"Sucessful response");
	if ([[inResponseDictionary valueForKeyPath:@"photo.exif"] objectAtIndex:0] != nil)
	{
		NSArray *exifTagspaces = [[NSArray alloc] initWithObjects:@"Summary", @"ExifIFD", @"Composite", @"XMP-exif", @"XMP-aux", @"XMP-crs", nil];
		
		// loop through all of the EXIF data and pick out the most relevant as defined in exifTagspaces
		NSArray *allEXIF = [[NSArray alloc] initWithArray:[inResponseDictionary valueForKeyPath:@"photo.exif"]];
		NSMutableArray *exififdArray = [[NSMutableArray alloc] init];
		NSMutableArray *xmpexifArray = [[NSMutableArray alloc] init];
		NSMutableArray *xmpauxArray = [[NSMutableArray alloc] init];
		NSMutableArray *xmpcrsdArray = [[NSMutableArray alloc] init];
		NSMutableArray *compositeArray = [[NSMutableArray alloc] init];
		NSMutableArray *summaryArray = [[NSMutableArray alloc] init];

		for (int i = 0; i < [allEXIF count]; i++) {
			NSMutableDictionary *trimmedEXIFDict = [[NSMutableDictionary alloc] init];
			NSMutableDictionary *summaryEXIFDict = [[NSMutableDictionary alloc] init];
			NSDictionary *singleEXIF = [allEXIF objectAtIndex:i];
			NSString *tempTagSpace = [singleEXIF valueForKey:@"tagspace"];
			
			if ([tempTagSpace isEqualToString:@"ExifIFD"]) {
				if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Aperture"] ||
					[[singleEXIF objectForKey:@"label"] isEqualToString:@"ShutterSpeedValue"] ||
					[[singleEXIF objectForKey:@"label"] isEqualToString:@"ISO Speed"] ||
					[[singleEXIF objectForKey:@"label"] isEqualToString:@"Focal Length"]) {
					[summaryEXIFDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:singleEXIF]] forKey:@"Summary"];
					[summaryArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:summaryEXIFDict]]];
				}
/*				if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Aperture"] ||
					[[singleEXIF objectForKey:@"label"] isEqualToString:@"ShutterSpeedValue"] ||
					[[singleEXIF objectForKey:@"label"] isEqualToString:@"ISO Speed"] ||
					[[singleEXIF objectForKey:@"label"] isEqualToString:@"Exposure Bias"] ||
					[[singleEXIF objectForKey:@"label"] isEqualToString:@"Exposure Mode"] ||
					[[singleEXIF objectForKey:@"label"] isEqualToString:@"Focal Length"]) {
					[summaryEXIFDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:singleEXIF]] forKey:@"Summary"];
					[summaryArray addObject:summaryEXIFDict];
				}*/
				/*				} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"ShutterSpeedValue"]) {
					[summaryEXIFDict setObject:singleEXIF forKey:@"Summary"];
					[summaryArray addObject:summaryEXIFDict];
				} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"ISO Speed"]) {
					[summaryEXIFDict setObject:singleEXIF forKey:@"Summary"];
					[summaryArray addObject:summaryEXIFDict];
				} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Exposure Bias"]) {
					[summaryEXIFDict setObject:singleEXIF forKey:@"Summary"];
					[summaryArray addObject:summaryEXIFDict];
				} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Exposure Mode"]) {
					[summaryEXIFDict setObject:singleEXIF forKey:@"Summary"];
					[summaryArray addObject:summaryEXIFDict];
				} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Focal Length"]) {
					[summaryEXIFDict setObject:singleEXIF forKey:@"Summary"];
					[summaryArray addObject:summaryEXIFDict];
				}
*/
				[trimmedEXIFDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:singleEXIF]] forKey:[singleEXIF valueForKey:@"tagspace"]];
				[exififdArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:trimmedEXIFDict]]];
			} else if ([tempTagSpace isEqualToString:@"XMP-exif"]) {
				[trimmedEXIFDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:singleEXIF]] forKey:[singleEXIF valueForKey:@"tagspace"]];
				[xmpexifArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:trimmedEXIFDict]]];
			} else if ([tempTagSpace isEqualToString:@"XMP-aux"]) {
				[trimmedEXIFDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:singleEXIF]] forKey:[singleEXIF valueForKey:@"tagspace"]];
				if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Lens"]) {
					[summaryEXIFDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:singleEXIF]] forKey:@"Summary"];
					[summaryArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:summaryEXIFDict]]];
				}
				[xmpauxArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:trimmedEXIFDict]]];
			} else if ([tempTagSpace isEqualToString:@"XMP-crs"]) {
				[trimmedEXIFDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:singleEXIF]] forKey:[singleEXIF valueForKey:@"tagspace"]];
				[xmpcrsdArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:trimmedEXIFDict]]];
			} else if ([tempTagSpace isEqualToString:@"Composite"]) {
				[trimmedEXIFDict setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:singleEXIF]] forKey:[singleEXIF valueForKey:@"tagspace"]];
				[compositeArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:trimmedEXIFDict]]];
			}
			[trimmedEXIFDict release], trimmedEXIFDict = nil;
			[summaryEXIFDict release], summaryEXIFDict = nil;
			[singleEXIF release], singleEXIF = nil;
			tempTagSpace = nil;
		}
		
		NSMutableDictionary *exifDictFilled = [[NSMutableDictionary alloc] init];
		[exifDictFilled setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:summaryArray]] forKey:@"Summary"];
		[exifDictFilled setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:compositeArray]] forKey:@"Composite"];
		[exifDictFilled setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:exififdArray]] forKey:@"ExifIFD"];
		[exifDictFilled setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:xmpexifArray]] forKey:@"XMP-exif"];
		[exifDictFilled setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:xmpauxArray]] forKey:@"XMP-aux"];
		[exifDictFilled setObject:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:xmpcrsdArray]] forKey:@"XMP-crs"];
		NSData *exifArrayBuffer =[NSKeyedArchiver archivedDataWithRootObject:exifDictFilled];
		[sharedGroupState setPhotoEXIFData:[NSKeyedUnarchiver unarchiveObjectWithData:exifArrayBuffer]];	

		NSData *exifTagBuffer = [NSKeyedArchiver archivedDataWithRootObject:exifTagspaces];
		[sharedGroupState setExifKeys:[NSKeyedUnarchiver unarchiveObjectWithData:exifTagBuffer]];
		
		[summaryArray release], summaryArray = nil;
		[compositeArray release], compositeArray = nil;
		[exififdArray release], exififdArray = nil;
		[xmpexifArray release], xmpexifArray = nil;
		[xmpauxArray release], xmpauxArray = nil;
		[xmpcrsdArray release], xmpcrsdArray = nil;
		[exifDictFilled release], exifDictFilled = nil;
		[exifTagspaces release], exifTagspaces = nil;
		exifArrayBuffer = nil;
		exifTagBuffer = nil;
		//[allEXIF release], 
		allEXIF = nil;
	}
	NSLog(@"Processed XML");
	
	loadingEXIF = NO;
	[activityView stopAnimating];
	[activityView release];

	[self.tableView reloadData];
}

-(void)flickrRequest:(OFFlickrAPIContext *)inRequest didFailWithError:(NSError *)inError; {
	NSLog(@"Error Encountered with flickr!");
}


@end

