"""
private data: 

New:

__complete_cellular_decomposition - A list
containing binomial cellular ideals whose intersection is the given
ideal

__not_nilpotent_zerodivisors - a list of variables which are
zerodivisors while not nilpotent. Useful during the computation of a
cellular decomposition

__cell_variables - Save the maximal set delta of variables with
respect to which it is cellular(AS A LIST!). If delta is empty the
ideal is not cellular

Inherited:

__complete_primary_decomposition - A sequence of primary binomial
ideals whose intersection is the given ideal

__dimension - Vector space dimension of the ring modulo the ideal

__gb_singular - Groebnerbasis in Singular format

__singular - Singular Representation of the Ideal?

"""

from sage.rings.polynomial.multi_polynomial_ideal import MPolynomialIdeal

class BinomialIdeal(MPolynomialIdeal):
    def __init__(self, ring, gens, coerce=True):
        MPolynomialIdeal.__init__(self, ring, gens, coerce)
        self.__not_nilpotent_zerodivisors = []
        self.__cel_variables = []
        self.__singular_rep =  self._singular_()

    def __varsat (self, var):
        """
        Computes the saturation of an ideal with respect to 
        variable 'var' and returns also the necessary exponent
        """
        sat = self.__singular_rep.sat(var)
        return (BinomialIdeal(self.ring(),list(sat[1])),sat[2])
    # Old and slow implementation
#        I2 = 0 * R
#        l = 0 
#        while I2 != I:
#           I2 = I
#           l = l+1
#           I = I.quotient(var * R)
#        return (I,l-1)
    # End of varsat function

    def is_cellular (self):
        r""" This function tests whether a the ideal is cellular.  In
        the affirmative case it saves the largest subset of variables
        such that I is cellular.  In the negative case a variable
        which is a zerodivisor but not nilpotent is found.

        EXAMPLE :

        
        
        ALGORITHM: A1 in CS[00]

        """

        # Check if we did the computation already instead of setting it to zero!
        self.__not_nilpotent_zerodivisors = []

        R = self.ring()
        if self == 1*R:
            # print("The ideal is the whole ring and not cellular")
            return false

        ring_variables = list(R.gens())

        bad_variables = []

        for x in ring_variables:
            if self.__varsat(x)[0] == 1*R :
                bad_variables = bad_variables + [x]

        # We should use a list comprehension here !
        # self.__cell_variables = [x for x in ring_variables if x not in bad_variables] 
        # Seems to be slow :(

        self.__cell_variables = ring_variables
        for x in bad_variables:
            self.__cell_variables.remove(x)

        # print ("Here are the cell variables:")
        # print (self.__cell_variables)

        varprod = 1
        for x in self.__cell_variables:
            varprod = varprod * x
        # print(varprod)
        J = self.__varsat(varprod)[0]

        # print ("This is the full saturation with respect to the good variables")
        # print (str(J))

        if self == J:
           # print ("The ideal is cellular with respect to the cell variables:")
           # print (self.__cell_variables)
           return true
        else:
            # It should suffice to find one not-nilp-zd
            for x in self.__cell_variables:
                # print (self)
                # print (self.quotient(x*R))
                if self != self.quotient(x*R):
                    # print ('The variable',x,' is a zerodvisior but not nilpotent.' )
                    self.__not_nilpotent_zerodivisors += [x]

            # print (self.__not_nilpotent_zerodivisors)
            return false           


    def cellular_decomposition(self):
        r""" 
        Returns a list of cellular ideals such that their
        intersection is $I$ = \code{self}.

        EXAMPLES:
        sage: R = QQ['x1,x2,x3,x4,x5']
        sage: (x1,x2,x3,x4,x5) = R.gens()
        sage: I = BinomialIdeal(R,(x1*x4^2 - x2*x5^2,  x1^3*x3^3 - x4^2*x2^4,  x2*x4^8 - x3^3*x5^6))
        sage: I.cellular_decomposition()

        [Ideal (x1*x4^2 - x2*x5^2, x1^3*x3^3 - x2^4*x4^2, x2^3*x4^4 - x1^2*x3^3*x5^2, x2^2*x4^6 - x1*x3^3*x5^4, x2*x4^8 - x3^3*x5^6) of Multivariate Polynomial Ring inx1, x2, x3, x4, x5 over Rational Field,
        Ideal (x1*x4^2 - x2*x5^2, x1^3*x3^3 - x2^4*x4^2, x2^3*x4^4 - x1^2*x3^3*x5^2, x2^2*x4^6 - x1*x3^3*x5^4, x2*x4^8 - x3^3*x5^6) of Multivariate Polynomial Ring inx1, x2, x3, x4, x5 over Rational Field]

        ALGORITHM: A2 in CS[00]
        
        REFERENCES: 
        CS[00] Castilla/Sanchez 'Cellular Binomial Ideals. 
                  Primary Decomposition of Binomial Ideals"
        """
        
        try:
            return self.__complete_cellular_decomposition
        except AttributeError:
            self.__complete_cellular_decomposition = {}
        except KeyError:
            pass
        
        V = []
        # The computation starts here 
        if self.is_cellular():
            V += [self]
            # print ("achtung :")
            # print (V)
        else:
            badvar = self.__not_nilpotent_zerodivisors[0]
            # print("Choice of added variable:")
            # print(badvar)

            (J,l) = self.__varsat(badvar)
            # print(J,l)
            # Start a recursion

            # print ("The variable and exponent are :")
            # print (badvar, l)

            # If l is zero, K is the whole ring and M is already there
            if l != 0: 
                K = BinomialIdeal(R, list(self.gens()) + [badvar^l])
                if K != 1*R:
                    # print ("The sum Ideal:")
                    # print (K)
                    # print ("is not the full ring -> recurse")
                    V += K.cellular_decomposition()
                if J != 1*R:
                    # print (J)
                    # print ("is not the full ring -> recurse")
                    V += J.cellular_decomposition()

        # Finished the true computation 

        # Shall we invest computing time to return standard bases???
        self.__complete_cellular_decomposition = V
        return self.__complete_cellular_decomposition
    
    
"""
The Algorithm:
Starting from a binomial ideal
1) Compute a Cellular Decomposition
2) Compute primary decompositions of the cellular ideals
"""
