; hw41.asm - Ітеративна версія обчислення факторіалу
; Компіляція: nasm -f bin hw41.asm -o hw41.com
; Запуск: hw41.com (в DOSBox або подібному емуляторі)

org 100h

section .text
start:
    ; Встановлюємо вхідне число (наприклад, 7)
    mov ax, 7
    
    ; Друкуємо вхідне число
    call print_input
    
    ; Обчислюємо факторіал
    call factorial_iterative
    
    ; Друкуємо результат
    call print_result
    
    ; Завершення програми
    mov ah, 4Ch
    int 21h

; Функція обчислення факторіалу (ітеративна)
; Вхід: AX - число
; Вихід: DX:AX - факторіал
factorial_iterative:
    push bx
    push cx
    
    ; Зберігаємо вхідне число в CX
    mov cx, ax
    
    ; Ініціалізація результату (DX:AX = 1)
    mov dx, 0
    mov ax, 1
    
    ; Перевірка на 0! = 1
    cmp cx, 0
    je .done
    
    ; Перевірка на 1! = 1
    cmp cx, 1
    je .done
    
.loop:
    ; Множимо DX:AX на CX
    push dx
    push ax
    
    ; Множимо AX на CX
    mul cx          ; DX:AX = AX * CX
    
    ; Зберігаємо результат
    mov bx, ax      ; Молодша частина
    mov ax, dx      ; Старша частина з попереднього множення
    
    pop ax          ; Відновлюємо попередній AX
    pop dx          ; Відновлюємо попередній DX
    
    ; Правильне 32-бітне множення
    push cx
    push dx
    
    ; AX * CX
    mul cx          ; DX:AX = AX * CX
    mov bx, ax      ; Зберігаємо молодшу частину
    mov si, dx      ; Зберігаємо старшу частину
    
    pop dx          ; Відновлюємо старшу частину попереднього результату
    pop cx
    
    ; DX * CX (тільки молодша частина, бо результат іде в старшу частину)
    mov ax, dx
    mul cx
    add si, ax      ; Додаємо до старшої частини
    
    ; Формуємо фінальний результат
    mov ax, bx
    mov dx, si
    
    loop .loop
    
.done:
    pop cx
    pop bx
    ret

; Друк вхідного числа
print_input:
    push ax
    push dx
    
    ; Друкуємо повідомлення
    mov ah, 09h
    mov dx, msg_input
    int 21h
    
    pop dx
    
    ; Друкуємо число
    call print_number
    
    ; Новий рядок
    mov ah, 09h
    mov dx, newline
    int 21h
    
    pop ax
    ret

; Друк результату
print_result:
    push ax
    push dx
    
    ; Друкуємо повідомлення
    push dx
    push ax
    mov ah, 09h
    mov dx, msg_result
    int 21h
    pop ax
    pop dx
    
    ; Друкуємо DX:AX як 32-бітне число
    call print_dword
    
    ; Новий рядок
    mov ah, 09h
    mov dx, newline
    int 21h
    
    pop dx
    pop ax
    ret

; Друк 16-бітного числа з AX
print_number:
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0
    mov bx, 10
    
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

; Друк 32-бітного числа з DX:AX
print_dword:
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov cx, 0
    mov bx, 10
    
.divide:
    ; Ділимо DX:AX на 10
    push ax
    mov ax, dx
    xor dx, dx
    div bx          ; Ділимо старшу частину
    mov si, ax      ; Зберігаємо результат старшої частини
    pop ax
    div bx          ; Ділимо молодшу частину
    
    push dx         ; Зберігаємо залишок (цифру)
    inc cx
    
    mov dx, si      ; Переносимо результат в DX:AX
    
    ; Перевіряємо, чи результат = 0
    or ax, dx
    jnz .divide
    
.print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop .print
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

section .data
    msg_input db 'Vkhidne chyslo: $'
    msg_result db 'Faktorial: $'
    newline db 13, 10, '$'
