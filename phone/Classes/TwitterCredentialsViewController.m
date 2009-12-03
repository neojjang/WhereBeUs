//
//  TwitterCredentialsController.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "TwitterCredentialsViewController.h"
#import "ConnectionHelper.h"
#import "Utilities.h"
#import "JsonResponse.h"
#import "WhereBeUsState.h"
#import "WhereBeUsAppDelegate.h"
#import "EditCellViewController.h"

@implementation TwitterCredentialsViewController

@synthesize tableView;
@synthesize activityIndicator;
@synthesize delegate;


//-----------------------------------------------------------------------
// Private Implementation...
//-----------------------------------------------------------------------

- (void)startLoginProcess
{
	[usernameController.textField setEnabled:NO];
	[passwordController.textField setEnabled:NO];
	[passwordController.textField resignFirstResponder];
	[self.activityIndicator startAnimating];	
}

- (void)stopLoginProcess
{
	[usernameController.textField setEnabled:YES];
	[passwordController.textField setEnabled:YES];
	[self.activityIndicator stopAnimating];	
}

- (void)gotValidUsername:(NSString*)username password:(NSString*)password
{
	[self startLoginProcess];
	[ConnectionHelper twitter_verifyCredentialsWithTarget:self action:@selector(verifyCredentials_returned:) username:usernameController.textField.text password:passwordController.textField.text];	
}

- (void)verifyCredentials_returned:(JsonResponse *)results
{
	[self stopLoginProcess];
	
	if (results == nil)
	{
		[Utilities displayModalAlertWithTitle:@"Network Error" message:@"We couldn't contact Twitter. Please check your network connection and try again." buttonTitle:@"OK" delegate:self];
		return;
	}
	
	if (![results isDictionary])
	{
		[Utilities displayModalAlertWithTitle:@"Twitter Error" message:@"Twitter returned an unexpected response. Please try again later." buttonTitle:@"OK" delegate:self];
		return;
	}
	
	NSDictionary *dictionary = [results dictionary];
	
	NSString *error = [dictionary valueForKey:TWITTER_ERROR];
	if (error != nil)
	{
		[Utilities displayModalAlertWithTitle:@"Couldn't Log In" message:@"Your username and password weren't correct. Please try again." buttonTitle:@"OK" delegate:self];
		return;
	}
	
	// Success! Remember the twitter account information.
	WhereBeUsState *state = [WhereBeUsState shared];
	state.twitterUsername = [[[usernameController.textField text] copy] autorelease];
	state.twitterPassword = [[[passwordController.textField text] copy] autorelease];
	state.twitterFullName = [dictionary valueForKey:TWITTER_FULL_NAME];
	state.twitterProfileImageURL = [dictionary valueForKey:TWITTER_PROFILE_IMAGE_URL];
	[state save];
	
	[delegate twitterCredentialsViewControllerDidFinish:self];
}


//-----------------------------------------------------------------------
// UIAlertViewDelegate
//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[usernameController.textField becomeFirstResponder];
}


//-----------------------------------------------------------------------
// UITextFieldDelegate
//-----------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == usernameController.textField)
	{
		[passwordController.textField becomeFirstResponder];
		return YES;
	}
	else
	{	
		// textField is for passwordController. Make sure they didn't skip directly to it...
		if ([usernameController.textField.text length] < 1)
		{
			return NO;
		}
		
		// looks like we have a potentially valid u/p. Try it...
		[self gotValidUsername:usernameController.textField.text password:passwordController.textField.text];
		return YES;
	}
}


//-----------------------------------------------------------------------
// UIViewController overrides
//-----------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self != nil) 
	{
		self.navigationItem.title = @"Twitter Login";
		usernameController = (EditCellViewController *) [[EditCellViewController alloc] initWithNibName:@"EditCellViewController" bundle:nil];
		usernameController.labelText = @"Username";
		usernameController.textFieldDelegate = self;		
		usernameController.autocorrectionType = UITextAutocorrectionTypeNo;
		usernameController.enablesReturnKeyAutomatically = YES;
		usernameController.clearsOnBeginEditing = NO;
		usernameController.returnKeyType = UIReturnKeyNext;
		
		passwordController = (EditCellViewController *) [[EditCellViewController alloc] initWithNibName:@"EditCellViewController" bundle:nil];
		passwordController.labelText = @"Password";
		passwordController.textFieldDelegate = self;
		passwordController.autocorrectionType = UITextAutocorrectionTypeNo;
		passwordController.enablesReturnKeyAutomatically = YES;
		passwordController.returnKeyType = UIReturnKeyDone;
		passwordController.secureTextEntry = YES;
		passwordController.clearsOnBeginEditing = YES;
    }
    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];	
}

- (void)viewWillAppear:(BOOL)animated
{
	WhereBeUsState *state = [WhereBeUsState shared];
	if (state.hasTwitterCredentials)
	{
		[usernameController.textField setText:state.twitterUsername];
		[passwordController.textField setText:state.twitterPassword];
	}
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[usernameController.textField becomeFirstResponder];
	[super viewDidAppear:animated];
}

- (void)dealloc
{
	self.tableView = nil;
	self.activityIndicator = nil;
	self.delegate = nil;
	[usernameController release];
	[passwordController release];
    [super dealloc];
}


//-----------------------------------------------------------------------
// TableViewDataSource implementation. Static!
//-----------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
} 

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	if (row == 0)
	{
		return usernameController.cell;
	}
	else
	{
		return passwordController.cell;
	}
}


@end
