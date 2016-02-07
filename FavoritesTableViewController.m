//
//  FavoritesTableViewController.m
//  Maps
//
//  Created by Jose Manuel Gil on 04/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import <CoreData/CoreData.h>
#import "ViewController.h"

@interface FavoritesTableViewController (){
    NSArray *_consultaBD;
    NSMutableArray *_resultado;
    
    // Para el manejo de la BD local //
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator  *_persistentStoreCoordinator;
    NSManagedObjectContext *_managedObjectContext;
}

@end

@implementation FavoritesTableViewController



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
    
    [self recuperarListaFavoritos];
    
    // Añade un margen superior para que la status bar no se solape con el contenido de la tabla
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    [self.tableView reloadData];    
    [self addGestureRecogniserToTableView];
    [self addSwipeGesture];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Funcion que añade el reconocimiento del gesto longpress
- (void)addGestureRecogniserToTableView{
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(deleteRowFromTable:)];
    lpgr.minimumPressDuration = 0.8; //
    [self.tableView addGestureRecognizer:lpgr];
    
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

// Refresca la lista si aperece el interfaz de la tabla
-(void) viewWillAppear:(BOOL)animated{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Celda" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
  
    _consultaBD = [_managedObjectContext executeFetchRequest:request error:nil];
    _resultado = [[NSMutableArray alloc] initWithArray:_consultaBD];
    
    [self.tableView reloadData];
}
// Funcion que inicializa los objetos que permiten realizar la consulta y modificacion de la BD
- (void) prepareQuery{
    
    NSError *error;
    NSURL *modelURL = [[NSBundle mainBundle]URLForResource:@"Favorito" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    NSURL *storeURL = [[self applicationDocumentsDirectory]URLByAppendingPathComponent:@"FavoritesDataBase.sqlite"];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    _managedObjectContext = [[NSManagedObjectContext alloc]init];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
}
// Método que recupera la lista de favoritos
- (NSArray*) recuperarListaFavoritos {
    
    [self prepareQuery];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Celda" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    // Recupera en un array los datos almacenados en la BD
    if (!_resultado) {
        
        _consultaBD = [_managedObjectContext executeFetchRequest:request error:nil];
        _resultado = [[NSMutableArray alloc] initWithArray:_consultaBD];
        
    }
    
    return _consultaBD;
}

// Funcion que añade un nuevo lugar a favoritos. Esta funcion se llama desde el ViewController del mapa
- (void)addToFavorites:(NSString *)nombreFavorito descripcionFavorito:(NSString*)descripcion latitudFavorito:(float)latitud longitudFavorito:(float)longitud{
    
    [self prepareQuery];
    
    NSError *error;
    Celda *celda;
    
    celda = (Celda *) [NSEntityDescription insertNewObjectForEntityForName:@"Celda" inManagedObjectContext:_managedObjectContext];
    
    [celda setNombre:nombreFavorito];
    [celda setDescripcion:descripcion];
    [celda setLatitud:latitud];
    [celda setLongitud:longitud];
    if (![_managedObjectContext save:&error]){
        NSLog(@"Error en la inserción: %@, %@", error, [error userInfo]);
    }
    
    [_delegate addItemViewController:self withNewEventName:@"OK"];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_resultado count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath{

    UITableViewCell *cell = [[UITableViewCell alloc]  initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                            
    cell.textLabel.text = [_resultado[indexPath.row] nombre];
    cell.detailTextLabel.text = [_resultado[indexPath.row] descripcion];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Celda *celda;
        celda = (Celda *)[_resultado objectAtIndex:indexPath.row];
        [_managedObjectContext deleteObject:celda];
        NSError *error;
        if (![_managedObjectContext save:&error]){
            NSLog(@"Error en el borrado: %@, %@", error, [error userInfo]);
        }
        
        [_resultado removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self playerDetailsViewControllerDidSave:self];
       
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
    
   
}

// Funcion que se llama cuando se detecta un long press y permite borrar elementos de la lista
- (void)deleteRowFromTable:(UIGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    UITableView *table = (UITableView *)self.tableView;
    UITableViewController *control = (UITableViewController *)table.dataSource;
    
    // SI pasados 4 segundos no elimina
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(playerDetailsViewControllerDidSave:) userInfo:nil repeats:NO];
    [control setEditing:YES animated:YES];
    
    
}
// Funcion que al pulsar sobre un elemento de la lista lo muestra en el mapa
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ViewController *myVC1ref = ( ViewController *)[self.tabBarController.viewControllers objectAtIndex:0];
    Celda *object = _resultado[indexPath.row];
    [myVC1ref setDetailItem:object];
    [self.tabBarController setSelectedIndex:0];
    
}
// Funcion que desactiva el modo edicion en favoritos
- (void)playerDetailsViewControllerDidSave:(FavoritesTableViewController *)controller
{
    
    UITableView *table = (UITableView *)self.tableView;
    UITableViewController *control = (UITableViewController *)table.dataSource;

    [control setEditing:NO animated:YES];
  
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
