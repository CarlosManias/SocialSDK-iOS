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

//  This class is used to handle all flights, uncluding showing the list and booking

#import "SBTAcmeFlightView.h"
#import "SBTAcmeUtils.h"
#import "SBTAcmeCommunityView.h"
#import "SBTProfileListView.h"
#import <iOSSBTK/SBTHttpClient.h>
#import <iOSSBTK/FBLog.h>

@interface SBTAcmeFlightView ()

@property (strong, nonatomic) SBTAcmeFlight *flightInProgressOfBooking;

@end

@implementation SBTAcmeFlightView

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
    self.title = @"Flights";
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.listOfFlights count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTAcmeFlight *flight = [self.listOfFlights objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self addSubViewsToCell:cell];
    }
    
    // 1st row
    UILabel *departLabel = (UILabel *) [cell.contentView viewWithTag:100];
    UILabel *departTimeLabel = (UILabel *) [cell.contentView viewWithTag:101];
    UILabel *departCityLabel = (UILabel *) [cell.contentView viewWithTag:102];
    
    departLabel.text = NSLocalizedStringWithDefaultValue(@"DEPART_LABEL",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"DEPART",
                                  @"Depart");
    departTimeLabel.text = flight.departureTime;
    departCityLabel.text = [[self.airportCodes objectForKey:flight.departureCity] objectForKey:@"city"];
    
    
    // 2nd row
    UILabel *arriveLabel = (UILabel *) [cell.contentView viewWithTag:200];
    UILabel *arriveTimeLabel = (UILabel *) [cell.contentView viewWithTag:201];
    UILabel *arriveCityLabel = (UILabel *) [cell.contentView viewWithTag:202];
    
    arriveLabel.text = NSLocalizedStringWithDefaultValue(@"ARRIVE_LABEL",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"ARRIVE",
                                  @"Arrive");
    arriveTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"HOUR_LATER",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"%@ hour later",
                                  @"{hour} hour later"), flight.flightTime];
    arriveCityLabel.text = [[self.airportCodes objectForKey:flight.arrivalCity] objectForKey:@"city"];
    
    
    // 3rd row
    UILabel *flightLabel = (UILabel *) [cell.contentView viewWithTag:300];
    UILabel *flightNumberLabel = (UILabel *) [cell.contentView viewWithTag:301];
    
    flightLabel.text = NSLocalizedStringWithDefaultValue(@"FLIGHT_LABEL",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"FLIGHT",
                                  @"Flight");
    flightNumberLabel.text = [NSString stringWithFormat:@"%d", [flight.flightId intValue]];
    
    // 4th row
    UILabel *cabinLabel = (UILabel *) [cell.contentView viewWithTag:400];
    UILabel *cabinTypeLabel = (UILabel *) [cell.contentView viewWithTag:401];
    
    cabinLabel.text = NSLocalizedStringWithDefaultValue(@"CABIN_LABEL",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"CABIN",
                                  @"Cabin");
    
    cabinTypeLabel.text = NSLocalizedStringWithDefaultValue(@"ECONOMY_LABEL",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Economy",
                                  @"Economy");
    
    // Book button
    for (UIView *view in [cell.contentView subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *bookButton = (UIButton *) view;
            bookButton.tag = indexPath.row;
            if ([flight.booked boolValue] == YES) {
                [bookButton setTitle:NSLocalizedStringWithDefaultValue(@"BOOK_BUTTON_BOOKED",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Booked",
                                  @"Book button with booked state") forState:UIControlStateNormal];
                [bookButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            } else {
                [bookButton setTitle:NSLocalizedStringWithDefaultValue(@"BOOK_BUTTON",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Book",
                                  @"Book button") forState:UIControlStateNormal];
                [bookButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
            break;
        }
    }
    
    // Activity indicator
    UIActivityIndicatorView *actIndicator = (UIActivityIndicatorView *) [cell.contentView viewWithTag:500];
    if ([flight.isBooking boolValue]) {
        [actIndicator startAnimating];
    } else {
        [actIndicator stopAnimating];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 100;
    else
        return 70;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SBTAcmeFlight *flight = [self.listOfFlights objectAtIndex:indexPath.row];
    self.flightInProgressOfBooking = flight;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate: (id) self
                                                    cancelButtonTitle:
                                            NSLocalizedStringWithDefaultValue(
                                                  @"CANCEL",
                                                  @"Common",
                                                  [NSBundle mainBundle],
                                                  @"Cancel",
                                                  @"Cancel common label")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                            NSLocalizedStringWithDefaultValue(
                                                  @"BOOK_BUTTON",
                                                  nil,
                                                  [NSBundle mainBundle],
                                                  @"Book",
                                                  @"Book button"),
                                            NSLocalizedStringWithDefaultValue(
                                                  @"SEE_COLLEAGUES",
                                                  nil,
                                                  [NSBundle mainBundle],
                                                  @"See Colleagues",
                                                  @"See Colleagues"),
                                            NSLocalizedStringWithDefaultValue(
                                                  @"SEE_COMMUNITY",
                                                  nil,
                                                  [NSBundle mainBundle],
                                                  @"See Community",
                                                  @"See Community"),
                                nil];
    [actionSheet showInView:self.view];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) actionSheet:(UIActionSheet *) actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex {
    if (buttonIndex == 0) {
        // Book
        SBTAcmeFlight *flight = self.flightInProgressOfBooking;
        if ([flight.booked boolValue] == NO) {
            flight.isBooking = [NSNumber numberWithBool:YES];
            [self.tableView reloadData];
            UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
            [self getFirstLineManagerWithFlight:flight myProfile:self.myProfile completionHandler:^(BOOL success) {
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
            }];
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedStringWithDefaultValue(
                                                  @"FLIGHT_ALREADY_BOOKED",
                                                  nil,
                                                  [NSBundle mainBundle],
                                                  @"You've already requested to book Flight %@.",
                                                  @"You've already requested to book Flight {numFlight}."),
            self.flightInProgressOfBooking.flightId] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringWithDefaultValue(@"OK",
                                  @"Common",
                                  [NSBundle mainBundle],
                                  @"OK",
                                  @"OK Common label"), nil];
            [alert show];
        }
    } else if (buttonIndex == 1) {
        // Colleague view
        UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
        [self retrieveColleaguesForFlight:self.flightInProgressOfBooking completionHandler:^(NSMutableArray *list) {
            [progressView dismissWithClickedButtonIndex:100 animated:YES];
            if (list != nil) {
                SBTProfileListView *listView = [[SBTProfileListView alloc] init];
                listView.listOfProfiles = list;
                listView.title = NSLocalizedStringWithDefaultValue(@"COLLEAGUES",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Colleagues",
                                  @"Colleagues");
                [self.navigationController pushViewController:listView animated:YES];
            }
        }];
    } else if (buttonIndex == 2) {
        NSString *communityUuid = [SBTAcmeUtils getTestCommunityUUidForFlightId:self.flightInProgressOfBooking.flightId];
        if (communityUuid != nil) {
            UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
            SBTAcmeCommunityView *communityView = [[SBTAcmeCommunityView alloc] init];
            communityView.myProfile = self.myProfile;
            communityView.communityUuid = communityUuid;
            [communityView getCommunityWithCompletionHandler:^(BOOL success) {
                if (success)
                    [self.navigationController pushViewController:communityView animated:YES];
                
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
            }];
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"FLIGHT_HAS_NO_COMMUNITY",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Flight %@ has no community associated with it yet.",
                                  @"Flight {numFlight} has no community associated with it yet."),
            self.flightInProgressOfBooking.flightId] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringWithDefaultValue(@"OK",
                                  @"Common",
                                  [NSBundle mainBundle],
                                  @"OK",
                                  @"OK Common label"), nil];
            [alert show];
        }
    }
}

