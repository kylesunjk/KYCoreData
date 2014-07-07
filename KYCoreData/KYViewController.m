//
//  KYViewController.m
//  KYCoreData
//
//  Created by Sun Jiakang on 7/7/14.
//  Copyright (c) 2014 Massive_Infinity. All rights reserved.
//

#import "KYViewController.h"
#import "MICacheData.h"
#import "CDCache.h"
@interface KYViewController ()

@end

@implementation KYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadJobsTableView{
    CDCache *jobsCache = [[MICacheData singleton] dbLoad:[JT_StagingDomin stringByAppendingString:@"/get_jobs"]];
    
    if (!jobsCache) {
        [self requestForJobList];
    }
    else{
        double expire1 = (double)[[NSDate date] timeIntervalSince1970];
        double expire2 = [jobsCache.timestamp doubleValue];
        if (expire1-expire2 >60) {
            [self requestForJobList];
        }
        else{
            id one = [[jobsCache json] dataUsingEncoding:NSASCIIStringEncoding];
            [self refreashTableview:[self toArrayOrNSDictionary:one]];
        }
        
    }
}


- (void)requestForJobList{
    JTAppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    JTEmployeeObject *one = [app.loginUser.employee objectAtIndex:0];
    
    
    [JTApiManager getJobList:one.employee_id completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error){
        
        [self refreashTableview:response];
        NSData *jsondata = [self toJSONData:response];
        
        NSString *json = [[NSString alloc] initWithData:jsondata
                                               encoding:NSUTF8StringEncoding];
        [[MICacheData singleton] dbSave:[JT_StagingDomin stringByAppendingString:@"/get_jobs"] withContent:json];
        
        
    }];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"jobsCell";
    UITableViewCell *cell;
//    JTJobsTableViewCell* cell = [_jobsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[JTJobsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    JTJobsObject *jb = [[JTJobsObject alloc] init];
//    jb = [_jobsArray objectAtIndex:indexPath.row];
//    cell.jobsTitleLabel.text = jb.title;
//    
//    [cell.jobsTitleLabel setTextColor:COLOR_JT_LIGHT_BLUE];
//    cell.positionLabel.text = jb.position;
//    
//    [cell.positionLabel setTextColor:COLOR_JT_GREY];
//    
//    cell.salaryLabel.text = [NSString stringWithFormat:@"$%@/hr",jb.pay_rate];
//    
//    JTJobsDetail *jobDetail =[jb.jobs objectAtIndex:0];
//    
//    cell.locationLabel.text =jobDetail.location.address;
    
    return cell;
}


#pragma mark - data exchange

- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

- (id)toArrayOrNSDictionary:(NSData *)jsonData{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}

@end
