//1 by second index, 16 by first

//1 bit for a prescense of a ship
//2 bit for a hit 
//3 bit for left
//4 bit for right
//5 bit for up
//6 bit for down

.section .text
.global main    

.equ UP_SHIFT, 16
.equ RDONLY, 0
.equ ARBITR, 0
.equ OPEN, 56
.equ READ, 63

main: 
   // MOV X0, #0
   // LDR X1, =rand
   // MOV X2, #4            //Reading 4 bytes from stdin
   // MOV X8, READ 
   // SVC 0
b START_POINT

OUT_PREPARE:
    mov X0, #1 //using stdout
    mov X8, #64 
    mov X3, #0 // used as i
    mov X5, #0 // used as j
OUT:
   //If in corner
   cmp X5, #0         // j == 0 && j == 0
   ccmp X3, X5, 1, EQ
   b.eq LEFT_CORNER
   cmp X5, #20        // j == 20 && i == 0
   ccmp X3, #0, 1, EQ
   b.eq RIGHT_CORNER
   cmp X3, #20        // i == 20 && j == 0   ccmp X5, #0, 1, EQ   
   ccmp X5, #0, 1, EQ
   b.eq BOTTOM_LEFT_CORNER
   cmp X3, #20        // i == 20 && j == 20
   ccmp X5, X3, 1, EQ 
   b.eq BOTTOM_RIGHT_CORNER
   //If not in corner

   cmp X3, #0  
   b.eq UPPER_PARITY_CHECK
   cmp X3, #20
   b.eq LOWER_PARITY_CHECK
   cmp x5, #0
   b.eq LEFT_PARITY_CHECK
   cmp X5, #20 
   b.eq RIGHT_PARITY_CHECK

   tst X3, #0b00000001
   b.ne MIDDLE_EVEN_PARITY_CHECK
 RETURN:  
   tst X3, #0b00000001
   b.eq MIDDLE_NOT_EVEN_PARITY_CHECK

   b PRINT_CONTENT   

 LEFT_CORNER:
    mov X0, #1
    ldr X1, =vert_line
    mov X2, #23
    svc 0
    mov X0, #1 
    ldr X1, =left_box             // string address
    mov X2, #4                    // string length (in bytes. Not every symbol is created equal, remember about unicode ones)
    svc 0                         // Direct call
 b END_BRANCHING

 RIGHT_CORNER:
    mov X0, #1   
    ldr X1, =right_box
    mov X2, #3
    svc 0
 b END_BRANCHING    

 BOTTOM_LEFT_CORNER:
    mov X0, #1    
    ldr X1, =bottom_left_box
    mov X2, #4
    svc 0
 b END_BRANCHING

 BOTTOM_RIGHT_CORNER:
    mov X0, #1 
    ldr X1, =bottom_right_box
    mov X2, #3
    svc 0
 b END_BRANCHING  

 UPPER_PARITY_CHECK:
    tst X5, #0b00000001
    b.ne UPPER_NOT_EVEN
    mov X0, #1 
    ldr X1, =upper_even_box
    mov X2, #3
    svc 0   
 b END_BRANCHING   

 UPPER_NOT_EVEN:
    mov X0, #1 
    ldr X1, =upper_not_even_box
    mov X2, #3
    svc 0
 b END_BRANCHING 

 LOWER_PARITY_CHECK:
    tst X5, #0b00000001
    b.ne LOWER_NOT_EVEN
    mov X0, #1 
    ldr X1, =lower_even_box
    mov X2, #3
    svc 0
 b END_BRANCHING

 LOWER_NOT_EVEN:
    mov X0, #1 
    ldr X1, =lower_not_even_box 
    mov X2, #3
    svc 0
 b END_BRANCHING    

 LEFT_PARITY_CHECK:
    tst X3, #0b00000001
    b.ne LEFT_NOT_EVEN
    mov X0, #1  
    ldr X1, =left_even_box
    mov X2, #4
    svc 0
 b END_BRANCHING  

 LEFT_NOT_EVEN:
    mov X0, #1 
    ldr X1, =text
    mov X0, X3
    mov X2, #2     //Both number of chars and the divisor
    udiv X0, X0, X2
    add X0, X0, #'0'
    strb W0, [X1]
    mov X0, #0 
    svc 0

    ldr X1, =left_not_even_box
    mov X2, #3
    svc 0
 b END_BRANCHING
 
 RIGHT_PARITY_CHECK:
    tst X3, #0b00000001
    b.ne RIGHT_NOT_EVEN
    mov X0, #1 
    ldr X1, =right_even_box
    mov X2, #3
    svc 0
 b END_BRANCHING    

 RIGHT_NOT_EVEN:
    mov X0, #1  
    ldr X1, =right_not_even_box   
    mov X2, #3
    svc 0
 b END_BRANCHING  

 MIDDLE_EVEN_PARITY_CHECK:
    tst X5, #0b00000001
    b.ne RETURN
    mov X0, #1 
    ldr X1, =middle_horizontal_even_box
    mov X2, #3
    svc 0
 b END_BRANCHING

 MIDDLE_NOT_EVEN_PARITY_CHECK:
    tst X5, #0b00000001
    b.ne MIDDLE_NOT_EVEN
    mov X0, #1 
    ldr X1, =middle_even_box
    mov X2, #3
    svc 0
 b END_BRANCHING

 MIDDLE_NOT_EVEN:
    mov X0, #1 
    ldr X1, =middle_not_even_box
    mov X2, #3
    svc 0
 b END_BRANCHING 

 PRINT_CONTENT:
    mov X0, #1
    mov X1, X7
    add X1, X1, X5, LSR 1       //arr[j / 2 + 1], indexing collumns
    
    mov X2, UP_SHIFT
    MOV X9, #0
    ADD X9, X9, X3, LSR 1
    ADD X9, X9, #1
    MUL X9, X9, X2
    add X1, X1, X9 
    add X1, X1, #9 //first poooooooooointeeeeeeeeeeer
                  //arr[i / 2 + 1][j / 2 + 1] 

    mov X2, #1
    ldrb W0, [X1]
    tst W0, #0b001000000
    b.NE PRINT_HIT
    cmp W0, #0
    b.EQ PRINT_SPACE
    tst W0, #0b10000000                     
    b.NE PRINT_SPACE
    mov X0, #0
    svc 0
 b END_BRANCHING 

 PRINT_HIT:
   tst W0, #0b10000000
   b.NE PRINT_SHIP
   mov X0, #'.'
   ldr X1, =temp_symb
   str X0, [X1]
   mov X0, #0
   mov X2, #1
   svc 0
 b END_BRANCHING

 PRINT_SHIP:
  mov X0, #'X'
   ldr X1, =temp_symb
   str X0, [X1]
   mov X0, #0
   mov X2, #1
   svc 0
 b END_BRANCHING  

