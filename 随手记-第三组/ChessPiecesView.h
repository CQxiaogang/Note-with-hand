//
//  ChessPiecesView.h
//  OC-黑白棋
//
//  Created by lanou3g on 16/6/13.
//  Copyright © 2016年 ezor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ChessKind{
    NormalChess = 0,
    CanChess,
    BlackChess,
    WhiteChess
}ChessKind;

@interface ChessPiecesView : UIView

@property (nonatomic , assign) ChessKind chessKind;

@property (nonatomic , strong,readonly) NSIndexPath *indexPath;

- (instancetype)initWithFrame:(CGRect)frame andIndexPath:(NSIndexPath *)indexPath;

@end
