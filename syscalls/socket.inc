include './syscall.inc'

AF_INET equ 0x2
SOCK_STREAM equ 0x1

macro socket
{
    mov rax, SYS_SOCKET
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    xor rdx, rdx
    syscall
}

struc sockaddr_in_t _port_
{
    .sin_family dw AF_INET
    .sin_port   db 0, _port_
    .sin_addr   db 4 dup(0)
    .sin_zero   db 8 dup(0)
}

macro bind _fd_, _addr_, _addr_size_
{
    mov rax, SYS_BIND
    mov rdi, _fd_
    mov rsi, _addr_
    mov rdx, _addr_size_
    syscall
}

SOMAXCONN equ 128

macro listen _fd_, _backlog_
{
    mov rax, SYS_LISTEN
    mov rdi, _fd_
    mov rsi, SOMAXCONN
    syscall
}

macro accept _fd_
{
    mov rax, SYS_ACCEPT
    mov rdi, _fd_
    xor rsi, rsi
    xor rdx, rdx
    syscall
}
