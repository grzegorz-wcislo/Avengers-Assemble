ASSUME	cs:code1, ds:data1, es:data1


data1	segment
msg1	db	"Please enter an operation:",10,13,'$'
msg2	db	"Here is your answer:",10,13,'$'
msg3	db	"Input error!!!",10,13,'$'
newline1 db 10,13,'$'
plus	db	"plus",'$'
minus	db	"minus",'$'
times	db	"times",'$'
min1	db	"minus ",'$'
zero	db	"zero",'$'
one	db	"one",'$'
two	db	"two",'$'
three	db	"three",'$'
four	db	"four",'$'
five	db	"five",'$'
six	db	"six",'$'
seven	db	"seven",'$'
eight	db	"eight",'$'
nine	db	"nine",'$'
ten	db	"ten",'$'
eleven	db	"eleven",'$'
twelve	db	"twelve",'$'
thirteen	db	"thirteen",'$'
fourteen	db	"fourteen",'$'
fifteen	db	"fifteen",'$'
sixteen	db	"sixteen",'$'
seventeen	db	"seventeen",'$'
eighteen	db	"eighteen",'$'
nineteen	db	"nineteen",'$'
twenty	db	"twenty ",'$'
thirty	db	"thirty ",'$'
forty	db	"forty ",'$'
fifty	db	"fifty ",'$'
sixty	db	"sixty ",'$'
seventy	db	"seventy ",'$'
eighty	db	"eighty ",'$'
ninety	db	"ninety ",'$'
stdio	db	128
	db ?
	db 128 dup(?)
clean db 128 dup('$')
data1	ends

code1	segment
start1:
	nop
	;; ustawienie stosu
	mov	ax,seg st1
	mov	ss,ax
	mov sp,offset st1

	call	welcome1
	call	readandprint1
	call	end1

welcome1:
	mov	dx,offset msg1
	call printdx
	ret

readandprint1:
	mov ax,seg data1
	mov ds,ax
	mov dx,offset stdio
	mov ah,0ah
	int 21h

	mov dx,offset newline1
	call printdx

	call cleaninput1

	mov bp,sp					;zrób stack frame
	push bp

	mov dx,offset clean
	inc dx						;zignoruj pierwszy dolar
	call matchnum1
	call matchop1
	call matchnum1
	call	perform1
	pop ax						;weź wynik
	add sp,6					;usuń przekazane zmienne
	pop bp						;przywróć stary stackframe
	call	result1

	ret

cleaninput1:
	mov ax,seg data1			; ustawienie wskażników na pierwsze znaki stringów
	mov di,offset stdio + 2
	mov si,offset clean
	mov ds,ax

	xor cx,cx
	mov cl,byte ptr ds:[di-1]	;liczba wczytanych znaków, bug przy 0

loop1:
	xor ax,ax
	mov al,byte ptr ds:[di]		;wczytaj następny znak
	cmp ax,'a'
	jge lowercase1				;jeżeli litera jest już mała to nie zmieniaj wielkości

	add ax,32						;zmień literę na wielką

lowercase1:
	cmp ax,'a'
	jl whitespace1
	cmp ax,'z'
	jg whitespace1

letter1:
	inc si
	mov byte ptr ds:[si],al
	jmp nextloop1

whitespace1:
	cmp byte ptr ds:[si],'$'
	je nextloop1				;wcześniejszy znak też był whitespacem

	inc si
	mov byte ptr ds:[si],'$'

nextloop1:
	inc di						;następny znak
	loop loop1
	ret

matchnum1:
	mov ax,seg data1
	mov ds,ax
	mov es,ax
	cld							;ustaw kierunek porównywania

	mov si,dx
	mov di,offset zero
	mov cx,5
	mov ax,0
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset one
	mov cx,4
	mov ax,1
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset two
	mov cx,4
	mov ax,2
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset three
	mov cx,6
	mov ax,3
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset four
	mov cx,5
	mov ax,4
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset five
	mov cx,5
	mov ax,5
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset six
	mov cx,4
	mov ax,6
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset seven
	mov cx,6
	mov ax,7
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset eight
	mov cx,6
	mov ax,8
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset nine
	mov cx,5
	mov ax,9
	repe	cmpsb
	je matched1

	mov si,dx
	mov dx,offset msg3			;żadna cyfra nie pasuje
	call printdx
	call end1
	ret

matchop1:
	;; 1 - add
	;; 2 - subtract
	;; 3 - multiply
	mov ax,seg data1
	mov ds,ax
	mov es,ax
	cld							;ustaw kierunek porównywania

	mov si,dx
	mov di,offset plus
	mov cx,5
	mov ax,1
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset minus
	mov cx,6
	mov ax,2
	repe	cmpsb
	je matched1

	mov si,dx
	mov di,offset times
	mov cx,6
	mov ax,3
	repe	cmpsb
	je matched1

	mov si,dx
	mov dx,offset msg3			;żaden operator nie pasuje
	call printdx
	call end1
	ret

