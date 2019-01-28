SYS_EXIT  equ 3Ch

macro exit
{
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
}
