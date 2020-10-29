%% Chess V3.5 ALPHA BETA PRUNING by Dallas Hart
var HUMAN_PLAYER:boolean:=true
var W_KING,B_KING:boolean:=true
var P1_PLY_DEPTH:int:=5
var P2_PLY_DEPTH:int:=3
var NUM_OF_PRUNES:int:=0
var avtimo : real := 0
var eval : flexible array 1 .. 0 of int
var find_moves : flexible array 1 .. 0 of int
var time_per_move : flexible array 1 .. 0 of real
var EVALUATE_TOTAL : real
var ADD_OR_SUB : array 0 .. 1 of int
var AI_BEST_MOVE : string (4)
var POSSIBLE_KNIGHT_MOVES : array 0 .. 1, 1 .. 8 of int := init
(1, 2, 2, 1, -1, -2, -2, -1,
     2, 1, -1, -2, -2, -1, 1, 2)
var pos_pos : int := -1
var DESIRED_MOVE : string
var FOUND_MOVE : boolean := false
var REAL_TURN : boolean := true
var LEGAL_MOVE : boolean := false
var COLLISION_DETECT : boolean := false
var THEOR_MOVE_COORDS : array 0 .. 1 of int
var LEGAL_MOVES : flexible array 0 .. 0 of string (4)
var CUR_BOARD_POS : array 1 .. 8, 1 .. 8 of int := init %% Starting Board Position
(4, 1, 0, 0, 0, 0, -1, -4,
     2, 1, 0, 0, 0, 0, -1, -2,
     3, 1, 0, 0, 0, 0, -1, -3,
     5, 1, 0, 0, 0, 0, -1, -5,
     6, 1, 0, 0, 0, 0, -1, -6,
     3, 1, 0, 0, 0, 0, -1, -3,
     2, 1, 0, 0, 0, 0, -1, -2,
     4, 1, 0, 0, 0, 0, -1, -4)

var pawn_table : array 1 .. 8, 1 .. 8 of int := init %% Starting Board Position
(0, 5, 5, 0, 5, 10, 50, 0,
     0, 10, -5, 0, 5, 10, 50, 0,
     0, 10, -10, 0, 10, 20, 50, 0,
     0, -25, 0, 25, 27, 30, 50, 0,
     0, -25, 0, 25, 27, 30, 50, 0,
     0, 10, -10, 0, 10, 20, 50, 0,
     0, 10, -5, 0, 5, 10, 50, 0,
     0, 5, 5, 0, 5, 10, 50, 0)

var knight_table : array 1 .. 8, 1 .. 8 of int := init   %% Starting Board Position
(-50, -40, -30, -30, -30, 30, -40, -50,
     - 40, -20, 5, 0, 5, 0, -20, -40,
     - 20, 0, 10, 15, 15, 10, 0, -30,
     - 30, 5, 15, 20, 20, 15, 0, -30,
     - 30, 5, 15, 20, 20, 15, 0, -30,
     - 20, 0, 10, 15, 15, 10, 0, -30,
     - 40, -20, 5, 0, 5, 0, -20, -40,
     - 50, -40, -30, -30, -30, -30, -40, -50)

var bishop_table : array 1 .. 8, 1 .. 8 of int := init   %% Starting Board Position
(-20, -10, -10, -10, -10, -10, -10, -20,
     - 10, 5, 10, 0, 0, 0, 0, -10,
     - 40, 0, 10, 10, 5, 5, 0, -10,
     - 10, 0, 10, 10, 10, 10, 0, -10,
     - 10, 0, 10, 10, 10, 10, 0, -10,
     - 40, 0, 10, 10, 5, 5, 0, -10,
     - 10, 5, 10, 0, 0, 0, 0, -10,
     - 20, -10, -10, -10, -10, -10, -10, -20)

var rook_table : array 1 .. 8, 1 .. 8 of int := init   %% Starting Board Position
(25, 1, 0, 10, 0, 0, -5, 0,
     -20, 1, 10, 0, 0, 0, -5, 0,
     20, 1, 10, 0, 0, 0, 10, 0,
     40, 1, 10, -5, -5, 0, 25, 15,
     40, 1, 10, -5, -5, 0, 25, 15,
     20, 10, 10, 0, 0, 0, 10, 0,
     -20, 1, 10, 0, 0, 0, -5, 0,
     25, 1, 10, 0, 0, 0, -5, 0)

var king_table : array 1 .. 8, 1 .. 8,1..2 of int := init  %% Starting Board Position

