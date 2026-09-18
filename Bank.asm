.data
filename: .asciiz "C:/Users/as/Desktop/ATM3/Accounts.txt"

msg_enter_cnic: .asciiz "Enter CNIC(5 Digits):"
msg_wrong_cnic: .asciiz "You entered incorrect CNIC\n"
msg_enter_pin:  .asciiz "Enter PIN:"
msg_wrong_pin:  .asciiz "You entered incorrect PIN\n"
msg_goodbye:    .asciiz "Thanks for coming\n"
msg_deposit:        .asciiz "Enter deposit amount:"
msg_deposit_error:  .asciiz "Error: Deposit limit exceeded (Max 50000)\n"
msg_new_balance:    .asciiz "New Balance:"
msg_transfer_cnic: .asciiz "Enter receiver CNIC(5 Digits):"
msg_transfer_amt:  .asciiz "Enter transfer amount:"
msg_invalid_cnic: .asciiz "You entered invalid CNIC\n"
msg_same_cnic:    .asciiz "You cannot transfer to your own account\n"
msg_limit_error:  .asciiz "Transfer limit exceeded (Max 50000)\n"
msg_insufficient: .asciiz "You entered insufficient amount\n"
msg_sender_new:    .asciiz "Your New Balance:"
msg_menu: .asciiz "\nMain Menu:\n1. Check Balance\n2. Withdraw\n3. Deposit\n4. Funds Transfer\n5. Exit\nChoice:"
msg_balance: .asciiz "Your Balance:"
msg_withdraw: .asciiz "Enter withdrawal amount:"
msg_withdraw_error: .asciiz "Insufficient balance.\n"
msg_withdraw_limit: .asciiz "Withdraw limit exceeded (Max 50000)\n"
msg_file_error: .asciiz "File Error\n"
newline: .asciiz "\n"
space: .asciiz " "
pin_attempts: .word 0
msg_negative: .asciiz "Negative number is not Allowed\n"
msg_zero: .asciiz "Please Enter amount Greater than 500\n"
.align 2
CNICarray: .word 0:10
PINarray:  .word 0:10
BALarray:  .word 0:10

userCount: .word 0
buffer: .space 512
tmpnum: .space 32

.text
.globl main

# MAIN

main:
    # OPEN FILE (READ)
    li $v0,13
    la $a0,filename
    li $a1,0
    li $a2,0
    syscall
    bltz $v0,file_error
    move $s7,$v0

    # READ FILE
    li $v0,14
    move $a0,$s7
    la $a1,buffer
    li $a2,512
    syscall
    blez $v0,file_error

    # CLOSE FILE
    li $v0,16
    move $a0,$s7
    syscall

    la $t0,buffer

# PARSE USERS 

parse_users:
    lb $t1,0($t0)
    beqz $t1,auth_start
    beq $t1,'\n',next_line
    beq $t1,'\r',next_line

    lw $t5,userCount
    sll $t6,$t5,2

    la $t1,CNICarray
    addu $t1,$t1,$t6
    la $t2,PINarray
    addu $t2,$t2,$t6
    la $t3,BALarray
    addu $t3,$t3,$t6

    # CNIC
    li $t8,0
pc:
    lb $t9,0($t0)
    blt $t9,'0',pc_done
    bgt $t9,'9',pc_done
    addi $t9,$t9,-48
    mul $t8,$t8,10
    add $t8,$t8,$t9
    addi $t0,$t0,1
    j pc
pc_done:
    sw $t8,0($t1)
    addi $t0,$t0,1

    # PIN
    li $t8,0
pp:
    lb $t9,0($t0)
    blt $t9,'0',pp_done
    bgt $t9,'9',pp_done
    addi $t9,$t9,-48
    mul $t8,$t8,10
    add $t8,$t8,$t9
    addi $t0,$t0,1
    j pp
pp_done:
    sw $t8,0($t2)
    addi $t0,$t0,1

    # SKIP TO BALANCE (skip any spaces)
skip_to_balance:
    lb $t9,0($t0)
    beq $t9,' ',skip_to_balance_next
    beq $t9,'\t',skip_to_balance_next
    j skip_to_balance_done