#pragma mark - Helper methods

- (void) getUsersAndCheckWithColleagues:(NSMutableDictionary *) colleagues flight:(SBTAcmeFlight *) flight completionHandler:(void (^)(NSMutableArray *)) completionHandler; {
    NSURL *baseUrl = [NSURL URLWithString:[SBTAcmeUtils getAcmeUrl]];
    SBTHttpClient *httpClient = [[SBTHttpClient alloc] initWithBaseURL:baseUrl];
    NSString *path = [NSString stringWithFormat:@"/acme.social.sample.dataapp/rest/flights/%@/users", flight.flightId];
    [httpClient getPath:path
             parameters:nil
                success:^(id response, id result) {
                    NSError *error = nil;
                    NSMutableArray *users = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&error];
                    NSMutableArray *listOfProfiles = [[NSMutableArray alloc] init];
                    for (NSString *email in users) {
                        if ([colleagues objectForKey:email] != nil) {
                            [listOfProfiles addObject:[colleagues objectForKey:email]];
                        }
                    }
                    completionHandler(listOfProfiles);
                } failure:^(id response, NSError *error) {
                    if (IS_DEBUGGING)
                        [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                    
                    completionHandler(NO);
                }];
}

- (void) retrieveColleaguesForFlight:(SBTAcmeFlight *) flight completionHandler:(void (^)(NSMutableArray *)) completionHandler {
    SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
    [profileService getColleaguesWithProfile:self.myProfile success:^(NSMutableArray *list) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        for (SBTConnectionsProfile *profile in list) {
            [dictionary setObject:profile forKey:profile.email];
        }
        [dictionary setObject:self.myProfile forKey:self.myProfile.email];
        [self getUsersAndCheckWithColleagues:dictionary flight:flight completionHandler:completionHandler];
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
        
        completionHandler(NO);
    }];
}

