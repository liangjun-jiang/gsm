#import <UIKit/UIKit.h>


// A popup view
@protocol PopListViewDelegate;
@interface PopListView : UIView 

@property (nonatomic, assign) id<PopListViewDelegate> delegate;
- (id)initWithData:(NSDictionary *)aDict;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@end

@protocol PopListViewDelegate <NSObject>
- (void)popListView:(PopListView *)popListView didSelectedIndex:(NSInteger)anIndex;
- (void)popListViewDidCancel;
@end