//
//  WebServiceTableViewController.h
//  Maps
//
//  Created by Jose Manuel Gil on 01/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Celda.h"


@interface WebServiceTableViewController : UITableViewController


//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

// Spinner loading
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

- (void) descargarInfoCityBike: (NSString *)stringUrl;


@end