matched1:
	;; odczytany znak jest w ax
	mov dx,si					;wczytaj do dx początek następnej sekwencji
	pop bx						;wartość przekazana przez stos
	push ax
	push bx
	ret

perform1:
	mov ax,[bp-6]				;weź ze stosu kod operacji do wykonania

	cmp ax,1
	je add1

	cmp ax,2
	je subtract1

	cmp ax,3
	je multiply1

	call err1
	call end1

add1:
	mov ax,[bp-4]				;pierwsza liczba
	add ax,[bp-8]				;druga liczba
	jmp performend1

subtract1:
	mov	ax,[bp-4]
	sub	ax,[bp-8]
	jmp performend1

multiply1:
	xor dx,dx					;wyczyść dx dla pewności
	mov ax,[bp-4]
	mov bx,[bp-8]
	mul bl						;TODO: sprawdzić
	jmp performend1

performend1:
	pop dx
	push ax						;wstaw wynik operacji
	push dx
	ret

result1:
	push ax
	mov dx,offset msg2
	call printdx
	pop ax

	bt ax,15					;przenieś ostatni bit do flagi przeniesieni
	jnc skipminus1				;jeżeli liczba jest ujemna to wypisz minus
	je zero1

	push ax					 ; int 21h używa ax, więc robię backup
	mov dx,offset min1			;wypisz minus i zmień liczbę na dodatnią
	call printdx
	pop ax
	neg ax

skipminus1:
	mov bx,10					;podziel ax przez 10 (rozbicie na cyfry)
	xor dx,dx					;dzielenie wymaga wyzerowanego dx
	div bx					;cyfra jedności w dx, dziesiątek w ax
	push dx						;zapisuję cyfrę jedności na stosie

digit1:
	cmp al,0
	je digit2

	cmp al,1
	je teens1

	mov dx, offset twenty
	cmp al,2
	je printdigit1

	mov dx, offset thirty
	cmp al,3
	je printdigit1

	mov dx, offset forty
	cmp al,4
	je printdigit1

	mov dx, offset fifty
	cmp al,5
	je printdigit1

	mov dx, offset sixty
	cmp al,6
	je printdigit1

	mov dx, offset seventy
	cmp al,7
	je printdigit1

	mov dx, offset eighty
	cmp al,8
	je printdigit1

	mov dx, offset ninety
	cmp al,9
	je printdigit1

printdigit1:
	call printdx
	jmp digit2

teens1:
	pop ax						;weź cyfrę jedności ze stosu

	mov dx, offset ten
	cmp al,0
	je printdigit2

	mov dx, offset eleven
	cmp al,1
	je printdigit2

	mov dx, offset twelve
	cmp al,2
	je printdigit2

	mov dx, offset thirteen
	cmp al,3
	je printdigit2

	mov dx, offset fourteen
	cmp al,4
	je printdigit2

	mov dx, offset fifteen
	cmp al,5
	je printdigit2

	mov dx, offset sixteen
	cmp al,6
	je printdigit2

	mov dx, offset seventeen
	cmp al,7
	je printdigit2

	mov dx, offset eighteen
	cmp al,8
	je printdigit2

	mov dx, offset nineteen
	cmp al,9
	je printdigit2

digit2:
	pop ax						;weź cyfrę jedności ze stosu
	mov dx, offset zero
	cmp al,0
	je endprint1				;nie wypisuj zera jako drugiej cyfry, to niegramatyczne

	mov dx, offset one
	cmp al,1
	je printdigit2

	mov dx, offset two
	cmp al,2
	je printdigit2

	mov dx, offset three
	cmp al,3
	je printdigit2

	mov dx, offset four
	cmp al,4
	je printdigit2

	mov dx, offset five
	cmp al,5
	je printdigit2

	mov dx, offset six
	cmp al,6
	je printdigit2

	mov dx, offset seven
	cmp al,7
	je printdigit2

	mov dx, offset eight
	cmp al,8
	je printdigit2

	mov dx, offset nine
	cmp al,9
	je printdigit2

printdigit2:
	call printdx
	ret

zero1:
	mov dx, offset zero
	call printdx
	ret

endprint1:
	ret

err1:
	mov	dx,offset msg3
	call printdx
	ret

printdx:						;wypisz stringa adresowanego przez ds[dx]
	mov ax,seg data1
	mov ds,ax
	mov ah,9h
	int 21h
	ret

end1:
	mov ax,4c00h				;ustaw kod zakończenia programu
	int 21h

code1 ends

stack1	segment stack
	dw	1000 dup(?)
st1	dw	?
stack1	ends

end	start1
