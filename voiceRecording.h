//  voiceRecording.h
//
//  Created by Önder ÖZCAN on 18/04/14.
//  Copyright (c) 2014 Pixelblind, Inc. All rights reserved.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface voiceRecording : UIViewController<AVAudioPlayerDelegate,AVAudioRecorderDelegate>

- (IBAction)recordAudio:(id)sender;

- (IBAction)playAudio:(id)sender;

- (IBAction)stopAudio:(id)sender;

- (IBAction)closeModal:(id)sender;

- (IBAction)closeModalWithoutSave:(id)sender;

@property (strong, nonatomic) NSString *recordName;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *closeWithoutSave;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (strong,nonatomic) UIImageView *myView;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (strong, nonatomic) NSURL *soundURLPath;


-(void)setWorkOrder:(Work_Order__c*)Order;
-(void)setAttachment:(Attachment *)attach;
@end