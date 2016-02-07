//
//  CollectionWonderViewController.m
//  Maps
//
//  Created by Jose Manuel Gil on 17/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import "CollectionWonderViewController.h"
#import "ViewController.h"

@interface CollectionWonderViewController ()

@end

@implementation CollectionWonderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadInformation];
   
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self addSwipeGesture];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Funcion que añade el reconocimiento del gesto swipe
- (void) addSwipeGesture {
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRightButton:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLeftButton:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return _sevenWonderImages.count;
}

// Funcion que construye el collection view a partir de la informacion contenida en los arrays
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    
    UIImage *image;
    long row = [indexPath row];
    
    image = [UIImage imageNamed:_sevenWonderImages[row]];
    
    myCell.imageView.image = image;
    myCell.wonderName.text = _descriptions[row];
    return myCell;
}


#pragma mark -
#pragma mark UICollectionViewDelegate

// Funcion que al pulsar sobre un elemento del collection view muestra su localizacion en el mapa
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ViewController *myVC1ref = ( ViewController *)[self.tabBarController.viewControllers objectAtIndex:0];
    
    [myVC1ref setWonderAncient:_descriptions[indexPath.row] location:_coordenadas[indexPath.row ]];                                                                             
    [self.tabBarController setSelectedIndex:0];    
  
}



-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
   SupplementaryView *header = nil;
    
    if ([kind isEqual:UICollectionElementKindSectionHeader])
    {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MyHeader" forIndexPath:indexPath];
        
       // header.headerLabel.text = @"Seven Wonders of the Ancient World";
    }
    return header;
}

-(void) loadInformation{
    
    _sevenWonderImages = [@[@"piramide.jpg",
                            @"jardines.jpg",
                            @"temploartemisa.jpg",
                            @"estatuazeus.jpg",
                            @"mausoleo.jpg",
                            @"coloso.jpg",
                            @"faroalejandria.jpg"] mutableCopy];
    
    _descriptions = [NSMutableArray arrayWithObjects:@"Great Pyramid of Giza",
                     @"Hanging Gardens of Babylon",
                     @"Temple of Artemis at Ephesus",
                     @"Statue of Zeus at Olympia",
                     @"Mausoleum at Halicarnassus",
                     @"Colossus of Rhodes",
                     @"Lighthouse of Alexandria",
                     nil];
 
    CLLocation *pyramidLocation = [[CLLocation alloc] initWithLatitude:29.979537f longitude:31.134169f];
    CLLocation *gardensLocation = [[CLLocation alloc] initWithLatitude:33.050600f longitude:44.483303f];
    CLLocation *templeLocation = [[CLLocation alloc] initWithLatitude:37.950293f longitude:27.365355f];
    CLLocation *statueLocation = [[CLLocation alloc] initWithLatitude:37.643743f longitude:21.629441f];
    CLLocation *mausoleumLocation = [[CLLocation alloc] initWithLatitude:37.038227f longitude:27.429043f];
    CLLocation *colossusLocation = [[CLLocation alloc] initWithLatitude:36.451666f longitude:28.228083f];
    CLLocation *lightHouseLocation = [[CLLocation alloc] initWithLatitude:31.235021f longitude:29.922675f];
    
    _coordenadas = [[NSMutableArray alloc] init];
    
     [_coordenadas addObject:pyramidLocation];
    [_coordenadas addObject:gardensLocation];
    [_coordenadas addObject:templeLocation];
    [_coordenadas addObject:statueLocation];
    [_coordenadas addObject:mausoleumLocation];
    [_coordenadas addObject:colossusLocation];
    [_coordenadas addObject:lightHouseLocation];
    
}

// Funciones para controlar el swipe hacia la izquierda o la derecha
- (IBAction)tappedRightButton:(id)sender
{
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    
    [self.tabBarController setSelectedIndex:selectedIndex + 1];
}

- (IBAction)tappedLeftButton:(id)sender
{
    NSUInteger selectedIndex = [self.tabBarController selectedIndex];
    
    [self.tabBarController setSelectedIndex:selectedIndex - 1];
}

@end
