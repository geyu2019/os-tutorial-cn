        [org 0x7c00]

        mov bp,0x8000
        mov sp,bp

        push 'A'
        push 'B'
        push 'C'

        mov ah,0x0e

        mov al,[0x8000]
        int 0x10

        pop bx
        mov al,bl
        int 0x10

        pop bx
        mov al,bl
        int 0x10

        pop bx
        mov al,bl
        int 0x10

        pop bx
        mov al,bl
        int 0x10

        jmp $

        times 510-($-$$) db 0
        dw 0xaa55