/**
 This method gets the first line manager of the given user to initiate the approval process
 @param flight: flight
 @param myProfile: myProfile
 */
- (void) getFirstLineManagerWithFlight:(SBTAcmeFlight *) flight
                             myProfile:(SBTConnectionsProfile *) myProfile
                     completionHandler:(void (^)(BOOL)) completionHandler {
    
    SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
    [profileService getReportToChainWithUserId:self.myProfile.email
                                    parameters:nil
                                       success:^(NSMutableArray *list) {
                                           if (list != nil && [list count] > 1) {
                                               SBTConnectionsProfile *manager = [list objectAtIndex:1];
                                               flight.approver = manager.displayName;
                                               [self putRequestToAcmeWithFlight:flight
                                                                      myProfile:myProfile
                                                                        manager:manager
                                                              completionHandler:completionHandler];
                                           } else {
                                               completionHandler(NO);
                                               if (IS_DEBUGGING)
                                                   [FBLog log:@"No person is returned" from:self];
                                               
                                               flight.isBooking = [NSNumber numberWithBool:NO];
                                               [self.tableView reloadData];
                                           }
                                       } failure:^(NSError *error) {
                                           if (IS_DEBUGGING)
                                               [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                                           
                                           flight.isBooking = [NSNumber numberWithBool:NO];
                                           [self.tableView reloadData];
                                           completionHandler(NO);
                                       }];
}

/**
 This method save the flight request to the Acme server to sync up operations
 @param flight
 @param myProfile
 @param manager
 */
- (void) putRequestToAcmeWithFlight:(SBTAcmeFlight *) flight
                          myProfile:(SBTConnectionsProfile *) myProfile
                            manager:(SBTConnectionsProfile *) manager
                  completionHandler:(void (^)(BOOL)) completionHandler {
    
    NSURL *baseUrl = [NSURL URLWithString:[SBTAcmeUtils getAcmeUrl]];
    SBTHttpClient *httpClient = [[SBTHttpClient alloc] initWithBaseURL:baseUrl];
    [httpClient setDefaultHeader:@"Content-Type" value:@"application/json"];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              myProfile.email, @"UserId",
                              flight.flightId, @"FlightId",
                              manager.email, @"ApproverId",
                              nil, @"Reason",
                              nil];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                    options:NSJSONWritingPrettyPrinted
                                      error:&error];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       jsonData, @"body",
                                       nil];
    NSString *path = [NSString stringWithFormat:@"/acme.social.sample.dataapp/rest/flights/%@/lists",
                      myProfile.email];
    [httpClient postPath:path
             parameters:parameters
                success:^(id response, id result) {
                    [self postActivityStreamWithFlight:flight myProfile:myProfile manager:manager completionHandler:completionHandler];
                } failure:^(id response, NSError *error) {
                    if (IS_DEBUGGING)
                        [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                    
                    flight.isBooking = [NSNumber numberWithBool:NO];
                    [self.tableView reloadData];
                    completionHandler(NO);
                }];
}

