.MODEL SMALL
.DATA
    MSG_IN  DB 10, 13, 'Enter 20 single digits (0-9) continuously: $'
    MSG_OUT DB 10, 13, 'Zig-Zag Array at 4000H: $'

.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ; ========================================================
    ; PHASE 1: TAKE 20 INPUTS AND STORE AT 4000H
    ; ========================================================
    LEA DX, MSG_IN       ; Print input prompt
    MOV AH, 09H
    INT 21H

    MOV DI, 4000H        ; Set destination pointer to 4000H
    MOV CX, 20           ; Loop 20 times (14H)

INPUT_LOOP:
    MOV AH, 01H          ; DOS function for single keyboard input
    INT 21H              ; Wait for user to press a key
    
    SUB AL, 30H          ; Convert ASCII character to raw numeric value
    MOV [DI], AL         ; Store the raw number at the current 4000H offset
    INC DI               ; Move pointer to the next memory byte
    
    LOOP INPUT_LOOP

    ; ========================================================
    ; PHASE 2: ZIG-ZAG REARRANGEMENT AT 4000H
    ; ========================================================
    MOV SI, 4000H        ; Reset SI to point to the start of the array
    MOV CX, 19           ; 19 pairs to compare (20 elements - 1)
    MOV BL, 0            ; Toggle flag. 0 = Expect <, 1 = Expect >

ZIGZAG_LOOP:
    MOV AL, [SI]         ; Load current element
    MOV AH, [SI+1]       ; Load next element

    CMP BL, 0            
    JNE EXPECT_GREATER   ; If BL is 1, jump to Greater Than check

EXPECT_LESS:
    CMP AL, AH       
    JB NEXT_PAIR         ; If AL < AH, it is correct. Skip swap.
    JMP DO_SWAP          ; Otherwise, out of order. Swap them.

EXPECT_GREATER:
    CMP AL, AH
    JA NEXT_PAIR         ; If AL > AH, it is correct. Skip swap.

DO_SWAP:
    MOV [SI], AH         ; Put the second element into the first slot
    MOV [SI+1], AL       ; Put the first element into the second slot

NEXT_PAIR:
    XOR BL, 1            ; Toggle the flag (0 -> 1 -> 0)
    INC SI               ; Move to the next overlapping pair
    LOOP ZIGZAG_LOOP

    ; ========================================================
    ; PHASE 3: PRINT THE ZIG-ZAG ARRAY FROM 4000H
    ; ========================================================
    LEA DX, MSG_OUT      ; Print output prompt
    MOV AH, 09H
    INT 21H

    MOV SI, 4000H        ; Reset SI to read from the start of the array
    MOV CX, 20           ; Loop 20 times

PRINT_LOOP:
    MOV DL, [SI]         ; Load the raw number
    ADD DL, 30H          ; Convert back to ASCII character for printing
    MOV AH, 02H          ; DOS function to print character
    INT 21H

    MOV DL, ' '          ; Print a space separator
    MOV AH, 02H
    INT 21H

    INC SI               ; Move to the next byte
    LOOP PRINT_LOOP

    ; Terminate the program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
