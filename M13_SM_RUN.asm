; M13_SM_RUN.ASM
; Lab M13
; 

.586P
.MODEL FLAT     ; Flat memory model

PUBLIC SM_RUN            ; SM_RUN is externally visible to the linker

SM_RUN      PROTO NEAR32 stdcall, stack_machine_code:DWORD
push_cmd    PROTO NEAR32 stdcall, push_operand:DWORD
add_cmd     PROTO NEAR32 stdcall, push_operand:DWORD
sub_cmd     PROTO NEAR32 stdcall, push_operand:DWORD
nop_cmd     PROTO NEAR32 stdcall, push_operand:DWORD
hlt_cmd     PROTO NEAR32 stdcall, push_operand:DWORD
pop_cmd     PROTO NEAR32 stdcall, pop_operand:DWORD
pushreg_cmd PROTO NEAR32 stdcall, push_operand:DWORD
mul_cmd     PROTO NEAR32 stdcall, push_operand:DWORD


EXTERN _NEWARRAY@4:NEAR   ; This procedure is defined in M13_externs.cpp
EXTERN _OUTPUTSZ@4:NEAR   ; This procedure is defined in M13_externs.cpp
EXTERN _OUTPUTINT@4:NEAR  ; This procedure is defined in M13_externs.cpp
EXTERN _strlen:NEAR       ; This procedure is part of the C standard library

EXTERN _global_variable:DWORD    ; Sample global variable defined in M13_externs.cpp

