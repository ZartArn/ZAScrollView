//
//  ZAScrollView.h
//  TestScroll4
//
//  Created by zartarn on 08.01.13.
//  Copyright (c) 2013 zartarn. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ScrollItemsLayoutDirection {
    ScrollItemsLayoutDirectionH = 0,
    ScrollItemsLayoutDirectionV = 1
};
@protocol ZAScrollViewDelegate;

@interface ZAScrollView : UIView <UIScrollViewDelegate>
{
    UIEdgeInsets    _contentInsets;
    CGSize          _itemSize;
    enum ScrollItemsLayoutDirection _layoutDirection;
    
    // state
    NSInteger       _itemsCount;
    NSInteger       _currentPage;
    NSMutableSet   *_recycledItems;
    NSMutableSet   *_visibleItems;
    
    // geometry
    NSInteger       _colCountH;
    NSInteger       _rowCountH;
    NSInteger       _colCountV;
    NSInteger       _rowCountV;
    CGFloat         _rowGap;
    CGFloat         _colGap;
    UIEdgeInsets    _effectiveInsets;
    
}

@property(nonatomic, assign) id<ZAScrollViewDelegate> delegate;

@property(nonatomic, assign) UIEdgeInsets contentInsets;

@property(nonatomic) CGSize itemSize;
@property(nonatomic, readonly) NSInteger itemsCount;
@property(nonatomic, readonly) NSInteger colCountH;
@property(nonatomic, readonly) NSInteger rowCountH;
@property(nonatomic, readonly) NSInteger colCountV;
@property(nonatomic, readonly) NSInteger rowCountV;
@property (nonatomic) enum ScrollItemsLayoutDirection layoutDirection;
//@property (nonatomic, retain) NSMutableSet *visibleItems;
//@property (nonatomic, retain) NSMutableSet *recycledItems;

@property (nonatomic, readonly) int currentPage;

//- (id)initWithFrame:(CGRect)frame withParams:(NSDictionary *)params;
- (void) setColCount:(NSInteger)colCount rowCount:(NSInteger)rowCount onDirection:(enum ScrollItemsLayoutDirection)layoutDirection;
- (void) changeCurrentPage; // :(int) newPage;
- (UIView *)dequeueReusableItem;  // nil if none
- (void)clearData;

@end


@protocol ZAScrollViewDelegate <NSObject>

@required

- (NSInteger)numberOfItemsInScrollView:(ZAScrollView *)scrollView;
- (UIView *)viewForItemInScrollView:(ZAScrollView *)scrollView atIndex:(NSInteger)itemIndex;
//- (UIView *)viewForItemInArrayView:(ATArrayView *)arrayView atIndex:(NSInteger)index;

@end

