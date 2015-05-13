//
//  BPDViewController.h
//  stepsCounter
//
//  Created by Antonio de Carvalho Jr on 4/11/15.
//  Copyright (c) 2015 AntonioRCJr. All rights reserved.
//

@import UIKit;
@import HealthKit;

@interface BPDMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *startData;
@property (weak, nonatomic) IBOutlet UIDatePicker *endData;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property HKHealthStore *healthStore;
@property double numSteps;

- (IBAction)countSteps:(id)sender;

@end


