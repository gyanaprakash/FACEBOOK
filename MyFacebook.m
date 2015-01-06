//
//  MyFacebook.m
//  Photopinion
//
//  Created by Narendra Verma on 07/03/13.
//  Copyright (c) 2013 Shiv Mohan Singh. All rights reserved.
//
#define kTitle			@"title"
#define kDescription	@"description"
#define kPicture		@"picture"
#define kPostSuccess	@"isPostSuccess"
#define kFriendFBId		@"FrndFBId"
#define kMesssage		@"message"

#import "MyFacebook.h"
#import "NSDictionary+KeyExists.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Keys.h"
@implementation MyFacebook
@synthesize delegate;
@synthesize typeOfRequest;
@synthesize dictForData;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];

    return [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
    {
        [self sessionStateChanged:session state:state error:error];
    }];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
	
    switch (state)
    {
        case FBSessionStateOpen:
        {
			
			NSLog(@"FBSessionStateOpen");
			// FBSample logic
			// Pre-fetch and cache the friends for the friend picker as soon as possible to improve
			// responsiveness when the user tags their friends.
			FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
			[cacheDescriptor prefetchAndCacheForSession:session];
			
			[self callToFacebook];
		}
            break;
        case FBSessionStateClosed:
        {
			// FBSample logic
			// Once the user has logged out, we want them to be looking at the root view.
            
            AppDelegate *appDelegate = YACCAppDelegate;
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];

			NSLog(@"User Logout");
			[FBSession.activeSession closeAndClearTokenInformation];
		}
            break;
        case FBSessionStateClosedLoginFailed:
        {
			// if the token goes invalid we want to switch right back to
			// the login view, however we do it with a slight delay in order to
			// account for a race between this and the login view dissappearing`
			// a moment before
            AppDelegate *appDelegate = YACCAppDelegate;

            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];

           // [MBProgressHUD hideHUDForView:APP_DELEGATE.window animated:YES];
			NSLog(@"FBSessionStateClosedLoginFailed");
			
		}
            break;
        default:
            break;
    }
//    if (error)
//    {
//		UIAlertView *alertView = AlertView(@"Closito", @"Go to Device Setting->Facebook, Allow The App Closito On", nil);
//		[alertView show];
//		[self performSelectorOnMainThread:@selector(alertViewShowOnMain) withObject:self waitUntilDone:YES];
//    }
}
-(void)alertViewShowOnMain
{
    AppDelegate *appDelegate = YACCAppDelegate;

    [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
}

-(void)getUserInfo
{
	self.typeOfRequest = MyFbUserInfo;
	[self openSessionWithAllowLoginUI:YES];
}
-(void)getUserFriendList
{
	self.typeOfRequest = MyFbFriendList;
	[self openSessionWithAllowLoginUI:YES];
}
-(void)getUserInfoWithFriendList
{
	self.typeOfRequest = MyFBUserInfoNFriendList;
	[self openSessionWithAllowLoginUI:YES];
}

-(void)postImage:(UIImage*)image withMessage:(NSString *)message
{
	if (image)
	{
		self.typeOfRequest = MyFBPostImage;
		NSData *videoData = UIImagePNGRepresentation(image);
		NSDictionary *videoObject =@{
		  kPicture: videoData,
		  kMesssage : (message)?message:@""
		  };
		
		self.dictForData = [NSMutableDictionary dictionaryWithDictionary:videoObject];
		[self openSessionWithAllowLoginUI:YES];
	}
	else
	{
		NSLog(@"Error : Image required");                              
	}
	
}
-(void)PostFeedFBWall:(NSString*)feed withUrl:(NSString *)link andName:(NSString *)name
{
	NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithCapacity:0];
	
	if (feed)
	{
		self.typeOfRequest = MyFBPostFeed;
		[dictData setObject:feed forKey:@"message"];
		
		if (link)
			[dictData setObject:link forKey:@"link"];
		
		if(name)
			[dictData setObject:name forKey:@"name"];
		
		
		self.dictForData = [NSMutableDictionary dictionaryWithDictionary:dictData];
		[self openSessionWithAllowLoginUI:YES];
	}
}
-(void)PostOnFriendsWallWithFriendsID:(NSString*)frndID andFeed:(NSString*)feed withUrl:(NSString *)link andName:(NSString *)name
{
	NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithCapacity:0];
	
	if (feed)
	{
		self.typeOfRequest = MYFBPostFriendsWall;
		[dictData setObject:feed forKey:@"message"];
		
		if (link)
			[dictData setObject:link forKey:@"link"];
		
		if(name)
			[dictData setObject:name forKey:@"name"];
		
		
		self.dictForData = [NSMutableDictionary dictionaryWithDictionary:dictData];
		
		[self.dictForData setObject:frndID forKey:kFriendFBId];
		[self openSessionWithAllowLoginUI:YES];
	}
}

