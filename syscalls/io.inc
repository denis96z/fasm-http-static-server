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

macro write _fd_, _data_ptr_, _data_size_
{
    mov rax, SYS_WRITE
    mov rdi, _fd_
    mov rsi, _data_ptr_
    mov rdx, _data_size_
    syscall
}

macro close _fd_
{
    mov rax, SYS_CLOSE
    mov rdi, _fd_
    syscall
}