/**
 This method post an actioanable activity stream to the given manager for the flight request
 @param flight
 @param myProfile
 @param manager
 */
- (void) postActivityStreamWithFlight:(SBTAcmeFlight *) flight
                            myProfile:(SBTConnectionsProfile *) myProfile
                              manager:(SBTConnectionsProfile *) manager
                    completionHandler:(void (^)(BOOL)) completionHandler {
    
    SBTConnectionsActivityStreamService *actStrService = [[SBTConnectionsActivityStreamService alloc] init];
    NSDictionary *payload = [self generatePayloaWithFlight:flight myProfile:myProfile manager:manager];
    [actStrService postEntry:payload
                  parameters:nil
                     success:^(id result) {
                         flight.booked = [NSNumber numberWithBool:YES];
                         flight.isBooking = [NSNumber numberWithBool:NO];
                         flight.status = NSLocalizedStringWithDefaultValue(@"PENDING",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Pending",
                                  @"Pending");
                         [self.tableView reloadData];
                          completionHandler(YES);
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"YOU_BOOKED_FLIGHT",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"You've just booked flight # %@",
                                  @"You've just booked flight # {numFlight}"), flight.flightId] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                         [alert show];
                     } failure:^(NSError *error) {
                         if (IS_DEBUGGING)
                             [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                         
                         flight.isBooking = [NSNumber numberWithBool:NO];
                         [self.tableView reloadData];
                          completionHandler(NO);
                         
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"ERROR_BOOKING_FLIGHT",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"There was an error while booking flight # %@",
                                  @"There was an error while booking flight # {numFlight}"), flight.flightId] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringWithDefaultValue(@"OK",
                                  @"Common",
                                  [NSBundle mainBundle],
                                  @"OK",
                                  @"OK Common label"), nil];
                         [alert show];
                     }];
}

/**
 This methods generate the payload for the activity stream using flight, myProfile and the manager
 @param flight
 @param myProfile
 @param manager
 */
