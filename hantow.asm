;; Course: 2XA3 
;; Name: Navleen Singh
;; Student Number: 1302228
;; File: hantow.asm
;; Description: This is my final project for 2XA3. It takes in input from user between 2-8 and then it preformes step by step hanoi answer

%include "asm_io.inc"

segment .data                                               ; where all the predefined variables are stored

	aofr: db "Argument out of Range", 0                     ; define aofr as a String "Argument out of Range"
	ia: db "Incorrect Argument", 0                          ; define ia as a String "Incorrect Argument"
	tma: db "Too many Arguments", 0                         ; define tma as a String "Too many Arguments"
	done: db "Done", 0										; deifne done as a String "Done"
	hantowNumber dd 0                                       ; define hantowNumber this is what the size of the tower will be stored in

	start: dd 0,0,0,0,0,0,0,0,9								; this array is where all the rings start at
	end: dd 0,0,0,0,0,0,0,0,9								; this array is where all the rings end up at
	temp: dd 0,0,0,0,0,0,0,0,9								; this array is used to help move the rings

															; The next couple lines define the strings to show the pegs and what they look like
	
	towerName: db "      Tower 1                 Tower 2                 Tower 3      ", 10, 0
	lastLineRow: db "XXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXX     XXXXXXXXXXXXXXXXXXX        ", 10, 0
	buffer: db "     ", 0

segment .bss                                                ; where all the non defined variables are stored
	tempEBP resd 1 											; this is a variable to hold ebp in the start
	tempESP resd 1 											; this is a variable to hold esp in the start
	checkOrgTower resd 1 									; this is a varibale used to check if orginal tower should be printed or modified one
	finishCount resd 1 										; this is a variable to count the number of moves needed to finish
	totalCount resd 1 										; this is a variable to count the number of moves preformed so far

segment .text
	global  asm_main                                        ; run the main function
	extern printf
	extern atoi

asm_main:
	push ebp 												; stores the value on stack
	mov [tempEBP], ebp 										; saves ebp to a temp variable

	mov ebp, esp 											; moves stack pointer to ebp
	push ebp 												; stores the value on stack
	mov [tempESP], ebp										; saves ebp to a temp variable which is esp
	pop ebp 												; restores it

	mov edx, dword 0                                        ; set edx to zero this is where the hantowNumber is saved for now
	mov ecx, dword[ebp+8]                                   ; ecx has how many arguments are given
	mov eax, dword[ebp+12]                                  ; save the first argument in eax
	add eax, 4                                              ; move the pointer to the main argument
	mov ebx, dword[eax]                                     ; save the number into ebx
	
	push ebx                                                ; reserve ebx
	push ecx                                                ; reserve ecx

	cmp ecx, dword 2                                        ; compare if there are more the one argument given
	jg TmA                                                  ; if more then one argument is given then jump Too many Argument (TmA)

	mov ecx, 0                                              ; ecx = 0
	movzx eax, byte[ebx+ecx]                                ; eax is the first character number from the inputed number
	sub eax, 48                                             ; subtract 48 to get the actual number/letter/symbol
	cmp eax, 10                                             ; check if eax is less then 10
	jg IA                                                   ; if eax is greater then 10 then it is a letter or symbol

	string_To_int:                                          ; change String to int procedure
		add edx, eax                                        ; put the number in edx
		inc ecx                                             ; increase counter (ecx)
		movzx eax, byte[ebx+ecx]                            ; move the next number in eax
		cmp eax, 0                                          ; if eax = 0 then there are no more numbers
		mov [hantowNumber], edx                             ; change hantowNumber to what ever is in edx
		je rangeCheck                                       ; go to rangeCheck to check if between 2-8
		sub eax, 48                                         ; subtract 48 to get the actual number/letter/symbol 
		cmp eax, 10                                         ; check if eax is less then 10
		jg IA                                               ; if eax is greater then 10 then it is a letter or symbol
		imul edx, 10                                        ; multiply edx by 10 so the next number can be added to the end
		jmp string_To_int                                   ; jump back to string_To_int if not done 

	rangeCheck:                                             ; check the range of the number
		cmp edx, dword 2                                    ; compare edx with 2
		jl AofR                                             ; if hantowNumber (edx) < 2 then go to Argument out of Range (AofR)
	
		cmp edx, dword 8                                    ; compare edx with 8
		jg AofR                                             ; if hantowNumber (edx) > 8 then go to Argument out of Range (AofR)

	mov ecx, [hantowNumber]									; move the number enterd by user in ecx
	mov esi, 28 											; esi == 28 for stack pointer counter
	mov ebx, 1
	mov eax, 0

	totalMoves:												; check how many moves it should take
		imul ebx, 2 										; ebx * 2
		inc eax 											; increase eax
		cmp eax, ecx										; compare eax with ecx
		jne totalMoves										; if eax != ecx then go to start of this loop
		dec ebx												; subtract one from ebx
		mov [finishCount], ebx								; save ebx into a variable

	setStart:												; set the first array the starting peg
		mov [start+esi], ecx								; put ecx into the array
		sub esi, 4 											; take one away from stack pointer conter
		dec ecx												; take one away from ecx so the next number can go in to the array
		cmp ecx, 0											; compare ecx with 0
		jne setStart										; if ecx != 0 then go to setStart loop
		mov esi, 0
		mov ecx, 0
		jmp display