PRINT_SPACE:
   mov X0, #' '
   ldr X1, =temp_symb
   str X0, [X1]
   mov X0, #0
   mov X2, #1
   svc 0
 b END_BRANCHING

 END_BRANCHING:
   add X5, X5, #1 //j++
   cmp X5, #21 //End of horizontal lines
   b.lo OUT
   mov X0, #1 
   ldr X1, =new_line
   mov X2, #1
   svc 0
   mov X5, #0
   add X3,X3,#1
   cmp X3, #21
   b.lo OUT

 RET 


// X0 used as size; X1 used as j,
// X2 used as pos, X3 as i_pos
// X4 used as j_pos, X5 used as k / i
// X6 used as address, X7 USED AS A TABLE INDEXED, 
// X8 -, X9-X10 are free to use

CREATE_PREPARE:
   MOV X0, #4
  SIZE_CYCLE:  
   MOV X1, #0
  J_CYCLE:  
   MOV X3, #0
   MOV X4, #0
   MOV X5, #0
   //GENERATING RANDOM NUM
   LDR X9, =reg_save
   STP X0, X1, [X9]
   MOV X0, ARBITR     //Arbitary file
   LDR X1, =pathRnd
   MOV X2, RDONLY
   MOV X3, RDONLY
   MOV X8, OPEN
   SVC 0

   LDR X1, =rand
   MOV X2, #4
   MOV X8, READ
   SVC 0
   
   LDP X0, X1, [X9]
   LDR X2, rand 
 //END OF GENERATING
   mov X9, #11
   sub X9, X9, X0
   mov X10, #20
   mul X9, X10, X9
   udiv X10, X2, X9
   msub X2, X10, X9, X2
  AGAIN:
   mov X9, #2
   udiv X10, X2, X9 
   msub X9, X10, X9, X2
   cmp X9, #0
   b.eq EVEN

   mov X9, #2
   add X3, X3, X2, LSR 1
   mov X9, #11
   sub X9, X9, X0
   udiv X3, X3, X9
   add X3, X3, #1   //i_pos = (pos / 2) / (11 - size) + 1

   mov X9, #2
   add X4, X4, X2, LSR 1
   mov X9, #11
   sub X9, X9, X0
   udiv X10, X4, X9
   msub X4, X9, X10, X4 
   add X4, X4, #1     //j_pos = (pos / 2) % (11 - size) + 1

   MOV X5, X4 
   SUB X5, X5, #1
  NOT_EVEN_K_CYCLE:
   
   mov X8, X7 
   add X8, X8, #8      
   add X8, X8, X5    
   mov X9, X3
   sub X9, X9, #1
   mov X10, UP_SHIFT
   mul X9, X9, X10
   add X8, X8, X9
   
   LDRB W9, [X8]
   tst W9, #0b10000000
   b.ne NOT_EVEN_HAS_SHIP

   mov X8, X7
   add X8, X8, #8      
   add X8, X8, X5    
   mov X9, X3
   mov X10, UP_SHIFT
   mul X9, X9, X10
   add X8, X8, X9
   
   LDRB W9, [X8]
   tst W9, #0b10000000
   b.ne NOT_EVEN_HAS_SHIP

   mov X8, X7 
   add X8, X8, #8     
   add X8, X8, X5    
   mov X9, X3
   add X9, X9, #1
   mov X10, UP_SHIFT
   mul X9, X9, X10
   add X8, X8, X9
   
   LDRB W9, [X8]
   tst W9, #0b10000000
   b.ne NOT_EVEN_HAS_SHIP


   MOV X9, X4
   ADD X9, X9, X0
   CMP X5, X9
   ADD X5, X5, #1
   B.LS NOT_EVEN_K_CYCLE

   mov X9, #2
   udiv X2, X2, X9
   
   MOV X5, #0
  NOT_EVEN_I_CYCLE:
   mov X8, X7  
   add X8, X8, #8      
   mov X9, X4
   add X9, X9, X5
   add X8, X8, X9
   mov X10, UP_SHIFT
  
   mul X9, X10, X3
   add X8, X8, X9
   mov W9, #0b10000000
   cmp X5, #0
   b.eq NO_LEFT
  IS_LEFT: 
   add W9, W9, #0b00010000
   sub X0, X0, #1
   cmp X0, X5
   add X0, X0, #1
   b.eq NO_RIGHT
  IS_RIGHT:
   add W9, W9, #0b00001000 
   strb W9, [X8]

   ADD X5, X5, #1
   CMP X5, X0
   B.LT NOT_EVEN_I_CYCLE

   B J_ITER

   NOT_EVEN_HAS_SHIP:
   add X2, X2, #13
   mov X9, #11
   sub X9, X9, X0 
   mov X10, #20
   mul X9, X9, X10
   udiv X10, X2, X9
   msub X2, X9, X10, X2
   b AGAIN     

   NO_LEFT:
   sub W9, W9, #0b00010000
   b IS_LEFT

   NO_RIGHT:
   sub W9, W9, #0b00001000
   b IS_RIGHT
    
  EVEN: 
   mov X9, #2
   add X4, X4, X2, LSR 1
   mov X9, #11
   sub X9, X9, X0
   udiv X4, X4, X9
   add X4, X4, #1   //i_pos = (pos / 2) / (11 - size) + 1

   mov X9, #2
   add X3, X3, X2, LSR 1
   mov X9, #11
   sub X9, X9, X0
   udiv X10, X3, X9
   msub X3, X9, X10, X3 
   add X3, X3, #1     //j_pos = (pos / 2) % (11 - size) + 1

   MOV X5, X3   
   SUB X5, X5, #1
  EVEN_K_CYCLE:
   

   mov X8, X7   
   add X8, X8, #8        
   mov X9, X4
   sub X8, X8, #1
   add X8, X8, X9
   mov X10, UP_SHIFT
   mul X9, X5, X10
   add X8, X8, X9
   
   LDRB W9, [X8]
   tst W9, #0b10000000
   b.ne EVEN_HAS_SHIP

   mov X8, X7          
   add X8, X8, #8       
   mov X9, X4
   add X8, X8, X9
   mov X10, UP_SHIFT
   mul X9, X5, X10
   add X8, X8, X9
   
   LDRB W9, [X8]
   tst W9, #0b10000000
   b.ne EVEN_HAS_SHIP

   mov X8, X7  
   add X8, X8, #8          
   mov X9, X4
   ADD X8, X8, #1
   add X8, X8, X9
   mov X10, UP_SHIFT
   mul X9, X5, X10
   add X8, X8, X9
   
   LDRB W9, [X8]
   tst W9, #0b10000000
   b.ne EVEN_HAS_SHIP


   MOV X9, X3
   ADD X9, X9, X0
   CMP X5, X9
   ADD X5, X5, #1
   B.LS EVEN_K_CYCLE

   mov X9, #2
   udiv X2, X2, X9
   
   MOV X5, #0
  EVEN_I_CYCLE:

   mov X8, X7          
   add X8, X8, #8   
   mov X9, X4
   add X8, X8, X9
   mov X10, UP_SHIFT
   mov X9, X3
   add X9, X9, X5 
   
   mul X9, X10, X9
   add X8, X8, X9
 
   mov W9, #0b10000000
   cmp X5, #0
   b.eq NO_UP
  IS_UP:
   add W9, W9, #0b00000100
   sub X0, X0, #1
   cmp X5, X0
   add X0, X0, #1
   b.eq NO_DOWN
  IS_DOWN: 
   add W9, W9, #0b00000010
   strb W9, [X8]
   ADD X5, X5, #1
   CMP X5, X0
   B.LT EVEN_I_CYCLE

   B J_ITER

  NO_UP:
    sub W9, W9, #0b00000100
    b IS_UP
  
  NO_DOWN:
    sub W9, W9, #0b00000010
    b IS_DOWN 

  EVEN_HAS_SHIP:
   add X2, X2, #13
   mov X9, #11
   sub X9, X9, X0 
   sub X9, X9, #1 
   mov X10, UP_SHIFT
   mul X9, X9, X10
   udiv X10, X2, X9
   msub X2, X9, X10, X2
   b AGAIN 


  J_ITER: 
   MOV X9, #5
   SUB X9, X9, X0
   ADD X1, X1, #1 
   CMP X1, X9 
   B.LO J_CYCLE
  I_ITER:
   MOV X9, #0
   SUB X0, X0, #1
   CMP X0, X9
   B.HI SIZE_CYCLE

   RET

