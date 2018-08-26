//
//  NotesViewController.m
//  CiklumFirebaseTest
//
//  Created by Artem Shvets on 24.08.2018.
//  Copyright © 2018 Artem Shvets. All rights reserved.
//

#import "NotesViewController.h"
#import "NotesTableViewCell.h"
#import "Note.h"
#import "NSDateFormatter+ASDateFormatter.h"
#import "AppDelegate.h"

#import <Firebase/Firebase.h>
#import <FIRDatabase.h>

#define WAITING_DURATION 10.f

@interface NotesViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) FIRDatabaseReference* notesDataRef;
@property (nonatomic, strong) NSMutableArray<Note*>* notesArray;
@property (nonatomic, strong) NSFetchedResultsController<NoteObject *> *fetchedResultsController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@end

@implementation NotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.notesArray = [NSMutableArray new];
    [self loadLocalData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.notesDataRef removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Getters

- (FIRDatabaseReference*)notesDataRef{
    return [[FIRDatabase database] referenceWithPath:@"note-items"];
}

- (NSManagedObjectContext *)managedObjectContext{
    return [AppDelegate sharedInstance].persistentContainer.viewContext;
}

#pragma mark - Actions

- (void)loadLocalData{
    NSMutableArray* notes = [NSMutableArray new];
    for (NoteObject* noteManagedObject in self.fetchedResultsController.fetchedObjects) {
        Note* note = [[Note alloc] initWithNoteObject:noteManagedObject];
        [notes insertObject:note atIndex:0];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    [notes sortUsingDescriptors:@[sortDescriptor]];
    self.notesArray = notes;
    [self.tableView reloadData];
}

- (void)addObservers{
    
    __weak typeof(self)weakSelf = self;
    
    [[self.notesDataRef queryOrderedByKey] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [weakSelf fireDataDidChangeItem:snapshot];
    }];
    
    [[self.notesDataRef queryOrderedByKey] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [weakSelf fireDataDidChangeItem:snapshot];
    }];
    
    [[self.notesDataRef queryOrderedByKey] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [weakSelf fireDataDidRemoveIem:snapshot];
    }];
}

- (IBAction)addNoteDidTapped:(id)sender {
    
    __weak typeof(self)weakSelf = self;
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Add Note" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* addAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField* textField = alertController.textFields.firstObject;
        if(!textField.text.length)
            return;
        
        NSString* text = textField.text;
        Note* note = [[Note alloc] initWithText:text creatDate:[NSDate date]];
        FIRDatabaseReference* reference = [weakSelf.notesDataRef childByAutoId];
        
        [reference setValue:[note fireModel] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            NSLog(@"ERROR: %@",error.localizedDescription);
        }];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:addAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSInteger)indexOfNoteForKey:(NSString*)key{
    NSInteger index = NSNotFound;
    for(Note* note in self.notesArray){
        if([note.noteID isEqualToString:key]){
            index = [self.notesArray indexOfObject:note];
            break;
        }
    }
    return index;
}

#pragma mark - Timers

- (void)shouldReloadItem:(NSTimer*)timer{
    if(!timer.userInfo)
        return;
    
    NSString* noteID = timer.userInfo;
    for(Note* note in self.notesArray){
        if([note.noteID isEqualToString:noteID]){
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.notesArray indexOfObject:note] inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
    
    [NSTimer scheduledTimerWithTimeInterval:WAITING_DURATION
                                     target:self
                                   selector:@selector(shouldSaveItem:)
                                   userInfo:noteID
                                    repeats:NO];
}

- (void)shouldSaveItem:(NSTimer*)timer{
    if(!timer.userInfo)
        return;
    
    NSString* noteID = timer.userInfo;
    for(Note* note in self.notesArray){
        if([note.noteID isEqualToString:noteID]){
            [self insertNoteToDB:note];
            break;
        }
    }
}

- (void)insertNoteToDB:(Note*)note {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NoteObject *noteObj = [[NoteObject alloc] initWithContext:context];
    
    noteObj.createDate = note.createDate;
    noteObj.text = note.text;
    noteObj.noteID = note.noteID;
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    }
}

#pragma mark - Firebase Data Events

- (void)fireDataDidChangeItem:(FIRDataSnapshot*)snapshot{
    
    Note* note = [[Note alloc] initWithSnapshot:snapshot];
    NSInteger index = [self indexOfNoteForKey:snapshot.key];
    
    if(index != NSNotFound){
        
        if([self.notesArray[index].noteID isEqualToString:note.noteID] && self.notesArray[index].isSaved)
            return;
        
        [self.notesArray replaceObjectAtIndex:index withObject:note];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        note.receivingDateInterval = [[NSDate date] timeIntervalSinceReferenceDate];
        [self.notesArray insertObject:note atIndex:0];
        [NSTimer scheduledTimerWithTimeInterval:WAITING_DURATION
                                         target:self
                                       selector:@selector(shouldReloadItem:)
                                       userInfo:note.noteID
                                        repeats:NO];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)fireDataDidRemoveIem:(FIRDataSnapshot*)snapshot{
    NSInteger index = [self indexOfNoteForKey:snapshot.key];
    if(index != NSNotFound){
        [self.notesArray removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotesTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NotesTableViewCell class]) forIndexPath:indexPath];
    
    Note* note = self.notesArray[indexPath.row];
    cell.noteLabel.text = note.text;
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
    
    if(note.isSaved){
        cell.noteLabel.textColor = [UIColor greenColor];
    }else if((currentTimeInterval - note.receivingDateInterval) < WAITING_DURATION){
        cell.noteLabel.textColor = [UIColor redColor];
    }else{
        cell.noteLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notesArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController<NoteObject *> *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest<NoteObject *> *fetchRequest = NoteObject.fetchRequest;
    [fetchRequest setFetchBatchSize:0];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSFetchedResultsController<NoteObject *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(NoteObject*)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
        case NSFetchedResultsChangeUpdate:
        {
            NSInteger index = [self indexOfNoteForKey:anObject.noteID];
            if(index != NSNotFound){
                Note* note = self.notesArray[index];
                note.saved = YES;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView reloadData];
        }
            
            break;
        default:
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
}

@end
