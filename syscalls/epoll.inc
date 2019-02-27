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

macro epollcreate _size_
{
    mov rax, SYS_EPOLL_CREATE
    mov rdi, _size_
    syscall
}

macro epollctl _epfd_, _op_, _fd_, _evt_ptr_
{
    mov rax, SYS_EPOLL_CTL
    mov rdi, _epfd_
    mov rsi, _op_
    mov rdx, _fd_
    mov rcx, _evt_ptr_
    syscall
}

macro epollwait _epfd_, _evt_buff_, _max_evt_, _timeout_
{
    mov rax, SYS_EPOLL_WAIT
    mov rdi, _epfd_
    mov rsi, _evt_buff_
    mov rdx, _max_evt_
    mov rcx, _timeout_
    syscall
}
