macro u64tos _x_, _buff_ptr_, _buff_size_
{
    mov rax, _x_

    mov r8, 10
    mov r9, _buff_ptr_ + _buff_size_ - 1

@@:
    xor rdx, rdx
    div r8

    mov byte [r9], dl
    add byte [r9], '0'
    dec r9

    test rax, rax
    jnz  @b
}
