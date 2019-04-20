print:
        pusha
loop:
        mov al,[bx]
        cmp al,0
        je end
        mov ah,0x0e
        int 0x10
        inc bx
        jmp loop

print_nl:
        pusha
        mov ah,0x0e

        mov al,0x0a
        int 0x10

        mov al,0x0d
        int 0x10

        popa
        ret

print_hex:
        pusha


        mov cx,0
count_loop:
        mov bx, HEX_TEMP
        add bx,cx
        mov al,[bx]
        cmp al,0x0
        je  count_end
        inc cx
        jmp count_loop
count_end:
        mov [LENGCE],cx
        sub cx,1
hex_begin:
        mov ax,dx
        and ax,0x000f
        add ax,0x30
        cmp ax,0x39
        jle little9
        add ax,0x07

little9:
        mov bx, HEX_TEMP
        add bx,cx

        mov [bx],al
        sub cx,1
        cmp cx,1
        je hex_end
        ror dx,4
        jmp hex_begin

hex_end:
        mov bx,HEX_TEMP
        call print
        call print_nl
        popa
        ret

HEX_TEMP:
        db "0x0000",0,0
LENGCE:
        db 0,0

end:
        popa
        ret
