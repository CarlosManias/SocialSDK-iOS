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

//  This class shows an update along with its comments. It also allows user to like and comment on a post

#import <UIKit/UIKit.h>
#import "IBMConnectionsActivityStreamService.h"
#import "IBMConnectionsProfile.h"
#import "IBMConnectionsCommunity.h"

@interface IBMAcmeStatusUpdateView : UITableViewController

@property (strong, nonatomic) IBMActivityStreamEntry *entry;
@property (strong, nonatomic) IBMConnectionsProfile *myProfile;
@property (strong, nonatomic) IBMConnectionsCommunity *community;
@property (strong, nonatomic) UIViewController *delegateViewController;

/**
 This method allows user to get status update before showing the view
 */
- (void) getEntryWithCompletionHandler:(void (^)(BOOL)) completionHandler;

@end