- (NSDictionary *) generatePayloaWithFlight:(SBTAcmeFlight *) flight
                                  myProfile:(SBTConnectionsProfile *) myProfile
                                    manager:(SBTConnectionsProfile *) manager {
    
    NSString *homePageUrl = [NSString stringWithFormat:@"%@/acme.social.sample.webapp", [SBTAcmeUtils getAcmeUrl]];
    NSString *myId = myProfile.userId;
    NSString *approverId = manager.userId;
    
    // Generator
    NSDictionary *image = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSString stringWithFormat:@"%@/favicon.ico", homePageUrl], @"url",
                           nil];
    NSDictionary *generator = [NSDictionary dictionaryWithObjectsAndKeys:
                               image, @"image",
                               @"AcmeAirlines", @"id",
                               @"Acme Airlines", @"displayName",
                               homePageUrl, @"url",
                               nil];
    // Actor
    NSDictionary *actor = [NSDictionary dictionaryWithObjectsAndKeys:
                           myId, @"id",
                           nil];
    
    // Object
    NSString *summary = [NSString stringWithFormat:
                         NSLocalizedStringWithDefaultValue(@"FLIGHT_REQUEST_MESSAGE",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"%@ is requesting to fly from %@ to %@ on flight %d.",
                                  @"{User name} is requesting to fly from {departCity} to {arriveCity} on flight {numFligh}."),
                         self.myProfile.displayName,
                         flight.departureCity,
                         flight.arrivalCity,
                         [flight.flightId intValue]];
    NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:
                            summary, @"summary",
                            @"flight", @"objectType",
                            flight.flightId, @"id",
                            NSLocalizedStringWithDefaultValue(@"FLIGHT_REQUEST",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Flight Request",
                                  @"Flight Request"),
                            @"displayName",
                            homePageUrl, @"url",
                            nil];
    
    // Target
    NSDictionary *target = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Airlines Booking App", @"summary",
                            @"application", @"objectType",
                            @"AcmeAirlines", @"id",
                            @"Acme Airlines iOS App", @"displayName",
                            homePageUrl, @"url",
                            nil];
    
    // Connections
    NSString *rollupId = [NSString stringWithFormat:@"acmeairlines:%@",approverId];
    NSDictionary *connections = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"true", @"actionable",
                                 rollupId, @"rollupid",
                                 nil];
    // To
    NSDictionary *deliverTo = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"person", @"objectType",
                               approverId, @"id",
                               nil];
    NSArray *deliverToList = [NSArray arrayWithObjects:deliverTo, nil];
    
    // Open Social
    /*NSString *approveUrl = [NSString stringWithFormat:
                            @"http://localhost:8080/acme.sample.webapp.ios/approve.jsp?userid=%@&flightid=%@",
                            myProfile.userId,
                            [flight.flightId stringValue]];
    //NSDictionary *embed = [NSDictionary dictionaryWithObjectsAndKeys:approveUrl, @"url", nil];*/
    NSDictionary *flightContext = [NSDictionary dictionaryWithObjectsAndKeys:
                            myProfile.email, @"UserId",
                            flight.flightId, @"FlightId",
                            manager.email, @"ApproverId",
                            flight.departureTime, @"Arrive",
                            flight.departureTime, @"Depart",
                            nil];
    NSString *gadgetUrl = [NSString stringWithFormat:@"%@/acme.social.sample.webapp/gadgets/airlines/airlines.xml", [SBTAcmeUtils getAcmeUrl]];
    NSDictionary *embed = [NSDictionary dictionaryWithObjectsAndKeys:
                           gadgetUrl, @"gadget",
                           flightContext, @"context",
                           nil];
    NSDictionary *openSocial = [NSDictionary dictionaryWithObjectsAndKeys:
                                embed, @"embed",
                                nil];
    
    // Content
    NSString *content = [NSString stringWithFormat:
                         NSLocalizedStringWithDefaultValue(@"PLEASE_APPROVE",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Please approve %@'s flight request for flight %@.",
                                  @"Please approve {User's name}'s flight request for flight {numFlight}."),
                         self.myProfile.displayName,
                         flight.flightId];
    // All together
    NSDictionary *jsonPayload = [NSDictionary dictionaryWithObjectsAndKeys:
                                 actor, @"actor",
                                 connections, @"connections",
                                 deliverToList, @"to",
                                 object, @"object",
                                 generator, @"generator",
                                 target, @"target",
                                 openSocial, @"openSocial",
                                 @"created", @"verb",
                                 NSLocalizedStringWithDefaultValue(@"ACTOR_CREATED_OBJECT",
                                      nil,
                                      [NSBundle mainBundle],
                                      @"${Actor} created a ${Object} in the ${Target}",
                                      @"${Actor} created a ${Object} in the ${Target}"),
                                 @"title",
                                 content, @"content",
                                 object, @"object",
                                 nil];
    return jsonPayload;
}


/**
 Add all neccessary subviews to the cell
 */
