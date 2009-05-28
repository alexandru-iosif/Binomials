-- -*- coding: utf-8 -*-
--  cyclotomic.m2
--
--  Copyright (C) 2009 Thomas Kahle <kahle@mis.mpg.de>
--
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or (at
--  your option) any later version.
--
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
--
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

newPackage(
	"Cyclotomic",
    	Version => "0.2", 
    	Date => "May 2009",
    	Authors => {{Name => "Thomas Kahle", 
		  Email => "kahle@mis.mpg.de", 
		  HomePage => "http://personal-homepages.mis.mpg.de/kahle/"}},
    	Headline => "routines for cyclotomic fields",
    	DebuggingMode => true
    	)

export {cyclotomicField,
        cyclotomicPoly,
	findRootPower
       }

cyclotomicField = (i,R) -> (
     -- Given a ring R, and a power i, the cyclotomic field is returned
     return toField (R / sub (ideal(cyclotomicPoly (i,R_0)) ,R));
     )

cyclotomicPoly = (i,v) -> (
     -- returns the i-th cyclotomic polynomial in variable v.
     -- v must be a variable a priori
     v = value v;
     if i <= 0 then error "the input should be > 0.";
     if i==1 then return v-1 ;
     min := v^i -1;
     -- dividing out the first cylcotomic polynomial
     -- (with result a polynomial)
     min = (flatten entries syz matrix {{min ,(v-1)}})#1; 

     -- i is prime:
     if isPrime i then return min / (leadCoefficient min);
     
     -- i is not prime:
     -- find the divisors:
     for f in toList (2..i//2) do (
	  -- check for factor
	  if i%f == 0 then (
	       fac := cyclotomicPoly (f,v);
	       -- print fac;
	       -- division with result in polynomial ring:
	       min = (flatten entries syz matrix {{min,fac}})#1;
	       )
	  );
     --make sure the leading coefficient is one.
     min=min / leadCoefficient(min);            
     return(min);                        
)

findRootPower = R -> (
     -- Finds the power of the adjoined root of unity in the
     -- coefficient ring of R by just exponentiating.
     -- Returns '2' if the input was a polynomial ring over QQ
     r := 0;
     F := coefficientRing R;
     g := gens F;
     if #g == 0 then return 2;
     if #g > 1 then error "The coefficient field has more than one generator";
     g = value (g#0);
     gg := g; -- the generator
     while not 1_F == gg do (
	  r = r+1;
	  gg = gg *g;
	  );
     if r<2 then return 2
     else return r+1;
     )

-- End of source code ---

beginDocumentation()


document { 
        Key => Cyclotomic,
        Headline => "a package for cyclotomic fields",
        EM "Cyclotomic", " is a package for cyclotomic fields."
        }

document {
     Key => {cyclotomicField},
     Headline => "Cyclotomic Field Construction",
     Usage => "cyclotomicField (i,R)",
     Inputs => {
          "i" => { "an integer, the power of the root to be adjoined."},
	  "R" => { "a polyomial ring in one variable, the name whose variable will be the name of the adjoined root."} },
     Outputs => {
          "S" => {"A cyclotomic field with $1^(1/s)$ adjoined"} },
     EXAMPLE {
          "R = QQ[ww]",
          "S = cyclotomicField (5,R)",
	  "isField S",
	  "(ww^9, ww^10, ww^11)",
          "T = S[x,y]",
     	  "I = ideal (x-ww)",
	  "dim I"
          },
     Caveat => {"Strange things can happen with the reduction of the coefficients."},
     SeeAlso => cyclotomicPoly
     }

document {
     Key => {cyclotomicPoly},
     Headline => "Cyclotomic Polynomial",
     Usage => "cyclotomicPoly (i,v)",
     Inputs => {
          "i" => { "an integer, the power of a root of unity."},
	  "v" => { "a variable name in which the polynomial is returned."} },
     Outputs => {
          "f" => {"The minimal polynomial of the i-th root of unity."} },
     EXAMPLE {
          "R = QQ[ww]",
          "f = cyclotomicPoly (6,ww)",
          },
     SeeAlso => cyclotomicField
     }

document {
     Key => {findRootPower},
     Headline => "Find the order of the root in the coefficients of polynomial ring over a cyclotomic field",
     Usage => "findRootPower R",
     Inputs => {
          "R" => { "a polynomial ring over a cyclotomic field"}},
     Outputs => {
          "i" => {"The order of the adjoined root of unity."} },
     EXAMPLE {
	  "R = QQ[ww]",
          "S = cyclotomicField (5,R)",
          "T = S[x,y]",
     	  "findRootPower T"
          },
     SeeAlso => cyclotomicField
     }
