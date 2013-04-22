//
//  ZAScrollView.m
//  TestScroll4
//
//  Created by zartarn on 08.01.13.
//  Copyright (c) 2013 zartarn. All rights reserved.
//

#import "ZAScrollView.h"

@interface ZAScrollView()

@property (nonatomic, retain) UIScrollView *scrollView;

@property(nonatomic, readonly) NSInteger firstVisibleItemIndex;
@property(nonatomic, readonly) NSInteger lastVisibleItemIndex;



@end


@implementation ZAScrollView

#pragma mark - init / destroy

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) dealloc
{
    [_scrollView release];
    
    [super dealloc];
}

- (void) setup
{
    _visibleItems = [[NSMutableSet alloc] init];
    _recycledItems = [[NSMutableSet alloc] init];
    
    _colCountH = 0;
    _rowCountH = 0;
    _colCountV = 0;
    _rowCountV = 0;
    _itemSize =  CGSizeZero;
    _itemsCount = 0;
    
    self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollView];

}

- (void) setColCount:(NSInteger)colCount rowCount:(NSInteger)rowCount onDirection:(enum ScrollItemsLayoutDirection)layoutDirection
{
    if (layoutDirection == ScrollItemsLayoutDirectionH) {
        _colCountH = colCount;
        _rowCountH = rowCount;
    } else if (layoutDirection == ScrollItemsLayoutDirectionV) {
        _colCountV = colCount;
        _rowCountV = rowCount;
    }
}

#pragma mark - UIView layouts

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    BOOL boundsChanged = !CGRectEqualToRect(_scrollView.frame, self.bounds);
    
    NSInteger _colCount;
    NSInteger _rowCount;
    
    if (boundsChanged)
    {
        NSMutableDictionary *pages = [[[NSMutableDictionary alloc] init] autorelease];
        
        int _perPage = [self perPage];
        int currentFirstItemIndex = _currentPage * _perPage;
        int currrentLastItemIndex = MIN(currentFirstItemIndex + _perPage - 1, [_delegate numberOfItemsInScrollView:self] - 1);
        
        _scrollView.frame = self.bounds;
        CGSize scrollSize = self.bounds.size;
        if (scrollSize.width > scrollSize.height)
        {
            _layoutDirection = ScrollItemsLayoutDirectionH;
        }
        else
        {
            _layoutDirection = ScrollItemsLayoutDirectionV;
        }
    
        _perPage = [self perPage];
        
        for (int i=currentFirstItemIndex; i <= currrentLastItemIndex; i++)
        {
            int newPageNumber = floorf((i + 0) / _perPage);
            id cnt = [pages objectForKey:[NSNumber numberWithInt:newPageNumber]];
            if (cnt == nil) {
                [pages setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:newPageNumber]];
            } else {
                int j = [cnt intValue];
                j++;
                [pages setObject:[NSNumber numberWithInt:j] forKey:[NSNumber numberWithInt:newPageNumber]];
            }
        }
        
        int newPage = 0;
        
        if ([pages count] > 0) {
            NSArray *arr = [pages allValues];
            NSArray *keys = [pages allKeys];
            NSNumber *max = [arr valueForKeyPath:@"@max.intValue"];
            int key = [arr indexOfObject:max];
            newPage = [[keys objectAtIndex:key] intValue];
        }
        
        _currentPage = newPage;
    }
    
    if (_layoutDirection == ScrollItemsLayoutDirectionH) {
        _colCount = _colCountH;
        _rowCount = _rowCountH;
    } else {
        _colCount = _colCountV;
        _rowCount = _rowCountV;
    }
    
    _rowGap = (self.bounds.size.height - _rowCount * _itemSize.height) / _rowCount;
    _colGap = (self.bounds.size.width - _colCount * _itemSize.width) / _colCount;
    
    _effectiveInsets = UIEdgeInsetsMake(
                                        _rowGap / 2,
                                        _colGap / 2,
                                        _rowGap / 2,
                                        _colGap / 2);
    
    [self loadItems:boundsChanged];
}

- (NSInteger)firstVisibleItemIndex
{
    int page = MAX(floorf(CGRectGetMinY(_scrollView.bounds) / _scrollView.frame.size.height), 0);
    return ( page * [self perPage] );
}

- (NSInteger)lastVisibleItemIndex
{
    int page = floorf(CGRectGetMaxY(_scrollView.bounds) / _scrollView.frame.size.height);
    return ( MIN((page+1)*[self perPage] - 1, _itemsCount - 1) );
}


