;Author Information
;  Author name: Kevin Ochoa
;  Author email: ochoakevinm@gmail.com
;Project Information
;  Project title: Harmonic Series Optimization
;  Purpose: The purpose of this assignment is to calculate the harmonic sum using vector processing to achieve the least amount of clock cycles.
;  Project files: harmonicseries.asm, seriesdriver.cpp
;Module Information
;  This module's call name: harmonic_series
;  Date last modified: 2015-11-30
;  Language: X86-64
;  Purpose:  The purpose of this module is to prompt the user for a term value. The program then calcuates the harmonic sum from 1 to that term using vector processing. 
;            It then returns the sum and the last term of the series to the driver.
;  Filename: harmonicseries.asm
;Translator Information:
;   Linux: nasm -f elf64 -l harmonicseries.lis -o harmonicseries.o harmonicseries.asm
;References and Credits:
;   Holliday, Floyd. Floating Point Input and Output. N.p., 1 July 2015. Web. 30 Nov 2015
;   Holliday, Floyd. Instructions acting on SSE and AVX. N.p., 27 August 2015. Web. 30 Nov. 2015. 
;   Holliday, Floyd. trapcomputation.asm. N.p., 15 February 2012, Web. 30 Nov 2015
;Format Information
;  Page width: 172 columns
;  Begin Comments: 61
;Permission information: No restrictions on posting this file online.
;===== Beginning of harmonicseries.asm ====================================================================================================================================

extern printf                                               ;External C++ function for writing to standard output device

extern scanf                                                ;External C++ function for reading from standard input device

global harmonic_series                                      ;Allows the harmonic_series to be called outside of file

segment .data                                               ;Place for initialized data

;===== Message and Format Declarations ====================================================================================================================================

startmessage db "This program will compute a partial sum of the harmonic series.",10,10,0

specifications db "These results were obtained on a desktop with a Core i5-3570k quad core processor at 3.4GHz.",10,10,0

termprompt db "Please enter a positive integer for the number of terms to include in the harmonic sum: ",0

sumstart db "The harmonic sum H(%ld) is being computed.",10,0

durationmessage db "Please be patient . . . .",10,0

timeafter db "The clock time after computing the harmonic sum was %ld",10,0

timebefore db "The clock time before computing the sum was         %ld",10,0

runtime db "The harmonic computation required %ld clock cycles (tics) which is %1.0lf nanoseconds on this machine.",10,0

result db "The harmonic sum of %ld terms is %1.18lf, which is 0x%lX.",10,0

endmessage db "This assembly program will now return the harmonic sum and the last term to the caller.",10,0

stringformat db "%s",0

term_format db "%ld",0

segment .bss                                                ;Place for pointers to un-initialized space

;===== Entry point of harmonic_series =====================================================================================================================================

segment .text                                               ;Place for executable instructions

harmonic_series:                                            ;Entry point for harmonic_series

push       rbp                                              ;This marks the start of a new stack frame for this function.
mov        rbp, rsp                                         ;rbp holds the address of the start of this new stack frame.

;===== Backup the registers needed for return to caller ===================================================================================================================

push      rdi                                               ;Backup rdi
push      rsi                                               ;Backup rsi

;===== Display Start Message ==============================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, startmessage                                ;"This program will compute a partial sum of the harmonic series."
call       printf                                           ;Call a library function to make the output 

;===== Display the specifications of this machine =========================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, specifications                              ;"These results were obtained on a desktop with Core-i5 quad core processor at 3.4GHz."
call       printf                                           ;Call a library function to make the output     

;===== Prompt the user for a term value ====================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, termprompt                                  ;"Please enter a positive integer for the number of terms to include in the harmonic sum: "
call       printf                                           ;Call a library function to make the output

;===== Get the term value and store in high numbered r-register ============================================================================================================

push qword 0 						    ;reserve 8 bytes of storage for the term value
mov        rax, 0                                           ;SSE is not involved with this scanf operation
mov        rdi, term_format                                 ;"%ld"
mov        rsi, rsp				            ;Give scanf a point to reserved storage
call       scanf                                            ;Call a library function to retrieve user values

pop        r15                                              ;pop the term value into high numbered r-register

;===== Inform user that the algorithm has begun ===========================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rsi, r15                                         ;move the term value into rsi for printing
mov        rdi, sumstart                                    ;"The harmonic sum H(%ld) is being computed"
call       printf                                           ;Call a library function to make the output