START_POINT:
   ldr X7, =first_field
   bl CREATE_PREPARE
   ldr X7, =second_field
   bl CREATE_PREPARE
   bl OUT_PREPARE

MAIN_LOOP:   
   bl PARSE
  PARSE_RET:  
   mov X3, #0
   mov X4, #0   //Preparing for the hardest checker
   bl CHECK_IF_DESTROYED
   cmp X3, X4
   ccmp X3, 0, #0b1111, LS
   b.ne FILL_CELLS_AROUND

 FILLED:
    B CHANGE_TURN
  CHANGE_RET:
            
   bl OUT_PREPARE
   bl CHECKER
   cmp X4, #20 
   cmp X4, #20
   b.MI MAIN_LOOP
   b FI

 CHANGE_TURN:
   ldr X11, =first_field
   cmp X7, X11
   b.eq TO_PLAYER_TWO 
   b TO_PLAYER_ONE

 TO_PLAYER_TWO:
   ldr X7, =second_field
   b CHANGE_RET
 TO_PLAYER_ONE:
   ldr X7, =first_field
   b CHANGE_RET

 PARSE_CELL:
   ldr X0, =rand
   ldrb W1, [X0]
   cmp W1, #'A'
   b.MI INCORRECT_INPUT
   cmp W1, #'J'
   b.HI INCORRECT_INPUT
   add X0, X0, #1
   ldrb W1, [X0]
   cmp W1, #'0'
   b.MI INCORRECT_INPUT
   cmp W1, #'9'
   b.HI INCORRECT_INPUT
   add X0, X0, #1
   ldrb W1, [X0]
   cmp W1, #'\n'
   b.NE CLEAR_BUFF
   sub X0, X0, #1
   ldrb W1, [X0]
   mov X9, X7
   sub X1, X1, #'0'
   mov X2, #16
   mul X1, X1, X2
   add X9, X9, X1
   add X9, X9, #25
   sub X0, X0, #1
   ldrb W1, [X0]
   sub X1, X1, #'A'
   add X9, X9, X1
   ldrb W1, [X9]
   tst W1, #0b01000000
   b.ne INCORRECT_INPUT
   orr W1, W1, #0b001000000
   strb W1, [X9]
   TST W1, #0b10000000
   
  CH_RET: 
   b.ne CHAAAANGE

   RET   //Dirty tricks with the difference between functions and branches

  CLEAR_BUFF:
    mov X0, #0
    ldr X1, =temp_symb
    mov X2, #1            //Reading 1 byte from stdin
    mov X8, READ 
    SVC 0
    ldrb W0, [X1] 
    cmp W0, #'\n'
    b.ne CLEAR_BUFF
  b INCORRECT_INPUT

  CHAAAANGE:
   ldr X11, =first_field
   cmp X7, X11
   b.eq CH_TO_PLAYER_TWO 
   b CH_TO_PLAYER_ONE

 CH_TO_PLAYER_TWO:
   ldr X7, =second_field
   b PARSE_RET
 CH_TO_PLAYER_ONE:
   ldr X7, =first_field
   b PARSE_RET 

 GREET_PLAYER_ONE:
    mov X0, #1 
    ldr X1, =player1_turn             // string address
    mov X2, #11                    // string length (in bytes. Not every symbol is created equal, remember about unicode ones)
    MOV X8, #64
    svc 0    
    b GREET_RET
  
  GREET_PLAYER_TWO:
    mov X0, #1 
    ldr X1, =player2_turn             // string address
    mov X2, #11                    // string length (in bytes. Not every symbol is created equal, remember about unicode ones)
    MOV X8, #64
    svc 0    
    b GREET_RET

  PARSE:
    ldr X11, =first_field
    cmp X11, X7
    b.eq GREET_PLAYER_ONE 
    b GREET_PLAYER_TWO
  GREET_RET:  

    ldr X1, =reg_save 
    str X30, [X1]
    mov X0, #1 
    ldr X1, =input_ask             // string address
    mov X2, #23                    // string length (in bytes. Not every symbol is created equal, remember about unicode ones)
    svc 0    
    mov X0, #0
    ldr X1, =rand
    mov X2, #4            //Reading 4 bytes from stdin
    mov X8, READ 
   
    SVC 0
    bl PARSE_CELL
    ldr X1, =reg_save
    ldr X30, [X1]
    b PARSE_RET

   INCORRECT_INPUT:
    mov X0, #1 
    ldr X1, =input_fail             // string address
    mov X2, #23                    // string length (in bytes. Not every symbol is created equal, remember about unicode ones)
    mov X8, #64
    svc 0  
    b PARSE
    
