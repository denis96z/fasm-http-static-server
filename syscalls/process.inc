include './io.inc'
include './syscall.inc'

macro fork
{
    mov rax, SYS_FORK
    syscall
}

macro exit _code_
{
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
}

macro panic _message_, _message_len_
{
    print _message_, _message_len_
    exit  -1
}
