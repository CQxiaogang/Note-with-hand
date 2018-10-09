//
//  ChessPiecesView.m
//  OC-黑白棋
//
//  Created by lanou3g on 16/6/13.
//  Copyright © 2016年 ezor. All rights reserved.
//

#import "ChessPiecesView.h"

@implementation ChessPiecesView
@synthesize indexPath = _indexPath;
- (void)setChessKind:(ChessKind)chessKind{
    _chessKind = chessKind;
    
    [self setNeedsDisplay];
}
- (instancetype)initWithFrame:(CGRect)frame andIndexPath:(NSIndexPath *)indexPath
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _indexPath = indexPath;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGRect temp = CGRectMake(1, 1, CGRectGetWidth(rect) - 2, CGRectGetHeight(rect) - 2);
    if (_chessKind == BlackChess) {
        UIImage *image = [UIImage imageNamed:@"blackChess"];
        [image drawInRect:temp];
    }else if (_chessKind == WhiteChess) {
        UIImage *image = [UIImage imageNamed:@"whiteChess"];
        [image drawInRect:temp];
    }else if (_chessKind == CanChess) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2) radius:CGRectGetWidth(rect) / 8 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        
        [[UIColor colorWithRed:106 / 255.0 green:171 / 255.0 blue:71 / 255.0 alpha:1] set];
        
        [path fill];
    }
}
@end