FI: 
   
   mov X0, #0                 // 0 аs return code
   mov X8, #93                // 93 code is for finishing the program
   svc 0                      // syscaaaaaaall  
 


//X2 as i
//X3 as J
//X4 as a result, finishes when equal 20

CHECKER: 
mov X1, X7
mov X2, #0
mov X4, #0
add X1, X1, #8 //arr[0][0]
 CHECK_I:
  mov X3, #0
 CHECK_J:
  ldrb W0, [X1]
  tst W0, #0b01000000
  b.NE IS_HIT
 HIT_COUNTED:
  add X1, X1, #1 
  add X3, X3, #1
  cmp X3, #12
  b.MI CHECK_J 
  sub X1, X1, #12
  add X1, X1, #16
  add X2, X2, #1
  cmp X2, #11
  b.MI CHECK_I
RET 
  IS_HIT:
   tst W0, #0b10000000
   b.NE SHIP_IS_HIT
   b HIT_COUNTED
  SHIP_IS_HIT:
   add X4, X4, #1
   b HIT_COUNTED 

 //X3 for total count of hit cells
 //X3 for size of the ship
CHECK_IF_DESTROYED:
  ldrb W0, [X9]
  mov X5, X9
  tst W0, #0b10000000
  b.ne HIT_SHIP
 HIT_RET: 
  RET

