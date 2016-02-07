//
//  ViewController.m
//  Maps
//
//  Created by Jose Manuel Gil on 01/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import "ViewController.h"
#import "Celda.h"
//#import <CoreData/CoreData.h>


@interface ViewController (){
    
    UITextView *_textViewNombre;
    UITextView *_textViewDescripcion;
    float _latitudItemSelected;
    float _longitudItemSelected;
    NSString *_nombredelItem;
    
    CLLocation *usuarioLocation;
}

@end


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation ViewController


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    _mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    #ifdef __IPHONE_8_0
        if(IS_OS_8_OR_LATER) {
            // Use one or the other, not both. Depending on what you put in info.plist
            [self.locationManager requestWhenInUseAuthorization];
            //[self.locationManager requestAlwaysAuthorization];
        }
    #endif
        [self.locationManager startUpdatingLocation];
   
    _mapView.showsUserLocation = YES;

    
    
    
    [self addGestureRecogniserToMapView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


// Funcion que permite ocultar el teclado
- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView removeOverlays:_mapView.overlays];
    [self performSearch];
}

// Funcion que realiza una busqueda de la palabra introducida
- (void) performSearch {
    
    MKLocalSearchRequest *request =
    [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = _searchText.text;
    request.region = _mapView.region;
    
    _matchingItems = [[NSMutableArray alloc] init];
    
    MKLocalSearch *search =
    [[MKLocalSearch alloc]initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse  *response, NSError *error) {
                                        
        if (response.mapItems.count == 0){
            // NSLog(@"No Matches");
            if([_searchText.text isEqualToString:@""]){
                
                // MOSTRAR MARCADORES FAVORITOS SI BUSQUEDA ESTA EN BLANCO
                
                [self showFavoritesInMap];
                
            }
        }
        else{
            for (MKMapItem *item in response.mapItems)
            {
                [_matchingItems addObject:item];
                MKPointAnnotation *annotation =
                [[MKPointAnnotation alloc]init];
                annotation.coordinate = item.placemark.coordinate;
                annotation.title = item.name;
               
                [_mapView addAnnotation:annotation];
            }
            
        }
    }];
    
   
}

// Funcion que muestra en el mapa los marcadores de los favoritos
- (void) showFavoritesInMap{
    
    FavoritesTableViewController *favoritos = [[FavoritesTableViewController alloc] init];
    
    [favoritos setDelegate:self];
    
    NSArray *arrayFav = [favoritos recuperarListaFavoritos];
    
    NSMutableArray *arrayFavMK = [[NSMutableArray alloc] init];
    
    for(id object in arrayFav){
        
        [arrayFavMK addObject: [self putTheMarker:object]];
        
    }
    
    [_mapView showAnnotations:arrayFavMK animated:YES];
    
}

// Funcion que muestra en el mapa un marcador favorito
- (MKPointAnnotation *)putTheMarker:(id)newDetailItem
{
    
    Celda *celda = (Celda *)newDetailItem;
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = CLLocationCoordinate2DMake([celda latitud], [celda longitud]);
    myAnnotation.title = [celda nombre];
    myAnnotation.subtitle = [celda descripcion];
    
    [_mapView addAnnotation: myAnnotation];
    [_mapView selectAnnotation:myAnnotation animated:YES];
    
    return myAnnotation;
    
}

// Funcion lalmada al pulsar el boton + de la anotacion y que genera una alerta personalizada
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createAlertView]];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK",@"Cancel",nil]];
    [alertView setDelegate:self]; // para poder invocar los metodos del delegado y controlarlos
    [alertView show];
    
}


// Funcion que captura las coordenadas del marcador tocado
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    _latitudItemSelected = view.annotation.coordinate.latitude;
    _longitudItemSelected = view.annotation.coordinate.longitude;
    _nombredelItem = view.annotation.title;
}

// FUENTE: http://stackoverflow.com/questions/7923961/right-callout-accessory-method-and-implementation
- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id < MKAnnotation >)annotation
{
    
    static NSString *reuseId = @"StandardPin";
    
    MKPinAnnotationView *aView = (MKPinAnnotationView *)[sender dequeueReusableAnnotationViewWithIdentifier:reuseId];
                                                         
    if (aView == nil)
    {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId] ;
                 
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        aView.canShowCallout = YES;
        aView.pinColor = MKPinAnnotationColorGreen;
    }
    
    aView.annotation = annotation;
    
    return aView;   
}

// Funcion que se invoca de manera automatica para dibujar la ruta
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        return routeRenderer;
    }
    else return nil;
}

// Funcion que recoge y guarda las coordenadas del usuario
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    
    
    usuarioLocation = [[CLLocation alloc] initWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];

}

// Funcion que muestra en el mapa un marcador favorito
- (void)setDetailItem:(id)newDetailItem
{
    [_mapView removeAnnotations:[_mapView annotations]]; // Remove all annotations
    
    Celda *celda = (Celda *)newDetailItem;
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = CLLocationCoordinate2DMake([celda latitud], [celda longitud]);
    myAnnotation.title = [celda nombre];
    myAnnotation.subtitle = [celda descripcion];
    
    [_mapView removeOverlays:_mapView.overlays];
    
    // si esta almacenada la ubicacion del usuario dibuja la ruta
    if(usuarioLocation){
        
        NSMutableArray *arrayAnota = [[NSMutableArray alloc]init];
        MKPointAnnotation *myPos = [[MKPointAnnotation alloc]init];
        
        myPos.coordinate = usuarioLocation.coordinate;
        myPos.title = @"I'm here";
        
        [arrayAnota addObject:myAnnotation];
        [arrayAnota addObject:myPos];
        
        [_mapView showAnnotations:arrayAnota animated:YES];
        
        CLLocation *destinyLocation = [[CLLocation alloc] initWithLatitude:[celda latitud] longitude:[celda longitud]];
        
        [self drawRouteBetweenUser:destinyLocation];

    }
    else{
        [_mapView addAnnotation:myAnnotation];
    }
    
    
    [_mapView selectAnnotation:myAnnotation animated:YES];
    
}

