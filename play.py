'''
Polynomial long division

From http://stackoverflow.com/questions/26173058/division-of-polynomials-in-python

A polynomial is represented by a list of its coefficients, eg
5*x**3 + 4*x**2 + 1 -> [1, 0, 4, 5]

Modified by PM 2Ring 2014.10.03
'''

def normalize(poly):
  while poly and poly[-1] == 0:
    poly.pop()
  if poly == []:
    poly.append(0)


"""
  Performs long polynomial division on polynomials A and B.

  Args:
  num: The numerator polynomial as an array of integer coefficients.
  den: The denominator polynomial as an array of integer coefficients.

  Returns:
  (Q, R): The quotient and remainder polynomials as arrays of integer coefficients.
"""
def poly_divmod(num, den):
  #Create normalized copies of the args
  normalize(num)
  normalize(den)

  if len(num) >= len(den):
    #Shift den towards right so it's the same degree as num
    shiftlen = len(num) - len(den)
    den = [0] * shiftlen + den
  else:
    return [0], num

  quot = []
  divisor = float(den[-1])
  for i in xrange(shiftlen + 1):
    #Get the next coefficient of the quotient.
    mult = num[-1] / divisor
    quot = [mult] + quot

    #Subtract mult * den from num, but don't bother if mult == 0
    #Note that when i==0, mult!=0; so quot is automatically normalized.
    if mult != 0:
      d = [mult * u for u in den]
      num = [u - v for u, v in zip(num, d)]

    num.pop()
    den.pop(0)

  normalize(num)
  return quot, num