(20, -50, 20, -30, -10 ,-30, -20, -30,
     -30, -30, -30, -30, -30, -30, -30, -50,
     30, -30, 20, -30, -20, -10, -30, -10,
     -40, -10, -40, -10, -40, -20, -40, -40,
     10, -30, 0, 0, -20, 20, -30, 30,
     -40, 30, -40, 20, -40, -10, -40, -30,
     0, -30, 0, 0, -20, 30, -40, 40,
     -50, 40, -50, 30, -50, 0, -50, -20,
     0, -30, 0, 0, -20, 30, -40, 40,
     -50, 40, -50, 30, -50, 0, -50, -20,
     10, -30, 0, 0, -20, 20, -30, 30,
     -40, 30, -40, 20, -40, -10, -40, -30,
     30, -30, 20, -30, -20, -10, -30, -10,
     -40, -10, -40, -10, -40, -20, -40, -40,
     20, -50, 20, -30, -10, -30, -20, -30,
     -30, -30, -30, -30, -30, -30, -30, -50)

var piecepic : array - 6 .. 6 of int
for i : -6 .. 6
     piecepic (i) := Pic.FileNew ("Pictures/Pieces/Chess_" + intstr (i) + ".bmp")
end for
     var board : int := Pic.FileNew ("Pictures/Board/Board.bmp")
setscreen ("graphics:600;600")
var branchsize : int := 0

proc DRAW_BOARD
     Pic.Draw (board, 40, 40, picCopy)
     for decreasing y : 8 .. 1
          for x : 1 .. 8
               if CUR_BOARD_POS (x, y) not= 0 then
                    Pic.Draw (piecepic (CUR_BOARD_POS (x, y)), x * 60, y * 60, picMerge)
               end if
          end for
     end for
end DRAW_BOARD

proc RESIGN (player:boolean)
     cls
     DRAW_BOARD
     if player then
          put "White Resigns!"
     else
          put "Black Resigns!"
     end if
     quit
end RESIGN

proc CHECK_MOVE_SAFETY (THEOR_MOVE_X : int, THEOR_MOVE_Y : int, PIECE_ID : int)
     if CUR_BOARD_POS (THEOR_MOVE_X, THEOR_MOVE_Y) = 0 then
          LEGAL_MOVE := true
          return
     end if
     if PIECE_ID / CUR_BOARD_POS (THEOR_MOVE_X, THEOR_MOVE_Y) > 0 then
          LEGAL_MOVE := false
          COLLISION_DETECT := true
     else
          LEGAL_MOVE := true
          COLLISION_DETECT := true
     end if
end CHECK_MOVE_SAFETY

proc FIND_ROOK_MOVES (PIECE_LOC_X : int, PIECE_LOC_Y : int)
     for X_OR_Y : 0 .. 1
          for PRE_ADD_OR_SUB : 0 .. 1
               COLLISION_DETECT := false
               THEOR_MOVE_COORDS (0) := PIECE_LOC_X
               THEOR_MOVE_COORDS (1) := PIECE_LOC_Y
               ADD_OR_SUB (0) := PRE_ADD_OR_SUB * 2 - 1
               loop
                    THEOR_MOVE_COORDS (X_OR_Y) += ADD_OR_SUB (0)
                    exit when COLLISION_DETECT
                    exit when THEOR_MOVE_COORDS (0) > 8 or THEOR_MOVE_COORDS (0) < 1 or THEOR_MOVE_COORDS (1) > 8 or THEOR_MOVE_COORDS (1) < 1
                    CHECK_MOVE_SAFETY (THEOR_MOVE_COORDS (0), THEOR_MOVE_COORDS (1), CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y))
                    if LEGAL_MOVE then
                         %% Add the legal Move to the list
                         new LEGAL_MOVES, upper (LEGAL_MOVES) + 1
                         LEGAL_MOVES (upper (LEGAL_MOVES)) := intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y) + intstr (THEOR_MOVE_COORDS (0)) + intstr (THEOR_MOVE_COORDS (1))
                         LEGAL_MOVE := false
                    end if
               end loop
          end for
     end for
end FIND_ROOK_MOVES

