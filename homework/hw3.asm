.model small
.stack 100h
.data
    num dw ?
    msg_prime db ' e prostym', 0Dh, 0Ah, '$'  ; "є простим"
    msg_not_prime db ' ne e prostym', 0Dh, 0Ah, '$'  ; "не є простим"
    buffer db 6 dup(?)  ; Буфер для рядка числа (максимум 5 цифр + знак або щось)

.code
main proc
    ; Припустимо, що число вже в AX на вході
    mov num, ax  ; Зберегти число

    ; Вивести число
    call print_number

    ; Перевірити, чи просте
    call is_prime
    cmp ax, 1
    je print_prime
    mov dx, offset msg_not_prime
    jmp print_msg

print_prime:
    mov dx, offset msg_prime

print_msg:
    mov ah, 09h
    int 21h

    ; Завершити програму
    mov ah, 4Ch
    int 21h
main endp

; Процедура для виведення числа з num
print_number proc
    mov ax, num
    mov bx, 10
    mov cx, 0  ; Лічильник цифр
    mov di, offset buffer + 5  ; Почати з кінця буфера
    mov byte ptr [di], '$'  ; Кінець рядка
    dec di

convert_loop:
    mov dx, 0
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    inc cx
    cmp ax, 0
    jne convert_loop

    ; Вивести рядок
    inc di
    mov dx, di
    mov ah, 09h
    int 21h
    ret
print_number endp

; Процедура перевірки простоти, вхід: num, вихід: AX=1 якщо просте, 0 інакше
is_prime proc
    mov ax, num
    cmp ax, 1
    jle not_prime

    mov cx, 2
check_loop:
    cmp cx, ax
    jge its_prime
    mov dx, 0
    mov bx, ax  ; Зберегти ax тимчасово
    mov ax, num
    div cx
    mov ax, bx  ; Відновити
    cmp dx, 0
    je not_prime
    inc cx

    ; Оптимізація: перевіряти тільки до sqrt(num)
    mov bx, cx
    imul bx, cx
    cmp bx, num
    jg its_prime

    jmp check_loop

its_prime:
    mov ax, 1
    ret

not_prime:
    mov ax, 0
    ret
is_prime endp

end main
