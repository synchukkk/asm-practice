; hw5.asm - Програма для малювання конверту
; Компіляція: nasm -f bin hw5.asm -o hw5.com
; Запуск: hw5.com (в DOSBox або подібному емуляторі)

org 100h

section .text
start:
    ; Встановлюємо розміри конверту
    mov ah, 30      ; Ширина (30 символів)
    mov al, 14      ; Висота (14 рядків)
    
    call draw_envelope
    
    ; Завершення програми
    mov ah, 4Ch
    int 21h

; Функція малювання конверту
; Вхід: AH - ширина, AL - висота
draw_envelope:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Зберігаємо розміри
    mov byte [width], ah
    mov byte [height], al
    
    ; Лічильник рядків
    mov cl, 1
    
.draw_row:
    mov ch, 1       ; Лічильник колонок
    
.draw_col:
    ; Визначаємо, який символ друкувати
    call get_char_at_position
    
    ; Друкуємо символ
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Наступна колонка
    inc ch
    cmp ch, [width]
    jbe .draw_col
    
    ; Новий рядок
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h
    
    ; Наступний рядок
    inc cl
    cmp cl, [height]
    jbe .draw_row
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Визначає символ в позиції (CL, CH)
; Вхід: CL - рядок (1-based), CH - колонка (1-based)
; Вихід: AL - символ для друку
get_char_at_position:
    push bx
    push cx
    push dx
    
    mov al, ' '     ; За замовчуванням - пробіл
    
    ; Перевірка верхнього та нижнього рядка
    cmp cl, 1
    je .border
    cmp cl, [height]
    je .border
    
    ; Перевірка лівої та правої межі
    cmp ch, 1
    je .border
    cmp ch, [width]
    je .border
    
    ; Тепер перевіряємо діагоналі
    ; Ліва верхня діагональ (йде вниз-вправо)
    mov bl, cl
    sub bl, 1       ; BL = рядок - 1 (0-based)
    mov bh, ch
    sub bh, 1       ; BH = колонка - 1 (0-based)
    
    cmp bl, bh
    je .diagonal
    
    ; Права верхня діагональ (йде вниз-вліво)
    mov bl, cl
    sub bl, 1       ; BL = рядок - 1
    mov bh, [width]
    sub bh, ch      ; BH = ширина - колонка
    
    cmp bl, bh
    je .diagonal
    
    ; Ліва нижня діагональ (йде вгору-вправо)
    mov bl, [height]
    sub bl, cl      ; BL = висота - рядок
    mov bh, ch
    sub bh, 1       ; BH = колонка - 1
    
    cmp bl, bh
    je .diagonal
    
    ; Права нижня діагональ (йде вгору-вліво)
    mov bl, [height]
    sub bl, cl      ; BL = висота - рядок
    mov bh, [width]
    sub bh, ch      ; BH = ширина - колонка
    
    cmp bl, bh
    je .diagonal
    
    jmp .done

.border:
    mov al, '*'
    jmp .done

.diagonal:
    mov al, '*'

.done:
    pop dx
    pop cx
    pop bx
    ret

section .data
    width db 0
    height db 0
