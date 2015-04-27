; RUN: firrtl -i %s -o %s.flo -x abcdefghijklm -p c | tee %s.out | FileCheck %s

;CHECK: Inline Instances
circuit top :
   module subtracter :
      input x : UInt
      input y : UInt
      output q : UInt
      q := sub-wrap-uu(x, y)
   module gcd :
      input a : UInt<16>
      input b : UInt<16>
      input e : UInt<1>
      output z : UInt<16>
      output v : UInt<1>
      reg x : UInt
      reg y : UInt
      on-reset x := UInt(0)
      on-reset y := UInt(42)
      when gt-uu(x, y) :
         inst s of subtracter
         s.x := x
         s.y := y
         x := s.q
      else :
         inst s2 of subtracter
         s2.x := x
         s2.y := y
         y := s2.q
      when e :
         x := a
         y := b
      v := eq-uu(v, UInt(0))
      z := x
   module top :
      input a : UInt<16>
      input b : UInt<16>
      output z : UInt
      inst i of gcd
      i.a := a
      i.b := b
      i.e := UInt(1)
      z := i.z

; CHECK: Finished Inline Instances