proc FIND_BISHOP_MOVES (PIECE_LOC_X : int, PIECE_LOC_Y : int)
     for PRE_ADD_OR_SUB_X : 0 .. 1
          for PRE_ADD_OR_SUB_Y : 0 .. 1
               COLLISION_DETECT := false
               THEOR_MOVE_COORDS (0) := PIECE_LOC_X
               THEOR_MOVE_COORDS (1) := PIECE_LOC_Y
               ADD_OR_SUB (0) := PRE_ADD_OR_SUB_X * 2 - 1
               ADD_OR_SUB (1) := PRE_ADD_OR_SUB_Y * 2 - 1
               loop
                    THEOR_MOVE_COORDS (0) += ADD_OR_SUB (0)
                    THEOR_MOVE_COORDS (1) += ADD_OR_SUB (1)
                    exit when COLLISION_DETECT
                    exit when THEOR_MOVE_COORDS (0) > 8 or THEOR_MOVE_COORDS (0) < 1 or THEOR_MOVE_COORDS (1) > 8 or THEOR_MOVE_COORDS (1) < 1
                    CHECK_MOVE_SAFETY (THEOR_MOVE_COORDS (0), THEOR_MOVE_COORDS (1), CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y))
                    if LEGAL_MOVE then
                         %% Add the legal Move to the list
                         new LEGAL_MOVES, upper (LEGAL_MOVES) + 1
                         LEGAL_MOVES (upper (LEGAL_MOVES)) := intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y) + intstr (THEOR_MOVE_COORDS (0)) + intstr (THEOR_MOVE_COORDS (1))
                         LEGAL_MOVE := false
                    end if
               end loop
          end for
     end for
end FIND_BISHOP_MOVES

proc FIND_KNIGHT_MOVES (PIECE_LOC_X : int, PIECE_LOC_Y : int)
     for KNIGHT_MOVE_IDENTIFIER : 1 .. 8
          THEOR_MOVE_COORDS (0) := PIECE_LOC_X + POSSIBLE_KNIGHT_MOVES (0, KNIGHT_MOVE_IDENTIFIER)
          THEOR_MOVE_COORDS (1) := PIECE_LOC_Y + POSSIBLE_KNIGHT_MOVES (1, KNIGHT_MOVE_IDENTIFIER)
          if THEOR_MOVE_COORDS (0) <= 8 and THEOR_MOVE_COORDS (0) >= 1 and THEOR_MOVE_COORDS (1) <= 8 and THEOR_MOVE_COORDS (1) >= 1 then
               CHECK_MOVE_SAFETY (THEOR_MOVE_COORDS (0), THEOR_MOVE_COORDS (1), CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y))
               if LEGAL_MOVE then
                    %% Add the legal Move to the list
                    new LEGAL_MOVES, upper (LEGAL_MOVES) + 1
                    LEGAL_MOVES (upper (LEGAL_MOVES)) := intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y) + intstr (THEOR_MOVE_COORDS (0)) + intstr (THEOR_MOVE_COORDS (1))
                    LEGAL_MOVE := false
               end if
          end if
     end for
end FIND_KNIGHT_MOVES

proc FIND_PAWN_MOVES (PIECE_LOC_X : int, PIECE_LOC_Y : int)
     for TEMP_X : -1 .. 1
          if PIECE_LOC_X + TEMP_X <= 8 and PIECE_LOC_X + TEMP_X >= 1 and PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) <= 8 and PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) >= 1 then
               if TEMP_X = 0 then
                    if CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y)) = 0 then
                         %% Add the legal Move to the list
                         new LEGAL_MOVES, upper (LEGAL_MOVES) + 1
                         LEGAL_MOVES (upper (LEGAL_MOVES)) := intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y) + intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y))
                         /*put PIECE_LOC_X:5,PIECE_LOC_Y:5
                         put CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y )
                         put PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) * 2
                         put (CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) - 1) * 2.5 + 2*/
                         if PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) * 2 ~= 9 and PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) * 2 ~= 0 then
                              if CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) * 2) = 0 and PIECE_LOC_Y = abs((CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) - 1) * 2.5) + 2 then
                                   new LEGAL_MOVES, upper (LEGAL_MOVES) + 1
                                   LEGAL_MOVES (upper (LEGAL_MOVES)) := intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y) + intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) *
                                   2)
                              end if
                         end if
                    end if
               else
                    if CUR_BOARD_POS (PIECE_LOC_X + TEMP_X, PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y)) / CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y) < 0 then
                         new LEGAL_MOVES, upper (LEGAL_MOVES) + 1
                         LEGAL_MOVES (upper (LEGAL_MOVES)) := intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y) + intstr (PIECE_LOC_X + TEMP_X) + intstr (PIECE_LOC_Y + CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y))
                    end if
               end if
          end if
     end for
