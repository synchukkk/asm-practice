; hw6.asm - Функція сортування масиву
; Компіляція: nasm -f bin hw6.asm -o hw6.com
; Запуск: hw6.com (в DOSBox або подібному емуляторі)

org 100h

section .text
start:
    ; Приклад використання: сортування масиву з 2-байтних чисел
    mov si, source_array
    mov di, sorted_array
    mov cx, 10              ; 10 елементів
    mov bx, 2               ; Розмір елемента 2 байти
    
    ; Друкуємо оригінальний масив
    call print_original
    
    ; Викликаємо функцію сортування
    call sort_array
    
    ; Друкуємо відсортований масив
    call print_sorted
    
    ; Завершення програми
    mov ah, 4Ch
    int 21h

; Функція сортування масиву (Bubble Sort)
; Вхід: 
;   SI - адреса вхідного масиву
;   DI - адреса вихідного масиву
;   CX - кількість елементів
;   BX - розмір одного елемента (1, 2, 4, 8 байтів)
; Вихід: відсортований масив за адресою DI
sort_array:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    
    ; Зберігаємо параметри
    mov [elem_count], cx
    mov [elem_size], bx
    
    ; Обчислюємо загальний розмір масиву
    mov ax, cx
    mul bx
    mov [total_size], ax
    
    ; Копіюємо вхідний масив в вихідний
    push si
    push di
    push cx
    mov cx, [total_size]
    rep movsb
    pop cx
    pop di
    pop si
    
    ; Bubble Sort
    mov cx, [elem_count]
    dec cx                  ; Зовнішній цикл: n-1 проходів
    cmp cx, 0
    je .done
    
.outer_loop:
    push cx
    mov dx, 0               ; Прапорець обміну
    mov cx, [elem_count]
    dec cx                  ; Внутрішній цикл
    mov bp, 0               ; Індекс поточного елемента
    
.inner_loop:
    push cx
    
    ; Порівнюємо елементи [bp] та [bp+1]
    mov si, di
    mov ax, bp
    mul word [elem_size]
    add si, ax              ; SI вказує на елемент [bp]
    
    mov bx, si
    add bx, [elem_size]     ; BX вказує на елемент [bp+1]
    
    ; Порівнюємо елементи
    call compare_elements
    
    ; Якщо перший > другий, міняємо місцями
    cmp al, 1
    jne .no_swap
    
    ; Міняємо місцями
    call swap_elements
    mov dx, 1               ; Встановлюємо прапорець обміну
    
.no_swap:
    inc bp
    pop cx
    loop .inner_loop
    
    pop cx
    
    ; Якщо не було обмінів, масив відсортовано
    cmp dx, 0
    je .done
    
    loop .outer_loop
    
.done:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Порівняння двох елементів
; Вхід: SI - адреса першого елемента, BX - адреса другого
; Вихід: AL = 1 якщо SI > BX, інакше 0
compare_elements:
    push cx
    push si
    push di
    push bx
    
    mov di, bx
    mov cx, [elem_size]
    
    ; Порівнюємо побайтно з кінця (для big-endian порівняння)
    add si, cx
    add di, cx
    dec si
    dec di
    
.compare_loop:
    mov al, [si]
    mov ah, [di]
    cmp al, ah
    ja .greater
    jb .less
    
    dec si
    dec di
    loop .compare_loop
    
    ; Рівні
    mov al, 0
    jmp .compare_done
    
.greater:
    mov al, 1
    jmp .compare_done
    
.less:
    mov al, 0
    
.compare_done:
    pop bx
    pop di
    pop si
    pop cx
    ret

; Обмін двох елементів
; Вхід: SI - адреса першого елемента, BX - адреса другого
swap_elements:
    push ax
    push cx
    push si
    push di
    
    mov di, bx
    mov cx, [elem_size]
    
.swap_loop:
    mov al, [si]
    mov ah, [di]
    mov [si], ah
    mov [di], al
    inc si
    inc di
    loop .swap_loop
    
    pop di
    pop si
    pop cx
    pop ax
    ret

; Друк оригінального масиву
print_original:
    push ax
    push cx
    push dx
    push si
    
    mov ah, 09h
    mov dx, msg_original
    int 21h
    
    mov si, source_array
    mov cx, 10
    
.print_loop:
    mov ax, [si]
    call print_number
    
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    add si, 2
    loop .print_loop
    
    mov ah, 09h
    mov dx, newline
    int 21h
    
    pop si
    pop dx
    pop cx
    pop ax
    ret

; Друк відсортованого масиву
print_sorted:
    push ax
    push cx
    push dx
    push si
    
    mov ah, 09h
    mov dx, msg_sorted
    int 21h
    
    mov si, sorted_array
    mov cx, 10
    
.print_loop:
    mov ax, [si]
    call print_number
    
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    add si, 2
    loop .print_loop
    
    mov ah, 09h
    mov dx, newline
    int 21h
    
    pop si
    pop dx
    pop cx
    pop ax
    ret

; Друк числа з AX
print_number:
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0
    mov bx, 10
    
    ; Спеціальний випадок для 0
    cmp ax, 0
    jne .divide
    push ax
    inc cx
    jmp .print
    
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide
    
.print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop .print
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

section .data
    ; Тестові дані: масив з 10 елементів по 2 байти
    source_array dw 64, 34, 25, 12, 22, 11, 90, 88, 45, 50
    
    msg_original db 'Oryginal: $'
    msg_sorted db 'Sorted:   $'
    newline db 13, 10, '$'
    
    elem_count dw 0
    elem_size dw 0
    total_size dw 0

section .bss
    sorted_array resw 10
