pair sqrt(explicit pair z)
{
  return sqrt(abs(z))*expi(angle(z,false)/2);
}

struct laguer {
  pair x;
  int its;
}

real EPS=10*realEpsilon;
laguer laguer(pair[] a, int m=a.length-1, pair x)
{/*
   Given the degree 'm' and 'm+1' complex coefficients a[0...m] of polynomial sum(a[i]*x^i),
   and given a complex value "x", this routine improves 'x' by Laguerre's method until it converges to a root of the given polynomial. The value of x found and the number of iterations taken is returned as 'laguer' structure.
   Adapted from http://www.nrbook.com/a/bookcpdf/c9-5.pdf
 */

  static real MR=8, MT=10, MAXIT=MT*MR;
  int its;
  laguer ol;
  real[] ret;
  int iter,j;
  real abx,abp,abm,err;
  pair dx,x1,b,d,f,g,h,sq,gp,gm,g2,ox=x;
  static real[] frac={0, 0.5, 0.25, 0.75, 0.13, 0.38, 0.62, 0.88, 1};

  laguer ret(){
    ol.x=x;
    ol.its=its;
    return ol;
  }
  for (iter=1; iter <= MAXIT ; ++iter) {
    its=iter;
    b=a[m];
    err=abs(b);
    d=(0,0); f=d;
    abx=abs(x);
    for (int j=m-1; j >=0 ; --j) {
      f=x*f+d;
      d=x*d+b;
      b=x*b+a[j];
      err=abs(b)+abx*err;
    }
    err *= EPS;
    if(abs(b) <= err) return ret();
    g=d/b;
    g2=g^2;
    h=g2-2*f/b;
    sq=sqrt((m-1)*(m*h-g2));
    gp=g+sq;
    gm=g-sq;
    abp=abs(gp);
    abm=abs(gm);
    if(abp < abm) gp=gm;
    dx=(max(abp,abm) > 0.0) ? (m,0)/gp :
      (1+abx)*(cos(iter),sin(iter));
    x1=x-dx;
    if(x.x == x1.x && x.y == x1.y) return ret();
    if(iter%MT == 0) x=x1;
    else x=x-frac[floor(iter/MT)]*dx;
  }
  abort("Too many iteration in laguer.");
  return ret();
}

pair[] zroots(pair[] a, bool polish=true)
{/*
   Given the complex coefficients a[0...m] of the polynomial sum(a[i]*x^i),
   this routine returns all the complex roots by Laguer's method.
   If 'polish' is true, the roots are polished (also by Laguer's method');
   Adapted from http://www.nrbook.com/a/bookcpdf/c9-5.pdf
 */
  laguer L;
  int m=a.length-1,its=L.its;
  pair[] ad=copy(a);
  pair x=L.x,b,c;
  pair[] roots;
  for (int j=m; j >= 1 ; --j) {
    x=(0,0);
    L=laguer(ad,j,L.x);
    x=L.x; its=L.its;
    if(abs(x.y) <= 2*EPS*abs(x.x)) x=(x.x,0);
    roots[j-1]=x;
    b=ad[j];
    for (int k=j-1; k >= 0 ; --k) {
      c=ad[k];
      ad[k]=b;
      b=x*b+c;
    }
  }

  if(polish) {
    for (int j=0; j < m ; ++j) {
      L.x=roots[j];
      L.its=its;
      L=laguer(a,L.x);
      roots[j]=L.x;
      its=L.its;
    }
  }
  for (int j=0; j < m ; ++j) {
    pair x=roots[j];
    int i;
    for (i=j-1; i >= 0 ; --i) {
      if(roots[i].y == 0) break;
      roots[i+1]=roots[i];
    }
    roots[i+1]=x;
  }
  return roots;
}

real sgn(real a, real b)
{
  return (b == 0) ? abs(a): sgn(b)*abs(a);
}