HIT_SHIP:
  add X3, X3, #1
  add X4, X4, #1
  tst W0, #0b00010000
  b.ne CHECK_LEFT
 LEFT_CHECKED: 
  tst W0, #0b00001000
  b.ne CHECK_RIGHT
  tst W0, #0b00000100
  b.ne CHECK_UP
 UP_CHECKED:
  tst W0, #0b00000010
  b.ne CHECK_DOWN
 DOWN_CHECKED: 
 RIGHT_CHECKED: 
  b HIT_RET

CHECK_LEFT:
  sub X9, X9, #1
  ldrb W0, [X9]
  tst W0, #0b10000000
  b.ne LEFT_CONTAINS_SHIP
 LEFT_RET: 
  tst W0, #0b01000000
  b.ne LEFT_IS_HIT
 LEFT_HIT_RET: 
  tst W0, #0b00010000
  b.ne CHECK_LEFT
  MOV X9, X5
  ldr W0, [X9]
  b LEFT_CHECKED;

 LEFT_CONTAINS_SHIP:
  add X3, X3, #1
  b LEFT_RET
 LEFT_IS_HIT:
  add X4, X4, #1
  b LEFT_HIT_RET

CHECK_RIGHT:
  add X9, X9, #1
  ldrb W0, [X9]
  tst W0, #0b10000000
  b.ne RIGHT_CONTAINS_SHIP
 RIGHT_RET:
  tst W0, #0b01000000
  b.ne RIGHT_IS_HIT
 RIGHT_HIT_RET: 
  tst W0, #0b00001000
  b.ne CHECK_RIGHT
  b RIGHT_CHECKED

 RIGHT_CONTAINS_SHIP:
  add X3, X3, #1
  b RIGHT_RET 
 RIGHT_IS_HIT:
  add X4, X4, #1
  b RIGHT_HIT_RET