;===== Inform the user that algorithm may take a while ====================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat 				    ;"%s"
mov        rsi, durationmessage 			    ;"Please be patient . . . ."
call       printf 					    ;Call a library function to make the output

;===== Initialize vector of ones for use in division ======================================================================================================================

mov        rbx, 0x3FF0000000000000                          ;constant 1.0 needed to initialize vector
push       rbx                                              ;place the constant on the integer stack
vbroadcastsd ymm15, [rsp]                                   ;broadcast 1.0 into all spaces of ymm15
pop        rax                                              ;discard 1.0 from the integer stack

;===== Initialize vector of fours to use for incrementing =================================================================================================================

mov        rbx, 0x4010000000000000                          ;constant 4.0 needed to initialize vector
push       rbx                                              ;place the constant on the integer stack
vbroadcastsd ymm14, [rsp]                                   ;broadcast 4.0 into all spaces of ymm14
pop        rax                                              ;discard 4.0 from the integer stack

;===== Set the accumulator to zero ========================================================================================================================================

mov        rbx, 0x0000000000000000                          ;constant 0.0 needed to zero out ymm13
push       rbx                                              ;place the constant on the integer stack
vbroadcastsd ymm13, [rsp]                                   ;broadcast 0.0 into all spaces of ymm13
pop        rax                                              ;discard 0.0 from the integer stack

;===== Calculate N value for loop using the term value ====================================================================================================================

cvtsi2sd   xmm0, r15                                        ;Convert the term value into a double for use in division    
divsd      xmm0, xmm14                                      ;divide the term by 4.0 stored in xmm14 to get n value
cvtsd2si   r14,  xmm0                                       ;convert n into integer so that it can be used in the loop

;===== Read the clock before start of loop    =============================================================================================================================

cpuid                                                       ;call cpuid before reading the clock
rdtsc                                                       ;read the clock for the first time
shl rdx, 32                                                 ;shift the clock value over 32 bits
or  rdx, rax                                                ;transfer half of rax into rdx to get entire clock value
mov r11, rdx                                                ;store the clock value into high-numbered r register

;===== Loop through the calculations of harmonic sum ======================================================================================================================

mov      r13, 0                                             ;set the loop counter equal to zero
mov      r12, r14                                           ;set iterative value equal to n
beginloop:                                                  ;marks the beginning of the loop
cmp      r13, r12                                           ;compare the counter value to iterative
jg       loopfinished                                       ;jump to loopfinished if counter is greater than iterative
cmp      r13, 0                                             ;compare the counter to zero
je       initialcase				            ;jump to initialcase if counter is equal to zero
cmp      r13,r14					    ;cmp the counter to n
je       finalcase                                          ;jump to finalcase if counter is equal to n

vdivpd   ymm11, ymm15, ymm12                                ;divide the vector of ones by the terms and store value in ymm11
vaddpd   ymm13, ymm11                                       ;add vector containing (1 / x)  values to accumulator
vaddpd   ymm12,ymm14                                        ;increment each term by four 

inc      r13                                                ;increment the loop counter by one
jmp      beginloop                                          ;jump to beginning of loop for next iteration

initialcase:                                                ;marks the case where n equals zero

mov        rbx, 0x3FF0000000000000                          ;constant 1.0 needed to create term vector
push       rbx                                              ;place the constant on the integer stack
mov        rbx, 0x4000000000000000                          ;constant 2.0 needed to create term vector
push       rbx                                              ;place the constant on the integer stack
mov        rbx, 0x4008000000000000                          ;constant 3.0 needed to create term vector
push       rbx                                              ;place the constant on the integer stack
mov        rbx, 0x4010000000000000                          ;constant 4.0 needed to create term vector
push       rbx                                              ;place the constant on the integer stack

vmovupd    ymm12, [rsp]                                     ;place the first four terms into ymm12 for use in calculations

pop        rax                                              ;discard value from integer stack
pop        rax                                              ;discard value from integer stack
pop        rax                                              ;discard value from integer stack
pop        rax                                              ;discard value from integer stack

inc      r13                                                ;increment the counter by one
jmp      beginloop                                          ;jump to beginning of loop for next iteration

finalcase:                                                  ;marks the case where counter is equal to n

vdivpd    ymm11, ymm15, ymm12                               ;divide the vector of ones by the terms and store value in ymm11
vaddpd    ymm13, ymm11                                      ;add vector containing (1 / x)  values to accumulator
vhaddpd   ymm10, ymm13, ymm13                               ;horizontally add the values in the accumulator and store in ymm10
vextractf128 xmm0,ymm10,1                                   ;move the upper half of ymm10 into xmm0 for addition
addsd    xmm0, xmm10                                        ;add the upper half of ymm10 to xmm0 to get the total of harmonic series 

