section .data
    newline db 10

section .bss
    buffer resb 20

section .text
global _start

_start:
    mov eax, 1234567     ; число для перетворення
    mov esi, buffer      ; адреса буфера
    call int2str

    ; вивід результату
    mov eax, 4           ; sys_write
    mov ebx, 1           ; stdout
    mov ecx, buffer
    mov edx, 20
    int 0x80

    mov eax, 1           ; sys_exit
    xor ebx, ebx
    int 0x80


; ==============================
; int2str - перетворення int у string
; Вхід:
;   EAX - число
;   ESI - адреса буфера
; Вихід:
;   buffer містить рядок числа
; ==============================

int2str:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, 0          ; лічильник цифр

.convert:
    mov ebx, 10
    xor edx, edx
    div ebx             ; eax = eax / 10, edx = остача
    add dl, '0'         ; цифра в ASCII
    push dx             ; кладемо в стек
    inc ecx
    test eax, eax
    jnz .convert

.write:
    pop dx
    mov [esi], dl
    inc esi
    loop .write

    mov byte [esi], 0   ; завершення рядка

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