skip_to_balance_next:
    addi $t0,$t0,1
    j skip_to_balance
skip_to_balance_done:

    # BALANCE
    li $t8,0
pb:
    lb $t9,0($t0)
    blt $t9,'0',pb_done
    bgt $t9,'9',pb_done
    addi $t9,$t9,-48
    mul $t8,$t8,10
    add $t8,$t8,$t9
    addi $t0,$t0,1
    j pb
pb_done:
    sw $t8,0($t3)

    lw $t5,userCount
    addi $t5,$t5,1
    sw $t5,userCount

next_line:
    lb $t9,0($t0)
    beqz $t9,auth_start
    beq $t9,'\n',skip_newline
    beq $t9,'\r',skip_newline
    addi $t0,$t0,1
    j next_line
    
skip_newline:
    addi $t0,$t0,1
    j parse_users

# AUTHENTICATION WITH ERROR MESSAGES

auth_start:
    # Prompt for CNIC
cnic_prompt:
    li $v0,4
    la $a0,msg_enter_cnic
    syscall
    li $v0,5
    syscall
    move $s0,$v0

    # Search for CNIC
    lw $t9,userCount
    la $t1,CNICarray
    li $t2,0

find_cnic:
    beq $t2,$t9,cnic_not_found
    lw $t3,0($t1)
    beq $t3,$s0,cnic_found
    addi $t1,$t1,4
    addi $t2,$t2,1
    j find_cnic

cnic_not_found:
    li $v0,4
    la $a0,msg_wrong_cnic
    syscall
    j cnic_prompt

cnic_found:
    move $s1,$t2

    # PIN verification
    la $t1,PINarray
    sll $t6,$s1,2
    addu $t1,$t1,$t6
    # Reset attempts when CNIC is correct
    li $t0,0
    sw $t0,pin_attempts

pin_prompt:
    li $v0,4
    la $a0,msg_enter_pin
    syscall

    li $v0,5
    syscall
    move $t4,$v0

    lw $t3,0($t1)
    beq $t4,$t3,pin_correct

    # Wrong PIN
    lw $t0,pin_attempts
    addi $t0,$t0,1
    sw $t0,pin_attempts

    li $v0,4
    la $a0,msg_wrong_pin
    syscall

    li $t5,3
    beq $t0,$t5,exit_after_pin_fail

    j pin_prompt

exit_after_pin_fail:
    li $v0,4
    la $a0,msg_goodbye
    syscall
    li $v0,10
    syscall


pin_correct:

# MENU

menu:
    li $v0,4
    la $a0,msg_menu
    syscall

menu_input:
    li $v0,5
    syscall
    bltz $v0,menu_negative

    beq $v0,1,show_balance
    beq $v0,2,withdraw
    beq $v0,3,deposit
    beq $v0,4,funds_transfer
    beq $v0,5,save_and_exit
    j menu

menu_negative:
    li $v0,4
    la $a0,msg_negative
    syscall
    j menu


show_balance:
    la $t1,BALarray
    sll $t6,$s1,2
    addu $t1,$t1,$t6
    li $v0,4
    la $a0,msg_balance
    syscall
    li $v0,1
    lw $a0,0($t1)
    syscall
    li $v0,4
    la $a0,newline
    syscall
    j menu

# WITHDRAW

withdraw:
    li $v0,4
    la $a0,msg_withdraw
    syscall

withdraw_input:
    li $v0,5
    syscall
    bltz $v0,withdraw_negative
    move $t7,$v0
    li $t9,500
    blt $t7,$t9,withdraw_less_than_500
    j withdraw_continue
    
withdraw_negative:
    li $v0,4
    la $a0,msg_negative
    syscall
    j withdraw
    
withdraw_less_than_500:
    li $v0,4
    la $a0,msg_zero   
    syscall
    j withdraw

withdraw_continue:
    la $t1,BALarray
    sll $t6,$s1,2
    addu $t1,$t1,$t6
    lw $t8,0($t1)

    li $t9,50000
    bgt $t7,$t9,msg_withdraw1
    blt $t8,$t7,withdraw_err

    sub $t8,$t8,$t7
    sw $t8,0($t1)
    j show_balance

