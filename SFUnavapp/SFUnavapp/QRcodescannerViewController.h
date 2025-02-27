//
//  QRcodescannerViewController.h
//  SFUnavapp
//  Team NoMacs
//
//  Created by James Leong on 2015-03-27.
//  Copyright (c) 2015 Team NoMacs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QRcodescannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UITextView *lblStatus;
@property (weak, nonatomic) IBOutlet UIButton *buttonStart;

@end