.const
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Trace messages for debugging
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        SZ_SUB_CMD      BYTE "...sub_cmd...", 13, 10, 0
        SZ_PUSH_CMD     BYTE "...push_cmd...", 13, 10, 0
        SZ_ADD_CMD      BYTE "...add_cmd...", 13, 10, 0
        SZ_NOP_CMD      BYTE "...nop_cmd...", 13, 10, 0
        SZ_HLT_CMD      BYTE "...hlt_cmd...", 13, 10, 0
        SZ_POP_CMD      BYTE "...pop_cmd...", 13, 10, 0
        SZ_POP_CMD_BAD  BYTE "...Attempt to pop from an empty stack, command ignored...", 13, 10, 0
        SZ_PUSHREG_CMD  BYTE "...pushreg_cmd...", 13, 10, 0
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Constants corresponding to the command opcodes
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        COMMAND_NOP                EQU 0 
        COMMAND_PUSH_NUMBER        EQU 1
        COMMAND_PUSH_REGISTER      EQU 2
        COMMAND_ADD                EQU 3
        COMMAND_SUB                EQU 4
        COMMAND_HLT                EQU 5
        COMMAND_POP                EQU 6
        COMMAND_MUL                EQU 7
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data   ; The data segment
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Table of procedure addresses invoked by the stack machine
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        call_table DWORD OFFSET nop_cmd
                   DWORD OFFSET push_cmd
                   DWORD OFFSET pushreg_cmd
                   DWORD OFFSET add_cmd
                   DWORD OFFSET sub_cmd
                   DWORD OFFSET hlt_cmd
                   DWORD OFFSET pop_cmd
                   DWORD OFFSET mul_cmd
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sm_pointer DWORD 0
        sm_memory  DWORD 512 DUP( 0 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.code                    ; Code segment begins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure for running the stack machine program
; Output: EAX is the status code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SM_RUN  PROC NEAR32 stdcall, stack_machine_code:DWORD

        mov   eax, [stack_machine_code]
        mov   DWORD PTR [sm_pointer], 0 ; reset temp memory index

        ; Invoke procedures corresponding to particular opcodes
forever:
        mov     ebx, [ eax ]            ; get the opcode
        push    DWORD PTR [ eax + 4 ]   ; for each command push operand on stack
        call    call_table[ ebx * 4 ]   ; invoke command handler
        ;cmp     call_table[ ebx * 4 ], OFFSET hlt_cmd ; HALT?
        cmp     ebx, COMMAND_HLT
        je      getout                  ; Yes, we are done.
        add     eax, 8                  ; Advance to the next opcode
        jmp     forever

getout:
        mov DWORD PTR [_global_variable], 456    ; Testing global variable
        ;DEBUG;mov eax, 678                     ; Procedure return value
        ; return result to the caller:
        mov edi, DWORD PTR [sm_pointer]  ; load temp memory index
        dec edi                          ; set index to the top element
        mov eax, sm_memory[ edi * 4 ]    ; store operand in temp memory
        ret
SM_RUN  ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure handling the PUSH command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
push_cmd PROC  NEAR32 stdcall, push_operand:DWORD
        pushad
        mov   edx, push_operand  ; get the opeand from the stack

        ; sm_memory[ sm_pointer ] = edx  ; store value in temp memory
        ; ++sm_pointer
        mov edi, DWORD PTR [sm_pointer]  ; load temp memory index
        mov sm_memory[ edi * 4 ], edx    ; store operand in temp memory
        inc DWORD PTR [sm_pointer]

        pushd OFFSET SZ_PUSH_CMD
        call  _OUTPUTSZ@4                 ; display text
        push  DWORD PTR [push_operand]
        call  _OUTPUTINT@4                ; display text
        popad
        ret
push_cmd ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure handling the ADD command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
add_cmd PROC NEAR32 stdcall, push_operand:DWORD
        pushad
        ; push( pop() + pop() )
        ;       eax

        mov edi, DWORD PTR [sm_pointer]  ; load temp memory index
        dec edi                          ; index of existing element
        mov eax, sm_memory[ edi * 4 ]    ; get top operand
        dec edi                          ; index of the second operand
        add sm_memory[ edi * 4 ], eax    ; add to the second operand
        dec DWORD PTR [sm_pointer]       ; maintain the index

        pushd OFFSET SZ_ADD_CMD
        call  _OUTPUTSZ@4    ; display text
        popad
        ret
add_cmd ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure handling the SUB command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sub_cmd PROC NEAR32 stdcall, push_operand:DWORD
        pushad
        ; push( pop() - pop() )
        ;       eax

        mov edi, DWORD PTR [sm_pointer]  ; load temp memory index
        dec edi                          ; index of existing element
        mov eax, sm_memory[ edi * 4 ]    ; get top operand
        dec edi                          ; index of the second operand
        sub sm_memory[ edi * 4 ], eax    ; subtract from the second operand

        dec DWORD PTR [sm_pointer]       ; maintain the index
        pushd OFFSET SZ_SUB_CMD
        call  _OUTPUTSZ@4    ; display text
        popad
        ret
sub_cmd ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure handling the NOP command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nop_cmd PROC NEAR32 stdcall, push_operand:DWORD
        pushad
        pushd OFFSET SZ_NOP_CMD
        call  _OUTPUTSZ@4    ; display text
        popad
        ret
nop_cmd ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure handling the HLT command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hlt_cmd PROC NEAR32 stdcall, push_operand:DWORD
        pushad
        pushd OFFSET SZ_HLT_CMD
        call  _OUTPUTSZ@4    ; display text
        popad
        ret
hlt_cmd ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure handling the POP command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop_cmd PROC NEAR32 stdcall, pop_operand:DWORD
        pushad

        ; handle the command logic:
        cmp [sm_pointer], 0 ; test whether there is anything on the stack
        jne @F              ; if okay, then proceed with the command
        ; otherwise, fail:
        pushd OFFSET SZ_POP_CMD_BAD
        call  _OUTPUTSZ@4    ; display error message
        jmp exit_pop_cmd

@@:
        dec [sm_pointer]    ; decrement stack pointer

        pushd OFFSET SZ_POP_CMD
        call  _OUTPUTSZ@4    ; display text

exit_pop_cmd:
        popad
        ret
pop_cmd ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure handling the MUL command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MUL_cmd PROC NEAR32 stdcall, push_operand:DWORD
        pushad
        ; push( pop() * pop() )
        ;       eax

        mov edi, DWORD PTR [sm_pointer]  ; load temp memory index
        dec edi                          ; index of existing element
        mov eax, sm_memory[ edi * 4 ]    ; get top operand
        dec edi                          ; index of the second operand
        mul sm_memory[ edi * 4 ], eax    ; multiply the operands

        dec DWORD PTR [sm_pointer]       ; maintain the index
        pushd OFFSET SZ_SUB_CMD
        call  _OUTPUTSZ@4    ; display text
        popad
        ret
mul_cmd ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure handling the PUSH REG command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pushreg_cmd PROC NEAR32 stdcall, push_operand:DWORD
        pushad
        pushd OFFSET SZ_PUSHREG_CMD
        call  _OUTPUTSZ@4    ; display text
        popad
        ret
pushreg_cmd ENDP

END
