//
//  BNRCoursesViewController.m
//  NerdFeed
//
//  Created by Archer on 8/14/14.
//  Copyright (c) 2014 Oodalalee. All rights reserved.
//

#import "BNRCoursesViewController.h"
#import "BNRWebViewController.h"

@interface BNRCoursesViewController () <NSURLSessionDataDelegate>

//Holds onto instance of NSURLSession
@property (nonatomic)NSURLSession *session;
//Hangs onto Courses array
@property (nonatomic, copy) NSArray *courses;

@end

@implementation BNRCoursesViewController

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *course = self.courses[indexPath.row];
    NSURL *URL = [NSURL URLWithString:course[@"url"]];
    
    self.webViewController.title = course[@"title"];
    self.webViewController.URL = URL;
    
    //Check for slit view controller before pushing BNRWEbViewController onto nav stack
    if (!self.splitViewController) {
    [self.navigationController pushViewController:self.webViewController animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.courses count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSDictionary *course = self.courses[indexPath.row];
    cell.textLabel.text = course[@"title"];
    
    return cell;
}

//Creates NSURLRequest that connects to bookapi.bignerdranch.com to ask for list of courses.

- (void)fetchFeed
{
    //implement authentication string
    NSString *requestString = @"https://bookapi.bignerdranch.com/private/courses.json";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    //transfers request to server
    NSURLSessionDataTask *dataTask =
    [self.session dataTaskWithRequest:req completionHandler:
        ^(NSData *data, NSURLResponse *response, NSError *error) {
        //Uses NSJSONSerialization class to convert raw JSON data into foundation objects.
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        self.courses = jsonObject[@"courses"];
        
        NSLog(@"%@", self.courses);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        
        }];
    [dataTask resume];
}

- (instancetype) initWithStyle:(UITableViewStyle)style
{
    //NSURLSession is created with a configuration, a delegate, and a delegate queue.
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"BNR Courses";
        
        NSURLSessionConfiguration *config =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        //_session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        
        //Session object can now be used to create tasks, return instance of NSURLSessionTask
        [self fetchFeed];
    }
    return self;
}

//Implement delegate method to handle authentication challenge
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    NSURLCredential *cred =
        [NSURLCredential credentialWithUser:@"BigNerdRanch"
                                   password:@"AchieveNerdvana"
                                persistence:NSURLCredentialPersistenceForSession];
    completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
}


@end
