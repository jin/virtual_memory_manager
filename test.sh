#!/bin/bash
ruby app.rb --config test_files/initialization.txt --input test_files/input-vaddrs.txt > test_files/A0111764L_1.txt 
ruby app.rb --config test_files/initialization.txt --input test_files/input-vaddrs.txt --enable-tlb > test_files/A0111764L_2.txt

# ruby app.rb --config test_files/jermynInput1.txt --input test_files/jermynInput2.txt > test_files/A0111764L_1.txt 
# ruby app.rb --config test_files/jermynInput1.txt --input test_files/jermynInput2.txt --enable-tlb > test_files/A0111764L_2.txt
