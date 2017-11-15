Test code

### 1. Partial Sum(loop)
This function is for summing the numbers from a0(first parameter) to a1(second parameter).
If a1 is smaller than a0, it returns 0.
This function uses the instructions of J, JR, JAL, BNE, ADDI, ADD, SLT.

Test case
 i) (a<sub>0</sub>, a<sub>1</sub>) = (-222, 224) : 447(0x21)
 ii) (a<sub>0</sub>, a<sub>1</sub>) = (6691‬, 66910) : 0(0x00)
 iii) (a<sub>0</sub>, a<sub>1</sub>) = (83798, 83798) : 83798(0x00014756)

Expected Result:
 The value of $t7(register 15) should be 0x00003410

### 2. Partial Sum(recursion)
The purpose of this function is same with (1). The implementation is different. It uses recursion
This function uses the instructions of SW, LW, JR, JAL, BNE, ADDI, ADD, SLT.

Expected Result: same with (1)
 The value of $t7(register 15) should be 0x00003410

### 3. Simple Subtraction
Initialize register $a0 with 3 and $a1 with 1. Apply subtraction operation with $a0 and $1 and save the result to $t0. Confirm that the saved value of $t0 at the end of the program is 2.

### 4. Simple xori
Initialize register $a0 with value d1010. Apply xori operation with $a0 and d0011 and save the result in $t0. Confirm that the saved value of $t0 at the end of the program is h000003fb.
