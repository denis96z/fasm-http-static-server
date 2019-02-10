HTTP_VERSION equ 'HTTP/1.1 '

HTTP_STATUS_OK                 equ '200 OK'
HTTP_STATUS_NOT_FOUND          equ '404 Not Found'
HTTP_STATUS_METHOD_NOT_ALLOWED equ '405 Method Not Allowed'

HTTP_SERVER_HEADER equ 'Server: x-asm-http'

HTTP_CONTENT_TYPE_HEADER   equ 'Content-Type: '
HTTP_CONTENT_LENGTH_HEADER equ 'Content-Length: '

CONTENT_TYPE_HTML        equ 'text/html'
CONTENT_TYPE_CSS         equ 'text/css'
CONTENT_TYPE_JAVA_SCRIPT equ 'text/javascript'
CONTENT_TYPE_JPEG        equ 'image/jpeg'
CONTENT_TYPE_PNG         equ 'image/png'
CONTENT_TYPE_GIF         equ 'image/gif'
CONTENT_TYPE_FLASH       equ 'application/x-shockwave-flash'

CONTENT_LENGTH_BUFFER_SIZE equ 8

_http_html_headers db HTTP_VERSION
                   db HTTP_STATUS_OK,0x0D,0x0A
                   db HTTP_SERVER_HEADER,0x0D,0x0A
                   db HTTP_CONTENT_TYPE_HEADER,CONTENT_TYPE_HTML,0x0D,0x0A
                   db HTTP_CONTENT_LENGTH_HEADER
                   db CONTENT_LENGTH_BUFFER_SIZE-1 dup(' '),'0',0x0D,0x0A
                   db 0x0D,0x0A
__http_html_headers_size = $-_http_html_headers
