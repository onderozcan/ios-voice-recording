//  voiceRecording.m
//
//  Created by Önder ÖZCAN on 18/04/14.
//  Copyright (c) 2014 Pixelblind, Inc. All rights reserved.
//

#import "voiceRecording.h"

@implementation voiceRecording
{

    Work_Order__c *_workOrder;
    Attachment * _attachment;
    NSManagedObjectContext *moc;
    
}

@synthesize buttonsView,myView;

@synthesize soundURLPath,recordName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    moc= [app getContext];
    
    if(recordName.length == 0)
    {
        
        [_recordButton setEnabled:YES];
        
        [_stopButton setEnabled:NO];
        
        [_playButton setEnabled:NO];
        
        [_playButton setAlpha:0.5];
        
        [_closeWithoutSave setTag:1];
        
        [_closeButton setTag:1];
        
        
    } else {
        
        [_closeWithoutSave setTitle:@"Delete" forState:UIControlStateNormal];
        
        [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
        
        [_closeWithoutSave setTag:0];
        
        [_closeButton setTag:0];
        
        [_playButton setAlpha:1.0];
        
        [_recordButton setEnabled:NO];
        
        [_stopButton setEnabled:NO];
        
        [_playButton setEnabled:YES];
    }
    
    _closeButton.layer.cornerRadius = 5.0;
    
    _closeWithoutSave.layer.cornerRadius = 5.0;

}

-(NSString *)makeUniqueString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMddHHmmss"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    int randomValue = arc4random() % 1000;
    
    NSString *unique = [NSString stringWithFormat:@"%@.%d",dateString,randomValue];
    
    return unique;
}



-(void)saveVoicetoCoreData:(NSURL *)soundURL  soundName : (NSString *)soundFileName
{
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSData *voiceData=nil;
    
    voiceData = [[NSData alloc] initWithContentsOfURL:soundURL];
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:soundFileName];
    
    NSError * error = nil;
    
    [voiceData writeToFile:path options:NSDataWritingAtomic error:&error];
    
    Attachment* file=[NSEntityDescription insertNewObjectForEntityForName:@"Attachment" inManagedObjectContext:moc];
    file.isDirty = [NSNumber numberWithInt:1];

    file.filePath=path;
    
    file.name=soundFileName;
    
    file.workOrder=_workOrder;
    
    file.contentType = @"audio/x-caf";
    
    file.parentId=[_workOrder valueForKey:@"id"];
    
    NSError*err;
    
    [moc save:&err];
    
    if (err != nil) {
        NSLog(@"Error while saving into file: %@", err);
        return;
    }
    
}

-(void)removeVoice
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    Attachment* attachment = (Attachment *) [moc existingObjectWithID:_attachment.objectID error:nil];
    
    
    [fileManager removeItemAtPath:attachment.filePath error:NULL];
    [moc deleteObject:attachment];
    [moc save:nil];
    
}

- (IBAction)recordAudio:(id)sender {
    
    if (!_audioRecorder.recording)
    {
        
        if(recordName.length == 0)
        {
            
            NSArray *dirPaths;
            
            NSString *docsDir;
            
            dirPaths = NSSearchPathForDirectoriesInDomains(
                                                           NSDocumentDirectory, NSUserDomainMask, YES);
            docsDir = dirPaths[0];
            
            NSString *soundFilePath;
            recordName = _workOrder.name;
            
            NSString *dateString = [self makeUniqueString];
            
            recordName = [recordName stringByAppendingFormat:@"-%@%@",dateString,@".caf"];
            
            soundFilePath = [docsDir
                             stringByAppendingPathComponent:recordName];
            
            
            soundFilePath = [soundFilePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *escapedUrlString = [soundFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            soundURLPath = [NSURL URLWithString:escapedUrlString];
            
            
            NSDictionary *recordSettings = [NSDictionary
                                            dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:AVAudioQualityMin],
                                            AVEncoderAudioQualityKey,
                                            [NSNumber numberWithInt:16],
                                            AVEncoderBitRateKey,
                                            [NSNumber numberWithInt: 2],
                                            AVNumberOfChannelsKey,
                                            [NSNumber numberWithFloat:44100.0],
                                            AVSampleRateKey,
                                            nil];
            
            NSError *error = nil;
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                                error:nil];
            
            NSLog(@"sound path url = %@",soundURLPath);
            
            _audioRecorder = [[AVAudioRecorder alloc]
                              initWithURL:soundURLPath
                              settings:recordSettings
                              error:&error];
            
            if (error)
            {
                NSLog(@"error: %@", [error localizedDescription]);
            } else {
                [_audioRecorder prepareToRecord];
            }
            
        }

        [_audioRecorder record];
        
        UIImage *spinner = [UIImage imageNamed:@"stopspinner.png"];
        
        myView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 0.0, spinner.size.width, spinner.size.height)];
        
        myView.image = spinner;
        
        [buttonsView addSubview:myView];
        

        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             _recordButton.alpha = 0.0;
                             
                             _stopButton.alpha = 1.1;
                             
                             _playButton.alpha = 0.5;
                             
                             
                         } completion:^(BOOL finished){
                             
                             [_recordButton setEnabled:NO];
                             
                             [_stopButton setEnabled:YES];
                             
                             [_playButton setEnabled:NO];
                         } ];
        
        [self runSpinAnimationWithDuration:0.06f];

        
    } else {
        
        
        [_audioRecorder pause];
        
        [myView.layer removeAnimationForKey:@"rotationAnimation"];
    }
    
}

- (void) runSpinAnimationWithDuration:(CGFloat) duration;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * 2 * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [myView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (IBAction)playAudio:(id)sender {
    
    if (!_audioRecorder.recording)
    {
        NSError *error;
        
        
        
        _audioPlayer = [[AVAudioPlayer alloc]
                        initWithContentsOfURL:soundURLPath
                        error:&error];
        
        _audioPlayer.delegate = self;
        
        if (error)
            NSLog(@"Error: %@",
                  [error localizedDescription]);
        else
            [_audioPlayer play];
    }

}

- (IBAction)stopAudio:(id)sender {
    
    //_recordButton.title = @"Record";
    
    if (_audioRecorder.recording)
    {
        [_audioRecorder stop];
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             _recordButton.alpha = 1.0;
                             
                             _playButton.alpha = 1.0;
                             
                             _stopButton.alpha = 0.0;
                             
                         } completion:^(BOOL finished){
                             
                             [_recordButton setEnabled:YES];
                             
                             [_stopButton setEnabled:NO];
                             
                             [_playButton setEnabled:YES];
                         } ];
        
        [myView removeFromSuperview];

    }

}

- (IBAction)closeModal:(id)sender {
    
    
    if(recordName.length > 0 & _closeButton.tag == 1)
    {
        [self saveVoicetoCoreData:soundURLPath soundName:recordName];
        
    }
    

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeModalWithoutSave:(id)sender {
    
    if(recordName.length > 0 && _closeButton.tag == 0)
    {
        [self removeVoice];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void)setWorkOrder:(Work_Order__c*)Order{
    _workOrder = Order;


}
-(void)setAttachment:(Attachment *)attach{

    _attachment = attach;

}
@end
