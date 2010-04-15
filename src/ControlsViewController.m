/*
     File: ControlsViewController.m
 Abstract: The view controller for hosting the UIControls features of this sample.
  Version: 2.6
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "ControlsViewController.h"

#define kUIProgressBarHeight	 9.0 // obtained from Interface Builder (fixed)
#define kUIProgressBarWidth		 150.0 // obtained from Interface Builder (default)

#define kViewTag				1		// for tagging our embedded controls for removal at cell recycle time

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kLabelKey = @"labelKey";
static NSString *kViewKey = @"viewKey";

#pragma mark -

@implementation ControlsViewController

@synthesize dataSourceArray;

- (void)dealloc
{	
	[switchCtl release];
	[sliderCtl release];
	[progressInd release];
	[progressBar release];
	
	[dataSourceArray release];
	
	[super dealloc];
}

- (void)viewDidLoad
{	
    [super viewDidLoad];
	self.title = NSLocalizedString(@"ControlsTitle", @"");

	self.dataSourceArray = [NSArray arrayWithObjects:
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UISwitch", kSectionTitleKey,
								 @"Standard Switch", kLabelKey,
								 self.switchCtl, kViewKey,
							 nil],

							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UISlider", kSectionTitleKey,
								 @"Standard Slider", kLabelKey,
								 self.sliderCtl, kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UIActivityIndicatorView", kSectionTitleKey,
								 @"Style Gray", kLabelKey,
								 self.progressInd, kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UIProgressView", kSectionTitleKey,
								 @"Style Default", kLabelKey,
								 self.progressBar, kViewKey,
							 nil],
							nil];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload 
{
    [super viewDidUnload];
	
	// release the controls and set them nil in case they were ever created
	// note: we can't use "self.xxx = nil" since they are read only properties
	//
	[switchCtl release];
    switchCtl = nil;
    [sliderCtl release];
    sliderCtl = nil;
    [progressInd release];
    progressInd = nil;
    [progressBar release];
    progressBar = nil;
	
	self.dataSourceArray = nil;	// this will release and set to nil
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.dataSourceArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.dataSourceArray objectAtIndex: section] valueForKey:kSectionTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}


// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kDisplayCell_ID = @"DisplayCellID";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCell_ID] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else
	{
		// the cell is being recycled, remove old embedded controls
		UIView *viewToRemove = nil;
		viewToRemove = [cell.contentView viewWithTag:kViewTag];
		if (viewToRemove)
			[viewToRemove removeFromSuperview];
	}
	
	cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kLabelKey];
	
	UIControl *control = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kViewKey];
	//[cell.contentView addSubview:control];

	cell.accessoryView = control;
	
	return cell;
}

- (void)switchAction:(id)sender
{
	NSLog(@"switchAction: value = %d", [sender isOn]);
}

- (void)pageAction:(id)sender
{
	NSLog(@"pageAction: current page = %d", [sender currentPage]);
}


#pragma mark -
#pragma mark Lazy creation of controls

- (UISwitch *)switchCtl
{
    if (switchCtl == nil) 
    {
        switchCtl = [[UISwitch alloc] init];
        [switchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        switchCtl.backgroundColor = [UIColor clearColor];
		
		[switchCtl setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
		
		switchCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    }
    return switchCtl;
}

- (UISlider *)sliderCtl
{
    if (sliderCtl == nil) 
    {
        sliderCtl = [[UISlider alloc] init];
        [sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        sliderCtl.backgroundColor = [UIColor clearColor];
        
        sliderCtl.minimumValue = 0.0;
        sliderCtl.maximumValue = 100.0;
        sliderCtl.continuous = YES;
        sliderCtl.value = 50.0;

		// Add an accessibility label that describes the slider.
		[sliderCtl setAccessibilityLabel:NSLocalizedString(@"StandardSlider", @"")];
		
		sliderCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    }
    return sliderCtl;
}


- (void)sliderAction:(id)sender{
	UISlider *slider = (UISlider*)sender;
	NSLog(@"slider moved to %f", slider.value);
}

- (UIActivityIndicatorView *)progressInd
{
    if (progressInd == nil)
    {
        progressInd = [[UIActivityIndicatorView alloc] init];
        [progressInd startAnimating];
        progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [progressInd sizeToFit];
        progressInd.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleBottomMargin);
		
		progressInd.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    }
    return progressInd;
}

- (UIProgressView *)progressBar
{
    if (progressBar == nil) 
    {
        progressBar = [[UIProgressView alloc] init];
        CGRect frame = progressBar.frame;
		// need to set these or it doesn't appear for some reason
		frame.size.width = kUIProgressBarWidth;
		frame.size.height = kUIProgressBarHeight;
		progressBar.frame = frame;
		progressBar.progressViewStyle = UIProgressViewStyleDefault;
        progressBar.progress = 0.5;
		
		progressBar.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    }
    return progressBar;
}

@end

