; ============================================================
; mergesort.asm — Bottom-up Merge Sort for int32_t arrays
; ABI: System V AMD64, NASM/Intel syntax
; void mergesort(int *arr, size_t n, int *tmp); // tmp >= n
; Build: nasm -f elf64 mergesort.asm -o mergesort.o
; ============================================================

        default rel
        bits 64

        section .text
        global mergesort

; ------------------------------------------------------------
; void mergesort(int *arr, size_t n, int *tmp)
; RDI=arr, RSI=n, RDX=tmp
; ------------------------------------------------------------
mergesort:
        push    rbp
        mov     rbp, rsp
        push    r15                     ; we use r15 to hold tmp persistently
        mov     r15, rdx

        cmp     rsi, 2
        jb      .ms_ret

        mov     r8, 1                   ; width = 1
.outer:
        cmp     r8, rsi
        jae     .ms_ret

        xor     r9, r9                  ; i = 0
.inner:
        cmp     r9, rsi
        jae     .step_done

        mov     r10, r9                 ; left = i
        mov     r11, r9
        add     r11, r8                 ; mid = i + width
        cmp     r11, rsi
        cmovg   r11, rsi                ; mid = min(mid, n)

        mov     rcx, r9
        lea     rcx, [rcx + r8*2]       ; right = i + 2*width
        cmp     rcx, rsi
        cmovg   rcx, rsi                ; right = min(right, n)

        cmp     r11, rcx
        jae     .skip_merge             ; if mid >= right, already sorted run-length

        ; merge_ranges(arr, left, mid, right, tmp)
        mov     rsi, r10
        mov     rdx, r11
        mov     r8,  r15                ; tmp
        ; RCX already right
        call    merge_ranges

.skip_merge:
        lea     r9, [r9 + r8*2]         ; i += 2*width
        jmp     .inner

.step_done:
        shl     r8, 1                   ; width *= 2
        jmp     .outer

.ms_ret:
        pop     r15
        mov     rsp, rbp
        pop     rbp
        ret

; ------------------------------------------------------------
; static void merge_ranges(int *arr, size_t left, size_t mid, size_t right, int *tmp)
; RDI=arr, RSI=left, RDX=mid, RCX=right, R8=tmp
; Merges [left, mid) and [mid, right) into tmp, then copies back.
; ------------------------------------------------------------
merge_ranges:
        push    rbp
        mov     rbp, rsp

        mov     r9, rsi                 ; i = left
        mov     r10, rdx                ; j = mid
        mov     r11, rsi                ; k = left

.merge_loop:
        cmp     r9, rdx
        jae     .left_done
        cmp     r10, rcx
        jae     .right_done

        mov     eax, dword [rdi + r9*4] ; a[i]
        mov     edx, dword [rdi + r10*4]; a[j]
        cmp     eax, edx                ; signed compare
        jle     .take_left

        ; take right
        mov     dword [r8 + r11*4], edx
        inc     r10
        inc     r11
        jmp     .merge_loop

.take_left:
        mov     dword [r8 + r11*4], eax
        inc     r9
        inc     r11
        jmp     .merge_loop

.left_done:
        ; copy remaining right half
        cmp     r10, rcx
        jae     .copy_back
.copy_right:
        mov     edx, dword [rdi + r10*4]
        mov     dword [r8 + r11*4], edx
        inc     r10
        inc     r11
        cmp     r10, rcx
        jb      .copy_right
        jmp     .copy_back

.right_done:
        ; copy remaining left half
        cmp     r9, rdx
        jae     .copy_back
.copy_left:
        mov     eax, dword [rdi + r9*4]
        mov     dword [r8 + r11*4], eax
        inc     r9
        inc     r11
        cmp     r9, rdx
        jb      .copy_left

.copy_back:
        mov     r9, rsi                 ; t = left
.cb_loop:
        cmp     r9, rcx
        jae     .mret
        mov     eax, dword [r8 + r9*4]
        mov     dword [rdi + r9*4], eax
        inc     r9
        jmp     .cb_loop

.mret:
        mov     rsp, rbp
        pop     rbp
        ret
