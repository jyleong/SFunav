//
//  CoursesTableViewController.m
//  SFUnavapp
//
//  Created by Arjun Rathee on 2015-04-01.
//  Copyright (c) 2015 Team NoMacs. All rights reserved.
//

#import "CoursesTableViewController.h"
#import "ServicesTableViewController.h"
#import "Course.h"
#import "TFHpple.h"
#import "Reachability.h"
#import "CourseDisplayTableViewCell.h"
#import "CourseDetailViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
#define baseURL [NSString stringWithFormat:@"http://www.sfu.ca/bin/wcm/course-outlines?year=current&term=current"]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green: ((float)((rgbValue & 0xFF00) >> 8))/255.0 blue: ((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CoursesTableViewController ()
{
    NSMutableArray *courseCollection;
    int flag;
    NSInteger indexNumber;
}
@end

@implementation CoursesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(void) viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    flag=0;
    if (autoLogin!=YES)
        [self notlogin];
    else
        [self genCourses];
}

-(void) reloadtable
{
    [self.tableView reloadData];
}
#pragma mark - Course Parsing
-(void) notlogin{
    if (flag!=1)
    {
        UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:@"Not Logged In" message:@"Login is required to see your current courses. You can browse all courses without login" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Browse", @"Login",nil];
        [Alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqual:@"No Internet"])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if (buttonIndex==1)
        [self performSegueWithIdentifier:@"BrowseCourse" sender:self];
    if (buttonIndex==2)
        [self performSegueWithIdentifier:@"LogIn" sender:self];
}

//Function Call to initiate new object and start course parsing
-(void) genCourses{
    if ([self checkInternet])
    {
         [courseCollection removeAllObjects];
        courseCollection=[[NSMutableArray alloc]init];
        dispatch_async(kBgQueue, ^{
            [self parseCanvas];
            [self parseCoursys];
            [self performSelectorOnMainThread:@selector(reloadtable) withObject:nil waitUntilDone:YES];
        });
    }
    else{
        UIAlertView *NoIntAlert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:@"Internet Connection is required. Reconnect and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [NoIntAlert show];
        flag=1;
    }
}

//Generates courses from canvas
-(void) parseCanvas{
    NSData *result = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://canvas.sfu.ca/courses"]];
    TFHpple *xpath = [[TFHpple alloc] initWithHTMLData:result];
    Course *temp;
    NSArray *data = [xpath searchWithXPathQuery:@"//*[@id='my_courses_table']/tr/td/a/span/@title"];
    if (data==nil)
        return;
    for (int i=0; i<[data count]; i++)
    {
        temp=[[Course alloc]init];
        NSString *tempStr;
        int numberIndex=-1;
        TFHppleElement *item = data[i];
        NSLog(@"Content %@",item.content);
        if ([item.content length]>13 )
            tempStr=[[item.content substringFromIndex:[item.content length]-13] lowercaseString];
        tempStr=[tempStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([tempStr length]>4)
            temp.section=[tempStr substringFromIndex:[tempStr length]-4];
        tempStr=[tempStr stringByReplacingOccurrencesOfString:temp.section withString:@""];
        if ([tempStr characterAtIndex:[tempStr length]-1]=='w')
        {
            
        }
        
        for (int j=0; j<[tempStr length]&&numberIndex==-1;j++)
        {
            if(isdigit([tempStr characterAtIndex:j]))
            {
                numberIndex=j;
            }
        }
        if (numberIndex<[tempStr length])
        {    temp.number=[tempStr substringFromIndex:numberIndex];
            temp.dept=[tempStr substringToIndex:numberIndex];
        }
        NSLog(@"Temp dept:%@, number:%@ section:%@",temp.dept, temp.number, temp.section);
        temp.location=YES;
        [self genCourseInfo:temp];
        
        temp.days=[temp.days lowercaseString];
        temp.campus=[temp.campus lowercaseString];
        if ([temp.dept isEqualToString:@"(null)"] || temp.dept==nil)
        {
            return;
        }
        [courseCollection addObject:temp];
    
    }

}
//Generates courses from Coursys
-(void) parseCoursys{

    NSData *result = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://courses.cs.sfu.ca"]];
    TFHpple *xpath = [[TFHpple alloc] initWithHTMLData:result];
    Course *temp;
    NSArray *data = [xpath searchWithXPathQuery:@"//*[@id='page-content']/section/div[2]/ul[1]/li"];
    if (data==nil)
        return;
    for (int i=0; i<[data count]; i++)
    {
        temp=[[Course alloc]init];
        TFHppleElement *item = data[i];
        NSLog(@"Content %@",item.content);
        NSMutableArray *array = (NSMutableArray *)[[item.content lowercaseString] componentsSeparatedByString:@" "];
        [array removeObject:@""];
        temp.section=array[2];
        if ([temp.section length]==2)
            temp.section=[temp.section stringByAppendingString:@"00"];
        temp.number=array[1];
        temp.dept=array[0];
        NSLog(@"Temp dept:%@, number:%@ section:%@",array[0], array[1], array[2]);
        temp.location=YES;
        [self genCourseInfo:temp];
        temp.days=[temp.days lowercaseString];
        temp.campus=[temp.campus lowercaseString];
        [courseCollection addObject:temp];
    }
}

// Generates course info from api reults
-(void) genCourseInfo:(Course *)temp
{
        NSString *apiURL=[NSString stringWithFormat:
                         @"%@"
                         @"&dept=%@"
                         @"&number=%@"
                         @"&section=%@",baseURL,temp.dept,temp.number,temp.section
                         ];
        apiURL=[apiURL lowercaseString];
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:apiURL ]];
        NSLog(@"info url:%@",apiURL);
        if (data==nil)
            return;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data //1
                              
                              options:kNilOptions
                              error:&error];
        
        NSArray *info=[json objectForKey:@"courseSchedule"];
        
        temp.days=@"";
        temp.campus=@"";
        for (int i=0;i<[info count];i++)
        {
            temp.days=[temp.days stringByAppendingString:[info[i] objectForKey:@"days"]];
            temp.campus=[temp.campus stringByAppendingString:[info[i] objectForKey:@"campus"]];
        }

}
-(BOOL) checkInternet
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        return NO;
    }
    NSLog(@"There IS internet connection");
    return  YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [courseCollection count];
}

