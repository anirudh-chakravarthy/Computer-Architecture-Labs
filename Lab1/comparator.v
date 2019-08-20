module comparator(a,b,c):
	input [3:0]a, [3:0]b;
	output [2:0]c;
	wire d3,d2,d1,d0; // for xnor
	wire e1, e0; // for equality
	wire s3,s2,s1,s0; // negation of a
	wire t3,t2,t1,t0; // negation of b
	wire g3,g2,g1,g0; // for intermediary steps of greater
	wire l3,l2,l1,l0; // for intermediary steps of lesser
	wire p3,p2,p1,p0;
	
	not na0(s0, a[0]);
	not na1(s1, a[1]);
	not na2(s2, a[2]);
	not na3(s3, a[3]);
	
	not nb0(t0, b[0]);
	not nb1(t1, b[1]);
	not nb2(t2, b[2]);
	not nb3(t3, b[3]);
	
	xnor xn0(d0, a[0], b[0]);
	xnor xn1(d1, a[1], b[1]);
	xnor xn2(d2, a[2], b[2]);
	xnor xn3(d3, a[3], b[3]);
	
	and a0(p0, d3, d2);
	and a1(p1, p0, d1);
	
	// equality
	and ae0(e0, d1, d0);
	and ae1(e1, d2, d3);
	and ae2(c[2], e0, e1);
	
	// lesser
	and al0(l0, s0, b[0]);
	and al1(l1, s1, b[1]);
	and al2(l2, s2, b[2]);
	and al3(l3, s3, b[3]);
	
	// greater
	and ag0(g0, a[0], t0);
	and ag1(g1, a[1], t1);
	and ag2(g2, a[2], t2);
	and ag3(g3, a[3], t3);