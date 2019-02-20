include './syscall.inc'

F_GETFD equ 0x01
F_SETFL equ 0x04

O_NONBLOCK equ 0x0FA0

EPOLLIN equ 0x00000001
EPOLLET equ 0x80000000

struc epoll_event_t
{
    .events dd ?
    .data   dq ?
}

macro setnb _fd_
{
    mov rax, SYS_FCNTL
    mov rdi, _fd_
    mov rsi, F_GETFD
    xor rdx, rdx
    syscall

    or  rax, O_NONBLOCK
    mov r8,  rax

    mov rax, SYS_FCNTL
    mov rdi, _fd_
    mov rsi, F_SETFL
    mov rdx, r8
    syscall
}
