.data
fileName: .asciiz "C:/Users/dylan/OneDrive/Desktop/CSC2002S_Architecture_Assignment/input.ppm"
tofileName: .asciiz "C:/Users/dylan/OneDrive/Desktop/CSC2002S_Architecture_Assignment/output.ppm"
text_buffer: .space 65000
b_buffer: .space 65000
s_buffer: .space 10
string_buffer: .space 20
newline: .asciiz "\n"

.text
.globl main

main:

read_file:

    li $v0, 13              # open_file syscall code = 13
    la $a0, fileName        # get the file name
    li $a1, 0               # file flag = read (0)          file flag: 0 = read file    1 = write file
    syscall      
    move $s0, $v0
                                                               
    # read the file
    li $v0, 14              # read_file syscall code = 14
    move $a0, $s0           # save the file descriptior $s0 = file
    la $a1, text_buffer     # allocate space for the bytes loaded
    li $a2, 65000           # number of bytes to be read
    syscall 

    # Close the file
    li $v0, 16              # close_file syscall code
    move $a0, $s0           # file descriptor to close
    syscall

    # initialise registers
    move $t0, $a1           # t0 - pointer to the file (text_buffer)
    la $t1, b_buffer        # t1 - pointer to b_buffer 
    la $t2, s_buffer        # t2 - pointer to s_buffer
    move $t3, $zero         # t3 - number of pixels read
    move $s1, $zero         # s1 - counter for pixels
    move $s2, $zero         # s2 - counter for edited pixels
    la $t7, 19

move_header:

    beq $t3, 1, change_type
    beq $t3, 19, end_move_header
    lb $t4, 0($t0)          # load byte from file
    sb $t4, 0($t1)          # store byte in b_buffer - doesnt need editing
    addi $t0, $t0, 1        # increment file pointer
    addi $t1, $t1, 1        # increment b_buffer pointer
    addi $t3, $t3, 1        # increment number of bytes reads
    j move_header           # iterates over first 19 characters putting them into b_buffer

change_type:                # Change P"3" to P"2"
    lb $t4, 0($t0)
    li $t8, 50              # ASCII for 2
    sb $t8, 0($t1)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    j move_header

end_move_header:

    move $t3, $zero     # t3 - number of pixels read
    move $t9, $zero     # t9 - counter of summed pixels
    move $s6, $zero     # s6 - running counter of pixels
    move $t6, $zero

main_loop:                  

    beq $t6, 12288, end_main_loop # iterate over 12292 lines - first 4 = 12288 lines 
    
    lb $t4, 0($t0)          # load byte pointed at from file to t4
    sb $t4, 0($t2)          # store byte in t4 in s_buffer - needs editing

    addi $t0, $t0, 1        # increment file pointer
    addi $t2, $t2, 1        # increment s_buf pointer
    addi $t3, $t3, 1        # incrememnt line counter
    beq $t4, 13, edit_pixel # When reached end of the line = edit the pixel (interger)
    j main_loop
# Note: t series = dont need to be saved when changing function
edit_pixel:
    addi $t6, $t6, 1        # inc number of lines
    li  $s4, 13
    li  $s5, 10
    li  $s7, 48 
    la $t2, s_buffer

start_str_int_loop:
    move $t5, $zero         # initialise complete integer buffer t5 to 0

str_int_loop:
    lb $s0, 0($t2)
    addi $t2, $t2, 1
    beq $s0, $s4, end_str_int_loop
    sub $s3, $s0, $s7
    mul $t5, $t5, $s5
    add $t5, $t5, $s3
    j   str_int_loop

end_str_int_loop:
      
    add $s6, $s6, $t5       # Add the calculated value in $t5 to the running sum in $s6   
    addi $t9, $t9, 1        # Increment the counter in $t9 for tracking the number of values added  

    bne $t9, 3, cleanup_before_main  
    j average

cleanup_before_main:

    la $t2, s_buffer      
    j main_loop

average:
    move $t9, $zero         # Reset the counter $t9 to zero      

    div $s2, $s6, 3         # Divide the sum in $s6 by 3, representing the average
    move $s6, $zero         # Reset the running sum to zero
    mflo $t5                # Move the result of the division to $t5 (the average value)

   # Initialize variables
    la $a0, string_buffer   # Load the address of the result string
    li $a2, 10              # Load 10 (base 10)
    sb $zero, ($a0)         # Null-terminate the string
    addi $a0, $a0, 10       # Move to the end of the string



convert_loop:               # Convert back to string - calculate the remainder (digit) and quotient

    div $t5, $a2            # t5 (completed integer) divided by 10
    mflo $s5                # s5 - Quotient of division
    mfhi $s4                # s4 - Remainder of division

# Need to convert back to string (ASCII) and store in string_buffer
    addi $s4, $s4, 48       # Convert to ASCII
    sb $s4, -1($a0)         # Store the digit in the string

    addi $a0, $a0, -1
    beqz $s5, end_convert   # If quotient = zero then end of conversion
    move $t5, $s5           
    j convert_loop          # Else cont looping

end_convert:
    move $s7, $a0

write_b_buffer:

    lb $t5, 0($s7)
    beq $t5, $zero, end_write_b_buffer
    sb $t5, 0($t1)
    addi $s7, $s7, 1
    addi $t7, $t7, 1
    addi $t1, $t1, 1
    j write_b_buffer

end_write_b_buffer:

    lb $t5, newline
    sb $t5, 0($t1)
    addi $t1, $t1, 1
    addi $t7, $t7, 1
    la $t2, s_buffer
    j main_loop

end_main_loop:

write_file:
    # open file
    li $v0, 13              # open_file syscall code = 13
    la $a0, tofileName      # get the file name
    li $a1, 1               # file flag = write (1)
    syscall
    move $s3, $v0          

    # Write the file
    li $v0, 15              # write_file syscall code = 15
    move $a0, $s3           # file descriptor
    la $a1, b_buffer        # the string that will be written
    move $a2, $t7           # length of the toWrite string
    syscall

    # MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    li $v0, 16              # close_file syscall code
    move $a0, $s3           # file descriptor to close
    syscall

exit:

    li $v0, 10
    syscall