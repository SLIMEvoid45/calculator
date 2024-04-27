.global _start

.section .data
msg:    .asciz "Enter first number: "
msg2:   .asciz "Enter second number: "
msg3:   .asciz "Result: %d\n"

.section .bss
num1:   .space 4
num2:   .space 4
result: .space 4

.section .text
_start:
    // Выводим приглашение для ввода первого числа
    mov x0, 0x1          // file descriptor - stdout
    ldr x1, =msg
    mov x2, #18          // message length
    mov x8, #0x40        // syscall number for write
    svc #0

    // Читаем первое число
    mov x0, 0x0          // file descriptor - stdin
    ldr x1, =num1
    mov x2, #4           // buffer size
    mov x8, #0           // syscall number for read
    svc #0

    // Выводим приглашение для ввода второго числа
    mov x0, 0x1          // file descriptor - stdout
    ldr x1, =msg2
    mov x2, #22          // message length
    mov x8, #0x40        // syscall number for write
    svc #0

    // Читаем второе число
    mov x0, 0x0          // file descriptor - stdin
    ldr x1, =num2
    mov x2, #4           // buffer size
    mov x8, #0           // syscall number for read
    svc #0

    // Конвертируем строки в числа
    ldr x1, =num1
    ldr x2, [x1]
    mov w3, #10          // основание системы счисления (десятичная)
    bl atoi

    ldr x1, =num2
    ldr x2, [x1]
    mov w4, #10          // основание системы счисления (десятичная)
    bl atoi

    // Складываем числа
    add w5, w3, w4

    // Преобразуем результат обратно в строку
    mov w6, w5
    mov x1, result
    bl itoa

    // Выводим результат
    mov x0, 0x1          // file descriptor - stdout
    ldr x1, =msg3
    mov x2, #10          // message length
    mov x8, #0x40        // syscall number for write
    svc #0

    // Выходим из программы
    mov x0, #0           // код завершения 0
    mov x8, #93          // syscall number for exit
    svc #0

atoi:
    // Перевод строки в число
    mov w0, w2
    adr x1, str_end
    mov x2, w3
loop:
    ldrb w3, [x0], #1
    cbz w3, finish
    sub w3, w3, #'0'
    madd w2, w2, w2, w3
    cmp x0, x1
    bne loop
finish:
    ret

itoa:
    // Перевод числа в строку
    ldr x3, =10
    mov x0, x1
    add x2, x0, #9
    strb xzr, [x2, #-1]
    mov x2, xzr
    add x0, x0, #8
loop1:
    sdiv x1, x0, x3
    msub x0, x1, x3, x0
    add x2, x2, #1
    strb x0, [x1]
    cmp x1, xzr
    bne loop1
    ret

.section .data
str_end: .word 0