setTowers: 
	rmTow1: 												; removes the top disk from tower 1
		mov ecx, [start+esi] 								; moves through each position of the array
		add esi, 4
		cmp ecx, 0 											; checks if 0, if so moves to next position
		je rmTow1
		sub esi, 4 											; if the index has a value the position is moved back one
		mov edx, [start+esi] 								; stores the value of the disk being removed
		mov [start+esi], dword 0 							; removes the disk by replacing with a 0 in teh array
		jmp checkHantow 									; jumps down to the add section to compute where the disk is being moved to

	addTow1: 												; add a disk to tower 1
		mov ecx, [start+esi] 								;  runs through the array to check for the first #
		add esi, 4
		cmp ecx, 9 											; if there are currently no disks on the peg then the disk is added to the second last position
		je addTow1Count 
		cmp ecx, 0 
		je addTow1
		addTow1Count: 										; add a disk on top of the current top disk in that tower unless there are no disks
			sub esi, 8 
			mov [start+esi], edx 							; uses the disk that was removed from another tower in the rmTow step
			mov edx, 0 										; clears out edx to prevent errors
			mov ecx, 0										; clears out ecx to prevent errors
			mov esi, 0										; clears out esi to prevent errors
			jmp display 									; jumps down to display the edited towers

	rmTow2:
		mov ecx, [end+esi]
		add esi, 4
		cmp ecx, 0
		je rmTow2
		sub esi, 4
		mov edx, [end+esi]
		mov [end+esi], dword 0
		jmp checkHantow

	addTow2:
		mov ecx, [end+esi]
		add esi, 4
		cmp ecx, 9
		je addTow2Count
		cmp ecx, 0
		je addTow2
		addTow2Count:
			sub esi, 8
			mov [end+esi], edx
			mov edx, 0 										; clears out edx to prevent errors
			mov ecx, 0										; clears out ecx to prevent errors
			mov esi, 0										; clears out esi to prevent errors
			jmp display 									; jumps down to display the edited towers

	rmTow3:
		mov ecx, [temp+esi]
		add esi, 4
		cmp ecx, 0
		je rmTow3
		sub esi, 4
		mov edx, [temp+esi]
		mov [temp+esi], dword 0
		jmp checkHantow

	addTow3:
		mov ecx, [temp+esi]
		add esi, 4
		cmp ecx, 9
		je addTow3Count
		cmp ecx, 0
		je addTow3
		addTow3Count:
			sub esi, 8
			mov [temp+esi], edx
			mov edx, 0 										; clears out edx to prevent errors
			mov ecx, 0										; clears out ecx to prevent errors
			mov esi, 0										; clears out esi to prevent errors
			jmp display 									; jumps down to display the edited towers

