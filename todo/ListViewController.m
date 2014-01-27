//
//  ListViewController.m
//  todo
//
//  Created by Jenny Kwan on 1/25/14.
//  Copyright (c) 2014 Jenny Kwan. All rights reserved.
//

#import "ListViewController.h"
#import "EditableCell.h"

@interface ListViewController (){
    UITapGestureRecognizer *tapRecognizer;
}

@property (nonatomic, strong) NSMutableArray *todoList;
@property (nonatomic, strong) NSMutableArray *heights;

@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

- (IBAction)clearText:(id)sender;
- (IBAction)onTap:(id)sender;

- (void)onEditButton;
- (void)onDoneButton;
- (void)onNewButton;

- (void)doneEditing;
- (void)saveData;

@end

@implementation ListViewController

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
	// Do any additional setup after loading the view.
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.tableView addGestureRecognizer:tapRecognizer];
    
    self.title = @"To Do List";
    // self.heights = [[NSMutableArray alloc] initWithObjects:@"33", nil];
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButton)];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton)];
    
    self.navigationItem.leftBarButtonItem = self.editButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onNewButton)];
    
    // Don't show lines below available cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Load data from NSUserDefaults or initialize if empty
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *todoArray = [defaults arrayForKey:@"todoList"];
    NSArray *heights = [defaults arrayForKey:@"heights"];
    if (todoArray.count == 0) {
        todoArray = @[@""];
        heights = @[@"33"];
    }
    self.todoList = [NSMutableArray arrayWithArray:todoArray];
    self.heights = [NSMutableArray arrayWithArray:heights];
    
    // Debug printout
    for (int i = 0; i < self.todoList.count; i++) {
        NSLog(@"TODO LIST: %@", self.todoList[i]);
    }
    
    [self saveData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Table view methods
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.todoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditableCell *cell= (EditableCell *)[tableView dequeueReusableCellWithIdentifier:@"EditableCell"];
    
    // Set textView
    if ([self.todoList[indexPath.row] isEqualToString:@""]) {
        cell.todoTextView.textColor = [UIColor lightGrayColor];
        cell.todoTextView.text = @"Add a todo item";
    } else {
        cell.todoTextView.textColor = [UIColor blackColor];
        cell.todoTextView.text = self.todoList[indexPath.row];
    }
    
    // One method of knowing which row in a TextFieldDelegate function would
    // be to use tags. But then I'd need to keep track of the tags as well, so
    // keeping the weird superview.superview.superview for now
    //cell.todoTextView.tag = [NSString stringWithFormat:@"%d", indexPath.row];
    
    cell.todoTextView.delegate = self;
    
    // Format clear button
    cell.clearButton.hidden = YES;
    [cell.clearButton.layer setBorderWidth:1.0f];
    [cell.clearButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    cell.clearButton.layer.cornerRadius = 7.5f;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Make everything editable except for the last entry
    if (indexPath.row == self.todoList.count-1)
        return NO;
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Make everything movable except for the last entry
    if (indexPath.row == self.todoList.count-1)
        return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // Debug printout
    NSLog(@"Re-ordering rows %d and %d", sourceIndexPath.row, destinationIndexPath.row);
    
    NSString *stringToMove = [self.heights objectAtIndex:sourceIndexPath.row];
    [self.heights removeObjectAtIndex:sourceIndexPath.row];
    [self.heights insertObject:stringToMove atIndex:destinationIndexPath.row];
    
    stringToMove = [self.todoList objectAtIndex:sourceIndexPath.row];
    [self.todoList removeObjectAtIndex:sourceIndexPath.row];
    [self.todoList insertObject:stringToMove atIndex:destinationIndexPath.row];
    
    [self saveData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.todoList removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    [self.heights removeObjectAtIndex:indexPath.row];
    [self saveData];
 
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    if (indexPath.row < self.heights.count)
        height = [self.heights[indexPath.row] floatValue];
    else
        NSLog(@"ERROR: Tried to access height at undefined index %d", indexPath.row);
    
    if (height > 44.0)
        return height + 4.0;
    return 44.0;
}

# pragma mark - Gesture recognizer method
- (IBAction)clearText:(id)sender {
    UITextView *s = (UITextView *)sender;
    UITableViewCell *editableCell = (UITableViewCell *)(s.superview.superview.superview);
    int currentRow = [self.tableView indexPathForCell:editableCell].row;
    
    [self.tableView beginUpdates];
    self.todoList[currentRow] = @"";
    self.heights[currentRow] = @"33";
    ((EditableCell *)editableCell).todoTextView.text = @""; // Why do I have to do this too?
    [self.tableView endUpdates];

    [self saveData];
}

- (IBAction)onTap:(id)sender {
    [self doneEditing];
}

# pragma mark - Text view methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self doneEditing];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UITableViewCell *cell = (UITableViewCell *)textView.superview.superview.superview; // Why 3 levels?
    int currentRow = [self.tableView indexPathForCell:cell].row;
    EditableCell *editableCell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:0]];
    editableCell.clearButton.hidden = NO;

    textView.textColor = [UIColor blackColor];
    if ([textView.text isEqualToString:@"Add a todo item"])
        textView.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    UITableViewCell *cell = (UITableViewCell *)textView.superview.superview.superview; // Why 3 levels?
    int currentRow = [self.tableView indexPathForCell:cell].row;
    EditableCell *editableCell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:0]];
    editableCell.clearButton.hidden = YES;
    
    NSString *heightToAdd = [NSString stringWithFormat:@"%f",textView.contentSize.height];
    
    self.todoList[currentRow] = textView.text;
    self.heights[currentRow] = heightToAdd;
    [self saveData];
}

# pragma mark - Private utility methods
- (void)doneEditing {
    // Dismiss keyboard
    [self.view endEditing:YES];
    
    // If the last table element added is non-empty, increment number of todo items
    // This is so user can select next textfield to input data
    NSString *lastItem = self.todoList[self.todoList.count-1];
    if (lastItem.length > 0) {
        [self.todoList addObject:@""];
        [self.heights addObject:@"33"];
        [self saveData];
    }
        
    // Debug print statements
//    for (int i = 0; i < [self.heights count]; i++)
//       NSLog(@"Height[%d] = %@", i, self.heights[i]);
    
    // Reload table
    [self.tableView reloadData];
}

- (void)saveData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.todoList forKey:@"todoList"];
    [defaults setObject:self.heights forKey:@"heights"];
    [defaults synchronize];
}

# pragma mark - Actions on button presses
- (void)onEditButton {
    [self.tableView removeGestureRecognizer:tapRecognizer];
    [self doneEditing];
    
    [self.tableView setEditing:YES animated:YES];
    [self.tableView reloadData];
    self.navigationItem.leftBarButtonItem = self.doneButton;
    
}

- (void)onDoneButton {
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = self.editButton;
    [self.tableView addGestureRecognizer:tapRecognizer];
}

- (void)onNewButton {
    [self.todoList insertObject:@"" atIndex:0];
    [self.heights insertObject:@"33" atIndex:0];
    [self saveData];

    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    
    // Auto-select inserted cell
    EditableCell *cell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.todoTextView becomeFirstResponder];
    
}

@end
