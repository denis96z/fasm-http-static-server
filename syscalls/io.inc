include './syscall.inc'

STDOUT equ 01h

macro print ptr, size
{
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, ptr
    mov rdx, size
    syscall
}

macro close fd
{
    mov rax, SYS_CLOSE
    mov rdi, fd
    syscall
}