end FIND_PAWN_MOVES

proc FIND_KING_MOVES (PIECE_LOC_X : int, PIECE_LOC_Y : int)
     for TEMP_X : -1 .. 1
          for TEMP_Y : -1 .. 1
               if PIECE_LOC_X + TEMP_X <= 8 and PIECE_LOC_X + TEMP_X >= 1 and PIECE_LOC_Y + TEMP_Y <= 8 and PIECE_LOC_Y + TEMP_Y >= 1 then
                    if not (TEMP_X = 0 and TEMP_Y = 0) then
                         CHECK_MOVE_SAFETY (PIECE_LOC_X + TEMP_X, PIECE_LOC_Y + TEMP_Y, CUR_BOARD_POS (PIECE_LOC_X, PIECE_LOC_Y))
                         if LEGAL_MOVE then
                              %% Add the legal Move to the list
                              new LEGAL_MOVES, upper (LEGAL_MOVES) + 1
                              LEGAL_MOVES (upper (LEGAL_MOVES)) := intstr (PIECE_LOC_X) + intstr (PIECE_LOC_Y) + intstr (PIECE_LOC_X + TEMP_X) + intstr (PIECE_LOC_Y + TEMP_Y)
                              LEGAL_MOVE := false
                         end if
                    end if
               end if
          end for
     end for
end FIND_KING_MOVES

proc FIND_KINGS(CUR_BOARD_POS : array 1 .. 8, 1 .. 8 of int)
     W_KING:=false
     B_KING:=false
     for decreasing y : 8 .. 1
          for x : 1 .. 8
               case CUR_BOARD_POS (x, y) of
               label 6 :
                    W_KING:=true
               label -6 :
                    B_KING:=true
               label :
               end case
          end for
     end for
end FIND_KINGS

proc FIND_LEGAL_MOVES (CUR_BOARD_POS : array 1 .. 8, 1 .. 8 of int, TURN : boolean)
     new LEGAL_MOVES, 0
     %if TURN then
     for decreasing y : 8 .. 1
          for x : 1 .. 8
               if CUR_BOARD_POS (x, y) > 0 = TURN and CUR_BOARD_POS (x, y) < 0 not= TURN then
                    case abs (CUR_BOARD_POS (x, y)) of
                    label 1 :
                         FIND_PAWN_MOVES (x, y)
                    label 2 :
                         FIND_KNIGHT_MOVES (x, y)
                    label 3 :
                         FIND_BISHOP_MOVES (x, y)
                    label 4 :
                         FIND_ROOK_MOVES (x, y)
                    label 5 :
                         FIND_ROOK_MOVES (x, y)
                         FIND_BISHOP_MOVES (x, y)
                    label 6 :
                         FIND_KING_MOVES (x, y)
                    end case
               end if
          end for
     end for
          /*else
     for decreasing y : 8 .. 1
     for x : 1 .. 8
     if CUR_BOARD_POS (x, y) > 0 = TURN and CUR_BOARD_POS (x, y) < 0 not= TURN then
     case abs (CUR_BOARD_POS (x, y)) of
label 1 :
     FIND_PAWN_MOVES (x, y)
label 2 :
     FIND_KNIGHT_MOVES (x, y)
label 3 :
     FIND_BISHOP_MOVES (x, y)
label 4 :
     FIND_ROOK_MOVES (x, y)
label 5 :
     FIND_ROOK_MOVES (x, y)
     FIND_BISHOP_MOVES (x, y)
label 6 :
     FIND_KING_MOVES (x, y)
     end case
     end if
     end for
          end for
          
     
     
     end if*/
end FIND_LEGAL_MOVES

fcn SIGN (INTEGER : int) : int
     if INTEGER > 0 then
          result 1
     else
          result - 1
     end if
end SIGN

