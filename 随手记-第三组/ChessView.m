//
//  ChessView.m
//  OC-黑白棋
//
//  Created by lanou3g on 16/6/13.
//  Copyright © 2016年 ezor. All rights reserved.
//

#import "ChessView.h"
#import "ChessPiecesView.h"

#define WDWidth self.frame.size.width
#define WDHeight self.frame.size.height

typedef NSIndexPath *(^path)(int i);

@interface ChessView (){
    CGFloat _heightMargin;
    CGFloat _widthMargin;
    CGFloat _lineWidthMargin;
    CGFloat _lineHeightMargin;
}

@property (nonatomic , strong) NSMutableArray <__kindof ChessPiecesView*
>*blackChessArray;
@property (nonatomic , strong) NSMutableArray <__kindof ChessPiecesView*
>*whiteChessArray;
@property (nonatomic , assign) BOOL isBlack;

@end

@implementation ChessView

- (NSMutableArray <__kindof ChessPiecesView*
   >*)blackChessArray{
    if (!_blackChessArray) {
        _blackChessArray = [NSMutableArray array];
    }
    return _blackChessArray;
}

- (NSMutableArray <__kindof ChessPiecesView*
   >*)whiteChessArray{
    if (!_whiteChessArray) {
        _whiteChessArray = [NSMutableArray array];
    }
    return _whiteChessArray;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _widthMargin = WDWidth / 20;
        _heightMargin = WDHeight / 20;
        _lineWidthMargin = (WDWidth - _widthMargin * 2) / 8;
        _lineHeightMargin = (WDHeight - _heightMargin * 2) / 8;
        _isBlack = YES;
        for (int y = 1; y <= 8; y ++) {
            for (int x = 1; x <= 8; x ++) {
                ChessPiecesView *chess = [[ChessPiecesView alloc] initWithFrame:CGRectMake(_widthMargin + (x - 1) * _lineWidthMargin,_heightMargin + (y - 1) * _lineHeightMargin,_lineWidthMargin,_lineHeightMargin) andIndexPath:[NSIndexPath indexPathForRow:x inSection:y]];
                
                chess.chessKind = NormalChess;
                
                chess.tag = x + y * 10 + 100;
                
                if ((x == 4&&y == 4)||(x == 5&&y == 5)){
                    chess.chessKind = BlackChess;
                    
                    [self.blackChessArray addObject:chess];
                }else if ((x == 4&&y == 5)||(x == 5&&y ==4)){
                    chess.chessKind = WhiteChess;
                    
                    [self.whiteChessArray addObject:chess];
                }
                [self addSubview:chess];
            }
        }
        
        [self judgeCanChess];
    }
    return self;
}

- (ChessPiecesView *)chessWithIndexPath:(NSIndexPath *)indexPath{
    NSInteger tag = indexPath.row + indexPath.section * 10 + 100;
    
    return [self viewWithTag:tag];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *rectPathBig = [UIBezierPath bezierPathWithRect:rect];
    
    [[UIColor colorWithRed:107 / 255.0 green: 37 / 255.0 blue: 11 / 255.0 alpha: 1] setFill];
    
    [rectPathBig fill];
    
    UIBezierPath *rectPathSmall = [UIBezierPath bezierPathWithRect:CGRectMake(_widthMargin, _heightMargin, CGRectGetWidth(rect) - _widthMargin * 2, CGRectGetHeight(rect) - _heightMargin * 2)];
    
    [[UIColor colorWithRed: 40 / 255.0 green: 108 / 255.0 blue: 47 / 255.0 alpha: 1] setFill];
    
    [rectPathSmall fill];
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
    for (int i = 0; i < 9; i++) {
        CGPoint pointStart = CGPointMake(_lineWidthMargin * i + _widthMargin, _heightMargin);
        
        [linePath moveToPoint:pointStart];
        
        CGPoint pointEnd = CGPointMake(_lineWidthMargin * i + _widthMargin, WDHeight - _heightMargin);
        
        [linePath addLineToPoint:pointEnd];
    }
    for (int i = 0; i < 9; i++) {
        [linePath moveToPoint:CGPointMake(_widthMargin, _lineHeightMargin * i + _heightMargin)];
        
        [linePath addLineToPoint:CGPointMake(WDWidth - _widthMargin, _lineHeightMargin * i + _heightMargin)];
    }
    [[UIColor blackColor] setStroke];
    
    [linePath stroke];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    
    for (ChessPiecesView *item in self.subviews) {
        if (CGRectContainsPoint(item.frame, [touch locationInView:self])) {
            if (item.chessKind == CanChess) {
                if (_isBlack) {
                    item.chessKind = BlackChess;
                }else{
                    item.chessKind = WhiteChess;
                }
                _isBlack = !_isBlack;
                
                [self putInChess:item];
            }
            
            break;
        }
        
    }
    
}
#pragma mark ==================判断哪个位置能下=================
- (void)judgeCanChess{
    [self clearAllCanChess];
    NSArray *array  = nil;
    if (_isBlack) {
        array = self.blackChessArray;
    }else{
        array = self.whiteChessArray;
    }

    for (ChessPiecesView *chess in array) {
        NSInteger x = chess.indexPath.row;
        NSInteger y = chess.indexPath.section;
        //上
        [self judgeFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
            return [NSIndexPath indexPathForRow:x inSection:y - i];
        }];
        //下
        [self judgeFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
            return [NSIndexPath indexPathForRow:x inSection:y + i];
        }];
        //左
        [self judgeFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
            return [NSIndexPath indexPathForRow:x - i inSection:y];
        }];
        //右
        [self judgeFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
            return [NSIndexPath indexPathForRow:x + i inSection:y];
        }];
        //左上
        [self judgeFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
            return [NSIndexPath indexPathForRow:x - i inSection:y - i];
        }];
        //左下
        [self judgeFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
            return [NSIndexPath indexPathForRow:x - i inSection:y + i];
        }];
        //右上
        [self judgeFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
            return [NSIndexPath indexPathForRow:x + i inSection:y - i];
        }];
        //右下
        [self judgeFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
            return [NSIndexPath indexPathForRow:x + i inSection:y + i];
        }];
    }
    
    for (ChessPiecesView *item in self.subviews) {
        if (item.chessKind == CanChess) {
            return;
        }
    }
    
    _isBlack = !_isBlack;
    
    for (ChessPiecesView *item in self.subviews) {
        if (item.chessKind == NormalChess) {
            item.chessKind = CanChess;
        }
    }
}

