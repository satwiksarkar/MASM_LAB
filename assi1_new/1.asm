.MODEL SMALL
.DATA
    MSG_IN  DB 10, 13, 'Enter 10 digits (0-9): $'
    MSG_OUT DB 10, 13, 'Modified Data at 4000H: $'

.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ; ========================================================
    ; PHASE 1: TAKE INPUT AND STORE AT 3000H
    ; ========================================================
    ; Print prompt message
    LEA DX, MSG_IN
    MOV AH, 09H
    INT 21H

    MOV DI, 3000H       ; Set DI to point to memory location 3000H
    MOV CX, 000AH       ; Set loop counter to 10

INPUT_LOOP:
    MOV AH, 01H         ; DOS function for single keyboard input
    INT 21H             ; Read character (Echoes to screen, saves in AL)
    
    SUB AL, 30H         ; Convert ASCII char to raw number (e.g., '5' -> 05H)
    MOV [DI], AL        ; Store the raw number into memory at 3000H
    INC DI              ; Move pointer to the next memory byte
    
    LOOP INPUT_LOOP     ; Repeat until 10 digits are entered

    ; ========================================================
    ; PHASE 2: TRANSFER FROM 3000H TO 4000H AND MODIFY
    ; ========================================================
    MOV SI, 3000H       ; Set Source Pointer to 3000H
    MOV DI, 4000H       ; Set Destination Pointer to 4000H
    MOV CX, 000AH       ; Set loop counter to 10

TRANSFER_LOOP:
    MOV AL, [SI]        ; Load the raw number from 3000H
    
    MOV BL, 05H         ; Multiplier (5)
    MUL BL              ; AL = AL * 5
    ADD AL, 0AH         ; AL = AL + 10
    
    MOV [DI], AL        ; Store modified result at 4000H
    
    INC SI              ; Move to next source byte
    INC DI              ; Move to next destination byte
    
    LOOP TRANSFER_LOOP  ; Repeat 10 times

    ; ========================================================
    ; PHASE 3: READ FROM 4000H AND PRINT TO SCREEN
    ; ========================================================
    ; Print output message
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    MOV SI, 4000H       ; Set Source Pointer to read from 4000H
    MOV CX, 000AH       ; Set loop counter to 10

PRINT_LOOP:
    MOV AL, [SI]        ; Load the modified byte (e.g., 25)
    XOR AH, AH          ; Clear AH (Set AH to 00H)
    
    ; AAM (ASCII Adjust for Multiply) divides AL by 10.
    ; It puts the quotient (Tens) in AH, and remainder (Ones) in AL.
    AAM                 ; E.g., if AL=25, AAM makes AH=02, AL=05
    
    MOV BX, AX          ; Save the split digits into BX (BH=Tens, BL=Ones)
    
    ; Print the Tens digit
    MOV DL, BH          ; Move Tens digit to DL
    ADD DL, 30H         ; Convert back to ASCII character
    MOV AH, 02H         ; DOS function to print character
    INT 21H
    
    ; Print the Ones digit
    MOV DL, BL          ; Move Ones digit to DL
    ADD DL, 30H         ; Convert back to ASCII character
    MOV AH, 02H         ; DOS function to print character
    INT 21H
    
    ; Print a space separator between numbers
    MOV DL, ' '         
    MOV AH, 02H
    INT 21H
    
    INC SI              ; Move to next memory byte at 4000H
    LOOP PRINT_LOOP     ; Repeat until all 10 modified bytes are printed

    ; Terminate Program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
