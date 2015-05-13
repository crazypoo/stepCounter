//
//  BPDViewController.m
//  stepsCounter
//
//  Created by Antonio de Carvalho Jr on 4/11/15.
//  Copyright (c) 2015 AntonioRCJr. All rights reserved.
//

#import "BPDMainViewController.h"

@interface BPDMainViewController ()

@end

@implementation BPDMainViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *readDataTypes = [self dataTypesToRead];
        
        if (!self.healthStore) {
            self.healthStore = [HKHealthStore new];
        }
        
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"The user allow the app to read information about StepCount");
            });
        }];
    }

}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *steps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    return [NSSet setWithObjects:steps, nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)countSteps:(id)sender {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    self.numSteps = 0;
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create the query
    HKStatisticsCollectionQuery *query =
        [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                          quantitySamplePredicate:nil
                                                          options:HKStatisticsOptionCumulativeSum
                                                       anchorDate:anchorDate
                                               intervalComponents:interval];
    
    // Set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
        }
        
        NSDate *endDate = self.endData.date;
        NSDate *startDate = self.startData.date;
        
        [results enumerateStatisticsFromDate:startDate
                                      toDate:endDate
                                   withBlock:^(HKStatistics *result, BOOL *stop) {
                                       HKQuantity *quantity = result.sumQuantity;

                                       if (quantity) {
                                           NSDate *date = result.startDate;
                                           double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                                           //stepsCount = stepsCount + value;
                                           self.numSteps = self.numSteps + value;
                                       }
                                       
                                       NSLog(@"%f", self.numSteps);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           self.stepsLabel.text = [NSString stringWithFormat:@"%.f", self.numSteps];
                                       });
                                   }];
    };
    
    [self.healthStore executeQuery:query];
}
@end