display: 													; display all three towers after a disk was moved
	mov eax, towerName										; eax == tower names
	call print_string										; print tower names
	call print_nl											; print extra line after tower name

	displayTower1: 											; display the first tower
		mov ebx, [start+esi] 								; ebx == the disk at the current array index (start array)
		cmp ebx, 9 											; compare ebx with 9 
		je lastLine											; if ebx == 9 then go to lastLine
		mov ecx, 9  										; ecx has 9 
		sub ecx, ebx 										; checks how many blacn spaces needed for each disk in every row on each side
		mov edx, 0 											; edx is 0

	call draw												; call draw function to draw the pegs

	displayTower2: 											; display the second tower
		mov ebx, [end+esi]	 								; ebx == the disk at the current array index (end array)
		mov ecx, 9  										; ecx has 9 
		sub ecx, ebx 										; checks how many blacn spaces needed for each disk in every row on each side
		mov edx, 0 											; edx is 0

	call draw												; call draw function to draw the pegs

	displayTower3: 											; display the third tower
		mov ebx, [temp+esi] 								; ebx == the disk at the current array index (temp array)
		mov ecx, 9  										; ecx has 9 
		sub ecx, ebx 										; checks how many blacn spaces needed for each disk in every row on each side
		mov edx, 0 											; edx is 0

	call draw												; call draw function to draw the pegs
					
	add esi, 4 												; add 4 to esi to move to the next index in array
	cmp esi, 36 											; compare esi to 36 to see if it went through the whole array
	call print_nl											; print new line
	jne displayTower1 										;  if esi not equal to 36 then go to displayTower1

	lastLine: 												; prints the last line of the tower
		mov eax, lastLineRow								; eax has "XXXXXXXXXXXXXXXXXXX"
		call print_string									; prints it to the screen
		call print_nl										; puts a blank line

	mov eax, [finishCount] 									; moves total move count into eax
	cmp eax, [totalCount] 									; compares with the total moves done thus far
	jne runCount 											; jumps if program is not done
	mov eax, done 											; eax has the final output
	call print_string 										; prints final message
	call print_nl											; print extra line
	jmp Exit 												; jump to end of the program

	runCount: 
		call read_char										; wait for enter to be pressed

	cmp [checkOrgTower], dword 1 							; checks to see if the original arrays was printed
	jne towersOfHanoi 										; if they have not been printed, the program strats the recursion (hanoi algorithm)
	jmp hantowCounter 										; if the original array have been printed, then the program will continue 

towersOfHanoi: 
	mov [checkOrgTower], dword 1 							; used to make sure the program outputs the correct towers
	mov ebp, [tempEBP] 										; gets the temp ebp from the beginning
	push ebp 												; push to stack, save ebp
	mov esp, [tempESP] 										; gets temp esp

	mov	ebp, esp 											; ebp has esp stored in it right now
	mov	eax, [ebp+12]                               	    ; save the first argument in eax
	add eax, 4                                      	    ; move the pointer to the main argument
	mov	edx, [eax]                                      	; move the pointer to the main argument
	push dword edx 											; save what ever is in edx
	call atoi 												; converts to integer
	add	esp, 4 												; keeps stack clean
	
	push dword 0x2											; below pushes set up the stack for towerAlgorithm
	push dword 0x1											; below pushes set up the stack for towerAlgorithm
	push dword 0x3											; below pushes set up the stack for towerAlgorithm
	push dword eax 											; save what ever is in edx
	call towerAlgorithm 									; calls the actually algorithm
	
	add	esp, 16 											; clean stack
	mov	esp, ebp
	pop	ebp
	ret

	towerAlgorithm: 										; actual recusion loop
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
		call towerAlgorithm 								; recursion call

		add	esp, 16 										; cleans up
		push dword [ebp+16]									; when a disk is moved diskMoved is called to make the changes to the arrays
		push dword [ebp+12]
		call diskMoved 

		add	esp,8 
		mov	eax,[ebp+8]
		dec	eax
		push dword [ebp+16] 								; same as above but for second part
		push dword [ebp+20]
		push dword [ebp+12]
		push dword eax
		call towerAlgorithm 

		add	esp, 16 										; clean up
		jmp Exit 											; exits

	diskMoved: 												; computes which arrays need to be changed
		add [totalCount], dword 1 							; keeps track of how many moves have been made
		push ebp
		mov	ebp, esp

		mov esi, 0 											; insures esi is 0 for array writing
		cmp dword [ebp+12], 1 								; if a disk on tower 1 is being moved
		je rmTow1 											; jumps to proper set array section
		cmp dword [ebp+12], 2 								; same
		je rmTow3
		cmp dword [ebp+12], 3 
		je rmTow2

		checkHantow: 										; one a disk has been removed from a tower, it must be added to another tower
			mov esi, 0 										; insures esi is 0
			cmp dword [ebp+8], 1 							; if a disk is added to tower 1
			je addTow1
			cmp dword [ebp+8], 2 							; if a disk is added to tower 2
			je addTow3
			cmp dword [ebp+8], 3 							; if a disk is added to tower 3
			je addTow2

		hantowCounter: 										; reference to jump to to continue the program after displaying a move
			add	esp, 0xc 
			mov	esp, ebp 									; cleans up everything to re run 
			pop	ebp
			ret

