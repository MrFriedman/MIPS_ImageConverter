.data
fileName: .asciiz "C:/Users/dylan/OneDrive/Desktop/CSC2002S_Architecture_Assignment/input.ppm"
tofileName: .asciiz "C:/Users/dylan/OneDrive/Desktop/CSC2002S_Architecture_Assignment/output.ppm"
text_buffer: .space 65000
b_buffer: .space 65000
s_buffer: .space 10
string_buffer: .space 20
newline: .asciiz "\n"
avg_value_message_old: .asciiz "Average pixel value of the original image:\n"
avg_value_message_new: .asciiz "Average pixel value of the new image:\n"

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
    move $t3, $zero         # t3 - number of bytes read
    move $s1, $zero         # s1 - counter for pixels
    move $s2, $zero         # s2 - counter for edited pixels

# Now we have all content of testimagine in text_buffer - Need to interate thru and change values
# ? How can we copy the first 3 lines - store_header  
# ? How can we interate over (line 3 # * # times) & update value & check value is <256 & store value

move_header:

    beq $t3, 19, end_move_header
    lb $t4, 0($t0)          # load byte from file
    sb $t4, 0($t1)          # store byte in b_buffer - doesnt need editing
    addi $t0, $t0, 1        # increment file pointer
    addi $t1, $t1, 1        # increment b_buffer pointer
    addi $t3, $t3, 1        # increment number of bytes reads
    j move_header           # iterates over first 19 characters putting them into b_buffer

end_move_header:

    li $t9, 10
    move $t6, $zero         # initialize number of lines t6 to 0

main_loop:                  

    beq $t6, 12288, end_main_loop # iterate over 12292 lines - first 4 = 12288 lines 
    
    lb $t4, 0($t0)          # load byte pointed at from file to t4
    sb $t4, 0($t2)          # store byte in t4 in s_buffer - needs editing

    addi $t0, $t0, 1        # increment file pointer
    addi $t2, $t2, 1        # increment s_buf pointer
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
    add $s1, $s1, $t5       # Add the integer t5 to s1
    addi $t5, $t5, 10       # Increase the brightness by 10
    bge $t5, 255, clamp
    j dont_clamp

clamp:
    li $t5, 255
    j dont_clamp

dont_clamp:
 # Initialize for Integer to String Conversion
    add $s2, $s2, $t5        # Add the integer + 10 to s2(sum of buffed pixels) 
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
    addi $t3, $t3, 1
    addi $s7, $s7, 1
    addi $t1, $t1, 1
    j write_b_buffer

end_write_b_buffer:

    lb $t5, newline
    sb $t5, 0($t1)
    addi $t1, $t1, 1
    addi $t3, $t3, 1
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
    move $a2, $t3           # length of the toWrite string
    syscall

    # MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    li $v0, 16              # close_file syscall code
    move $a0, $s3           # file descriptor to close
    syscall

exit:

    mtc1 $s1, $f2
    mtc1 $s2, $f3
    mtc1 $t6, $f6 

    div.s $f5, $f2, $f6
   # div.s $f5, $f2, 255
    div.s $f7, $f3, $f6
   # div.s $f7, $f2, 255

    li $v0, 4
    la $a0, avg_value_message_old       # Print the result for the old image 
    syscall

    li $v0, 2
    mov.s $f12, $f5  # Load old result into $f12 for printing
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 4
    la $a0, avg_value_message_new     # Print result for the new image 
    syscall

    li $v0, 2
    mov.s $f12, $f7  # Load new result into $f12 for printing
    syscall

    li $v0, 10
    syscall