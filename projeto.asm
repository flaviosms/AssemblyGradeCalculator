.486
.model flat, stdcall
option casemap :none
 
        include \masm32\include\windows.inc
 
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\masm32.inc
 
        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\masm32.lib
.data
        nota               dq      ?
        nnotas               dq      ?
        somatorio          dq      ?
        Result          dq      ?
        contador  dd  0.0
        incremento dq 1.0
        const7 dd 7.0
        const5 dd 5.0
        const4 dd 4.0
        constpesomedia dd 0.6
        constpesofinal dd 0.4

        opcao dd ?

        aszBemvindo      db      0Dh, 0Ah, 'Bem vindo ao calculador de notas ultracomplicado.', 0
        aszPromptnnotas      db      0Dh, 0Ah, 'Insira o numero de notas: ', 0
        aszPromptnota      db      0Dh, 0Ah, 'Insira a uma nota: ', 0
        aszMsgResult    db      0Dh, 0Ah, 'Result: ', 0
        asznovoaluno   db      0Dh, 0Ah, 0Dh, 0Ah, "Digite 1 para calcular a media de outro aluno ou qualquer outra tecla para sair:", 0
        aszaprovado   db      0Dh, 0Ah, 0Dh, 0Ah, "Estas notas deixam voce aprovado na disciplina", 0

        aszreprovado   db      0Dh, 0Ah, 0Dh, 0Ah, "Estas notas deixam voce reprovado na disciplina", 0

        aszfinal   db      0Dh, 0Ah, 0Dh, 0Ah, "Estas notas deixam voce na prova final da disciplina precisando de :", 0

        hConsoleOutput  HANDLE  ?
        hConsoleInput   HANDLE  ?
        Buffer          db      1024 dup(?)
        BufLen          dd      ?
.code
 
start:
 
        ; ????????? ?????????? ????? ? ?????? ???????
        invoke  GetStdHandle,   STD_INPUT_HANDLE
        mov     hConsoleInput,  eax
 
        invoke  GetStdHandle,   STD_OUTPUT_HANDLE
        mov     hConsoleOutput, eax

        


        _novoaluno:
        xor eax,eax
        mov [contador] , eax
        invoke  ClearScreen
        invoke  WriteConsole, hConsoleOutput, ADDR aszBemvindo,\
                        LENGTHOF aszBemvindo - 1, ADDR BufLen, NULL
        ;???? nnotas
        invoke  WriteConsole, hConsoleOutput, ADDR aszPromptnnotas,\
                LENGTHOF aszPromptnnotas - 1, ADDR BufLen, NULL
        invoke  ReadConsole, hConsoleInput, ADDR Buffer,\
                LENGTHOF Buffer, ADDR BufLen, NULL
        lea     esi,    [Buffer]        ;???????? ????????
        add     esi,    [BufLen]        ;???????? ??????
        sub     esi,    2               ;?? ?????? ?????
        mov     [esi], word ptr 0
        finit
        invoke  StrToFloat, ADDR Buffer, ADDR nnotas
        
        ;inicializando somatorio
        finit
        fld [nnotas]
        fld st(0)
        fsubp   st(1),  st(0)
        fstp    [somatorio]
        finit
        

        ;???? nota
        _somanota:
        
            invoke  WriteConsole, hConsoleOutput, ADDR aszPromptnota,\
                    LENGTHOF aszPromptnota - 1, ADDR BufLen, NULL
            invoke  ReadConsole, hConsoleInput, ADDR Buffer,\
                    LENGTHOF Buffer, ADDR BufLen, NULL
            lea     esi,    [Buffer]        ;???????? ????????
            add     esi,    [BufLen]        ;???????? ??????
            sub     esi,    2               ;?? ?????? ?????
            mov     [esi], word ptr 0
            finit
            invoke  StrToFloat, ADDR Buffer, ADDR nota
 
            finit
 
            fld     [nota]             ;st(0)=nota
            fld     [somatorio]        ;st(0)=somatorio,st(1)=nota
            faddp   st(1),  st(0) 
            fstp    [somatorio]                      
            ;limpa FPU
            finit
 
            fld [contador]
            fld [incremento]
            
            faddp   st(1),  st(0) 
            
            fstp [contador]
            
            finit
            fld [nnotas]
            fld [contador]
            
            
            fcom
            wait                 ;wait FPU
            fstsw ax             ;copy FPU flags to ax
            sahf                 ;copy ax to CPU flags
            jb _somanota        ;do less or equal
            
        finit
        fld     [somatorio]        ;st(0)=somatorio
        fld     [nnotas]
        fdiv
        fstp    [Result]
        finit
        invoke  WriteConsole, hConsoleOutput, ADDR aszMsgResult,\
                LENGTHOF aszMsgResult - 1, ADDR BufLen, NULL
        invoke  FloatToStr2, [Result], ADDR Buffer
        invoke  StrLen, ADDR Buffer
        mov     [BufLen],       eax
        invoke  WriteConsole, hConsoleOutput, ADDR Buffer,\
                BufLen, ADDR BufLen, NULL
        finit
        fld [Result]
        fld [const7]
        fcom
        
        wait                 ;wait FPU
        fstsw ax             ;copy FPU flags to ax
        sahf                 ;copy ax to CPU flags
        jb _passou       ;do bigger
        
        finit
        fld [Result]
        fld [const4]
        fcom
        wait                 ;wait FPU
        fstsw ax             ;copy FPU flags to ax
        sahf                 ;copy ax to CPU flags
        jbe _final        ;do bigger
        _reprovou:
            invoke  WriteConsole, hConsoleOutput, ADDR aszMsgResult,\
                LENGTHOF aszMsgResult - 1, ADDR BufLen, NULL
            jmp _fim

        _passou:
            invoke  WriteConsole, hConsoleOutput, ADDR aszreprovado,\
                LENGTHOF aszreprovado - 1, ADDR BufLen, NULL
            jmp _fim
        _final:
        invoke  WriteConsole, hConsoleOutput, ADDR aszfinal,\
                LENGTHOF aszfinal - 1, ADDR BufLen, NULL
        finit
        fld [const5]  ;0=5
        fld [Result]    ;0=media 1=5
        fld [constpesomedia] ; 0=0.6 1=media 2=5
        fmulp st(1),  st(0) ; 0=mediax0.6 1=5
        
        fsubp st(1),  st(0) ; 0=5-mediax0.6
        fld[constpesofinal] ; 0=0.4 1 =5-mediax0.6 
        fdivp st(1),  st(0) ; 0=resultadofinal
        fstp [Result]
        invoke  FloatToStr2, [Result], ADDR Buffer
        invoke  StrLen, ADDR Buffer
        mov     [BufLen],       eax
        invoke  WriteConsole, hConsoleOutput, ADDR Buffer,\
                BufLen, ADDR BufLen, NULL
        jmp _fim
        
        _fim:
        invoke  WriteConsole, hConsoleOutput, ADDR asznovoaluno,\
                LENGTHOF asznovoaluno - 1, ADDR BufLen, NULL
        invoke  ReadConsole, hConsoleInput, ADDR Buffer,\
                LENGTHOF Buffer, ADDR BufLen, NULL
            lea     esi,    [Buffer]        ;???????? ????????

        mov ecx, 2
        mov edi, esi
        mov al , '1'
        cld
        repne scasb
        je _novoaluno ; when found
        
        invoke  ExitProcess, 0

        
 
end start