fcn EVALUATE_POS (CUR_BOARD_POS : array 1 .. 8, 1 .. 8 of int, TURN : boolean) : real
     EVALUATE_TOTAL := 0
     var NUM_OF_PIECES:int:=0
     var SEL_BOARD:int:=1
     for decreasing y : 8 .. 1
          for x : 1 .. 8
               if abs(CUR_BOARD_POS (x, y)) > 0 then
                    NUM_OF_PIECES+=1
               end if
          end for
     end for
          if NUM_OF_PIECES<=16 then
          SEL_BOARD:=2
     end if
     %FIND_LEGAL_MOVES (CUR_BOARD_POS, TURN)
     %EVALUATE_TOTAL -= upper (LEGAL_MOVES)
     for decreasing y : 8 .. 1
          for x : 1 .. 8
               case CUR_BOARD_POS (x, y) of
               label 1 :
                    EVALUATE_TOTAL += 10 + pawn_table (x, y) / 10
               label 2 :
                    EVALUATE_TOTAL += 28 + knight_table (x, y) / 10
               label 3 :
                    EVALUATE_TOTAL += 32 + bishop_table (x, y) / 10
               label 4 :
                    EVALUATE_TOTAL += 51 + rook_table (x, y) / 10
               label 5 :
                    EVALUATE_TOTAL += 95 + rook_table (x, y) / 10 + bishop_table (x, y) / 10
               label 6 :
                    EVALUATE_TOTAL += 1000 + king_table (x, y,SEL_BOARD) / (10-(SEL_BOARD-1)*5) 
               label - 1 :
                    EVALUATE_TOTAL -= 10 + pawn_table (x, y * -1 + 9)/10
               label - 2 :
                    EVALUATE_TOTAL -= 28 + knight_table (x, y * -1 + 9) / 10
               label - 3 :
                    EVALUATE_TOTAL -= 32 + bishop_table (x, y * -1 + 9) / 10
               label - 4 :
                    EVALUATE_TOTAL -= 51 + rook_table (x, y * -1 + 9) / 10
               label - 5 :
                    EVALUATE_TOTAL -= 95 + rook_table (x, y * -1 + 9) / 10 + bishop_table (x, y * -1 + 9) / 10
               label - 6 :
                    EVALUATE_TOTAL -= 1000 + king_table (x, y * -1 + 9,SEL_BOARD) / (10-(SEL_BOARD-1)*5) 
               label :
               end case
          end for
     end for
          
     result EVALUATE_TOTAL
end EVALUATE_POS

