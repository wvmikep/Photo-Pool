//
//  FlickrGroupSearchController.h
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

#import <UIKit/UIKit.h>
#import "ObjectiveFlickr.h"
#import "SingletonFlickrGroup.h"


@interface FlickrGroupSearchController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, OFFlickrAPIRequestDelegate> {
	
	NSDictionary *plistDictionary;
	OFFlickrAPIContext *context;
	OFFlickrAPIRequest *flickrRequest;
	
	NSMutableArray *groupArray;
	UITableView *resultsTable;
	UISearchBar *groupSearchBar;
	NSMutableDictionary *groupSearchResults;
	NSMutableArray *groupKeys;
	BOOL loadingGroups;
	SingletonFlickrGroup *sharedGroupState;
	int downloadCount;
	UIPopoverController *popover;
}

@property (nonatomic, retain) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic, retain) OFFlickrAPIContext *context;
@property (nonatomic, retain) NSDictionary *plistDictionary;
@property (nonatomic, retain) IBOutlet UITableView *resultsTable;
@property (nonatomic, retain) IBOutlet UISearchBar *groupSearchBar;
@property (nonatomic, retain) NSMutableDictionary *groupSearchResults;
@property (nonatomic, retain) NSMutableArray *groupKeys;
@property (nonatomic, retain) NSMutableArray *groupArray;

-(void) resetSearch;
//-(void) handleSearchForTerm:(NSString *)searchTerm;
-(void)setGroupPop:(UIPopoverController*)aPopover;

@end
