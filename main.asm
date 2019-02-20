format ELF64 executable 3
entry main

segment readable executable

include './config/config.inc'

include './syscalls/io.inc'
include './syscalls/socket.inc'
include './syscalls/epoll.inc'
include './syscalls/process.inc'

include './utils/fmt.inc'

main:
    openr CONFIG_FILENAME
    cmp   rax, -1
    jne   @f

    panic OPEN_CONFIG_FAIL_LOG_STR, OPEN_CONFIG_FAIL_LOG_LEN

@@:
    mov  r10, rax

    read r10, _config_buffer, CONFIG_BUFFER_SIZE
    cmp  rax, -1
    jne  @f

    panic READ_CONFIG_FAIL_LOG_STR, READ_CONFIG_FAIL_LOG_LEN

@@:
    mov   [_config_data_size], rax
    close r10

    socket
    cmp rax, 0
    jg  @f

    panic SOCKET_FAIL_LOG_STR, SOCKET_FAIL_LOG_LEN

@@:
    mov   [_sock_fd], rax

    setnb [_sock_fd]
    cmp   rax, -1
    jne   @f

    panic SET_NONBLOCKING_FAIL_LOG_STR, SET_NONBLOCKING_FAIL_LOG_LEN

@@:
    bind [_sock_fd], _sock_addr, SOCK_ADDR_SIZE
    test rax, rax
    jz   @f

    panic BIND_FAIL_LOG_STR, BIND_FAIL_LOG_LEN

@@:
    listen [_sock_fd]
    test   rax, rax
    je     @f

    panic LISTEN_FAIL_LOG_STR, LISTEN_FAIL_LOG_LEN

@@:
    print SERVER_START_LOG_STR, SERVER_START_LOG_LEN

    mov r9, [_srv_config.num_workers]

fork_loop:
    fork
    mov r10, rax
    cmp r10, -1
    jne @f

    panic FORK_FAIL_LOG_STR, FORK_FAIL_LOG_LEN

@@:
    test r10, r10
    jne  @f

    dec  r9
    test r9, r9
    jne  fork_loop

    exit 0

@@:
    getpid
    mov    r15, rax
    u64tos r15, _worker_pid_buff, WORKER_PID_BUFF_SIZE

    inc r9 ;first char of pid

    print WORKER_START_LOG_STR, WORKER_START_LOG_LEN
    print r9, WORKER_PID_BUFF_SIZE
    print NEW_LINE_LOG_STR, NEW_LINE_LOG_LEN

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

_config_buffer    db CONFIG_BUFFER_SIZE dup(?)
_config_data_size dq ?

_srv_config srv_config_t

SERVER_PORT equ 80

_sock_fd dq ?
_clnt_fd dq ?

_sock_addr sockaddr_in_t SERVER_PORT
SOCK_ADDR_SIZE = $-_sock_addr

_worker_pid_buff db WORKER_PID_BUFF_SIZE dup(' ')
WORKER_PID_BUFF_SIZE = 16

_sock_ev epoll_event_t

;_clnt_events     epoll_event_t DEFAULT_NUM_WORKERS dup(<>) ;TODO
;_num_clnt_events dq            ?                           ;TODO

include './http/response.asm'

segment readable

NEW_LINE_LOG_STR db 0x0A
NEW_LINE_LOG_LEN = $-NEW_LINE_LOG_STR

CONFIG_FILENAME db '/etc/httpd.conf',0x00

OPEN_CONFIG_FAIL_LOG_STR db 'config open() fail!',0x0A
OPEN_CONFIG_FAIL_LOG_LEN = $-OPEN_CONFIG_FAIL_LOG_STR

READ_CONFIG_FAIL_LOG_STR db 'config read() fail!',0x0A
READ_CONFIG_FAIL_LOG_LEN = $-READ_CONFIG_FAIL_LOG_STR

CLOSE_CONFIG_FAIL_LOG_STR db 'config close() fail!',0x0A
CLOSE_CONFIG_FAIL_LOG_LEN = $-CLOSE_CONFIG_FAIL_LOG_STR

SOCKET_FAIL_LOG_STR db 'socket() fail!',0x0A
SOCKET_FAIL_LOG_LEN = $-SOCKET_FAIL_LOG_STR

SET_NONBLOCKING_FAIL_LOG_STR db 'fcntl() set non-blocking fail!',0x0A
SET_NONBLOCKING_FAIL_LOG_LEN = $-SET_NONBLOCKING_FAIL_LOG_STR

BIND_FAIL_LOG_STR db 'bind() fail!',0x0A
BIND_FAIL_LOG_LEN = $-BIND_FAIL_LOG_STR

LISTEN_FAIL_LOG_STR db 'listen() fail!',0x0A
LISTEN_FAIL_LOG_LEN = $-LISTEN_FAIL_LOG_STR

SERVER_START_LOG_STR db 'listening on 0.0.0.0:80', 0x0A ;TODO print port
SERVER_START_LOG_LEN = $-SERVER_START_LOG_STR

FORK_FAIL_LOG_STR db 'fork() fail!',0x0A
FORK_FAIL_LOG_LEN = $-FORK_FAIL_LOG_STR

WORKER_START_LOG_STR db 'worker started, pid:'
WORKER_START_LOG_LEN = $-WORKER_START_LOG_STR

ACCEPT_FAIL_LOG_STR db 'accept() fail!',0x0A
ACCEPT_FAIL_LOG_LEN = $-ACCEPT_FAIL_LOG_STR
