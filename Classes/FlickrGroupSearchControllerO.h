//
//  FlickrGroupSearchController.h
//  Photo Pool
//
//  Created by Michael Pulsifer on 8/17/10.
//  Copyright 2010 Mike Pulsifer. All rights reserved.
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
-(void) handleSearchForTerm:(NSString *)searchTerm;

@end
