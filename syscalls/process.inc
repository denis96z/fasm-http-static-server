SYS_FORK equ 0x39
SYS_EXIT equ 0x3C

macro fork
{
    mov rax, SYS_FORK
    syscall
}

macro exit_ok
{
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
}

macro exit_error
{
    mov rax, SYS_EXIT
    mov rdi, -1
    syscall
}
