//
//  ViewController.h
//  Maps
//
//  Created by Jose Manuel Gil on 01/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomIOS7AlertView.h"
#import "FavoritesTableViewController.h"

@interface ViewController : UIViewController  <MKMapViewDelegate, CustomIOS7AlertViewDelegate,FavoritesTableViewControllerDelegate >


@property (strong, nonatomic) NSMutableArray *matchingItems;
@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property(nonatomic, retain) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;


- (IBAction)textFieldReturn:(id)sender;
- (void)setDetailItem:(id)newDetailItem;
- (void)setCityBike:(id)newCityBike;
- (void)setWonderAncient:(id)oldWonderWorld location:(CLLocation *)coordenates;

@end

