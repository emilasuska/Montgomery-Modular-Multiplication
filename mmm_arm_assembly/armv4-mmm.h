#ifndef _armv4_mmm_h_
#define _armv4_mmm_h_

void MontgomeryProductInPlace(
	unsigned int *a,  // write result back to a
	const unsigned int *b,
	const unsigned int *n,
	unsigned int w,  // must be >= 3
	unsigned int np0
);

void MontgomerySquareInPlace(
	unsigned int *a,  // write result back to a
	const unsigned int *n,
	unsigned int w,  // must be >= 3
	unsigned int np0
);

void MontgomeryProduct(
	unsigned int *d,  // cannot be same as a, b, or n
	const unsigned int *a,
	const unsigned int *b,
	const unsigned int *n,
	unsigned int w,  // must be >= 3
	unsigned int np0
);

#endif // _armv4_mmm_h_
