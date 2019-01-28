SYS_WRITE equ 01h

STDOUT equ 01h

macro print ptr, size
{
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, ptr
    mov rdx, size
    syscall
}