Exit:                                                   	; ends the program when it jumps to here
	mov	esp,ebp
	pop	ebp                       		                 	; return back to C                 
	ret

IA:
	mov eax, ia                                         	; put the string in eax
	push eax                                            	; reserve eax
	call print_string                                   	; output the string that is in eax
	call print_nl                                       	; print a new line after the output
	pop eax                                             	; put eax back to normal
	add esp, 4                                          	; takes 4 from stack
	jmp Exit                                            	; jump to Exit at the end of the program

AofR:
	mov eax, aofr                                       	; put the string in eax
	push eax                                            	; reserve eax
	call print_string                                   	; output the string that is in eax
	call print_nl                                       	; print a new line after the output
	pop eax                                             	; put eax back to normal
	add esp, 4                                          	; takes 4 from stack
	jmp Exit                                            	; jump to Exit at the end of the program

TmA:
	mov eax, tma                                        	; put the string in eax
	push eax                                            	; reserve eax
	call print_string                                   	; output the string that is in eax
	call print_nl                                       	; print a new line after the output
	pop eax                                             	; put eax back to normal
	add esp, 4                                          	; takes 4 from stack
	jmp Exit                                            	; jump to Exit at the end of the program

draw:
	enter   0,0                                             ; setup routine
	pusha

	towerSpaces1: 											; blank spaces part 1
		mov eax, ' '										; eax is equal to a blank space
		call print_char 									; print the char
		inc edx 											; add one to the counter
		cmp edx, 9 											; compares if edx with 9 for how many more blank spaces needed
		je towerPeg 										; if edx == 9 then jump to towerPeg
		cmp edx, ecx 										; compare edx with ecx
		jne towerSpaces1 									; if they are not equal then go to towerSpaces1

	towerPluse1: 											; draw the pluse part 2
		mov eax, '+' 										; put '+' symbol in eax
		call print_char										; print '+'
		inc edx 											; add one to edx
		cmp edx, 9 											; compare edx with 9 
		jne towerPluse1 									; if they are not equl then jump back to the start of the loop

	towerPeg: 												; draw the center line part 4
		mov eax, '|'										; send the line to register eax 
		call print_char										; output it to the screen		

	towerPluse2: 											; draw the pluse part 4
		cmp ebx, 0 											; compare ebx with 0
		je towerSpaces2 									; if ebx == 0 then towerSpaces2
		mov eax, '+'  										; put '+' symbol in eax 
		call print_char										; print '+'
		dec edx												; decrease edx
		cmp edx, ecx 										; compare edx with ecx
		jne towerPluse2										; jump back to the start of this loop if not equal

	towerSpaces2:  											; draw the spaces part 5
		mov eax, ' ' 										; put ' ' symbol in eax
		call print_char										; print ' '
		dec edx												; decrease edx
		cmp edx, 0 											; compare edx with 0
		jne towerSpaces2									; jump back to the start of this loop if not equal

	mov eax, buffer 										; print a blank line to split towers
	call print_string										; output to screen

	popa
	leave                     
	ret