CHECK_UP:
  sub X9, X9, #16
  ldrb W0, [X9]
  tst W0, #0b10000000
  b.ne UP_CONTAINS_SHIP
 UP_RET: 
  tst W0, #0b01000000
  b.ne UP_IS_HIT
 UP_HIT_RET: 
  tst W0, #0b00000100
  b.ne CHECK_UP
  MOV X9, X5
  ldr W0, [X9]
  b UP_CHECKED;

 UP_CONTAINS_SHIP:
  add X3, X3, #1
  b UP_RET
 UP_IS_HIT:
  add X4, X4, #1
  b UP_HIT_RET

CHECK_DOWN:
  add X9, X9, #16
  ldr X0, [X9]
  tst X0, #0b10000000
  b.ne DOWN_CONTAINS_SHIP
 DOWN_RET:
  tst X0, #0b01000000
  b.ne DOWN_IS_HIT
 DOWN_HIT_RET: 
  tst X0, #0b00000010
  b.ne CHECK_DOWN
  b DOWN_CHECKED

 DOWN_CONTAINS_SHIP:
  add X3, X3, #1
  b DOWN_RET 
 DOWN_IS_HIT:
  add X4, X4, #1
  b DOWN_HIT_RET

FILL_CELLS_AROUND:
  sub X9, X9, #1
  ldr X0, [X9]
  mov X5, X9
  tst X0, #0b00001000
  b.ne HORIZONTAL_FILL
  tst X0, #0b00010000
  b.ne HORIZONTAL_FILL
  add X9, X9, #1
  sub X9, X9, #16
  mov X5, X9
  ldr X0, [X9]
  tst X0, #0b00000100
  b.ne VERTICAL_FILL
  tst X0, #0b00000010
  b.ne VERTICAL_FILL
  b SINGLE_CELL_FILL 

 HORIZONTAL_FILL:  
  mov W0, #0b01000000
  sub X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #16            //MIDDLE CELL
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  sub X9, X9, #16
  ldr W0, [X9]
  tst W0, #0b00010000
  b.ne LEFT_IN_CHECK
  B LAST_LEFT
 LAST_LEFT_RET: 
  mov X9, X5
  ldr W0, [X9]
 RIGHT_CYCLE: 
  tst W0, #0b00001000
  mov W0, #0b01000000
  b.ne RIGHT_IN_CHECK
  B LAST_RIGHT
 LAST_RIGHT_RET: 
  b FILLED

 LAST_LEFT:
  sub X9, X9, #1
  sub X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000      //MIDDLE
  strb W0, [X9]
  add X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  sub X9, X9, #16
  add X9, X9, #1
  b LAST_LEFT_RET

 LAST_RIGHT:
  add X9, X9, #1
  sub X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000      //MIDDLE
  strb W0, [X9]
  add X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  sub X9, X9, #16
  sub X9, X9, #1
  b LAST_RIGHT_RET

 RIGHT_CHECKING:
  sub X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000      //MIDDLE
  strb W0, [X9]
  add X9, X9, #16
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  sub X9, X9, #16
  ldr W0, [X9]
  b RIGHT_CYCLE



 LEFT_IN_CHECK:
  sub X9, X9, #1
  b HORIZONTAL_FILL 
 RIGHT_IN_CHECK:
  add X9, X9, #1
  b RIGHT_CHECKING 

 VERTICAL_FILL:    
  mov W0, #0b01000000
  sub X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #1           //MIDDLE CELL
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  sub X9, X9, #1
  ldr W0, [X9]
  tst W0, #0b000000100
  b.ne UP_IN_CHECK
  B LAST_UP
 LAST_UP_RET: 
  mov X9, X5
  ldr W0, [X9]
 DOWN_CYCLE: 
  tst W0, #0b00000010
  mov W0, #0b01000000
  b.ne DOWN_IN_CHECK
  B LAST_DOWN
 LAST_DOWN_RET: 
  b FILLED

 LAST_UP:
  sub X9, X9, #16
  sub X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000      //MIDDLE
  strb W0, [X9]
  add X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  sub X9, X9, #1
  add X9, X9, #16
  b LAST_UP_RET

 LAST_DOWN:
  add X9, X9, #16
  sub X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000      //MIDDLE
  strb W0, [X9]
  add X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  sub X9, X9, #1
  sub X9, X9, #16
  b LAST_DOWN_RET

 DOWN_CHECKING:
  sub X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  add X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000      //MIDDLE
  strb W0, [X9]
  add X9, X9, #1
  ldr W0, [X9]
  orr W0, W0, #0b01000000
  strb W0, [X9]
  sub X9, X9, #1
  ldr W0, [X9]
  b DOWN_CYCLE



 UP_IN_CHECK:
  sub X9, X9, #16
  b VERTICAL_FILL 
 DOWN_IN_CHECK:
  add X9, X9, #16
  b DOWN_CHECKING

 SINGLE_CELL_FILL:
   add X9, X9, #16 

   ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   ADD X9, X9, #16
   ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   SUB X9, X9, #32
   ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   add X9, X9, #16
   
   sub X9, X9, #1
   ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   ADD X9, X9, #16
   ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   SUB X9, X9, #32
   ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   add X9, X9, #16
   
   add X9, X9, #2
    ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   ADD X9, X9, #16
   ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   SUB X9, X9, #32
   ldr W0, [X9]
   orr W0, W0, #0b01000000
   strb W0, [X9]
   add X9, X9, #16

 b FILLED




.data

first_field: .fill 180, 1, 0
second_field: .fill 180, 1, 0
pathRnd: .asciz "/dev/urandom"
left_box: .ascii " ╔"
right_box: .ascii "╗"
bottom_left_box: .ascii " ╚"
bottom_right_box: .ascii "╝"
upper_not_even_box: .ascii "═"
upper_even_box: .ascii "╦"
lower_not_even_box: .ascii "═"
lower_even_box: .ascii "╩"
left_even_box: .ascii " ╠"
left_not_even_box: .ascii "║"
right_even_box: .ascii "╣"
right_not_even_box: .ascii "║"
middle_horizontal_even_box: .ascii "║"
middle_not_even_box: .ascii "═"
middle_even_box: .ascii "╬"
new_line: .ascii "\n"
vert_line: .asciz "  A B C D E F G H I J\n"
input_ask: .asciz "enter the desired cell\n"
input_fail: .asciz "Enter the correct cell\n"
player1_turn: .asciz "Player 1, "
player2_turn: .asciz "Player 2, "
.align 2
rand: .word 0
reg_save: .octa 0
text: .asciz "A"
temp_symb: .byte 0
screen_clr: .asciz "\033c"