withdraw_err:
    li $v0,4
    la $a0,msg_withdraw_error
    syscall
    j withdraw

msg_withdraw1:
    li $v0,4
    la $a0,msg_withdraw_limit
    syscall
    j withdraw
    
# DEPOSIT

deposit:
    li $v0,4
    la $a0,msg_deposit
    syscall

deposit_input:
    li $v0,5
    syscall
    bltz $v0,deposit_negative
    move $t7,$v0   # deposit amount
    li $t9,500
    blt $t7,$t9,deposit_less_than_500
    j deposit_continue
    
    deposit_negative:
    li $v0,4
    la $a0,msg_negative
    syscall
    j deposit
    
deposit_less_than_500:
    li $v0,4
    la $a0,msg_zero   
    syscall
    j deposit
    
deposit_continue:
    # Check deposit limit (<= 50000)
    li $t9,50000
    bgt $t7,$t9,deposit_err

    # Load user balance
    la $t1,BALarray
    sll $t6,$s1,2
    addu $t1,$t1,$t6
    lw $t8,0($t1)

    # Add deposit amount
    add $t8,$t8,$t7
    sw $t8,0($t1)

    # Show New Balance
    li $v0,4
    la $a0,msg_new_balance
    syscall

    li $v0,1
    move $a0,$t8
    syscall

    li $v0,4
    la $a0,newline
    syscall

    j menu

deposit_err:
    li $v0,4
    la $a0,msg_deposit_error
    syscall
    j deposit

# FUNDS TRANSFER 

funds_transfer:
    # Ask receiver CNIC
    li $v0,4
    la $a0,msg_transfer_cnic
    syscall

     li $v0,5
    syscall
    bltz $v0,transfer_cnic_negative
    move $t0,$v0  # receiver CNIC
    j receiver_cnic_ok
transfer_cnic_negative:
    li $v0,4
    la $a0,msg_negative
    syscall
    j funds_transfer

receiver_cnic_ok:
    # Check same CNIC (self transfer)
    beq $t0,$s0,same_cnic_error

    # Search receiver CNIC
    lw $t9,userCount
    la $t1,CNICarray
    li $t2,0

find_receiver:
    beq $t2,$t9,invalid_cnic_error
    lw $t3,0($t1)
    beq $t3,$t0,receiver_found
    addi $t1,$t1,4
    addi $t2,$t2,1
    j find_receiver

receiver_found:
    move $s2,$t2        # receiver index
    j ask_transfer_amount          

ask_transfer_amount: 
    # Ask transfer amount
    li $v0,4
    la $a0,msg_transfer_amt
    syscall
    li $v0,5
    syscall
    bltz $v0,transfer_amt_negative
    move $t7,$v0       # transfer amount
    li $t9,500
    blt $t7,$t9,fund_less_than_500
    j transfer_amt_ok

transfer_amt_negative:
    li $v0,4
    la $a0,msg_negative
    syscall
    j ask_transfer_amount

fund_less_than_500:
    li $v0,4
    la $a0,msg_zero   
    syscall
    j ask_transfer_amount

transfer_amt_ok:
    # Transfer limit check (<= 50000)
    li $t6,50000
    bgt $t7,$t6,limit_error

    # Load sender balance
    la $t1,BALarray
    sll $t6,$s1,2
    addu $t1,$t1,$t6
    lw $t8,0($t1)

    # Insufficient balance check
    blt $t8,$t7,insufficient_error

    # Load receiver balance
    la $t2,BALarray
    sll $t6,$s2,2
    addu $t2,$t2,$t6
    lw $t9,0($t2)

    # Update balances
    sub $t8,$t8,$t7
    add $t9,$t9,$t7

    sw $t8,0($t1)
    sw $t9,0($t2)

    # Show sender new balance
    li $v0,4
    la $a0,msg_sender_new
    syscall

    li $v0,1
    move $a0,$t8
    syscall

    li $v0,4
    la $a0,newline
    syscall

    j menu

# TRANSFER ERRORS

