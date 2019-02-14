include './syscall.inc'

macro fork
{
    mov rax, SYS_FORK
    syscall
}

macro exit
{
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
}

macro panic
{
    mov rax, SYS_EXIT
    mov rdi, -1
    syscall
}