//Show cell details depending on Parsing results
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CourseDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"courseDisplayCell" forIndexPath:indexPath];

    cell.layer.cornerRadius = 10;
    [cell.layer setMasksToBounds:YES];
    //[cell.layer setBorderWidth:1];
    
    Course *temp=[courseCollection objectAtIndex:indexPath.row];
    cell.courseName.text=[[NSString stringWithFormat:
                     @"%@ "
                     @"%@ "
                     @"%@ ", temp.dept, temp.number, temp.section
                     ]uppercaseString];
    if ([temp.days rangeOfString:@"mo"].location == NSNotFound) {
        cell.mondayButton.hidden=YES;
    }
    else
    {
        cell.mondayButton.hidden=NO;
    }
    if ([temp.days rangeOfString:@"tu"].location == NSNotFound) {
        cell.tuesdayButton.hidden=YES;
    }
    else
    {
        cell.tuesdayButton.hidden=NO;
    }
    if ([temp.days rangeOfString:@"we"].location == NSNotFound) {
        cell.wednesdayButton.hidden=YES;
    }
    else
    {
        cell.wednesdayButton.hidden=NO;
    }
    
    if ([temp.days rangeOfString:@"th"].location == NSNotFound) {
        cell.thursdayButton.hidden=YES;
    }
    else
    {
        cell.thursdayButton.hidden=NO;
    }
    if ([temp.days rangeOfString:@"fr"].location == NSNotFound) {
        cell.fridayButton.hidden=YES;
    }
    else
    {
        cell.fridayButton.hidden=NO;
    }
    
    int campusFound=0;
    if ([temp.campus rangeOfString:@"burnaby"].location != NSNotFound) {
        cell.campusLocation.text=@"Burnaby";
        campusFound++;
    }
    if ([temp.campus rangeOfString:@"surrey"].location != NSNotFound) {
        cell.campusLocation.text=@"Surrey";
        campusFound++;
    }
    if ([temp.campus rangeOfString:@"vancouver"].location != NSNotFound) {
        cell.campusLocation.text=@"Vancouver";
        campusFound++;
    }
    if (campusFound>1)
    {
        cell.campusLocation.text=@"Multiple";
    }
    
    return cell;
}


#pragma mark - Navigation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexNumber=indexPath.row;
    [self performSegueWithIdentifier:@"showDetails" sender:self];
    
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqual:@"BrowseCourse"])
    {
    
    }
    else if([[segue identifier] isEqualToString:@"Login"])
    {
        //request login to access canvas and coursys courses
    }
    else if ([[segue identifier] isEqualToString:@"showDetails"])
    {
        CourseDetailViewController *fivc=[segue destinationViewController];
        Course *temp=[courseCollection objectAtIndex:indexNumber];
        fivc.courseTerm=@"current";
        fivc.courseDept=[temp.dept lowercaseString];
        fivc.courseNumber=[temp.number lowercaseString];
        fivc.courseSection=[temp.section lowercaseString];
        fivc.hidesBottomBarWhenPushed=YES;
    }
}


@end
