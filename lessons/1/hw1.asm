section .data
    msg db 'Hello from Assembly!', 0xA  ; Рядок для виведення (0xA - символ нового рядка)
    len equ $ - msg                   ; Довжина рядка (обчислюється автоматично)

section .text
    global _start                     ; Вхідна точка програми

_start:
    mov eax, 4                        ; Номер системного виклику: sys_write (4)
    mov ebx, 1                        ; Файловий дескриптор: stdout (1)
    mov ecx, msg                      ; Адреса рядка
    mov edx, len                      ; Довжина рядка
    int 0x80                          ; Виклик переривання (kernel call)

    mov eax, 1                        ; Номер системного виклику: sys_exit (1)
    xor ebx, ebx                      ; Код виходу: 0 (успішно)
    int 0x80                          ; Виклик переривання
