include irvine32.inc
Include macros.inc

.data
column DWORD 0

grid BYTE -1, -1, -1, -1, -1, -1, -1
rowSize = ($ - grid)
     BYTE -1, -1, -1, -1, -1, -1, -1
     BYTE -1, -1, -1, -1, -1, -1, -1
     BYTE -1, -1, -1, -1, -1, -1, -1
     BYTE -1, -1, -1, -1, -1, -1, -1
     BYTE -1, -1, -1, -1, -1, -1, -1

row DWORD ?
player BYTE 1

.code
main PROC
     call printLayout

     gameLoop:
        call printArrow
        call readChar
        cmp al, '1'
        jne checkEnterkey
        je breakLoop
        checkEnterKey: 
        cmp ax, 1C0Dh ;enter key ascii value
        jne checkRightKey
        call markPosition
        cmp eax, -1
     je gameLoop


     call printGrid
     call winCheck
     CMP eax,1
     JE playerWon
     call endGame
     cmp ebx, 1
     je breakLoop
     call changePlayer
     jmp gameLoop

 checkRightKey:
     cmp ax, 4D00h ;right-arrow key ascii value
     jne checkLeftKey
     inc column
     jmp exit1
 checkLeftKey:
     cmp ax, 4B00h ;left-arrow key ascii value
     jne exit1
     dec column
 exit1:
     cmp column, 0
     jge valid1
     mov column, 6
 valid1:
     cmp column, 7
     jb valid2
     mov column, 0
 valid2:
     jmp gameLoop

 playerWon: 
     call displayWinner

 breakLoop:
     mov DH, 20
     call gotoXY
     mov eax,green+(black*16)
     call settextcolor
     call crlf
     mWrite"--------------------------------------------------------------------------------------------------------------------"
     call crlf
     mWrite "******COAL PROJECT"
     call crlf
     mWrite"******Abdullah Anis Edhi(22K-4392)"
     call crlf
     mWrite"******Ansharah Asad(22K-4441)"
     call crlf
     mWrite"******Kousar Saeed(22K-4588)"
     mov eax,white+(black*16)
     call settextcolor
exit
main ENDP

printLayout PROC
    mov DH,2
    mov DL,10
    call gotoxy
    mov eax,blue+(black*16)
    call settextcolor
    mWrite "          Connect Four "
    call crlf
    INC DH
    call gotoxy
    mWrite "Player 1(red) vs Player 2(yellow)"
    
     mov DH, 6 ;printing numbers on the top of gird
     mov DL, 20
     call Gotoxy
     mov ebx, 0
     mov ecx, 7
 
 printLayoutL1:
     mov eax, ebx
     call writeDec
     mov al, " "
     call writeChar
     inc ebx
  Loop printLayoutL1

     mov DH, 14 ;printing base line
     mov DL, 20
     call gotoxy
     mov ecx, 13
  
  printLayoutL2:
     mov al, "-"
     call writeChar
  Loop printLayoutL2

     mov DH, 5
     mov DL, 20
     call gotoXy
     mov eax, red + (black * 16)
     call SetTextColor
     mwrite "Player 1 turn"
     mov eax, white + (black * 16)
     call SetTextColor

ret
printLayout ENDP

setColor PROC
     cmp player, 1
     jne setColorYellow
     mov eax, red + (black * 16)
     call SetTextColor
     jmp exit1
     setColorYellow:
     mov eax, yellow + (black * 16)
     call SetTextColor
  
exit1:
ret
setColor endp

printArrow PROC ;column value passed through variable "column"
     mov DH, 7
     mov DL, 20
     call Gotoxy
     mov al, " "
     mov ecx, 7
     mov ebx, 0
 
 printArrowL1: 
     cmp ebx, column
     jne printArrowfalse
     call setColor
     mov al, 31
     call writeChar
     mov eax, white + (black * 16)
     call SetTextColor
     mov al, " "
     jmp printArrowendif
 
 printArrowfalse:
     call writeChar

 printArrowendif:
     call writeChar
     
     inc ebx
  Loop printArrowL1

