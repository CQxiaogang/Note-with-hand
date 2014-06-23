//
//  UnlockViewController.h
//  WithTheNote
//
//  Created by student on 14-5-16.
//  Copyright (c) 2014年 JL. All rights reserved.
//

//-fno-objc-arc
#import "ViewController.h"
#import "MJPasswordView.h"

@interface UnlockViewController : ViewController<MJPasswordDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
