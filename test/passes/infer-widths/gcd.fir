; RUN: firrtl -i %s -o %s.v -X verilog -p ctd 2>&1 | tee %s.out | FileCheck %s

;CHECK: Infer Widths
circuit top :
   module subtracter :
      input x : UInt
      input y : UInt
      output q : UInt
      q <= tail(sub(x, y),1)
   module gcd :
      input a : UInt<16>
      input b : UInt<16>
      input e : UInt<1>
      input clk : Clock
      input reset : UInt<1>
      output z : UInt<16>
      reg x : UInt,clk with :
         reset => (reset,UInt(0))
      reg y : UInt,clk with :
         reset => (reset,UInt(42))
      when gt(x, y) :
         inst s of subtracter
         s.x <= x
         s.y <= y
         x <= s.q
      else :
         inst s2 of subtracter
         s2.x <= x
         s2.y <= y
         y <= s2.q
      when e :
         x <= a
         y <= b
      z <= x
   module top :
      input a : UInt<16>
      input b : UInt<16>
      input clk : Clock
      input reset : UInt<1>
      output z : UInt
      inst i of gcd
      i.a <= a
      i.b <= b
      i.clk <= clk
      i.reset <= reset
      i.e <= UInt(1)
      z <= i.z

; CHECK: Finished Infer Widths
