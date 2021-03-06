//
//  FrontSideNavigationController.m
//  WhereBeUs
//
//  Created by Dave Peck on 12/8/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "FrontSideNavigationController.h"
#import "MapViewController.h"
#import "UpdateDetailsViewController.h"
#import "SendMessageViewController.h"

@implementation FrontSideNavigationController

- (void)showMapViewController:(BOOL)animated
{
	MapViewController *mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil] autorelease];
	[self setNavigationBarHidden:YES];
	[self pushViewController:mapViewController animated:animated];
}

- (void)showModalSendMessage
{
	SendMessageViewController *controller = [[[SendMessageViewController alloc] initWithNibName:@"SendMessageViewController" bundle:nil] autorelease];	
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		controller.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	[self presentModalViewController:controller animated:YES];
}

- (void)showModalSendMessageWithCustomMessage:(NSString *)customMessage
{
	SendMessageViewController *controller = [[[SendMessageViewController alloc] initWithNibName:@"SendMessageViewController" bundle:nil customMessage:customMessage] autorelease];	
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		controller.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	[self presentModalViewController:controller animated:YES];
}

- (void)hideModalSendMessage
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showUpdateDetailView:(UpdateAnnotation *)annotation animated:(BOOL)animated
{
	UpdateDetailsViewController *updateDetailsViewController = [[[UpdateDetailsViewController alloc] initWithNibName:@"UpdateDetailsViewController" bundle:nil annotation:annotation] autorelease];
	[self pushViewController:updateDetailsViewController animated:animated];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
	[self showMapViewController:NO];
}

- (void)dealloc 
{
    [super dealloc];
}


@end