void hqr(real[][] a, int n, real[] wr=new real[]{}, real[] wi= new real[]{})
{/*
   Finds all eigenvalues of an upper Hessenberg matrix a[1...n][1..n].
   The real and imaginary parts of eigenvalues are returned in wr[1...n] and wi[1...n], respectively.
   Adapted from http://www.nrbook.com/a/bookcpdf/c11-6.pdf
  */
  int nn,m,l,k,j,its,i,mmin;
  real z,y,x,w,v,u,t,s,r,q,p,anorm=0;
  for (i=1; i <= n ; ++i)
    for (j=max(i-1,1); j <= n ; ++j) anorm += abs(a[i][j]);
  nn=n;t=0;
  while(nn >= 1) {
    its=0;
    do {
      for (l=nn; l >= 2 ; --l) {
        s=abs(a[l-1][l-1])+abs(a[l][l]);
        if(s == 0) s=anorm;
        if(abs(a[l][l-1])+s == s) {
          a[l][l-1]=0;
          break;
        }
      }
      x=a[nn][nn];
      if(l == nn) {
        wr[nn]=x+t;
        wi[--nn]=0;
      } else {
        y=a[nn-1][nn-1];
        w=a[nn][nn-1]*a[nn-1][nn];
        if(l == (nn-1)) {
          p=0.5*(y-x);
          q=p^2+w;
          z=sqrt(abs(q));
          x += t;
          if(q >= 0) {
            z=p+sgn(z,p);
            wr[nn-1]=wr[nn]=x+z;
            if(z != 0) wr[nn]=x-w/z;
            wi[nn-1]=wi[nn]=0;
          } else {
            wr[nn-1]=wr[nn]=x+p;
            wi[nn-1]=-(wi[nn]=z);
          }
          nn -= 2;
        } else {
          if(its == 30) abort("Too many iterations in hqr...");
          if(its == 10 || its == 20) {
            t += x;
            for(i=1; i <= nn; ++i) a[i][i] -= x;
            s=abs(a[nn][nn-1])+abs(a[nn-1][nn-2]);
            y=x=0.75*s;
            w= -0.4375*s^2;
          }
          ++its;
          for (m=nn-2; m >= l; --m ) {
            z=a[m][m];
            r=x-z;
            s=y-z;
            p=(r*s-w)/a[m+1][m]+a[m][m+1];
            q=a[m+1][m+1]-z-r-s;
            r=a[m+2][m+1];
            s=abs(p)+abs(q)+abs(r);
            p /= s; q /= s; r /= s;
            if(m == 1) break;
            u=abs(a[m][m-1])*(abs(q)+abs(r));
            v=abs(p)*(abs(a[m-1][m-1])+abs(z)+abs(a[m+1][m+1]));
            if(u+v == v) break;
          }
          for (i=m+2; i <= nn; ++i) {
            a[i][i-2]=0;
            if(i != m+2) a[i][i-3]=0;
          }
          for (k=m; k <= nn-1; ++k) {
            if(k != m) {
              p=a[k][k-1];
              q=a[k+1][k-1];
              r=0;
              if(k != nn-1) r=a[k+2][k-1];
              if((x=abs(p)+abs(q)+abs(r)) != 0) {
                p /= x;
                q /= x;
                r /=x;
              }
            }
            if((s=sgn(sqrt(p^2+q^2+r^2),p)) != 0) {
              if(k == m) {
                if(l != m) a[k][k-1]=-a[k][k-1];
              } else a[k][k-1]=-s*x;
              p += s;
              x=p/s; y=q/s; z=r/s; q /= p; r /= p;
              for (j=k; j <= nn; ++j) {
                p=a[k][j]+q*a[k+1][j];
                if(k != nn-1) {
                  p += r*a[k+2][j];
                  a[k+2][j] -= p*z;
                }
                a[k+1][j] -= p*y;
                a[k][j] -= p*x;
              }
              mmin=nn < k+3 ? nn : k+3;
              for (i=l; i <= mmin; ++i) {
                p=x*a[i][k]+y*a[i][k+1];
                if(k != nn-1) {
                  p += z*a[i][k+2];
                  a[i][k+2] -= p*r;
                }
                a[i][k+1] -= p*q;
                a[i][k] -= p;
              }
            }
          }
        }
      }
    } while(1 < nn-1);
  }
}

real RADIX=8;
void balanc(real[][] a, int n=a[0].length)
{/* Given a matrix 'a[1...n][1..n]', this routine replaces it by a balanced matrix with identical eigenvalues.
    A symmetric matrix is already balanced and is unaffected by this procedure.
    The variable RADIX should be the machine's floating-point radix.
   Adapted from http://www.nrbook.com/a/bookcpdf/c11-5.pdf
  */
  int last=0, j, i;
  real s, r, g, f, c, sqrdx=RADIX^2;
  while(last == 0) {
    last=1;
    for (i=1; i <= n; ++i) {
      r=c=0;
      for (j=1; j <= n; ++j)
        if(j != i) {
          c += abs(a[j][i]);
          r += abs(a[i][j]);
        }
      if(c != 0 && r != 0) {
        g=r/RADIX;
        f=1;
        s=c+r;
        while(c < g) {
          f *= RADIX;
          c *= sqrdx;
        }
        g=r*RADIX;
        while(c > g) {
          f /= RADIX;
          c /= sqrdx;
        }
        if((c+r)/f < 0.95*s) {
          last=0;
          g=1/f;
          for (j=1; j <= n; ++j) a[i][j] *= g;
          for (j=1; j <= n; ++j) a[j][i] *= j;
        }
      }
    }
  }
}

pair[] zroots(real[] a, bool polish=true)
{/* Return all the roots of a polynomial with real coefficients, sum(a[i]x^i).
    The method is to construct an upper Hessenberg matrix whose eigenvalues are
    the desired roots, and the use the routine 'balanc' and 'hqr'.
    If polish is true, root-polishing by Newton-Raphson's method is applied.
    Adapted from http://www.nrbook.com/a/bookcpdf/c9-5.pdf
  */
  int m=a.length-1;
  int j,k;
  real[][] hess=new real[m+1][m+1];
  real[] rtr=sequence(new real(int n){return 0;},m+1),
    rti=sequence(new real(int n){return 0;},m+1);
  real xr,xi;
  if(a[m] == 0) abort("Bad args in zroots.");
  for (k=1; k <= m; ++k) {
    hess[1][k]=-a[m-k]/a[m];
    for(j=2; j <= m; ++j) hess[j][k]=0;
    if(k != m) hess[k+1][k]=1;
  }
  balanc(hess,m);
  hqr(hess,m,rtr,rti);
  for (j=2; j <= m; ++j) {
    xr=rtr[j];
    xi=rti[j];
    for (k=j-1; k >= 1; --k) {
      if(rtr[k] <= xr) break;
      rtr[k+1]=rtr[k];
      rti[k+1]=rti[k];
    }
    rtr[k+1]=xr;
    rti[k+1]=xi;
  }
  pair[] roots=sequence(new pair(int n){return (rtr[n],rti[n]);},m+1);
  roots.delete(0);
  return roots;
}
