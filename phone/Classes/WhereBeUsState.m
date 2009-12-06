//
//  WhereBeUsState.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/30/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "WhereBeUsState.h"

static NSString *const kWhereBeUsStateFileName = @"wherebeus.state";
static NSString *const kTwitterUserIdKey = @"twitter_user_id";
static NSString *const kTwitterUsernameKey = @"twitter_username";
static NSString *const kTwitterPasswordKey = @"twitter_password";
static NSString *const kTwitterFullNameKey = @"twitter_full_name";
static NSString *const kTwitterProfileImageURLKey = @"twitter_profile_image_url";
static NSString *const kFacebookUserIdKey = @"facebook_user_id";
static NSString *const kFacebookFullNameKey = @"facebook_full_name";
static NSString *const kFacebookProfileImageURLKey = @"facebook_profile_image_url";
static NSString *const kLastMessageKey = @"last_message";

@implementation WhereBeUsState

#pragma mark Read/Write State File

+ (NSString *)filePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];	
	return [documentsDirectory stringByAppendingPathComponent:kWhereBeUsStateFileName];
}

+ (WhereBeUsState *)attemptToReadStateFile
{
	id state_id = nil;
	
	@try
	{
		state_id = [NSKeyedUnarchiver unarchiveObjectWithFile:[WhereBeUsState filePath]];
	}
	@catch (id exception)
	{
		// the NSInvalidArgumentException is raised if the archive file is invalid.
		// if the file simply isn't there, no exception is raised
		// but the return value of [unarchiveObjectWithFile] is nil.
		state_id = nil;
	}
	
	// Did we get anything back?
	if (state_id == nil)
	{
		return nil;
	}
	
	// Did we get back an expected type?
	if (![state_id isKindOfClass:[WhereBeUsState class]])
	{
		return nil;
	}
	
	// Success!
	return [((WhereBeUsState *)state_id) retain];
}

+ (WhereBeUsState *)getDefaultState
{
	return [[WhereBeUsState alloc] init];
}

+ (id)shared
{
	static WhereBeUsState *_shared;
	
	@synchronized (self)
	{
		if (_shared == nil)
		{
			_shared = [WhereBeUsState attemptToReadStateFile];
			if (_shared == nil)
			{
				_shared = [WhereBeUsState getDefaultState];
			}
		}		
	}
	
	return _shared;
}

- (void)save
{
	if (isDirty)
	{
		@try
		{
			[NSKeyedArchiver archiveRootObject:self toFile:[WhereBeUsState filePath]];
			isDirty = NO;
		}
		@catch (id exception)
		{
			// no-op -- not the end of the world if we fail to save state 
			// (though definitely SURPRISING!)
		}
	}
}

- (void)propertyChanged
{
	isDirty = YES;
}

#pragma mark Init/Dealloc

- (void)setDefaults
{
	twitterUserId = (TwitterId) 0;
	twitterUsername = nil;
	twitterPassword = nil;
	twitterFullName = nil;
	twitterProfileImageURL = nil;
	facebookUserId = (FBUID) 0;
	facebookFullName = nil;
	facebookProfileImageURL = nil;
	lastMessage = nil;
	isDirty = NO;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setDefaults];
	}
	return self;
}

- (void)dealloc
{	
	[twitterUsername release];
	[twitterPassword release];
	[twitterFullName release];
	[twitterProfileImageURL release];
	[facebookFullName release];
	[facebookProfileImageURL release];
	[lastMessage release];
	[super dealloc];
}

#pragma mark Properties

- (BOOL)hasTwitterCredentials
{
	return (twitterUserId != (TwitterId) 0);
}

- (BOOL)hasFacebookCredentials
{
	return (facebookUserId != (FBUID) 0);
}

- (BOOL)isDirty
{
	return isDirty;
}

// These return whatever is logged in, but if both are 
// logged in they return twitter (naturally!)
- (NSString *)preferredFullName
{
	if (self.hasTwitterCredentials)
	{
		return self.twitterFullName;
	}
	
	return self.facebookFullName;
}

- (NSString *)preferredProfileImageURL
{
	if (self.hasTwitterCredentials)
	{
		return self.twitterProfileImageURL;
	}
	
	return self.facebookProfileImageURL;
}

- (TwitterId)twitterUserId
{
	return twitterUserId;
}

- (NSString *)twitterUsername
{
	return twitterUsername;
}

- (NSString *)twitterPassword
{
	return twitterPassword;
}

- (NSString *)twitterFullName
{
	return twitterFullName;
}

- (NSString *)twitterProfileImageURL
{
	return twitterProfileImageURL;
}

- (FBUID)facebookUserId
{
	return facebookUserId;
}

