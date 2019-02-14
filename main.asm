format ELF64 executable 3
entry main

segment readable executable

include './config/config.inc'

include './syscalls/io.inc'
include './syscalls/socket.inc'
include './syscalls/process.inc'

main:
    mov   ax, DEFAULT_SERVER_PORT
    hton  ax
    mov   [_srv_config.port], ax

    openr CONFIG_FILENAME
    cmp   rax, -1
    jne   @f

    print OPEN_CONFIG_FAIL_LOG_STR, OPEN_CONFIG_FAIL_LOG_LEN
    panic

@@:
    mov  [_config_fd], rax

    read [_config_fd], _config_buffer, CONFIG_BUFFER_SIZE
    cmp  rax, -1
    jne  @f

    print READ_CONFIG_FAIL_LOG_STR, READ_CONFIG_FAIL_LOG_LEN
    panic

@@:
    mov   [_config_data_size], rax
    exit  ;TODO

    socket
    cmp rax, 0
    jg  @f

    print SOCKET_FAIL_LOG_STR, SOCKET_FAIL_LOG_LEN
    panic

@@:
    mov   [_sock_fd], rax

    bind [_sock_fd], _sock_addr, SOCK_ADDR_SIZE
    test rax, rax
    je   @f

    print BIND_FAIL_LOG_STR, BIND_FAIL_LOG_LEN
    panic

@@:
    listen [_sock_fd]
    test   rax, rax
    je     @f

    print LISTEN_FAIL_LOG_STR, LISTEN_FAIL_LOG_LEN
    panic

accept_loop:
    accept [_sock_fd]
    cmp    rax, -1
    mov    [_clnt_fd], rax
    jne    @f

    print ACCEPT_FAIL_LOG_STR, ACCEPT_FAIL_LOG_LEN
    jmp   accept_loop

@@:
    write [_clnt_fd], _http_html_headers, __http_html_headers_size
    close [_clnt_fd]
    jmp   accept_loop

segment readable writeable

CONFIG_BUFFER_SIZE = 512

_config_fd        dq ?
_config_buffer    db CONFIG_BUFFER_SIZE dup(?)
_config_data_size dq ?

_srv_config srv_config_t

SERVER_PORT equ 80

_sock_fd dq ?
_clnt_fd dq ?

_sock_addr sockaddr_in_t SERVER_PORT
SOCK_ADDR_SIZE = $-_sock_addr

include './http/response.asm'

segment readable

CONFIG_FILENAME db '/etc/httpd.conf',0x00

OPEN_CONFIG_FAIL_LOG_STR db 'config open() fail!',0x0A
OPEN_CONFIG_FAIL_LOG_LEN = $-OPEN_CONFIG_FAIL_LOG_STR

READ_CONFIG_FAIL_LOG_STR db 'config read() fail!',0x0A
READ_CONFIG_FAIL_LOG_LEN = $-READ_CONFIG_FAIL_LOG_STR

SOCKET_FAIL_LOG_STR db 'socket() fail!',0x0A
SOCKET_FAIL_LOG_LEN = $-SOCKET_FAIL_LOG_STR

BIND_FAIL_LOG_STR db 'bind() fail!',0x0A
BIND_FAIL_LOG_LEN = $-BIND_FAIL_LOG_STR

LISTEN_FAIL_LOG_STR db 'listen() fail!',0x0A
LISTEN_FAIL_LOG_LEN = $-LISTEN_FAIL_LOG_STR

ACCEPT_FAIL_LOG_STR db 'accept() fail!',0x0A
ACCEPT_FAIL_LOG_LEN = $-ACCEPT_FAIL_LOG_STR
