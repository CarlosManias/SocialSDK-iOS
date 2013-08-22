/*
 * © Copyright IBM Corp. 2013
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

//  This class is a way to set up things for the purpose of demo.

#import "IBMAcmeSettingsView.h"
#import "IBMAcmeConstant.h"
#import "IBMAcmeUtils.h"
#import "IBMCredentialStore.h"
#import "IBMAcmeFlight.h"
#import "IBMConnectionsCommunityService.h"
#import "IBMConnectionsFileService.h"
#import "FBLog.h"

@interface IBMAcmeSettingsView ()

@end

@implementation IBMAcmeSettingsView

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

    self.title = @"Settings";
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:90.0/255
                                                                        green:91.0/255
                                                                         blue:71.0/255
                                                                        alpha:1];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 2;
    else if (section == 1)
        return 1;
    else
        return 1;
}

- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section
{
    if (section == 0 || section == 1) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            return 50;
        else
            return 40;
    }
    else
        return 10;
}


- (UIView *) tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        // Title label
        
        CGRect viewFrame;
        float textSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textSize = TEXT_SIZE_IPAD;
            viewFrame = CGRectMake(0, 0, WIDTH_FOR_IPAD-2*MARGIN_FOR_IPAD_GROUPED_TABLEVIEW, 50);
        } else {
            textSize = TEXT_SIZE_SMALL - 1;
            viewFrame = CGRectMake(0, 0, WIDTH_FOR_IPHONE-2*MARGIN_FOR_IPHONE_GROUPED_TABLEVIEW, 40);
        }
        
        UIView *view = [[UIView alloc] initWithFrame:viewFrame];
        
        CGRect labelFrame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            labelFrame = CGRectMake(MARGIN_FOR_IPAD_GROUPED_TABLEVIEW, 10, 400, 40);
        } else {
            labelFrame = CGRectMake(MARGIN_FOR_IPHONE_GROUPED_TABLEVIEW, 10, 280, 30);
        }
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.font = [UIFont fontWithName:TEXT_FONT size:textSize];
        label.textColor = [UIColor colorWithRed:245.0/255
                                          green:245.0/255
                                           blue:245.0/255
                                          alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.adjustsFontSizeToFitWidth = YES;
        label.numberOfLines = 0;
        if (section == 0)
            label.text = @"Here you can create/remove test community";
        else if (section == 1)
            label.text = @"Here you can upload log file to Connections";
        
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        
        return view;
    } else {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        return view;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        float textSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textSize = TEXT_SIZE_IPAD;
        } else {
            textSize = TEXT_SIZE_SMALL;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:textSize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
            cell.textLabel.text = @"Create Test Community for Flight 101";
        else if (indexPath.row == 1)
            cell.textLabel.text = @"Remove Test Community for Flight 101";
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"Upload log file";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // Create a community
            NSString *key = @"101";
            UIAlertView *progressView = [IBMAcmeUtils showProgressBar];
            IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
            IBMConnectionsCommunity *comm = [[IBMConnectionsCommunity alloc] init];
            comm.title = [NSString stringWithFormat:@"Flight %@ Community %f", key, [[NSDate date] timeIntervalSince1970]];
            comm.content = [NSString stringWithFormat:@"This community is created to enable discussion on flight %@. Here you can share about preparation and purpose for the trip.", key];
            comm.communityType = @"public";
            [comService createCommunity:comm success:^(IBMConnectionsCommunity *commmunity) {
                [IBMCredentialStore storeWithKey:key value:commmunity.communityUuid];
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Community is successfully created for flight 101" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            } failure:^(NSError *error) {
                if (IS_DEBUGGING)
                    [FBLog log:[error description] from:self];
                
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Community 101 can not be created." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }];
        } else if (indexPath.row == 1) {
            // Remove the community
            NSString *key = @"101";
            UIAlertView *progressView = [IBMAcmeUtils showProgressBar];
            IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
            IBMConnectionsCommunity *comm = [[IBMConnectionsCommunity alloc] init];
            comm.communityUuid = [IBMCredentialStore loadWithKey:key];
            [comService deleteCommunity:comm success:^(BOOL success) {
                [IBMCredentialStore removeWithKey:key];
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Community 101 is successfully removed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            } failure:^(NSError *error) {
                if (IS_DEBUGGING)
                    [FBLog log:[error description] from:self];
                
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Community 101 can not be deleted" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }];
        }
    } else if (indexPath.section == 1) {
        // Upload log files to Connections File
        UIAlertView *progressView = [IBMAcmeUtils showProgressBar];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"fb_log"];
        NSData *content = [NSData dataWithContentsOfFile:filePath];
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] initWithEndPointName:@"connections"];
        [fS uploadMultiPartFileWithContent:content
                                  fileName:[NSString stringWithFormat:@"%@.png", [[NSDate date] description]]
                                  mimeType:@"text/plain"
                                   success:^(id result) {
                                       [progressView dismissWithClickedButtonIndex:100 animated:YES];
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"File named fb_log uploaded successfully" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                       [alert show];
                                   } failure:^(NSError *error) {
                                       [progressView dismissWithClickedButtonIndex:100 animated:YES];
                                       if (IS_DEBUGGING)
                                           [FBLog log:[error description] from:self];
                                       
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Could not upload the log file" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                       [alert show];
                                   }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) cancel {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
}

@end