- (NSString *)facebookFullName
{
	return facebookFullName;
}

- (NSString *)facebookProfileImageURL
{
	return facebookProfileImageURL;
}

- (NSString *)lastMessage
{
	return lastMessage;
}

- (void)setTwitterUserId:(TwitterId)newTwitterUserId
{
	twitterUserId = newTwitterUserId;
	[self propertyChanged];
}

- (void)setTwitterUsername:(NSString *)newTwitterUsername
{
	[twitterUsername autorelease];
	twitterUsername = [newTwitterUsername retain];
	[self propertyChanged];
}

- (void)setTwitterPassword:(NSString *)newTwitterPassword
{
	[twitterPassword autorelease];
	twitterPassword = [newTwitterPassword retain];
	[self propertyChanged];
}

- (void)setTwitterFullName:(NSString *)newTwitterFullName
{
	[twitterFullName autorelease];
	twitterFullName = [newTwitterFullName retain];
	[self propertyChanged];
}

- (void)setTwitterProfileImageURL:(NSString *)newTwitterProfileImageURL
{
	[twitterProfileImageURL autorelease];
	twitterProfileImageURL = [newTwitterProfileImageURL retain];
	[self propertyChanged];
}

- (void)setFacebookUserId:(FBUID)newFacebookUserId
{
	facebookUserId = newFacebookUserId;
	[self propertyChanged];
}

- (void)setFacebookFullName:(NSString *)newFacebookFullName
{
	[facebookFullName autorelease];
	facebookFullName = [newFacebookFullName retain];
	[self propertyChanged];
}

- (void)setFacebookProfileImageURL:(NSString *)newFacebookProfileImageURL
{
	[facebookProfileImageURL autorelease];
	facebookProfileImageURL = [newFacebookProfileImageURL retain];
	[self propertyChanged];
}

- (void)setLastMessage:(NSString *)newLastMessage
{
	[lastMessage autorelease];
	lastMessage = [newLastMessage retain];
	[self propertyChanged];
}

#pragma mark NSCoding Implementation

- (void)encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeInt32:(int32_t)twitterUserId forKey:kTwitterUserIdKey];
	[encoder encodeObject:twitterUsername forKey:kTwitterUsernameKey];
	[encoder encodeObject:twitterPassword forKey:kTwitterPasswordKey];
	[encoder encodeObject:twitterFullName forKey:kTwitterFullNameKey];
	[encoder encodeObject:twitterProfileImageURL forKey:kTwitterProfileImageURLKey];
	[encoder encodeInt64:(int64_t)facebookUserId forKey:kFacebookUserIdKey];
	[encoder encodeObject:facebookFullName forKey:kFacebookFullNameKey];
	[encoder encodeObject:facebookProfileImageURL forKey:kFacebookProfileImageURLKey];
	[encoder encodeObject:lastMessage forKey:kLastMessageKey];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
	self = [super init];
	
	if (self != nil) 
	{
		[self setDefaults];
		self.twitterUserId = (TwitterId) [decoder decodeInt32ForKey:kTwitterUserIdKey];
		self.twitterUsername = [decoder decodeObjectForKey:kTwitterUsernameKey];
		self.twitterPassword = [decoder decodeObjectForKey:kTwitterPasswordKey];
		self.twitterFullName = [decoder decodeObjectForKey:kTwitterFullNameKey];
		self.twitterProfileImageURL = [decoder decodeObjectForKey:kTwitterProfileImageURLKey];
		self.facebookUserId = (FBUID) [decoder decodeInt64ForKey:kFacebookUserIdKey];
		self.facebookFullName = [decoder decodeObjectForKey:kFacebookFullNameKey];
		self.facebookProfileImageURL = [decoder decodeObjectForKey:kFacebookProfileImageURLKey];
		self.lastMessage = [decoder decodeObjectForKey:kLastMessageKey];
	}
	
	return self;
}

#pragma mark NSCopying Implementation

- (id)copyWithZone:(NSZone *)zone 
{
	WhereBeUsState *copy = [[[self class] allocWithZone:zone] init];
	
	copy.twitterUserId = twitterUserId;
	copy.twitterUsername = [[twitterUsername copy] autorelease];
	copy.twitterPassword = [[twitterPassword copy] autorelease];
	copy.twitterFullName = [[twitterFullName copy] autorelease];
	copy.twitterProfileImageURL = [[twitterProfileImageURL copy] autorelease];
	copy.facebookUserId = facebookUserId;
	copy.facebookFullName = [[facebookFullName copy] autorelease];
	copy.facebookProfileImageURL = [[facebookProfileImageURL copy] autorelease];
	copy.lastMessage = [[lastMessage copy] autorelease];
	
	return copy;
}

@end
