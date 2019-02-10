include './syscall.inc'

STDOUT equ 01h

macro print _ptr_, _size_
{
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, _ptr_
    mov rdx, _size_
    syscall
}

macro close _fd_
{
    mov rax, SYS_CLOSE
    mov rdi, _fd_
    syscall
}
