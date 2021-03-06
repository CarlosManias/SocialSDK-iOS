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

#import <Foundation/Foundation.h>
#import "SBTActivityStreamActor.h"

@interface SBTActivityStreamAttachment : NSObject

@property (strong, nonatomic) NSNumber *isImage;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) SBTActivityStreamActor *author;
@property (strong, nonatomic) NSString *aId;
@property (strong, nonatomic) NSString *published;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *imageUrl;


- (NSString *) description;

@end