invalid_cnic_error:
    li $v0,4
    la $a0,msg_invalid_cnic
    syscall
    j funds_transfer

same_cnic_error:
    li $v0,4
    la $a0,msg_same_cnic
    syscall
    j funds_transfer

limit_error:
    li $v0,4
    la $a0,msg_limit_error
    syscall
    j ask_transfer_amount

insufficient_error:
    li $v0,4
    la $a0,msg_insufficient
    syscall
    j ask_transfer_amount

# SAVE AND EXIT 
save_and_exit:
    # Open file for writing (create/truncate)
    li $v0, 13
    la $a0, filename
    li $a1, 1          # Write mode
    li $a2, 0
    syscall
    bltz $v0, file_error
    move $s7, $v0      # File descriptor

    li $s0, 0          # User index counter (i)
    lw $s4, userCount  # Total users

write_loop:
    bge $s0, $s4, write_done
    
    # Reset buffer for each user line
    la $s1, buffer     # $s1 points to current position in buffer

    # --- Process CNIC ---
    la $t0, CNICarray
    sll $t6, $s0, 2    # Offset = i * 4
    add $t0, $t0, $t6
    lw $a0, 0($t0)     # Get CNIC value
    move $a1, $s1      # Pass current buffer pointer
    jal int_to_string
    add $s1, $s1, $v0  # Move buffer pointer by length of string

    li $t4, ' '        # Add Space
    sb $t4, 0($s1)
    addi $s1, $s1, 1

    # --- Process PIN ---
    la $t0, PINarray
    sll $t6, $s0, 2
    add $t0, $t0, $t6
    lw $a0, 0($t0)     # Get PIN value
    move $a1, $s1
    jal int_to_string
    add $s1, $s1, $v0

    li $t4, ' '        # Add Space
    sb $t4, 0($s1)
    addi $s1, $s1, 1

    # --- Process BALANCE ---
    la $t0, BALarray
    sll $t6, $s0, 2
    add $t0, $t0, $t6
    lw $a0, 0($t0)     # Get Balance value
    move $a1, $s1
    jal int_to_string
    add $s1, $s1, $v0

    li $t4, '\n'       # Add Newline
    sb $t4, 0($s1)
    addi $s1, $s1, 1

    # --- Write the constructed line to file ---
    li $v0, 15
    move $a0, $s7      # File descriptor
    la $a1, buffer     # Buffer start
    sub $a2, $s1, $a1  # Length = CurrentPointer - BufferStart
    syscall

    addi $s0, $s0, 1   # Next user
    j write_loop

write_done:
    # Close file
    li $v0, 16
    move $a0, $s7
    syscall
    
    li $v0, 4
    la $a0, msg_goodbye
    syscall
    
    li $v0, 10
    syscall

# INT_TO_STRING SUBROUTINE 

int_to_string:
    # Input: $a0 = integer, $a1 = target buffer address
    # Output: $v0 = length of string created
    move $t0, $a1      # Save start address
    li $t1, 10
    li $t2, 0          # Digit counter
    
    # Zero case
    bnez $a0, convert_loop
    li $t3, '0'
    sb $t3, 0($a1)
    li $v0, 1
    jr $ra

convert_loop:
    beqz $a0, reverse_prep
    divu $a0, $t1
    mflo $a0
    mfhi $t3
    addi $t3, $t3, '0'
    sb $t3, 0($a1)     # Store digits in reverse first
    addi $a1, $a1, 1
    addi $t2, $t2, 1
    j convert_loop

reverse_prep:
    move $v0, $t2      # Set return length
    move $t3, $t0      # Start of string
    move $t4, $a1
    addi $t4, $t4, -1  # End of string
    
reverse_loop:
    bge $t3, $t4, reverse_done
    lb $t5, 0($t3)
    lb $t6, 0($t4)
    sb $t5, 0($t4)
    sb $t6, 0($t3)
    addi $t3, $t3, 1
    addi $t4, $t4, -1
    j reverse_loop

reverse_done:
    jr $ra

#################################################
file_error:
    li $v0,4
    la $a0,msg_file_error
    syscall

exit_prog:
    li $v0,10
    syscall
