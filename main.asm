format ELF64 executable 3
entry main

segment readable executable

include './syscalls/io.inc'
include './syscalls/socket.inc'
include './syscalls/process.inc'

main:
    openr _config_filename
    cmp   rax, -1
    jne   @f

    print _open_config_fail_log, __open_config_fail_log_size
    exit_error

@@:
    mov  [_config_fd], rax

    read [_config_fd], _config_buffer, CONFIG_BUFFER_SIZE
    cmp  rax, -1
    jne  @f

    print _read_config_fail_log, READ_CONFIG_FAIL_LOG_LEN
    exit_error

@@:
    mov   [_config_data_size], rax
    exit_ok ;TODO

call_socket:
    socket
    cmp rax, 0
    jg  on_socket_success

on_socket_fail:
    print _socket_fail_log, __socket_fail_log_size
    exit_error

on_socket_success:
    mov   [_sock_fd], rax
    print _socket_success_log, __socket_success_log_size

call_bind:
    bind [_sock_fd], _sock_addr, __sock_addr_size
    test rax, rax
    je   on_bind_success

on_bind_fail:
    print _bind_fail_log, __bind_fail_log_size
    exit_error

on_bind_success:
    print _bind_success_log, __bind_success_log_size

call_listen:
    listen [_sock_fd]
    test   rax, rax
    je     on_listen_success

on_listen_fail:
    print _listen_fail_log, __listen_fail_log_size
    exit_error

on_listen_success:
    print _listen_success_log, __listen_success_log_size

call_accept:
    accept [_sock_fd]
    cmp    rax, -1
    mov    [_clnt_fd], rax
    jne    on_accept_success

on_accept_fail:
    print _accept_fail_log, __accept_fail_log_size
    jmp   call_accept

on_accept_success:
    write [_clnt_fd], _http_html_headers, __http_html_headers_size
    close [_clnt_fd]
    jmp   call_accept

call_exit:
    exit_ok

segment readable writeable

CONFIG_BUFFER_SIZE = 512

_config_fd        dq ?
_config_buffer    db CONFIG_BUFFER_SIZE dup(?)
_config_data_size dq ?

SERVER_PORT equ 80

_sock_fd dq ?
_clnt_fd dq ?

_sock_addr sockaddr_in_t SERVER_PORT
__sock_addr_size = $-_sock_addr

include './http/response.asm'

segment readable

_config_filename db '/etc/httpd.conf',0x00
__config_filename_size = $-_config_filename

_open_config_fail_log db 'config open() fail!',0x0A
__open_config_fail_log_size = $-_open_config_fail_log

_read_config_fail_log db 'config read() fail!',0x0A
READ_CONFIG_FAIL_LOG_LEN = $-_read_config_fail_log

_open_ok db 'open() ok', 0x0A
_open_ok_size = $-_open_ok

_socket_fail_log db 'socket() fail!',0x0A
__socket_fail_log_size = $-_socket_fail_log

_socket_success_log db 'socket() success!',0x0A
__socket_success_log_size = $-_socket_success_log

_bind_fail_log db 'bind() fail!',0x0A
__bind_fail_log_size = $-_bind_fail_log

_bind_success_log db 'bind() success!',0x0A
__bind_success_log_size = $-_bind_success_log

_listen_fail_log db 'listen() fail!',0x0A
__listen_fail_log_size = $-_listen_fail_log

_listen_success_log db 'listen() success!',0x0A
__listen_success_log_size = $-_listen_success_log

_accept_fail_log db 'accept() fail!',0x0A
__accept_fail_log_size = $-_accept_fail_log

_accept_success_log db 'accept() success!',0x0A
__accept_success_log_size = $-_accept_success_log