- (void) drawRouteBetweenUser:(CLLocation *)andFavorite{
    
  
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:usuarioLocation.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:andFavorite.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        //NSLog(@"response = %@",response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            MKPolyline *line = [rout polyline];
            [_mapView addOverlay:line];
            //NSLog(@"Rout Name : %@",rout.name);
            //NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            NSArray *steps = [rout steps];
            
            //NSLog(@"Total Steps : %d",[steps count]);
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                //NSLog(@"Rout Instruction : %@",[obj instructions]);
                //NSLog(@"Rout Distance : %f",[obj distance]);
            }];
        }];
    }];

    
}

// Funcion que añade un los marcadores con la info procedente de CityBike
- (void)setCityBike:(id)newCityBike{
    
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView removeOverlays:_mapView.overlays];
    
    __block NSArray *annotations;

    // TAREA ASINCRONA
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        annotations = [self parseJSONCities:newCityBike];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
           
            [_mapView addAnnotations:annotations];
            
            if([annotations count] > 0){
                [_mapView selectAnnotation:[annotations objectAtIndex:0]animated:YES];
                [_mapView showAnnotations:annotations animated:YES];
            }
            else{
                NSLog(@"No hay información");
            }      
            
        });
    });
    
    

}

// Funcion que inserta los objetos json en un array de annotations
- (NSMutableArray *)parseJSONCities: (NSArray*)puntosBikeArray{
    
    NSMutableArray *retval = [[NSMutableArray alloc]init];

    for(id classObjeto in puntosBikeArray){

        float nuevaLat = [[classObjeto objectForKey:@"lat"]floatValue]/1e6;
        float nuevaLong = [[classObjeto objectForKey:@"lng"]floatValue]/1e6;
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(nuevaLat, nuevaLong);
        myAnnotation.title = [classObjeto objectForKey:@"name"];
        [retval addObject:myAnnotation];
        
    }
    
    return retval;
}

// Funcion que localiza en el mapa una antigua maravilla con su marcador
- (void)setWonderAncient:(id)oldWonderWorld location:(CLLocation *)coordenates{
    
    CLLocationCoordinate2D theCoordinate = coordenates.coordinate;    
    
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = theCoordinate;
    myAnnotation.title = oldWonderWorld;
    
    [_mapView addAnnotation:myAnnotation];
    
    [_mapView selectAnnotation:myAnnotation animated:YES];
}

// Funcion que al mantener pulsado el mapa activa la insercion de un marcador
- (void)addGestureRecogniserToMapView{
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPinToMap:)];
                                          
    lpgr.minimumPressDuration = 0.8; //
    [self.mapView addGestureRecognizer:lpgr];
    
}
// Añade un marcador nuevo al mapa bajo demanda
- (void)addPinToMap:(UIGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *toAdd = [[MKPointAnnotation alloc]init];
    
    toAdd.coordinate = touchMapCoordinate;
    toAdd.title = @"New place";
    
    [_mapView addAnnotation:toAdd];
    [_mapView selectAnnotation:toAdd animated:YES];
   
    
}

// Funcion que recoge la llamada de agregar a favoritos
- (void)addItemViewController:(FavoritesTableViewController *)controller withNewEventName:(NSString *)eventName

{
    // vuelve de insertar el nuevo favorito en la BD
    //NSLog(@"OK? %@",eventName);
    // abre la lista de favoritos
    [self.tabBarController setSelectedIndex:1];
}

// Funcion que recoge la accion despues de mostrar la alerta para añadir un nuevo lugar
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
     //NSLog(@"Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    if (buttonIndex == 0){
        
        NSString *nombredelsitio = _textViewNombre.text;
        NSString *descripciondelsitio = _textViewDescripcion.text;
        FavoritesTableViewController *favoritos = [[FavoritesTableViewController alloc] init];
        
        [favoritos setDelegate:self];
       
        [favoritos addToFavorites:nombredelsitio descripcionFavorito:descripciondelsitio latitudFavorito:_latitudItemSelected longitudFavorito:_longitudItemSelected];      
        
    }else{
        
        NSLog(@"Action cancelled");
        
    }
    
    [alertView close];
    
}

// Metodo para crear una alerta personalizada para añadir infromacion
- (UIView *)createAlertView
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    UILabel *labelNombre = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, 80)];
    [labelNombre setText:@"Name"];
    _textViewNombre = [[UITextView alloc]initWithFrame:CGRectMake(20, 55, 250, 30)];

    //To make the border look very close to a UITextField
    [_textViewNombre.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_textViewNombre.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    _textViewNombre.layer.cornerRadius = 5;
    _textViewNombre.clipsToBounds = YES;
    
    _textViewNombre.text = _nombredelItem;
    
    UILabel *labelDescripcion = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 270, 80)];
    [labelDescripcion setText:@"Description"];
    _textViewDescripcion = [[UITextView alloc]initWithFrame:CGRectMake(20, 125, 250, 60)];
    //To make the border look very close to a UITextField
    [_textViewDescripcion.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_textViewDescripcion.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    _textViewDescripcion.layer.cornerRadius = 5;
    _textViewDescripcion.clipsToBounds = YES;
    
    [demoView addSubview:labelNombre];
    [demoView addSubview:_textViewNombre];
    [demoView addSubview:labelDescripcion];
    [demoView addSubview:_textViewDescripcion];
    
    return demoView;
}

@end
