.MODEL SMALL
.DATA
    MSG_IN  DB 'Enter a single hex digit (0-9, A-F): $'
    MSG_OUT DB 10, 13, 'ASCII Equivalent printed: $'
    RAW_HEX DB ?    ; Variable to store the internal numeric value

.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ; ========================================================
    ; PHASE 1: TAKE INPUT AND CONVERT ASCII -> RAW HEX
    ; ========================================================
    ; Print input prompt
    LEA DX, MSG_IN
    MOV AH, 09H
    INT 21H

    ; Read a single character from the keyboard
    MOV AH, 01H
    INT 21H

    ; Convert ASCII input to raw numeric hex value (00H to 0FH)
    CMP AL, '9'         ; Check if input is '0'-'9'
    JBE IS_NUMBER_IN    ; If it is below or equal to '9', jump to IS_NUMBER_IN

    SUB AL, 37H         ; If 'A'-'F', subtract 37H (e.g., 'A'(41H) - 37H = 0AH)
    JMP STORE_VAL       ; Jump over the number logic

IS_NUMBER_IN:
    SUB AL, 30H         ; If '0'-'9', subtract 30H (e.g., '5'(35H) - 30H = 05H)

STORE_VAL:
    MOV RAW_HEX, AL     ; Save the raw hex value (00H-0FH) in memory

    ; ========================================================
    ; PHASE 2: CONVERT RAW HEX -> ASCII AND PRINT (Core Task)
    ; ========================================================
    ; Print output prompt
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; Load the raw hex value back into AL
    MOV AL, RAW_HEX

    ; Check if the value is 0-9 or A-F
    CMP AL, 09H
    JBE IS_NUMBER_OUT   ; If the value is 09H or less, it's a number (0-9)

    ADD AL, 37H         ; If it is 0AH-0FH, add 37H to get ASCII 'A'-'F'
    JMP PRINT_CHAR      ; Jump over the number logic

IS_NUMBER_OUT:
    ADD AL, 30H         ; If it is 00H-09H, add 30H to get ASCII '0'-'9'

PRINT_CHAR:
    ; The AL register now holds the correct ASCII character
    MOV DL, AL          ; Move character to DL for printing
    MOV AH, 02H         ; DOS function to print a character
    INT 21H

    ; Terminate Program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