fcn MINI_MAX (DEPTH : int, POS : array 1 .. 8, 1 .. 8 of int, MY_TURN : boolean,ALPHA:real,BETA:real) : real
     FIND_KINGS(POS)
     if ~W_KING then
          result -999999
     elsif ~B_KING then
          result 999999
     end if
     if DEPTH = 0 then
          branchsize += 1
          result EVALUATE_POS (POS, MY_TURN)
     end if
     FIND_LEGAL_MOVES (POS, MY_TURN)
     if DEPTH mod 2 = 0 then
          locate (2, 1)
          put "The Computer has looked through ", branchsize, "/", pos_pos,"/",NUM_OF_PRUNES
     end if
     var POS_LEGAL_MOVES : array 1 .. upper (LEGAL_MOVES) of string (4)
     for CUR_COPY_MOVE : 1 .. upper (POS_LEGAL_MOVES)
          POS_LEGAL_MOVES (CUR_COPY_MOVE) := LEGAL_MOVES (CUR_COPY_MOVE)
     end for
          
     var MY_ALPHA:real:=ALPHA
     var MY_BETA:real:=BETA
     
     if MY_TURN then
          var CUR_MOVE_VAL : real
          var AI_BEST_MOVE_VAL : real := -999999
          for CUR_MOVE : 1 .. upper (POS_LEGAL_MOVES)
               var temp : int := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)),
                    strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := 0
               CUR_MOVE_VAL := MINI_MAX (DEPTH - 1, POS, not MY_TURN,MY_ALPHA,MY_BETA)
               if AI_BEST_MOVE_VAL < CUR_MOVE_VAL then
                    AI_BEST_MOVE_VAL := CUR_MOVE_VAL
               end if
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)),
                    strint (POS_LEGAL_MOVES (CUR_MOVE) (4)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := temp
               MY_ALPHA:=max(MY_ALPHA,AI_BEST_MOVE_VAL)
               if MY_ALPHA>=MY_BETA then
               NUM_OF_PRUNES+=1
                    exit
               end if
          end for
               result AI_BEST_MOVE_VAL
     else
          var CUR_MOVE_VAL : real
          var AI_BEST_MOVE_VAL : real := 999999
          for CUR_MOVE : 1 .. upper (POS_LEGAL_MOVES)
               var temp : int := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)),
                    strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := 0
               CUR_MOVE_VAL := MINI_MAX (DEPTH - 1, POS, not MY_TURN,MY_ALPHA,MY_BETA)
               if AI_BEST_MOVE_VAL > CUR_MOVE_VAL then
                    AI_BEST_MOVE_VAL := CUR_MOVE_VAL
               end if
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)),
                    strint (POS_LEGAL_MOVES (CUR_MOVE) (4)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := temp
               MY_BETA:=min(MY_BETA,AI_BEST_MOVE_VAL)
               if MY_ALPHA>=MY_BETA then
               NUM_OF_PRUNES+=1
                    exit
               end if
          end for
               result AI_BEST_MOVE_VAL
     end if
end MINI_MAX

fcn MINI_MAX_ROOT (DEPTH : int, POS : array 1 .. 8, 1 .. 8 of int, MAIN_TURN : boolean,ALPHA:real,BETA:real) : string
     FIND_LEGAL_MOVES (POS, MAIN_TURN)
     var POS_LEGAL_MOVES : array 0 .. upper (LEGAL_MOVES) of string (4)
     for CUR_COPY_MOVE : 1 .. upper (LEGAL_MOVES)
          POS_LEGAL_MOVES (CUR_COPY_MOVE) := LEGAL_MOVES (CUR_COPY_MOVE)
     end for
          
     var MY_ALPHA:real:=ALPHA
     var MY_BETA:real:=BETA
     
     
     if MAIN_TURN then
          var CUR_MOVE_VAL : real
          var AI_BEST_MOVE_VAL : real := -999999
          for CUR_MOVE : 1 .. upper (POS_LEGAL_MOVES)
               var temp : int := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4)))
               var piece :int:=CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               if abs(CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))) = 1 and strint (POS_LEGAL_MOVES (CUR_MOVE) (4)) = (CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))+1)*3.5+1 then
                    CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))):=5*CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               else
                    CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               end if
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := 0
               CUR_MOVE_VAL := MINI_MAX (DEPTH - 1, POS, not MAIN_TURN,MY_ALPHA,MY_BETA)
               if AI_BEST_MOVE_VAL < CUR_MOVE_VAL then
                    AI_BEST_MOVE := POS_LEGAL_MOVES (CUR_MOVE)
                    AI_BEST_MOVE_VAL := CUR_MOVE_VAL
               end if
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := piece
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := temp
               locate (2, 1)
               put "The Computer has looked through ", branchsize, "/", pos_pos,"/",NUM_OF_PRUNES
               MY_ALPHA:=max(MY_ALPHA,AI_BEST_MOVE_VAL)
               if MY_ALPHA>=MY_BETA then
               NUM_OF_PRUNES+=1
                    exit
               end if
          end for
               if AI_BEST_MOVE_VAL = -999999 then
               if upper(POS_LEGAL_MOVES) = 0 then
                    cls
                    DRAW_BOARD
                    put "STALEMATE!"
                    quit
               end if
               RESIGN(true)
          end if
          result AI_BEST_MOVE
     else
          var CUR_MOVE_VAL : real
          var AI_BEST_MOVE_VAL : real := 999999
          for CUR_MOVE : 1 .. upper (POS_LEGAL_MOVES)
               var temp : int := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4)))
               var piece :int:=CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               if abs(CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))) = 1 and strint (POS_LEGAL_MOVES (CUR_MOVE) (4)) = (CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))+1)*3.5+1 then
                    CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))):=5*CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               else
                    CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               end if
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := 0
               CUR_MOVE_VAL := MINI_MAX (DEPTH - 1, POS, not MAIN_TURN,MY_ALPHA,MY_BETA)
               if AI_BEST_MOVE_VAL > CUR_MOVE_VAL then
                    AI_BEST_MOVE := POS_LEGAL_MOVES (CUR_MOVE)
                    AI_BEST_MOVE_VAL := CUR_MOVE_VAL
               end if
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := piece
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := temp
               locate (2, 1)
               put "The Computer has looked through ", branchsize, "/", pos_pos,"/",NUM_OF_PRUNES
               MY_BETA:=min(MY_BETA,AI_BEST_MOVE_VAL)
               if MY_ALPHA>=MY_BETA then
               NUM_OF_PRUNES+=1
                    exit
               end if
          end for
               if AI_BEST_MOVE_VAL =999999 then
               if upper(POS_LEGAL_MOVES) = 0 then
                    cls
                    DRAW_BOARD
                    put "STALEMATE!"
                    quit
               end if
               RESIGN(false)
          end if
          result AI_BEST_MOVE
     end if
end MINI_MAX_ROOT