inc      r13						    ;increment counter by one
jmp      beginloop					    ;jump to beginning of loop 
loopfinished:                                               ;marks the end of the loop

;===== Read the clock after exiting from loop =============================================================================================================================

cpuid                                                       ;call cpuid before reading the clock
rdtsc                                                       ;read the clock for the second time
shl        rdx, 32                                          ;shift the clock value over 32 bits
or         rdx, rax                                         ;transfer half of rax into rdx to get entire clock value
mov        r10, rdx                                         ;store the clock value into high-numbered r register

;===== Move important registers to safer places ===========================================================================================================================

movsd      xmm15, xmm0  				    ;Copy the harmonic sum over to xmm15
movsd      xmm14, xmm11                                     ;Copy the last term in the series to xmm14
mov        r14, r11                                         ;move the first clock reading into r14
mov        r13, r10                                         ;move the second clock reading into r13

;===== Pop registers and set up for return to caller ======================================================================================================================

pop      rsi                                                ;restore rsi
pop      rdi                                                ;restore rdi

push qword 0						    ;reserve 8 bytes of storage
movsd [rsp], xmm15					    ;move harmonic sum total into rsp
mov   rax, [rsp]					    ;move the total into rax
mov   [rdi], rax				            ;store total in rdi for return to caller
pop rax							    ;free up space

push qword 0						    ;reserve 8 bytes of storage
movsd [rsp], xmm14					    ;move last term in series into rsp
mov   rax, [rsp]					    ;move the last term into rax
mov   [rsi], rax				            ;store last term in rsi for return to caller
pop rax							    ;free up space

;===== Display the clock after the start of algorithm ====================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rsi, r13                                         ;move the second clock value into rsi before printing
mov        rdi, timeafter                                   ;"The clock time after computing the harmonic sum was %ld"
call       printf                                           ;call a library function to make the output 

;===== Display the clock before the start of algorithm ====================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rsi, r14                                         ;move the first clock value into rsi before printing
mov        rdi, timebefore                                  ;"The clock time before computing the sum was %ld"
call       printf                                           ;call a library function to make the output 

;===== Calculate the runtime of algorithm =================================================================================================================================

sub        r13, r14                                         ;subtract the clocks to get the number of tics
cvtsi2sd   xmm0, r13                                        ;convert the number of tics into a double for division
mov        rbx, 0x400B333333333333                          ;move constant 3.4 (GHz) into rbx for division
push       rbx                                              ;place the constant on the integer stack
divsd      xmm0, [rsp]                                      ;divide the tics by 3.4 to get run time in nanoseconds
pop        rax                                              ;discard 3.4 from integer stack

;===== Display the run time message =======================================================================================================================================

mov        rax, 1                                           ;1 floating point number will be printed
mov        rsi, r13                                         ;move the run time in tics into rsi for printing
mov        rdi, runtime                                     ;"The harmonic computation required %ld clock cycles (tics) which is %lf nanoseconds on this machine."
call       printf                                           ;Call a library function to make the output

;===== Place series sum into rdx to get Hex representation ================================================================================================================

movsd      xmm0,xmm15					    ;copy the sum into xmm0
push qword 0                                                ;reserve 8 bytes of storage
movsd      [rsp], xmm0                                      ;move the series sum into rsp
mov        rdx, [rsp]                                       ;place sum inside of rdx
pop        rax                                              ;free up space

;===== Display the sum in decimal and hex format ==========================================================================================================================

mov        rax, 1                                           ;1 floating point number will be printed
mov        rsi, r15 					    ;move the term value into rsi for printing
mov        rdi, result                                      ;"The harmonic sum of %ld terms is %1.18lf, which is 0x%lx."
call       printf                                           ;Call a library function to make the output

;===== Display End Message ================================================================================================================================================

mov qword  rax, 0                                           ;No data from SSE will be printed
mov        rdi, stringformat                                ;"%s"
mov        rsi, endmessage                                  ;"This assembly program will now return the harmonic sum and the last term to the caller."
call       printf                                           ;Call a library function to make the output 

;====== Restore the Base Pointer ==========================================================================================================================================

pop        rbp
ret

;===== End of harmonicseries.asm ==========================================================================================================================================






