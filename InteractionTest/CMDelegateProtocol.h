//
//  CMDelegateProtocol.h
//  MotionManagerDataSharing
//
//  Created by Sam Beedell on 02/04/15.
// http://iphonedevsdk.com/forum/iphone-sdk-development/54859-sharing-data-between-view-controllers-other-objects.html

#import <UIKit/UIKit.h>

@class CMDataObject;

@protocol CMDelegateProtocol

- (CMDataObject*) theMMDataObject;

@end
