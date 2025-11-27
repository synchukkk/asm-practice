; hw42.asm - Рекурсивна версія обчислення факторіалу
; Компіляція: nasm -f bin hw42.asm -o hw42.com
; Запуск: hw42.com (в DOSBox або подібному емуляторі)

org 100h

section .text
start:
    ; Встановлюємо вхідне число (наприклад, 7)
    mov ax, 7
    
    ; Друкуємо вхідне число
    call print_input
    
    ; Обчислюємо факторіал
    call factorial_recursive
    
    ; Друкуємо результат
    call print_result
    
    ; Завершення програми
    mov ah, 4Ch
    int 21h

; Функція обчислення факторіалу (рекурсивна)
; Вхід: AX - число
; Вихід: DX:AX - факторіал
factorial_recursive:
    push bx
    push cx
    push si
    
    ; Базовий випадок: якщо n <= 1, повертаємо 1
    cmp ax, 1
    jbe .base_case
    
    ; Зберігаємо поточне значення n
    mov cx, ax
    
    ; Рекурсивний виклик: factorial(n-1)
    dec ax
    call factorial_recursive
    
    ; Тепер DX:AX містить factorial(n-1)
    ; Потрібно помножити на n (що зберігається в CX)
    
    ; Зберігаємо результат factorial(n-1)
    mov bx, ax      ; Молодша частина
    mov si, dx      ; Старша частина
    
    ; Множимо молодшу частину на n
    mov ax, bx
    mul cx          ; DX:AX = BX * CX
    push ax         ; Зберігаємо молодшу частину результату
    push dx         ; Зберігаємо старшу частину першого множення
    
    ; Множимо старшу частину на n
    mov ax, si
    mul cx          ; DX:AX = SI * CX
    
    ; Додаємо старшу частину першого множення
    pop bx          ; Отримуємо старшу частину першого множення
    add ax, bx      ; Додаємо до молодшої частини другого множення
    
    ; Формуємо результат
    mov dx, ax      ; Старша частина в DX
    pop ax          ; Молодша частина в AX
    
    jmp .done

.base_case:
    ; Повертаємо 1 (DX:AX = 0:1)
    mov dx, 0
    mov ax, 1

.done:
    pop si
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
