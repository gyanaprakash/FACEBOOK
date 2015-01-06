//
//  MyFacebook.h
//  Photopinion
//
//  Created by Narendra Verma on 07/03/13.
//  Copyright (c) 2013 Shiv Mohan Singh. All rights reserved.
//

#define kUserInfo @"FBUserInfo"
#define kFBFriendlist @"FBFriendList"
#define kUserInfoNFrndList @"FBUserNFrnd"

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

typedef enum
{
	MyFbUserInfo,
	MyFbFriendList,
	MyFBUserInfoNFriendList,
	MyFBPostImage,
	MyFBPostFeed,
	MYFBPostFriendsWall,
}
FbRequestType;


@protocol MyFacebookDelegate <NSObject>

-(void)requsetResponseFromFB:(id)result andObject:(id)facebookObject;

@end
//-----------------------------------------
@interface MyFacebook : NSObject

@property (assign, nonatomic) id <MyFacebookDelegate> delegate;
@property (assign,nonatomic) FbRequestType typeOfRequest;
@property (retain, nonatomic) NSMutableDictionary * dictForData;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)getUserInfo;
- (void)getUserFriendList;

- (void)getUserInfoWithFriendList;
- (void)postImage:(UIImage*)image withMessage:(NSString *)message;
- (void)PostFeedFBWall:(NSString*)feed withUrl:(NSString *)link andName:(NSString *)name;
- (void)PostOnFriendsWallWithFriendsID:(NSString*)frndID andFeed:(NSString*)feed withUrl:(NSString *)link andName:(NSString *)name;
@end