#pragma mark - MainCall
-(void)callToFacebook
{
	if (self.typeOfRequest == MyFbUserInfo)
	{
		[[FBRequest requestForMe] startWithCompletionHandler:
		 ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
			 if (!error) {
				 
				 NSDictionary * dict = [NSDictionary dictionaryWithObject:user forKey:kUserInfo];
				 [self responseFromFB:dict];
			 }
		 }];
	}
	else if (self.typeOfRequest == MyFbFriendList)
	{
		[FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
        {
			if (!error)
			{
				if (![result valueForKeyIsNull:@"data"])
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObject:[result objectForKey:@"data"] forKey:kFBFriendlist];
					[self responseFromFB:dict];
				}
			}
		}];
		
	}
    else if (self.typeOfRequest == MyFBUserInfoNFriendList)
	{
		[[FBRequest requestForMe] startWithCompletionHandler:
		 ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)
        {
			 if (!error)
             {
				 
				 NSMutableDictionary * dictForBoth = [NSMutableDictionary dictionaryWithCapacity:0];
				 [dictForBoth setObject:user forKey:kUserInfo];
				
				 [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                 {
                     if (!error)
                     {
                         if (![result valueForKeyIsNull:@"data"])
                         {
                             [dictForBoth setObject:[result objectForKey:@"data"] forKey:kFBFriendlist];
                             [self responseFromFB:dictForBoth];
                         }
                     }
				 }];
			 }
		 }];
	}
	else if (self.typeOfRequest == MyFBPostImage)
	{
		FBRequest *uploadRequest = [FBRequest requestWithGraphPath:@"me/photos"
														parameters:self.dictForData
														HTTPMethod:@"POST"];
		
		[uploadRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {

			NSDictionary * dict = [NSDictionary dictionaryWithObject:(!error)?@"1":@"0" forKey:kPostSuccess];
			[self responseFromFB:dict];
		}];
	}
	else if (self.typeOfRequest == MyFBPostFeed)
	{
		[self postOnFacebookMeFeeds];
	}
    else if (self.typeOfRequest == MYFBPostFriendsWall)
	{
		[self postOnFacebookFriendWall];
	}
}


-(void)postOnFacebookMeFeeds
{
	if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
    {
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error)
        {
             if (!error)
             {
                 // re-call assuming we now have the permission
                 [self postOnFacebookMeFeeds];
             }
         }];
    }
	else
	{
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/feed"] parameters:self.dictForData HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
		 {
			 //Tell the user that it worked.
			 NSDictionary * dict = [NSDictionary dictionaryWithObject:(!error)?@"1":@"0" forKey:kPostSuccess];
			 [self responseFromFB:dict];
		 }];
    }
}
-(void)postOnFacebookFriendWall
{
	if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound)
    {
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_stream"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error)
        {
             if (!error)
             {
                 // re-call assuming we now have the permission
                 [self postOnFacebookFriendWall];
             }
        }];
    }
	else
	{
		//Post to friend's wall.
		NSString *userId = [self.dictForData objectForKey:kFriendFBId];
		
		[self.dictForData removeObjectForKey:kFriendFBId];
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", userId] parameters:self.dictForData HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
		 {
			 //Tell the user that it worked.
			 NSLog(@"Result : %@",result);
		 }];
    }
}

#pragma mark - Facbook Delegate

-(void)responseFromFB:(id)result
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(requsetResponseFromFB:andObject:)])
	{
		[self.delegate requsetResponseFromFB:result andObject:self];
	}
}

@end