ret
printArrow ENDP

printGrid PROC ;no value passed, only use grid 2d-array offset
     mov DL, 19
     mov DH, 8
     mov esi, OFFSET grid
     mov ecx, 6
     mov ebx, 0 ;for rows

  printGridL1:
     call Gotoxy
     push ecx
     mov edi, 0 ;for cols
     mov al, " "
     call writeChar
     mov ecx, 7
          printGridL2:
             mov eax, 0
             mov al, [esi + edi]
             cmp al, -1
             jne checkPlayer1 ;not empty, so check players
             mov al, " "
             jmp printElement
          checkPlayer1:
             cmp al, 1
             jne checkPlayer2 ;not player 1, so jump to player 2
             mov eax, red + (black *16)
             call SetTextColor
             mov al, 'O'
             jmp printElement
          checkPlayer2:
             mov eax, yellow + (black *16)
             call SetTextColor
             mov al, 'O'
             jmp printElement
          printElement:
             call writeChar
             mov eax, white + (black * 16)
             call SetTextColor
             mov al, " "
             call writeChar
             inc edi
        Loop printGridL2
    
    call Crlf
    add esi, rowSize
    inc edi
    inc dh
    pop ecx
  Loop printGridL1
    
    mov eax, white + (black *16)
    call SetTextColor

ret
printGrid ENDP

markPosition PROC ;uses value in column and player variable
     mov ecx, 6 ;return 1 if valid, otherwise -1 
     mov esi, OFFSET grid
     add esi, column
     add esi, rowSize*5

  markPositionL1:
     mov al, BYTE PTR [esi]
     cmp al, -1
     jne checkNextPosition
     mov al, BYTE PTR player
     mov [esi], al
     push esi
     call showAnimation
     mov eax, 1
   jmp markPositionExit
  
  checkNextPosition:
     sub esi, rowSize
  Loop markPositionL1
     mov eax, -1
     markPositionExit:

ret
markPosition ENDP

showAnimation PROC ;uses esi value as parameter through stack and uses column variable
    ENTER 0,0
    mov esi, [ebp+8]
    sub esi, column

    cmp player, 1 ;set text color according to player turn
    jne ShowAnimationplayer2

    mov eax, red + (black *16)
    call SetTextColor
    jmp EndplayerCheck
    
    ShowAnimationplayer2:
     mov eax, yellow + (black *16)
     call SetTextColor
    
    EndplayerCheck:
     mov eax, column
     mov bl, 2
     mul bl
     mov DL, 20
     add DL, AL
     mov DH, 8

    showAnimationWhile:
       cmp esi, OFFSET grid
       je showAnimationExit
       call gotoxy
       mWrite "O"
       mov eax, 50
       call delay
       call gotoxy
       mWrite " "
       inc DH
       sub esi, rowSize
    jmp showAnimationWhile

 showAnimationExit:
    mov eax, white + (black *16)

    call SetTextColor

pop ebp
ret 4
showAnimation ENDP

ChangePlayer PROC ;switch value of player variable
    mov DH, 5
    mov DL, 20
    call gotoXy

    cmp player, 1
    jne player2
    mov player, 2
    mov eax, yellow + (black * 16)
    call SetTextColor
    mwrite "Player 2 turn"
    jmp ChangePlayerExit

 player2:
    mov player, 1
    mov eax, red + (black * 16)
    call SetTextColor
    mwrite "Player 1 turn"
    ChangePlayerExit:
    mov eax, white + (black * 16)
    call SetTextColor

ret
ChangePLayer ENDP

endGame PROC ; returns 1 in ebx if the game has ended, returns 0 if the game has not ended
    mov esi, OFFSET grid
    mov ecx, 7
    mov edi, 0
    mov ebx, 1
    endGameL1:
    mov al, [esi + edi]
    cmp al, -1
    je endGameDonotEnd
    inc edi
    loop endGameL1
    jmp endGameExit1

 endGameDonotEnd:
    mov ebx, 0

 endGameExit1:
ret

endGame ENDP

winCheck PROC
     mov row,0
     mov column,0
     mov ecx,6
         rowloop: 
              mov esi,offset grid
              mov eax,rowsize
              mov ebx,row
              mul ebx
              add esi,eax
              push ecx
              mov ecx,7
              mov ebx,column
                 columnloop: 
                     mov al,[esi+ebx]
                     CMP al,player
                     JNE nextt 
                     
                     call checkHorizontal
                     cmp eax,1
                     JE foundd                               
                    
                    mov edx,row
                     call checkVertical
                     cmp eax,1
                     JE foundd

                     mov edx,row        
                     call checkDiagonalDECDEC
                     cmp eax,1
                     JE foundd

                     mov edx,row        
                     call checkDiagonalDECINC
                     cmp eax,1
                     JE foundd
                  nextt:
                     INC ebx
                     loop columnloop
             pop ecx
             INC row
          loop rowloop
      mov eax,0
jmp exitt
    foundd:
    pop ecx
    mov eax,1

exitt:
ret



winCheck ENDP

checkHorizontal PROC USES esi ebx ecx
      mov ecx,3

      check:
         INC ebx
         CMP ebx,6
         JA horizontalfail
         mov al,[esi+ebx]
         CMP al,player
         JNE horizontalfail
         loop check
         jmp pass

         horizontalfail:
         mov eax,0
         jmp exitt

         pass:
         mov eax,1
exitt:
ret
checkHorizontal ENDP

checkVertical PROC USES esi ebx ecx     
     mov ecx,3
   check:
         INC edx
         CMP edx,5
         JA verticalfail
         mov esi,offset grid
         mov eax,edx
         push edx
         push ebx
         mov ebx,rowsize      
         mul ebx
         add esi,eax
         pop ebx
         pop edx
         mov al,[esi+ebx]
         CMP al,player
         JNE verticalfail
    loop check
     
        mov eax,1
        jmp exitt
 verticalfail:
 mov eax,0

 exitt:
 ret
checkVertical ENDP


checkDiagonalDECDEC PROC USES ebx ecx esi
             
    mov ecx,3;check next3 rows and 3 columns for 1
        
        check1:
           DEC ebx ;ebx contains col
           CMP ebx,0
           JB diagonalFail
           DEC edx ;edx contains current row
           CMP edx,0
           JB diagonalFail
           mov esi,offset grid
           mov eax,rowsize
           push edx
           push ebx
           mov ebx,edx
           mul ebx
           add esi,eax
           pop ebx
           pop edx
           mov al,[esi+ebx]
           CMP al,player
           JNE diagonalFail
         loop check1
      mov eax,1
      jmp exitt

 diagonalFail:
  mov eax,0
              
exitt:
ret

checkDiagonalDECDEC endp


checkDiagonalDECINC PROC USES ebx ecx esi
             
    mov ecx,3;check next3 rows and 3 columns for 1
        
        check1:
           DEC ebx ;ebx contains col
           CMP ebx,0
           JB diagonalFail
           INC edx ;edx contains current row
           CMP edx,5
           JA diagonalFail
           mov esi,offset grid
           mov eax,rowsize
           push edx
           push ebx
           mov ebx,edx
           mul ebx
           add esi,eax
           pop ebx
           pop edx
           mov al,[esi+ebx]
           CMP al,player
           JNE diagonalFail
         loop check1
      mov eax,1
      jmp exitt

 diagonalFail:
  mov eax,0
              
exitt:
ret

checkDiagonalDECINC endp
displayWinner PROC
     call setColor
     mov DH,18
     mov DL,18
     call gotoxy
     mWrite "**********Player "
     movzx eax,player
     call writeDec 
     mWrite " won this game**********"
     call crlf
     mov eax,white+(black*16)
     call settextcolor

ret
displayWinner ENDP

end main