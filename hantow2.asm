;; Course: 2XA3 
;; Name: Navleen Singh
;; Student Number: 1302228
;; File: hantow.asm
;; Description: This is my final project for 2XA3. It takes in input from user between 2-8 and then it preformes step by step hanoi answer

%include "asm_io.inc"

segment .data                                               ; where all the predefined variables are stored

	ErrorString: db "Argument out of Range", 0                     ; define ErrorString as a String "Argument out of Range"
	ErrorInc: db "Incorrect Argument", 0                          ; define ErrorInc as a String "Incorrect Argument"
	ErrorArg: db "Too many Arguments", 0                         ; define ErrorArg as a String "Too many Arguments"
	finished: db "Done", 0										; deifne finished as a String "Done"
	Store dd 0                                       ; define Store this is what the size of the tower will be stored in

	StartArray: dd 0,0,0,0,0,0,0,0,9								; this array is where all the rings StartArray at
	EndArray: dd 0,0,0,0,0,0,0,0,9								; this array is where all the rings EndArray up at
	TempArray: dd 0,0,0,0,0,0,0,0,9								; this array is used to help move the rings

	; The next couple lines define the strings to show the pegs and what they look like
	
	Label: db "      Tower 1                 Tower 2                 Tower 3      ", 10, 0
	FinalRow: db "XXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXX        ", 10, 0
	Spaceing: db "     ", 0

segment .bss                                                ; where all the non defined variables are stored
	EBP resd 1 											; this is a variable to hold ebp in the StartArray
	ESP resd 1 											; this is a variable to hold esp in the StartArray
	CheckHanoi resd 1 									; this is a varibale used to check if orginal tower should be printed or modified one
	FinCount resd 1 										; this is a variable to count the number of moves needed to finish
	totalCount resd 1 										; this is a variable to count the number of moves preformed so far

segment .text
	global  asm_main                                        ; run the main function
	extern printf
	extern atoi

asm_main:
	push ebp 												; stores the value on stack
	mov [EBP], ebp 										; saves ebp to a TempArray variable

	mov ebp, esp 											; moves stack pointer to ebp
	push ebp 												; stores the value on stack
	mov [ESP], ebp										; saves ebp to a TempArray variable which is esp
	pop ebp 												; restores it

	mov edx, dword 0                                        ; set edx to zero this is where the Store is saved for now
	mov ecx, dword[ebp+8]                                   ; ecx has how many arguments are given
	mov eax, dword[ebp+12]                                  ; save the first argument in eax
	add eax, 4                                              ; move the pointer to the main argument
	mov ebx, dword[eax]                                     ; save the number into ebx
	
	push ebx                                                ; reserve ebx
	push ecx                                                ; reserve ecx

	cmp ecx, dword 2                                        ; compare if there are more the one argument given
	jg ToomanyArguments                                                  ; if more then one argument is given then jump Too many Argument (ToomanyArguments)

	mov ecx, 0                                              ; ecx = 0
	movzx eax, byte[ebx+ecx]                                ; eax is the first character number from the inputed number
	sub eax, 48                                             ; subtract 48 to get the actual number/letter/symbol
	cmp eax, 10                                             ; check if eax is less then 10
	jg IncorrectArgument                                                   ; if eax is greater then 10 then it is a letter or symbol

	StringToInt:                                          ; change String to int procedure
		add edx, eax                                        ; put the number in edx
		inc ecx                                             ; increase counter (ecx)
		movzx eax, byte[ebx+ecx]                            ; move the next number in eax
		cmp eax, 0                                          ; if eax = 0 then there are no more numbers
		mov [Store], edx                             ; change Store to what ever is in edx
		je CheckRng                                       ; go to CheckRng to check if between 2-8
		sub eax, 48                                         ; subtract 48 to get the actual number/letter/symbol 
		cmp eax, 10                                         ; check if eax is less then 10
		jg IncorrectArgument                                               ; if eax is greater then 10 then it is a letter or symbol
		imul edx, 10                                        ; multiply edx by 10 so the next number can be added to the EndArray
		jmp StringToInt                                   ; jump back to StringToInt if not finished 

	CheckRng:                                             ; check the range of the number
		cmp edx, dword 2                                    ; compare edx with 2
		jl ArgumentoutofRange                                             ; if Store (edx) < 2 then go to Argument out of Range (ArgumentoutofRange)
	
		cmp edx, dword 8                                    ; compare edx with 8
		jg ArgumentoutofRange                                             ; if Store (edx) > 8 then go to Argument out of Range (ArgumentoutofRange)

	mov ecx, [Store]									; move the number enterd by user in ecx
	mov esi, 28 											; esi == 28 for stack pointer counter
	mov ebx, 1
	mov eax, 0

	NumberMoves:												; check how many moves it should take
		imul ebx, 2 										; ebx * 2
		inc eax 											; increase eax
		cmp eax, ecx										; compare eax with ecx
		jne NumberMoves										; if eax != ecx then go to StartArray of this loop
		dec ebx												; subtract one from ebx
		mov [FinCount], ebx								; save ebx into a variable

	MainArraySet:												; set the first array the starting peg
		mov [StartArray+esi], ecx								; put ecx into the array
		sub esi, 4 											; take one away from stack pointer conter
		dec ecx												; take one away from ecx so the next number can go in to the array
		cmp ecx, 0											; compare ecx with 0
		jne MainArraySet										; if ecx != 0 then go to MainArraySet loop
		mov esi, 0
		mov ecx, 0
		jmp ShowTowers

