include './syscall.inc'

STDOUT equ 0x01
O_RDONLY equ 0x00

macro print _ptr_, _size_
{
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, _ptr_
    mov rdx, _size_
    syscall
}

macro openr _filename_
{
    mov rax, SYS_OPEN
    xor rdi, rdi
    mov rsi, _filename_
    mov rdx, O_RDONLY
    syscall
}

macro read _fd_, _buffer_ptr_, _buffer_size_
{
    mov rax, SYS_READ
    mov rdi, _fd_
    mov rsi, _buffer_ptr_
    mov rdx, _buffer_size_
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
