//
// This file is for circuit setup for Groth16
//
// * Receives alpha, beta, gamma, delta
// * Computes Fixed pairing of alpha and negative beta
// * Computes negative gamma, negative delta
// * Computes line functions for gamma, delta miller steps
//
// Returns
// * e(neg alpha, beta)
// * negative gamma, (negative negative) gamma
// * line functions array for gamma
// * negative delta, (negative negative) delta
// * line functions array for delta
//
// Then verification can be done as,
// e(a, b) * e_neg_alpha_beta * e(k, neg gamma) * e(c, neg delta) == 1
//