fcn NUM_FIN_POS (DEPTH : int, POS : array 1 .. 8, 1 .. 8 of int, MAIN_TURN : boolean) : int
     var NUM_OF_POS : int := 0
     FIND_LEGAL_MOVES (POS, MAIN_TURN)
     var POS_LEGAL_MOVES : array 1 .. upper (LEGAL_MOVES) of string (4)
     for CUR_COPY_MOVE : 1 .. upper (LEGAL_MOVES)
          POS_LEGAL_MOVES (CUR_COPY_MOVE) := LEGAL_MOVES (CUR_COPY_MOVE)
     end for
          if DEPTH ~= 1 then
          for CUR_MOVE : 1 .. upper (POS_LEGAL_MOVES)
               var temp : int := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)),
                    strint (POS_LEGAL_MOVES (CUR_MOVE) (2)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := 0
               NUM_OF_POS += NUM_FIN_POS (DEPTH - 1, POS, not MAIN_TURN)
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (1)), strint (POS_LEGAL_MOVES (CUR_MOVE) (2))) := CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)),
                    strint (POS_LEGAL_MOVES (CUR_MOVE) (4)))
               CUR_BOARD_POS (strint (POS_LEGAL_MOVES (CUR_MOVE) (3)), strint (POS_LEGAL_MOVES (CUR_MOVE) (4))) := temp
          end for
               result NUM_OF_POS
     else
          result upper (POS_LEGAL_MOVES)
     end if
end NUM_FIN_POS

