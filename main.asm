format ELF64 executable 3
entry main

segment readable executable

include './syscalls/io.inc'
include './syscalls/socket.inc'
include './syscalls/process.inc'

main:

call_socket:
    socket
    cmp    rax, 0
    jg     on_socket_success
    jmp    on_socket_fail

on_socket_fail:
    print _socket_fail_log, __socket_fail_log_size
    exit_error

on_socket_success:
    mov [_sock_fd], rax

call_bind:
    bind [_sock_fd], _sock_addr, __sock_addr_size
    cmp  rax, 0
    je   on_bind_success
    jmp  on_bind_fail

on_bind_fail:
    print _bind_fail_log, __bind_fail_log_size
    exit_error

on_bind_success:
call_exit:
    exit_ok

segment readable writeable

SERVER_PORT equ 80

_sock_fd dq ?

_sock_addr sockaddr_in_t SERVER_PORT
__sock_addr_size = $-_sock_addr

_socket_fail_log db 'socket() failed', 0xA
__socket_fail_log_size = $-_socket_fail_log

_bind_fail_log db 'bind() failed', 0xA
__bind_fail_log_size = $-_bind_fail_log

include './headers/server.inc'
include './headers/content_type.inc'
