//
//  SocialTableViewController.m
//  SFUnavapp
//  Team NoMacs
//
//  Created by James Leong on 2015-03-30.
//  Copyright (c) 2015 Team NoMacs. All rights reserved.
//

#import "SocialTableViewController.h"
#import "SocialTableViewCell.h"

@interface SocialTableViewController ()

@property (strong,nonatomic)NSArray *socialArray;
@property (nonatomic, strong) NSArray *searchResult; //mutable array that holds results STRINGS
@property (strong, nonatomic) NSDictionary *socialLink;

@end

@implementation SocialTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    // take from plist
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Social" ofType:@"plist"];
    _socialArray = [NSArray arrayWithContentsOfFile:path];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.title = @"Social";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 90;
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResult count];
    }
    else {

        return _socialArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // makes cell from actual self.table
    static NSString *CellIdentifier=@"socialCell";
    SocialTableViewCell *cell =
    (SocialTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.layer.cornerRadius = 10;
    
    [cell.layer setMasksToBounds:YES];
    //[cell.layer setBorderWidth:1];
    
    if (cell == nil) {
        cell = [[SocialTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //checks for which array
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        _socialLink = [_searchResult objectAtIndex:indexPath.row];
        NSLog(@"%@", _socialLink[@"Name"]);
    } else {
        _socialLink = [_socialArray objectAtIndex:indexPath.row];
    }
    
    // to hold the one dicionary
    //_socialLink = _socialArray[indexPath.row];
    NSString *name = _socialLink[@"Name"];
    //NSLog(@"%@", name);
    NSString *fb = _socialLink[@"Facebook"];
    NSString *tw = _socialLink[@"Twitter"];
    NSString *yt = _socialLink[@"Youtube"];
    
    cell.titleLabel.text = name;
    
    //hides those buttons if those services dont have those social pages
    if ([fb isEqualToString:@"NODATA"]) { cell.fbButton.hidden = YES;}
    else {cell.fbButton.hidden = NO;}
    if ([tw isEqualToString:@"NODATA"]) { cell.twButton.hidden = YES;}
    else {cell.twButton.hidden = NO;}
    if ([yt isEqualToString:@"NODATA"]) { cell.ytButton.hidden = YES;}
    else {cell.ytButton.hidden = NO;}
    
    // method calls for which button pressed
    // these methods will open to safari, not in app browser
    [cell.fbButton addTarget:self action:@selector(fbButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.twButton addTarget:self action:@selector(twButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.ytButton addTarget:self action:@selector(ytButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    // Configure the cell...
    
    return cell;
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"Name contains[cd] %@", searchText];
    _searchResult = [_socialArray filteredArrayUsingPredicate:resultPredicate];
    //NSLog(@"%@", _searchResult);
}
// method to update teh table as you type
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


-(IBAction) fbButtonPressed:(UIButton *)sender{
    int selectedRow = (int)[sender tag];
    _socialLink = _socialArray[selectedRow];
    NSURL * soc = [NSURL URLWithString:_socialLink[@"Facebook"]];
    [[UIApplication sharedApplication] openURL:soc];
}

-(IBAction) twButtonPressed:(UIButton *)sender{
    int selectedRow = (int)[sender tag];
    _socialLink = _socialArray[selectedRow];
    NSURL * soc = [NSURL URLWithString:_socialLink[@"Twitter"]];
    [[UIApplication sharedApplication] openURL:soc];
}

-(IBAction) ytButtonPressed:(UIButton *)sender{
    int selectedRow = (int)[sender tag];
    _socialLink = _socialArray[selectedRow];
    NSURL * soc = [NSURL URLWithString:_socialLink[@"Youtube"]];
    [[UIApplication sharedApplication] openURL:soc];
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