SetPegs: 
	RemovePeg1: 												; removes the top disk from tower 1
		mov ecx, [StartArray+esi] 								; moves through each position of the array
		add esi, 4
		cmp ecx, 0 											; checks if 0, if so moves to next position
		je RemovePeg1
		sub esi, 4 											; if the index has a value the position is moved back one
		mov edx, [StartArray+esi] 								; stores the value of the disk being removed
		mov [StartArray+esi], dword 0 							; removes the disk by replacing with a 0 in teh array
		jmp CheckArray 									; jumps down to the add section to compute where the disk is being moved to

	AddPeg1: 												; add a disk to tower 1
		mov ecx, [StartArray+esi] 								;  runs through the array to check for the first #
		add esi, 4
		cmp ecx, 9 											; if there are currently no disks on the peg then the disk is added to the second last position
		je addTow1Cont 
		cmp ecx, 0 
		je AddPeg1
		addTow1Cont: 										; add a disk on top of the current top disk in that tower unless there are no disks
			sub esi, 8 
			mov [StartArray+esi], edx 							; uses the disk that was removed from another tower in the rmTow step
			mov edx, 0 										; clears out edx to prevent errors
			mov ecx, 0										; clears out ecx to prevent errors
			mov esi, 0										; clears out esi to prevent errors
			jmp ShowTowers 									; jumps down to ShowTowers the edited towers

	RemovePeg2:
		mov ecx, [EndArray+esi]
		add esi, 4
		cmp ecx, 0
		je RemovePeg2
		sub esi, 4
		mov edx, [EndArray+esi]
		mov [EndArray+esi], dword 0
		jmp CheckArray

	AddPeg2:
		mov ecx, [EndArray+esi]
		add esi, 4
		cmp ecx, 9
		je addTow2Cont
		cmp ecx, 0
		je AddPeg2
		addTow2Cont:
			sub esi, 8
			mov [EndArray+esi], edx
			mov edx, 0 										; clears out edx to prevent errors
			mov ecx, 0										; clears out ecx to prevent errors
			mov esi, 0										; clears out esi to prevent errors
			jmp ShowTowers 									; jumps down to ShowTowers the edited towers

	RemovePeg3:
		mov ecx, [TempArray+esi]
		add esi, 4
		cmp ecx, 0
		je RemovePeg3
		sub esi, 4
		mov edx, [TempArray+esi]
		mov [TempArray+esi], dword 0
		jmp CheckArray

	AddPeg3:
		mov ecx, [TempArray+esi]
		add esi, 4
		cmp ecx, 9
		je addTow3Cont
		cmp ecx, 0
		je AddPeg3
		addTow3Cont:
			sub esi, 8
			mov [TempArray+esi], edx
			mov edx, 0 										; clears out edx to prevent errors
			mov ecx, 0										; clears out ecx to prevent errors
			mov esi, 0										; clears out esi to prevent errors
			jmp ShowTowers 									; jumps down to ShowTowers the edited towers