- (void) addSubViewsToCell:(UITableViewCell *) cell {
    // 1st row
    CGRect frame;
    float textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textSize = TEXT_SIZE_IPAD_SMALL;
        frame = CGRectMake(10, 5, 100, 22.5);
    } else {
        textSize = TEXT_SIZE_SMALL;
        frame = CGRectMake(10, 5, 70, 15);
    }
    UILabel *departLabel = [[UILabel alloc] initWithFrame:frame];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(departLabel.frame.origin.x + departLabel.frame.size.width + 10, 5, 130, 22.5);
    } else {
        frame = CGRectMake(departLabel.frame.origin.x + departLabel.frame.size.width + 3, 5, 80, 15);
    }
    UILabel *departTimeLabel = [[UILabel alloc] initWithFrame:frame];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(departTimeLabel.frame.origin.x + departTimeLabel.frame.size.width + 10, 5, 140, 22.5);
    } else {
        frame = CGRectMake(departTimeLabel.frame.origin.x + departTimeLabel.frame.size.width + 3, 5, 110, 15);
    }
    UILabel *departCityLabel = [[UILabel alloc] initWithFrame:frame];
    
    departLabel.tag = 100;
    departLabel.font = [UIFont boldSystemFontOfSize:textSize];
    departLabel.backgroundColor = [UIColor clearColor];
    
    departTimeLabel.tag = 101;
    departTimeLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    departTimeLabel.backgroundColor = [UIColor clearColor];
    departTimeLabel.adjustsFontSizeToFitWidth = YES;
    
    departCityLabel.tag = 102;
    departCityLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    departCityLabel.backgroundColor = [UIColor clearColor];
    departCityLabel.adjustsFontSizeToFitWidth = YES;
    
    [cell.contentView addSubview:departLabel];
    [cell.contentView addSubview:departTimeLabel];
    [cell.contentView addSubview:departCityLabel];
    
    // 2nd row
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(10, departLabel.frame.origin.y + departLabel.frame.size.height, departLabel.frame.size.width, 22.5);
    } else {
        frame = CGRectMake(10, departLabel.frame.origin.y + departLabel.frame.size.height, departLabel.frame.size.width, 15);
    }
    UILabel *arriveLabel = [[UILabel alloc] initWithFrame:frame];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(arriveLabel.frame.origin.x + arriveLabel.frame.size.width + 10, departLabel.frame.origin.y + departLabel.frame.size.height, departTimeLabel.frame.size.width, 22.5);
    } else {
        frame = CGRectMake(arriveLabel.frame.origin.x + arriveLabel.frame.size.width + 3, departLabel.frame.origin.y + departLabel.frame.size.height, departTimeLabel.frame.size.width, 15);
    }
    UILabel *arriveTimeLabel = [[UILabel alloc] initWithFrame:frame];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(arriveTimeLabel.frame.origin.x + arriveTimeLabel.frame.size.width + 10, departLabel.frame.origin.y + departLabel.frame.size.height, departCityLabel.frame.size.width, 22.5);
    } else {
        frame = CGRectMake(arriveTimeLabel.frame.origin.x + arriveTimeLabel.frame.size.width + 3, departLabel.frame.origin.y + departLabel.frame.size.height, departCityLabel.frame.size.width, 15);
    }
    UILabel *arriveCityLabel = [[UILabel alloc] initWithFrame:frame];
    
    arriveLabel.tag = 200;
    arriveLabel.font = [UIFont boldSystemFontOfSize:textSize];
    arriveLabel.backgroundColor = [UIColor clearColor];
    
    arriveTimeLabel.tag = 201;
    arriveTimeLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    arriveTimeLabel.backgroundColor = [UIColor clearColor];
    
    arriveCityLabel.tag = 202;
    arriveCityLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    arriveCityLabel.backgroundColor = [UIColor clearColor];
    arriveCityLabel.adjustsFontSizeToFitWidth = YES;
    
    [cell.contentView addSubview:arriveLabel];
    [cell.contentView addSubview:arriveTimeLabel];
    [cell.contentView addSubview:arriveCityLabel];
    
    // 3rd row
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(10, arriveLabel.frame.origin.y + arriveLabel.frame.size.height, departLabel.frame.size.width, 22.5);
    } else {
        frame = CGRectMake(10, arriveLabel.frame.origin.y + arriveLabel.frame.size.height, departLabel.frame.size.width, 15);
    }
    UILabel *flightLabel = [[UILabel alloc] initWithFrame:frame];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(flightLabel.frame.origin.x + flightLabel.frame.size.width + 10, arriveLabel.frame.origin.y + arriveLabel.frame.size.height, departTimeLabel.frame.size.width, 22.5);
    } else {
        frame = CGRectMake(flightLabel.frame.origin.x + flightLabel.frame.size.width + 3, arriveLabel.frame.origin.y + arriveLabel.frame.size.height, departTimeLabel.frame.size.width, 15);
    }
    UILabel *flightNumberLabel = [[UILabel alloc] initWithFrame:frame];
    
    flightLabel.tag = 300;
    flightLabel.font = [UIFont boldSystemFontOfSize:textSize];
    flightLabel.backgroundColor = [UIColor clearColor];
    
    flightNumberLabel.tag = 301;
    flightNumberLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    flightNumberLabel.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:flightLabel];
    [cell.contentView addSubview:flightNumberLabel];
    
    // 4th row
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(10, flightLabel.frame.origin.y + flightLabel.frame.size.height, departLabel.frame.size.width, 22.5);
    } else {
        frame = CGRectMake(10, flightLabel.frame.origin.y + flightLabel.frame.size.height, departLabel.frame.size.width, 15);
    }
    UILabel *cabinLabel = [[UILabel alloc] initWithFrame:frame];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(cabinLabel.frame.origin.x + cabinLabel.frame.size.width + 10, flightLabel.frame.origin.y + flightLabel.frame.size.height, departTimeLabel.frame.size.width, 22.5);
    } else {
        frame = CGRectMake(cabinLabel.frame.origin.x + cabinLabel.frame.size.width + 3, flightLabel.frame.origin.y + flightLabel.frame.size.height, 70, 15);
    }
    UILabel *cabinTypeLabel = [[UILabel alloc] initWithFrame:frame];
    
    cabinLabel.tag = 400;
    cabinLabel.font = [UIFont boldSystemFontOfSize:textSize];
    cabinLabel.backgroundColor = [UIColor clearColor];
    
    cabinTypeLabel.tag = 401;
    cabinTypeLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    cabinTypeLabel.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:cabinLabel];
    [cell.contentView addSubview:cabinTypeLabel];
    
    // Add book button
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(flightNumberLabel.frame.origin.x + flightNumberLabel.frame.size.width, flightNumberLabel.frame.origin.y, 90, 45);
    } else {
        frame = CGRectMake(flightNumberLabel.frame.origin.x + flightNumberLabel.frame.size.width, flightNumberLabel.frame.origin.y, 60, 30);
    }
    UIButton *bookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bookButton addTarget:self action:@selector(booked:) forControlEvents:UIControlEventTouchUpInside];
    bookButton.frame = frame;
    bookButton.titleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    [bookButton setTitleColor:[UIColor colorWithRed:95/255.0 green:158/255.0 blue:160/255.0 alpha:1]forState:UIControlStateNormal];
    
    //[cell.contentView addSubview:bookButton];
    
    // Add activity indicator
    UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actIndicator.frame = CGRectMake(bookButton.frame.origin.x + bookButton.frame.size.width/2 - 20,
                                    bookButton.frame.origin.y,
                                    40,
                                    40);
    actIndicator.tag = 500;
    [actIndicator stopAnimating];
    actIndicator.hidesWhenStopped = YES;
    [cell.contentView addSubview:actIndicator];
}

@end