- (void)clearAllCanChess{
    for (ChessPiecesView *item in self.subviews) {
        if (item.chessKind == CanChess) {
            item.chessKind = NormalChess;
        }
    }
}
 
- (void)judgeFromChess:(ChessPiecesView *)chess andIndexBlock:(path)path{
    NSIndexPath *indexPath = nil;
    
    int i = 1;

    while (1) {
        
        ChessPiecesView *compareChessUp = [self chessWithIndexPath:path(i)];
        
        if (compareChessUp != nil) {
            if (compareChessUp.chessKind == BlackChess) {
                if (!_isBlack) {
                    indexPath = path(i + 1);
                }else{
                    indexPath = nil;
                    break;
                }
            }else if (compareChessUp.chessKind == WhiteChess) {
                if (_isBlack) {
                    indexPath = path(i + 1);
                }else{
                    indexPath = nil;
                    break;
                }
            }else if (compareChessUp.chessKind == CanChess || compareChessUp.chessKind == NormalChess) {
                break;
            }
        }else{
            break;
        }
        
        i ++;
    }
    ChessPiecesView *chesses = [self chessWithIndexPath:indexPath];
    
    chesses.chessKind = CanChess;
}
#pragma mark ================下子后的操作=================
- (void)putInChess:(ChessPiecesView *)chess{
    NSInteger x = chess.indexPath.row;
    
    NSInteger y = chess.indexPath.section;
    //上
    [self putInFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
        return [NSIndexPath indexPathForRow:x inSection:y - i];
    }];
    //下
    [self putInFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
        return [NSIndexPath indexPathForRow:x inSection:y + i];
    }];
    //左
    [self putInFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
        return [NSIndexPath indexPathForRow:x - i inSection:y];
    }];
    //右
    [self putInFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
        return [NSIndexPath indexPathForRow:x + i inSection:y];
    }];
    //左上
    [self putInFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
        return [NSIndexPath indexPathForRow:x - i inSection:y - i];
    }];
    //右下
    [self putInFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
        return [NSIndexPath indexPathForRow:x + i inSection:y + i];
    }];
    //左下
    [self putInFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
        return [NSIndexPath indexPathForRow:x - i inSection:y + i];
    }];
    //右上
    [self putInFromChess:chess andIndexBlock:^NSIndexPath *(int i) {
        return [NSIndexPath indexPathForRow:x + i inSection:y - i];
    }];
    [self getAllChess];
    
    [self judgeCanChess];
}

- (void)getAllChess{
    [self.blackChessArray removeAllObjects];
    [self.whiteChessArray removeAllObjects];
    
    for (ChessPiecesView *item in self.subviews) {
        if (item.chessKind == BlackChess) {
            [self.blackChessArray addObject:item];
        }else if (item.chessKind == WhiteChess){
            [self.whiteChessArray addObject:item];
        }
    }
    
    self.blackCount = self.blackChessArray.count;
    
    self.whiteCount = self.whiteChessArray.count;
    
    if (self.blackCount + self.whiteCount == 64) {
        if (self.blackCount > self.whiteCount) {
            self.winKind = BlackWin;
        }else if (self.blackCount < self.whiteCount){
            self.winKind = WhiteWin;
        }else{
            self.winKind = Equal;
        }
    }else if (self.blackCount == 0){
        self.winKind = WhiteWin;
    }else if (self.whiteCount == 0){
        self.winKind = BlackWin;
    }
    
}

- (void)putInFromChess:(ChessPiecesView *)chess andIndexBlock:(path)path{
    NSMutableArray *chessArray = [NSMutableArray array];
    int i = 1;
    while (1) {
        NSIndexPath *indexPath = path(i);
        
        ChessPiecesView *chessUp = [self chessWithIndexPath:indexPath];
        
        if (chess.chessKind == BlackChess) {
            if (chessUp.chessKind == WhiteChess) {
                [chessArray addObject:chessUp];
            }else if (chessUp.chessKind == BlackChess){
                break;
            }else{
                [chessArray removeAllObjects];
                break;
            }
        }else if (chess.chessKind == WhiteChess) {
            if (chessUp.chessKind == BlackChess) {
                [chessArray addObject:chessUp];
            }else if (chessUp.chessKind == WhiteChess){
                break;
            }else{
                [chessArray removeAllObjects];
                break;
            }
        }
        
        i++;
    }
    for (ChessPiecesView *item in chessArray) {
        item.chessKind = chess.chessKind;
    }
}

@end