ShowTowers: 													; ShowTowers all three towers after a disk was moved
	mov eax, Label										; eax == tower names
	call print_string										; print tower names
	call print_nl											; print extra line after tower name

	ShowTower1: 											; ShowTowers the first tower
		mov ebx, [StartArray+esi] 								; ebx == the disk at the current array index (StartArray array)
		cmp ebx, 9 											; compare ebx with 9 
		je ShowBaseRow											; if ebx == 9 then go to ShowBaseRow
		mov ecx, 9  										; ecx has 9 
		sub ecx, ebx 										; checks how many blacn spaces needed for each disk in every row on each side
		mov edx, 0 											; edx is 0

	call PrintImage												; call PrintImage function to PrintImage the pegs

	ShowTower2: 											; ShowTowers the second tower
		mov ebx, [EndArray+esi]	 								; ebx == the disk at the current array index (EndArray array)
		mov ecx, 9  										; ecx has 9 
		sub ecx, ebx 										; checks how many blacn spaces needed for each disk in every row on each side
		mov edx, 0 											; edx is 0

	call PrintImage												; call PrintImage function to PrintImage the pegs

	ShowTower3: 											; ShowTowers the third tower
		mov ebx, [TempArray+esi] 								; ebx == the disk at the current array index (TempArray array)
		mov ecx, 9  										; ecx has 9 
		sub ecx, ebx 										; checks how many blacn spaces needed for each disk in every row on each side
		mov edx, 0 											; edx is 0

	call PrintImage												; call PrintImage function to PrintImage the pegs
					
	add esi, 4 												; add 4 to esi to move to the next index in array
	cmp esi, 36 											; compare esi to 36 to see if it went through the whole array
	call print_nl											; print new line
	jne ShowTower1 										;  if esi not equal to 36 then go to ShowTower1

	ShowBaseRow: 												; prints the last line of the tower
		mov eax, FinalRow								; eax has "XXXXXXXXXXXXXXXXXXX"
		call print_string									; prints it to the screen
		call print_nl										; puts a blank line

	mov eax, [FinCount] 									; moves total move count into eax
	cmp eax, [totalCount] 									; compares with the total moves finished thus far
	jne Counter 											; jumps if program is not finished
	mov eax, finished 											; eax has the final output
	call print_string 										; prints final message
	call print_nl											; print extra line
	jmp Exit 												; jump to EndArray of the program

	Counter: 
		call read_char										; wait for enter to be pressed

	cmp [CheckHanoi], dword 1 							; checks to see if the original arrays was printed
	jne Hanoi 										; if they have not been printed, the program strats the recursion (hanoi algorithm)
	jmp HanoiCounter 											; if the original array have been printed, then the program will continue 

Hanoi: 
	mov [CheckHanoi], dword 1 							; used to make sure the program outputs the correct towers
	mov ebp, [EBP] 										; gets the TempArray ebp from the beginning
	push ebp 												; push to stack, save ebp
	mov esp, [ESP] 										; gets TempArray esp

	mov	ebp, esp 											; ebp has esp stored in it right now
	mov	eax, [ebp+12]                               	    ; save the first argument in eax
	add eax, 4                                      	    ; move the pointer to the main argument
	mov	edx, [eax]                                      	; move the pointer to the main argument
	push dword edx 											; save what ever is in edx
	call atoi 												; converts to integer
	add	esp, 4 												; keeps stack clean
	
	push dword 0x2											; below pushes set up the stack for HanoiAl
	push dword 0x1											; below pushes set up the stack for HanoiAl
	push dword 0x3											; below pushes set up the stack for HanoiAl
	push dword eax 											; save what ever is in edx
	call HanoiAl 									; calls the actually algorithm
	
	add	esp, 16 											; clean stack
	mov	esp, ebp
	pop	ebp
	ret

	HanoiAl: 										; actual recusion loop
		push ebp
		mov	ebp, esp
		mov	eax, [ebp+8]  
		cmp	eax, 0 
		jle	Exit
		dec	eax
		push dword [ebp+12]									; edits stack for first recursive call
		push dword [ebp+16]
		push dword [ebp+20]
		push dword eax
		call HanoiAl 								; recursion call

		add	esp, 16 										; cleans up
		push dword [ebp+16]									; when a disk is moved ArrayMoved is called to make the changes to the arrays
		push dword [ebp+12]
		call ArrayMoved 

		add	esp,8 
		mov	eax,[ebp+8]
		dec	eax
		push dword [ebp+16] 								; same as above but for second part
		push dword [ebp+20]
		push dword [ebp+12]
		push dword eax
		call HanoiAl 

		add	esp, 16 										; clean up
		jmp Exit 											; exits

	ArrayMoved: 												; computes which arrays need to be changed
		add [totalCount], dword 1 							; keeps track of how many moves have been made
		push ebp
		mov	ebp, esp

		mov esi, 0 											; insures esi is 0 for array writing
		cmp dword [ebp+12], 1 								; if a disk on tower 1 is being moved
		je RemovePeg1 											; jumps to proper set array section
		cmp dword [ebp+12], 2 								; same
		je RemovePeg3
		cmp dword [ebp+12], 3 
		je RemovePeg2

		CheckArray: 											; one a disk has been removed from a tower, it must be added to another tower
			mov esi, 0 										; insures esi is 0
			cmp dword [ebp+8], 1 							; if a disk is added to tower 1
			je AddPeg1
			cmp dword [ebp+8], 2 							; if a disk is added to tower 2
			je AddPeg3
			cmp dword [ebp+8], 3 							; if a disk is added to tower 3
			je AddPeg2

		HanoiCounter: 										; reference to jump to to continue the program after displaying a move
			add	esp, 0xc 
			mov	esp, ebp 									; cleans up everything to re run 
			pop	ebp
			ret

