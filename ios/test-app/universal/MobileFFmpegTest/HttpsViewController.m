//
// HttpsViewController.m
//
// Copyright (c) 2018 Taner Sener
//
// This file is part of MobileFFmpeg.
//
// MobileFFmpeg is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MobileFFmpeg is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with MobileFFmpeg.  If not, see <http://www.gnu.org/licenses/>.
//

#import <MobileFFmpegConfig.h>
#import <MobileFFmpeg.h>
#import "HttpsViewController.h"

@interface HttpsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UITextField *urlText;
@property (strong, nonatomic) IBOutlet UIButton *getInfoButton;
@property (strong, nonatomic) IBOutlet UITextView *outputText;

@end

@implementation HttpsViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // STYLE UPDATE
    [Util applyEditTextStyle: self.urlText];
    [Util applyButtonStyle: self.getInfoButton];
    [Util applyOutputTextStyle: self.outputText];
    [Util applyHeaderStyle: self.header];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setActive];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)logCallback: (int)level :(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendOutput: message];
    });
}

- (IBAction)getInfoClicked:(id)sender {
    [self clearOutput];
    
    NSString *testUrl = [self.urlText text];
    if ([testUrl length] > 0) {
        NSLog(@"Testing HTTPS with url \'%@\'\n", testUrl);
    } else {
        testUrl = HTTPS_TEST_DEFAULT_URL;
        [self.urlText setText:testUrl];
        NSLog(@"Testing HTTPS with default url \'%@\'\n", testUrl);
    }
    
    // HTTPS COMMAND ARGUMENTS
    NSString* ffmpegCommand = [NSString stringWithFormat:@"-hide_banner -i %@ -f null -", testUrl];

    NSLog(@"FFmpeg process started with arguments\n\'%@\'\n", ffmpegCommand);

    // EXECUTE
    int result = [MobileFFmpeg execute: ffmpegCommand];

    NSLog(@"FFmpeg process exited with rc %d\n", result);
}

- (void)setActive {
    [MobileFFmpegConfig setLogDelegate:self];
}

- (void)clearOutput {
    [[self outputText] setText:@""];
}

- (void)appendOutput:(NSString*) message {
    self.outputText.text = [self.outputText.text stringByAppendingString:message];
    
    if (self.outputText.text.length > 0 ) {
        NSRange bottom = NSMakeRange(self.outputText.text.length - 1, 1);
        [self.outputText scrollRangeToVisible:bottom];
    }
}

@end
