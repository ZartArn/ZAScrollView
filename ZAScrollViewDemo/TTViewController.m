//
//  TTViewController.m
//  ZAScrollViewDemo
//
//  Created by Zart Arn on 22.04.13.
//  Copyright (c) 2013 Zart Arn. All rights reserved.
//

#import "TTViewController.h"
#import "DemoItemView.h"

@interface TTViewController ()

@property (nonatomic, retain) ZAScrollView *scrollView;
@end

@implementation TTViewController

#pragma mark - NSObjects

- (void)dealloc
{
    [_scrollView release];
    
    [super dealloc];
}

#pragma mark - ViewController LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scrollView = [[[ZAScrollView alloc] init] autorelease];
    self.scrollView.frame = self.view.bounds;
//    _scrollView.backgroundColor = [UIColor yellowColor];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollView setColCount:3 rowCount:3 onDirection:ScrollItemsLayoutDirectionV];
    [self.scrollView setColCount:4 rowCount:2 onDirection:ScrollItemsLayoutDirectionH];
    self.scrollView.delegate = self;
    self.scrollView.itemSize = CGSizeMake(200.f, 250.f);
    
    [self.view addSubview:self.scrollView];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.scrollView changeCurrentPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - ZAScrollViewDelegate

- (NSInteger)numberOfItemsInScrollView:(ZAScrollView *)scrollView
{
    return 72;
}

- (UIView *)viewForItemInScrollView:(ZAScrollView *)scrollView atIndex:(NSInteger)itemIndex
{
    DemoItemView *itemView = (DemoItemView *) [scrollView dequeueReusableItem];
    if (itemView == nil) {
        itemView = [[[DemoItemView alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    // set data this ...
    
    return itemView;
}

@end
