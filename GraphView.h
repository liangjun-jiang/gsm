

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class GraphViewSegment;
@class GraphTextView;
@interface GraphView : UIView
{
	NSMutableArray *segments;
	GraphViewSegment *__unsafe_unretained current; // weak reference
	GraphTextView *text; // weak reference
}

// This should be able to reuse
-(void)addX:(UIAccelerationValue)x y:(UIAccelerationValue)y z:(UIAccelerationValue)z;
-(void)addRotationX:(float)x y:(float)y z:(float)z;
-(void)addAtttidueX:(float)x y:(float)y z:(float)z;


@end
