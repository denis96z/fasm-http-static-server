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

