; RUN: firrtl -i %s -o %s.v -X verilog -p ck 2>&1 | tee %s.out | FileCheck %s

; CHECK: Resolve Kinds
circuit top :
   module subtracter :
      input x : UInt
      input y : UInt
      output z : UInt
      z <= tail(sub(x, y),1)
      ;CHECK: z@<k:port> <= tail(sub(x@<k:port>, y@<k:port>)@<k:exp>, 1)@<k:exp>   
   module gcd :
      input clk : Clock
      input reset : UInt<1>
      input a : UInt<16>
      input b : UInt<16>
      input e : UInt<1>
      output z : UInt<16>
      output v : UInt<1>
      reg x : UInt,clk with :
         reset => (reset,UInt(0))
      reg y : UInt,clk with :
         reset => (reset,UInt(42))
      when gt(x, y) :
         inst s of subtracter
         s.x <= x
         ;CHECK: s@<k:inst>.x@<k:inst> <= x@<k:reg>
         s.y <= y
         x <= s.z
      else :
         inst s2 of subtracter
         s2.x <= x
         s2.y <= y
         y <= s2.z
      when e :
         x <= a
         y <= b
      v <= eq(v, UInt(0))
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
      ;CHECK: z@<k:port> <= i@<k:inst>.z@<k:inst>
; CHECK: Finished Resolve Kinds


