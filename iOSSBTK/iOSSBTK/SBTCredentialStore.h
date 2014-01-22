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

//  This class is used to store and retrieve credentials, including username, passwords and outh token
//  !!!---We currently use the NSUserDefaults but a more secure way may be needed---!!!

#import <Foundation/Foundation.h>

@interface SBTCredentialStore : NSObject

+ (BOOL) storeWithKey:(NSString *) key value:(id) value;
+ (id) loadWithKey:(NSString *) key;
+ (BOOL) removeWithKey:(NSString *) key;

@end
