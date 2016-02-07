//
//  WebServiceTableViewController.m
//  Maps
//
//  Created by Jose Manuel Gil on 01/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import "WebServiceTableViewController.h"
#import "ViewController.h"


@interface WebServiceTableViewController (){    
   
    NSArray *puntosBikeArray;
    UIActivityIndicatorView *spinner;
    NSMutableData *dataJSON;
    NSArray *jsonArray;
    
    NSArray *searchResults;
   
}
@end


@implementation WebServiceTableViewController

@dynamic tableView;


 - (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Comprueba si existe la informacion de city.bike al cargar la vista la primera vez
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"arrayCityBikes"]) {
        
        [self  descargarInfoCityBike:@"http://api.citybik.es/networks.json"];
        
    }
    else{
        
        jsonArray = [userDefaults objectForKey:@"arrayCityBikes"];
    }
    
    [self addSwipeGesture];
 
}

-(void) viewDidAppear:(BOOL)animated{
    
     // Comprueba si existe la informacion de city.bike cada vez que carga la vista
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"arrayCityBikes"]) {
        
        [self  descargarInfoCityBike:@"http://api.citybik.es/networks.json"];
        
        // añade un lugar de prueba
        //[self addToFavorites:@"Nombrelugar" descripcionFavorito:@"Descripcion" latitudFavorito:36.0f longitudFavorito:-4.5f];
        
    }
    else{
       // NSLog(@"View controller: Existe el array de bikes");
        jsonArray = [userDefaults objectForKey:@"arrayCityBikes"];
    }
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

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
    [spinner stopAnimating];
}
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    // NSLog(@"Received response: %@", response);
    // It can be called multiple times, for example in the case of a redirect, so each time we reset the data.
    [dataJSON setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [dataJSON appendData:data];
}

// Esta funcion se llama de manera automatica cuando finaliza la conexion y se obtienen los datos
-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
  
    NSError *e = nil;
    NSURL *myURL = [[connection currentRequest] URL];
    NSString *myStringURL = [myURL absoluteString];
    
    // Si la peticion es a api.citybik.es/networks
    if([myStringURL isEqualToString:@"http://api.citybik.es/networks.json"]){
        
        jsonArray = [NSJSONSerialization JSONObjectWithData:dataJSON options: NSJSONReadingMutableContainers error: &e];
        if (!jsonArray) {
            
            NSLog(@"Error parsing JSON: %@", e);
        }
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:jsonArray forKey:@"arrayCityBikes"];
        
        [userDefaults synchronize];
        // actualiza el interfaz con los datos
        [self.tableView reloadData];
      
    }
    // si es a una localidad en concreto hay que añadir los marcadores al mapa
    else{
        
        puntosBikeArray = [NSJSONSerialization JSONObjectWithData:dataJSON options: NSJSONReadingMutableContainers error: &e];
        if (!puntosBikeArray) {
            
            NSLog(@"Error parsing JSON: %@", e);
        }
        else{
            
            [self.tabBarController setSelectedIndex:0];
           
            ViewController *myVC1ref = ( ViewController *)[self.tabBarController.viewControllers objectAtIndex:0];
            
            [myVC1ref setCityBike:puntosBikeArray];
            
        }

    }
    
    // detiene la animacion del spinner
    [spinner stopAnimating];
    
    
}

// Funcion que hace la peticion al web service de CityBike para descargar la informacion
- (void) descargarInfoCityBike: (NSString *)stringUrl{
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    // Petición NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *conexion = [NSURLConnection connectionWithRequest:request delegate:self];
    if (conexion){
        
        // configurar el spinner de carga
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin; // ajustar a la pantalla
        spinner.center = self.view.center;
        spinner.hidesWhenStopped = YES;
        [self.view addSubview:spinner];
        [spinner startAnimating];
        
        dataJSON = [[NSMutableData alloc] init];
       
    }else{
        NSLog(@"ERROR. Imposible realizar la conexión");
        [spinner stopAnimating];
    }
    
}


#pragma mark - Table view data source


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [jsonArray count];
    }
    //return [jsonArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [searchResults[indexPath.row]  objectForKey:@"name"];
    } else {
        cell.textLabel.text = [jsonArray[indexPath.row]  objectForKey:@"name"];
    }
    
   
    return cell;
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

// Funcion que al pulsar sobre un elemento de la lista lo muestra en el mapa
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *stringUrl;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
         stringUrl = [searchResults[indexPath.row]  objectForKey:@"url"];
        
    } else {
        
        stringUrl = [jsonArray[indexPath.row]  objectForKey:@"url"];
    }
    
    
    [self descargarInfoCityBike:stringUrl];
    
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    searchResults = [jsonArray filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}




@end