Exit:                                                   	; ends the program when it jumps to here
	mov	esp,ebp
	pop	ebp                       		                 	; return back to C                 
	ret

IncorrectArgument:
	mov eax, ErrorInc                                         	; put the string in eax
	push eax                                            	; reserve eax
	call print_string                                   	; output the string that is in eax
	call print_nl                                       	; print a new line after the output
	pop eax                                             	; put eax back to normal
	add esp, 4                                          	; takes 4 from stack
	jmp Exit                                            	; jump to Exit at the EndArray of the program

ArgumentoutofRange:
	mov eax, ErrorString                                       	; put the string in eax
	push eax                                            	; reserve eax
	call print_string                                   	; output the string that is in eax
	call print_nl                                       	; print a new line after the output
	pop eax                                             	; put eax back to normal
	add esp, 4                                          	; takes 4 from stack
	jmp Exit                                            	; jump to Exit at the EndArray of the program

ToomanyArguments:
	mov eax, ErrorArg                                        	; put the string in eax
	push eax                                            	; reserve eax
	call print_string                                   	; output the string that is in eax
	call print_nl                                       	; print a new line after the output
	pop eax                                             	; put eax back to normal
	add esp, 4                                          	; takes 4 from stack
	jmp Exit                                            	; jump to Exit at the EndArray of the program

PrintImage:
	enter   0,0                                             ; setup routine
	pusha

	DrawSpace1: 											; blank spaces part 1
		mov eax, ' '										; eax is equal to a blank space
		call print_char 									; print the char
		inc edx 											; add one to the counter
		cmp edx, 9 											; compares if edx with 9 for how many more blank spaces needed
		je DrawPeg 										; if edx == 9 then jump to DrawPeg
		cmp edx, ecx 										; compare edx with ecx
		jne DrawSpace1 									; if they are not equal then go to DrawSpace1

	DrawPluse1: 											; PrintImage the pluse part 2
		mov eax, '+' 										; put '+' symbol in eax
		call print_char										; print '+'
		inc edx 											; add one to edx
		cmp edx, 9 											; compare edx with 9 
		jne DrawPluse1 									; if they are not equl then jump back to the StartArray of the loop

	DrawPeg: 												; PrintImage the center line part 4
		mov eax, '|'										; send the line to register eax 
		call print_char										; output it to the screen		

	DrawPluse2: 											; PrintImage the pluse part 4
		cmp ebx, 0 											; compare ebx with 0
		je DrawSpace2 									; if ebx == 0 then DrawSpace2
		mov eax, '+'  										; put '+' symbol in eax 
		call print_char										; print '+'
		dec edx												; decrease edx
		cmp edx, ecx 										; compare edx with ecx
		jne DrawPluse2										; jump back to the StartArray of this loop if not equal

	DrawSpace2:  											; PrintImage the spaces part 5
		mov eax, ' ' 										; put ' ' symbol in eax
		call print_char										; print ' '
		dec edx												; decrease edx
		cmp edx, 0 											; compare edx with 0
		jne DrawSpace2									; jump back to the StartArray of this loop if not equal

	mov eax, Spaceing 										; print a blank line to split towers
	call print_string										; output to screen

	popa
	leave                     
	ret