loop
     var timetook : int := Time.Elapsed
     var mousex, mousey, buttonval : int
     new find_moves, upper (find_moves) + 1
     timetook := Time.Elapsed
     FIND_LEGAL_MOVES (CUR_BOARD_POS, not REAL_TURN)
     find_moves (upper (find_moves)) := Time.Elapsed - timetook
     put find_moves (upper (find_moves)) ..
     DRAW_BOARD
     new eval, upper (eval) + 1
     timetook := Time.Elapsed
     var q : real := EVALUATE_POS (CUR_BOARD_POS, REAL_TURN)
     eval (upper (eval)) := Time.Elapsed - timetook
     locate (1, 50)
     var aveval, avmoves : real := 0
     for x : 1 .. upper (find_moves)
          avmoves += find_moves (x)
     end for
          avmoves /= upper (find_moves)
     for x : 1 .. upper (eval)
          aveval += eval (x)
     end for
          aveval /= upper (eval)
     put avmoves : 0 : 2, aveval : 5 : 2
     locate (1, 1)
     put "Current board evaluation is ", EVALUATE_POS (CUR_BOARD_POS, REAL_TURN), "." ..
     if HUMAN_PLAYER then

          FIND_LEGAL_MOVES (CUR_BOARD_POS, REAL_TURN)
          loop
               FOUND_MOVE := false
               locate (1, 40)
               loop
                    Mouse.Where (mousex, mousey, buttonval)
                    if buttonval not= 0 then
                         if (mousex - 60) / 60 > 0 and (mousey - 60) / 60 > 0 and (mousex - 60) / 60 <= 8 and (mousey - 60) / 60 <= 8 then
                              DESIRED_MOVE := intstr (ceil ((mousex - 60) / 60)) + intstr (ceil ((mousey - 60) / 60))
                              loop
                                   Mouse.Where (mousex, mousey, buttonval)
                                   if buttonval = 0 then
                                        loop
                                             Mouse.Where (mousex, mousey, buttonval)
                                             if buttonval not= 0 then
                                                  if (mousex - 60) / 60 > 0 and (mousey - 60) / 60 > 0 and (mousex - 60) / 60 <= 8 and (mousey - 60) / 60 <= 8 then
                                                       DESIRED_MOVE := DESIRED_MOVE + intstr (ceil ((mousex - 60) / 60)) + intstr (ceil ((mousey - 60) / 60))
                                                       exit
                                                  end if
                                             end if
                                        end loop
                                        exit
                                   end if
                              end loop
                              exit
                         end if
                    end if
               end loop
               put DESIRED_MOVE
               for CUR_ANAL_LEGAL_MOVE : 1 .. upper (LEGAL_MOVES)
                    if DESIRED_MOVE = LEGAL_MOVES (CUR_ANAL_LEGAL_MOVE) then
                         FOUND_MOVE := true
                         exit
                    end if
               end for
                    exit when FOUND_MOVE
          end loop
          CUR_BOARD_POS (strint (DESIRED_MOVE (3)), strint (DESIRED_MOVE (4))) := CUR_BOARD_POS (strint (DESIRED_MOVE (1)), strint (DESIRED_MOVE (2)))
          CUR_BOARD_POS (strint (DESIRED_MOVE (1)), strint (DESIRED_MOVE (2))) := 0
          REAL_TURN := not REAL_TURN
          DRAW_BOARD
                    %pos_pos:=NUM_FIN_POS(P2_PLY_DEPTH, CUR_BOARD_POS, REAL_TURN)
          branchsize := 0
          timetook := Time.Elapsed
          AI_BEST_MOVE := MINI_MAX_ROOT (P2_PLY_DEPTH, CUR_BOARD_POS, REAL_TURN,-999999,999999)
          locate (2, 1)
          new time_per_move, upper (time_per_move) + 1
          time_per_move (upper (time_per_move)) := (Time.Elapsed - timetook) / 1000
          put "The Computer looked through ", branchsize, " positions! - It took ", (Time.Elapsed - timetook) div 1000, " seconds!"
          CUR_BOARD_POS (strint (AI_BEST_MOVE (3)), strint (AI_BEST_MOVE (4))) := CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2)))
          CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2))) := 0
          REAL_TURN := not REAL_TURN
          locate (1, 40)
          for x : 1 .. upper (time_per_move)
               avtimo += time_per_move (x)
          end for
               avtimo /= upper (time_per_move)
          put avtimo : 0 : 2 ..
          DRAW_BOARD
     else
          %pos_pos:=NUM_FIN_POS(P1_PLY_DEPTH, CUR_BOARD_POS, REAL_TURN)
          NUM_OF_PRUNES:=0
          branchsize := 0
          timetook := Time.Elapsed
          AI_BEST_MOVE := MINI_MAX_ROOT (P1_PLY_DEPTH, CUR_BOARD_POS, REAL_TURN,-999999,999999)
          locate (2, 1)
          new time_per_move, upper (time_per_move) + 1
          time_per_move (upper (time_per_move)) := (Time.Elapsed - timetook) div 1000
          put "The Computer looked through ", branchsize, " positions! - It took ", (Time.Elapsed - timetook) div 1000, " seconds!"
          if abs(CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2))))= 1 and strint (AI_BEST_MOVE (4)) = (CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2)))+1)*3.5+1 then
               CUR_BOARD_POS (strint (AI_BEST_MOVE (3)), strint (AI_BEST_MOVE (4))) := 5*CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2)))
          else
               CUR_BOARD_POS (strint (AI_BEST_MOVE (3)), strint (AI_BEST_MOVE (4))) := CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2)))
          end if
          CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2))) := 0
          REAL_TURN := not REAL_TURN
          DRAW_BOARD
          locate (1, 40)
          avtimo:= 0
          for x : 1 .. upper (time_per_move)
               avtimo += time_per_move (x)
          end for
               avtimo /= upper (time_per_move)
          put avtimo : 0 : 2 ..
          %pos_pos:=NUM_FIN_POS(P2_PLY_DEPTH, CUR_BOARD_POS, REAL_TURN)
          NUM_OF_PRUNES:=0
          branchsize := 0
          timetook := Time.Elapsed
          AI_BEST_MOVE := MINI_MAX_ROOT (P2_PLY_DEPTH, CUR_BOARD_POS, REAL_TURN,-999999,999999)
          locate (2, 1)
          new time_per_move, upper (time_per_move) + 1
          time_per_move (upper (time_per_move)) := (Time.Elapsed - timetook) div 1000
          put "The Computer looked through ", branchsize, " positions! - It took ", (Time.Elapsed - timetook) div 1000, " seconds!"
          if abs(CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2))))= 1 and strint (AI_BEST_MOVE (4)) = (CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2)))+1)*3.5+1 then
               CUR_BOARD_POS (strint (AI_BEST_MOVE (3)), strint (AI_BEST_MOVE (4))) := 5*CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2)))
          else
               CUR_BOARD_POS (strint (AI_BEST_MOVE (3)), strint (AI_BEST_MOVE (4))) := CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2)))
          end if
          CUR_BOARD_POS (strint (AI_BEST_MOVE (1)), strint (AI_BEST_MOVE (2))) := 0
          REAL_TURN := not REAL_TURN
          locate (1, 40)
          for x : 1 .. upper (time_per_move)
               avtimo += time_per_move (x)
          end for
               avtimo /= upper (time_per_move)
          put avtimo : 0 : 2 ..
          DRAW_BOARD
     end if
end loop
