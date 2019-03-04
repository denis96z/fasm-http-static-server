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
    mov eax, EPOLLIN
    or  eax, EPOLLET
    mov [_srv_sock_ev.events], eax

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

    mov r10, _worker_pid_buff + WORKER_PID_BUFF_SIZE
    sub r10, r9
    inc r9

    print WORKER_START_LOG_STR, WORKER_START_LOG_LEN
    print r9, r10
    print NEW_LINE_LOG_STR, NEW_LINE_LOG_LEN

    epollcreate EPOLL_SIZE
    cmp         rax, -1
    jne         @f

    panic EPOLL_CREATE_FAIL_LOG_STR, EPOLL_CREATE_FAIL_LOG_LEN

@@:
    mov [_epoll_fd], rax

    mov rax, [_sock_fd]
    mov [_srv_sock_ev.data], rax

    epollctl [_epoll_fd], EPOLL_CTL_ADD, [_sock_fd], _srv_sock_ev
    cmp      rax, -1
    jne      epoll_loop

    panic EPOLL_CTL_FAIL_LOG_STR, EPOLL_CTL_FAIL_LOG_LEN

epoll_loop:
    epollwait [_epoll_fd], _clnt_sock_evs, EPOLL_SIZE, EPOLL_TIMEOUT
    cmp       rax, -1
    jne       @f

    panic EPOLL_WAIT_FAIL_LOG_STR, EPOLL_WAIT_FAIL_LOG_LEN

@@:
    mov r12, _clnt_sock_evs
    mov r14, rax

serve_loop:
    print SERVE_LOOP_LOG_STR, SERVE_LOOP_LOG_LEN

    dec  r14
    cmp  r14, -1
    je   epoll_loop

    mov    r13, qword [r12 + 4] ;TODO possible optimization?
    cmp    r13, [_sock_fd]
    jne    @f

    accept r13
    cmp    rax, -1
    jne    @f

    print ACCEPT_FAIL_LOG_STR, ACCEPT_FAIL_LOG_LEN

    jmp serve_loop

@@:
    print ACCEPT_OK_LOG_STR, ACCEPT_OK_LOG_LEN
    close r13

    jmp serve_loop

segment readable writeable

CONFIG_BUFFER_SIZE = 512

_config_buffer    db CONFIG_BUFFER_SIZE dup(?)
_config_data_size dq ?

_srv_config srv_config_t

SERVER_PORT = 80

EPOLL_SIZE    = 1024
EPOLL_TIMEOUT = -1

_sock_fd  dq ?
_epoll_fd dq ?

_sock_addr sockaddr_in_t SERVER_PORT
SOCK_ADDR_SIZE = $-_sock_addr

_worker_pid_buff db WORKER_PID_BUFF_SIZE dup(' ')
WORKER_PID_BUFF_SIZE = 16

_srv_sock_ev epoll_event_t

_clnt_sock_evs     dd EPOLL_SIZE dup(?)
                   dq EPOLL_SIZE dup(?)
_num_clnt_sock_evs dq ?

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

EPOLL_CREATE_FAIL_LOG_STR db 'epoll_create() fail!',0x0A
EPOLL_CREATE_FAIL_LOG_LEN = $-EPOLL_CREATE_FAIL_LOG_STR

EPOLL_CTL_FAIL_LOG_STR db 'epoll_ctl() fail!',0x0A
EPOLL_CTL_FAIL_LOG_LEN = $-EPOLL_CTL_FAIL_LOG_STR

EPOLL_WAIT_FAIL_LOG_STR db 'epoll_wait() fail!',0x0A
EPOLL_WAIT_FAIL_LOG_LEN = $-EPOLL_WAIT_FAIL_LOG_STR

SERVE_LOOP_LOG_STR db 'serve loop!',0x0A
SERVE_LOOP_LOG_LEN = $-SERVE_LOOP_LOG_STR

ACCEPT_FAIL_LOG_STR db 'accept() fail!',0x0A
ACCEPT_FAIL_LOG_LEN = $-ACCEPT_FAIL_LOG_STR

ACCEPT_OK_LOG_STR db 'accept() ok!',0x0A
ACCEPT_OK_LOG_LEN = $-ACCEPT_OK_LOG_STR
