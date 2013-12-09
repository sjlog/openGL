//
//  ViewController.m
//  OpenGL
//
//  Created by sangjo_itwill on 2013. 12. 6..
//  Copyright (c) 2013년 sj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        EAGLView *contentView = [[EAGLView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    
        self.view = contentView;
        
        [contentView startAnimation];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