#pragma mark Data


#pragma mark - Item Views

- (UIView *)viewForItemAtIndex:(NSUInteger)index
{
    for (UIView *item in _visibleItems)
        if (item.tag == index)
            return item;
    return nil;
}

- (void) loadItems:(BOOL)reDisplay
{
    _itemsCount = [_delegate numberOfItemsInScrollView:self];
    
    int _colCount = [self colCount];
    int _rowCount = [self rowCount];

    _scrollView.contentSize = CGSizeMake(
                                         self.bounds.size.width,
                                         (ceilf((float)_itemsCount / (_rowCount*_colCount))) * self.bounds.size.height
                                         );

    // calculate which items are visible
    int firstIndex = [self firstVisibleItemIndex];
    int lastIndex  = [self lastVisibleItemIndex];
    
    
    // recycle items that are no longer visible
    for (UIView *item in _visibleItems) {
        if (item.tag < firstIndex || item.tag > lastIndex) {
            [self recycleItem:item];
        }
    }
    [_visibleItems minusSet:_recycledItems];
    
    if (lastIndex < 0)
        return;
    
        for (int itemIndex=firstIndex; itemIndex <= lastIndex; itemIndex++)
        {
            UIView *item = [self viewForItemAtIndex:itemIndex];
            if (item == nil) {
                NSLog(@"new item");
                UIView *pp = [_delegate viewForItemInScrollView:self atIndex:itemIndex];
                pp.tag = itemIndex; // + 100
                item = pp;
                [_scrollView addSubview:item];
                [_visibleItems addObject:item];
            } else if (!reDisplay) {
                continue;
            }

            CGRect rect = [self rectForItemAtIndex:(itemIndex)];
            item.frame = rect;
            [item setNeedsDisplay];
        }
}

- (CGRect)rectForItemAtIndex:(NSUInteger)index
{
    NSInteger row;
    NSInteger col;

    int _colCount = [self colCount];
    int _rowCount = [self rowCount];
    
    int page = index / [self perPage];
    index = index % [self perPage];
    
    if (_layoutDirection == ScrollItemsLayoutDirectionV) {
        row = index / _colCount;
        col = index % _colCount;
    } else {
        col = index / _rowCount;
        row = index % _rowCount;
    }
    
    CGRect rect = CGRectMake(_effectiveInsets.left + (_itemSize.width  + _colGap) * col,
                       _effectiveInsets.top  + (_itemSize.height + _rowGap) * row,
                       _itemSize.width, _itemSize.height);
    rect.origin.y += page * _scrollView.frame.size.height;
    return rect;
}


#pragma mark - state

- (NSInteger) perPage
{
    int _colCount = [self colCount];
    int _rowCount = [self rowCount];
    
    return (_colCount * _rowCount);
}

- (NSInteger) colCount
{
    return (_layoutDirection == ScrollItemsLayoutDirectionH ? _colCountH : _colCountV);
}

- (NSInteger) rowCount
{
    return (_layoutDirection == ScrollItemsLayoutDirectionH ? _rowCountH : _rowCountV);
}

#pragma change currentpage from Out

- (void) changeCurrentPage
{
    CGFloat height = _scrollView.frame.size.height;
    [_scrollView setContentOffset:CGPointMake(0, _currentPage*height)];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat fy = scrollView.bounds.origin.y;
    CGFloat height = scrollView.frame.size.height;
    
    int _curPage = floorf((fy + height / 2) / height);
    _currentPage = _curPage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self loadItems:NO];
}


#pragma mark Recycling

// It's the caller's responsibility to remove this item from _visibleItems,
// since this method is often called while traversing _visibleItems array.
- (void)recycleItem:(UIView *)item
{
    [_recycledItems addObject:item];
    [item removeFromSuperview];
}

- (UIView *)dequeueReusableItem
{
    UIView *result = [_recycledItems anyObject];
    if (result) {
        [_recycledItems removeObject:[[result retain] autorelease]];
    }
    return result;
}

// clear data

- (void)clearData
{
    // recycle all items
    for (UIView *view in _visibleItems) {
        [self recycleItem:view];
    }
    [_visibleItems removeAllObjects];
    _scrollView.frame = CGRectZero;
    _scrollView.contentOffset = CGPointMake(0.f, 0.f);
    _currentPage = 0;
    
//    [self setNeedsLayout];
}


@end
