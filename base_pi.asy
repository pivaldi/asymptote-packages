// Copyright (c) 2007, Philippe Ivaldi.
// Version: $Id: base_pi.asy,v 0.0 "2007/01/27 10:35:52" Philippe Ivaldi Exp $
// Last modified: Sun Oct 14 22:36:12 CEST 2007

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or (at
// your option) any later version.

// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
// 02110-1301, USA.

// Commentary:

// THANKS:

// BUGS:

// INSTALLATION:

// Code:

import math;

pair userMin(picture pic=currentpicture){return (pic.userMin().x,pic.userMin().y);}
pair userMax(picture pic=currentpicture){return (pic.userMax().x,pic.userMax().y);}

// *=======================================================*
// *.......................Structures......................*
// *=======================================================*
/*<asyxml><variable type="guide" signature="Straight(... guide[])"><code></asyxml>*/
guide Straight(... guide[])=operator --;/*<asyxml></code><documentation></documentation></variable></asyxml>*/
/*<asyxml><variable type="guide" signature="Spline(... guide[])"><code></asyxml>*/
guide Spline(... guide[])=operator ..;/*<asyxml></code><documentation></documentation></variable></asyxml>*/

typedef guide interpolate(... guide[]);

/*<asyxml><struct signature="rational"><code></asyxml>*/
struct rational
{/*<asyxml></code><documentation>
   'p' est le numérateur, 'q' est le dénominateur.
   'ep' est la précision avec laquelle le rationnel a été obtenu dans
   le cas où il y convertion à partir d'un irrationnel.
   ..................................................
   'p' is the numerator, 'q' is the denominator.
   'ep' is the precision with which the rational was obtained in the case of a
   convertion from irrational.
  </documentation></asyxml>*/
  int p;
  int q;
  real ep;
}/*<asyxml></struct></asyxml>*/

rational operator init() {return new rational;}

/*ANCrational(real,real)ANC*/
/*<asyxml><function type="rational" signature="rational(real,real)"><code></asyxml>*/
rational rational(real x, real ep=1/10^5)
{/*<asyxml></code><documentation>Retourne le rationnel qui approxime 'x' tel que 'abs(p/q-x)<=ep'.
   ..................................................
   Return the rational which approximates 'x' such as
   'abs(p/q-x)<=ep'.
   </documentation></function></asyxml>*/
  rational orat;
  int q=1;
  while (abs(round(q*x)-q*x)>ep)
    {
      ++q;
    }
  orat.p=round(q*x);
  orat.q=q;
  orat.ep=ep;
  return orat;
}

// *=======================================================*
// *...................Calculus routines...................*
// *=======================================================*
/*<asyxml><function type="int" signature="pgcd(int,int)"><code></asyxml>*/
int pgcd(int a, int b)
{/*<asyxml></code><documentation>Greatest common divisor.</documentation></function></asyxml>*/
  int a_=abs(a), b_=abs(b), r=a_;
  if (b_>a_) {a_=b_; b_=r; r=a_;}
  while (r>0)
    {
      r=a_%b_;
      a_=b_;
      b_=r;
    }
  return a_;
}

/*<asyxml><function type="int" signature="gcd(int,int)"><code></asyxml>*/
int gcd(int a, int b)
{/*<asyxml></code><documentation>Greatest common divisor.</documentation></function></asyxml>*/
  return pgcd(a,b);
}

// *=======================================================*
// *.................Extend point routine..................*
// *=======================================================*
/*<asyxml><function type="pair[]" signature="points(path g,real[])"><code></asyxml>*/
pair[] points(path g, real[] t)
{/*<asyxml></code><documentation>Extend 'point(path, real)' routine to array of 'real'.</documentation></function></asyxml>*/
  pair [] op;
  for (int i=0; i < t.length; ++i) {
    op.push(point(g,t[i]));
  }
  return op;
}

/*<asyxml><function type="pair[]" signature="points(path,int[])"><code></asyxml>*/
pair [] points(path g, int[] t)
{/*<asyxml></code><documentation>Extend 'point(path, int)' routine to array of 'int'.</documentation></function></asyxml>*/
  pair [] op;
  for (int i=0; i < t.length; ++i) {
    op.push(point(g,t[i]));
  }
  return op;
}

// *=======================================================*
// *.........................join..........................*
// *=======================================================*
/*<asyxml><function type="guide" signature="join(pair[],interpolate)"><code></asyxml>*/
guide join(pair[] a, interpolate join=operator --)
{/*<asyxml></code><documentation></documentation></function></asyxml>*/
  guide og;
  for(int i=0; i < a.length; ++i) og=join(og,a[i]);
  return og;
}

// *=======================================================*
// *...................Extend intersect....................*
// *=======================================================*
/*<asyxml><function type="real" signature="intersectp(path,pair,int,real)"><code></asyxml>*/
real intersectp(path g, pair a, int n=1, real fuzz=0)
{/*<asyxml></code><documentation>Retourne le "temps" par rapport à 'g' du premier point
    d'intersection de 'g' avec le plus petit cercle de centre 'a'
    coupant 'g'.
    La précision du découpage peut être augmentée en augmentant 'n'.
    ..................................................
    Return the time along 'g' of the first intersection point of the path
    "g" with the smaller circle centered in 'a' and which is intersecting
    'g'.
    The cutting precision is increased by increasing n.</documentation></function></asyxml>*/
  real r=0;
  real [] ip=intersect(g,(path)a,fuzz);
  while (ip.length < 2)
    {
      r+=1/(50*n);
      ip=intersect(g,shift(a)*scale(r)*unitcircle,fuzz);
    }
  return ip[0];
}

/*<asyxml><function type="real[]" signature="intersectsv(path,real)"><code></asyxml>*/
real[] intersectsv(path p, real x)
{/*<asyxml></code><documentation>Retourne les "temps" par rapport à 'g' de tous les points
    d'intersection de 'g' avec la droite verticale passant par (x,0).
    ..................................................
    Return the times along "g" of all intersection points of the path
    "g" with the vertical line passing by (x,0).</documentation></function></asyxml>*/
  return intersections(p,(x,0),(x,1));
}

/*<asyxml><function type="real[]" signature="intersectsh(path g, real y)"><code></asyxml>*/
real[] intersectsh(path p, real y)
{/*<asyxml></code><documentation>Retourne les "temps" par rapport à 'g' de tous les points
    d'intersection de 'g' avec la droite horizontale passant par (0,y).
    La précision du découpage peut être augmentée en augmentant 'n'.
    ..................................................
    Return the times along 'g' of all intersection points of the path
    'g' with the horizontal line passing by (0,y).</documentation></function></asyxml>*/
  return intersections(p,(0,y),(1,y));
}

/*<asyxml><function type="real[]" signature="intersectsd(path,pair,pair)"><code></asyxml>*/
real[] intersectsd(path g, pair a, pair b)
{/*<asyxml></code><documentation>Retourne les "temps" par rapport à 'g' de tous les points
    d'intersection de la demi-droite [ab) avec 'g'.
    ..................................................
    Return the times along 'g' of all intersection points of the
    half-line from 'a' towards 'b' with the path 'g'.</documentation></function></asyxml>*/
  real[] ot, ott;
  ott=intersections(g,a,b);
  pair ab=b-a;
  for(real t:ott) if(dot(point(g,t)-a,ab) >= 0) ot.push(t);
  return ot;
}


/*<asyxml><function type="pair[]" signature="intersectionpointsv(path,real)"><code></asyxml>*/
pair[] intersectionpointsv(path g, real x)
{/*<asyxml></code><documentation>Retourne tous les points d'intersection de 'g' avec la droite
    verticale passant par (x,0).
    ..................................................
    Return all the intersection points of the path
    "g" with the vertical line passing by (x,0).</documentation></function></asyxml>*/
  return points(g,intersectsv(g,x));
}

/*<asyxml><function type="pair[]" signature="intersectionpointsh(path,real)"><code></asyxml>*/
pair[] intersectionpointsh(path g, real y)
{/*<asyxml></code><documentation>
    Retourne tous les points d'intersection de 'g' avec la droite
    horizontale passant par (0,y).
    ..................................................
    Return all the intersection points of the path
    "g" with the horizontal line passing by (0,y).</documentation></function></asyxml>*/
  return points(g,intersectsh(g,y));/*IDOCpoints(path,real[])IDOC*/
}

/*<asyxml><function type="pair[]" signature="intersectionpointsd(path,pair,pair)"><code></asyxml>*/
pair[] intersectionpointsd(path g, pair a, pair b)
{/*<asyxml></code><documentation>
    Retourne tous les points d'intersection de la demi-droite [ab) avec
    'g'.
    ..................................................
    Return all the intersection points of the
    half-line from 'a' towards 'b' with the path 'g'.</documentation></function></asyxml>*/
  return points(g,intersectsd(g,a,b));
}

/*<asyxml><function type="pair[]" signature="intersectionpoints(path,pair,pair)"><code></asyxml>*/
pair[] intersectionpoints(path g, pair a, pair b)
{/*<asyxml></code><documentation>
    Retourne tous les points d'intersection de la droite (ab) avec
    'g'.
    ..................................................
    Return all the intersection points of the line (ab) with the path
    'g'.</documentation></function></asyxml>*/
  return points(g,intersections(g,a,b));
}

// *=======================================================*
// *.......................Fractions.......................*
// *=======================================================*

/*<asyxml><function type="string" signature="texfrac(int,int,string,bool,bool,bool,bool)"><code></asyxml>*/
string texfrac(int p, int q,
               string factor="",
               bool signin=false, bool factorin=true,
               bool displaystyle=false,
               bool zero=true)
{/*<asyxml></code><documentation>   Retourne le code LaTeX pour écrire la fraction p/q*factor.
   Si 'signin' vaut 'true' le signe '-' est dans la fraction (au
   numérateur).
   Si 'displaystyle' vaut 'true' le code est en mode 'displaystyle'.
   Si 'zero' vaut 'false' et 'p' vaut 0, le code génère 0/p*factor; 0
   si 'zero' vaut 'true'.
   ..................................................
   Return the LaTeX code to write the fraction p/q*factor.
   If 'signin' is 'true' the sign '-' is inside the fraction (within
   the numerator).
   If 'displaystyle' is 'true' the code is in mode 'displaystyle'.
   If 'zero' is 'false' and 'p' is 0, the code generates 0/p*factor; 0
   if 'zero' is 'true'.</documentation></function></asyxml>*/
  if (p==0) return (zero ? "$0$" : "");
  string disp= displaystyle ? "$\displaystyle " : "$";
  int pgcd=pgcd(p,q);
  int num= round(p/pgcd), den= round(q/pgcd);
  string nums;
  if (num==1)
    if (factor=="" || (!factorin && (den !=1))) nums="1"; else nums="";
  else
    if (num==-1)
      if (factor=="" || (!factorin && (den !=1))) nums="-1"; else nums="-";
    else nums= (string) num;
  if (den==1) return "$" + nums + factor + "$";
  else
    {
      string dens= (den==1) ? "" : (string) den;
      if (signin || num>0)
        if (factorin)
          return disp + "\frac{" + nums + factor + "}{" + (string) dens + "}$";
        else
          return disp + "\frac{" + nums + "}{" + (string) dens + "}"+ factor + "$";
      else
        {
          if (num==-1)
            if (factor=="" || !factorin) nums="1"; else nums="";
          else nums=(string)(abs(num));
          if (factorin)
            return disp + "-\frac{" + nums + factor + "}{" + (string) dens + "}$";
          else
            return disp + "-\frac{" + nums + "}{" + (string) dens + "}"+ factor + "$";
        }
    }
}

/*<asyxml><function type="string" signature="texfrac(rational,string,bool,bool,bool,bool)"><code></asyxml>*/
string texfrac(rational x,
               string factor="",
               bool signin=false, bool factorin=true,
               bool displaystyle=false,
               bool zero=true)
{/*<asyxml></code><documentation></documentation></function></asyxml>*/
  return texfrac(x.p, x.q, factor, signin, factorin, displaystyle, zero);
}

// *=======================================================*
// *......................About paths......................*
// *=======================================================*

/*<asyxml><function type="void" signature="drawline(picture,Label,pair,bool,pair,bool,align,pen,arrowbar,arrowbar,margin,Label,marker)"><code></asyxml>*/
void drawline(picture pic=currentpicture, Label L="",pair P, bool dirP, pair Q, bool dirQ,
              align align=NoAlign, pen p=currentpen,
              arrowbar arrow=None, arrowbar bar=None, margin margin=NoMargin,
              Label legend="", marker marker=nomarker)
{/*<asyxml></code><documentation>Ajoute les deux paramètres 'dirP' et 'dirQ' à la routine native
   'drawline' du module 'math'.
   La segment [PQ] sera prolongé en direction de P si 'dirP=true',
   en direction de Q si 'dirQ=true'.
   Si 'dirP=dirQ=true', le comportement est celui du 'drawline' natif.
   Ajoute tous les autres paramètres de 'draw'.
   ..................................................
   Add the two parameters 'dirP' and 'dirQ' to the native routine
   'drawline' of the module 'maths'.
   Segment [PQ] will be prolonged in direction of P if 'dirP=true', in
   direction of Q if 'dirQ=true'.
   If 'dirP=dirQ=true', the behavior is that of the native 'drawline'.
   Add all the other parameters of 'Draw'.</documentation></function></asyxml>*/
  pic.add(new void (frame f, transform t, transform, pair m, pair M) {
      picture opic;
      // Reduce the bounds by the size of the pen.
      m -= min(p); M -= max(p);

      // Calculate the points and direction vector in the transformed space.
      pair z=t*P;
      pair q=t*Q;
      pair v=t*Q-z;
      path g;
      real cp = dirP ? 1:0;
      real cq = dirQ ? 1:0;
      // Handle horizontal and vertical lines.
      if(v.x == 0) {
        if(m.x <= z.x && z.x <= M.x)
          g= dot(v,(z.x,m.y))<0 ?
            (z.x,z.y+cp*(m.y-z.y))--(z.x,q.y+cq*(M.y-q.y)):
            (z.x,q.y+cq*(m.y-q.y))--(z.x,z.y+cp*(M.y-z.y));
      } else if(v.y == 0) {
        if(m.y <= z.y && z.y <= M.y)
          g=(m.x,z.y)--(M.x,z.y);
        g= dot(v,(m.x,z.y))<0 ?
          (z.x+cp*(m.x-z.x),z.y)--(q.x+cq*(M.x-q.x),z.y):
          (q.x+cq*(m.x-q.x),z.y)--(z.x+cp*(M.x-z.x),z.y);
      } else {
        // Calculate the maximum and minimum t values allowed for the
        // parametric equation z + t*v
        real mx=(m.x-z.x)/v.x, Mx=(M.x-z.x)/v.x;
        real my=(m.y-z.y)/v.y, My=(M.y-z.y)/v.y;
        real tmin=max(v.x > 0 ? mx : Mx, v.y > 0 ? my : My);
        real tmax=min(v.x > 0 ? Mx : mx, v.y > 0 ? My : my);
        pair pmin=z+tmin*v;
        pair pmax=z+tmax*v;
        if(tmin <= tmax)
          g= z+cp*tmin*v--z+(cq==0 ? v:tmax*v);
      }
      if (length(g)>0) draw(opic, L=L, g=g, align=align, p=p,
                            arrow=arrow, bar=bar, margin=margin,
                            legend=legend, marker=marker);
      add(f,opic.fit());
    });
}

/*<asyxml><function type="void" signature="drawline(picture,Label,path,bool,bool,align,pen,arrowbar,arrowbar,margin,Label,marker)"><code></asyxml>*/
void drawline(picture pic=currentpicture, Label L="",path g, bool begin=true, bool end=true,
              align align=NoAlign, pen p=currentpen,
              arrowbar arrow=None, arrowbar bar=None, margin margin=NoMargin,
              Label legend="", marker marker=nomarker)
{/*<asyxml></code><documentation></documentation></function></asyxml>*/
  drawline(pic, L, point(g,0), begin, point(g,length(g)), end,
           align, p, arrow, bar, margin, legend, marker);
}

// *=======================================================*
// *....................Rotated labels.....................*
struct rotatedLabel
{
  Label L;
};

rotatedLabel rotatedLabel(string s, string size="",
                          align align=NoAlign,
                          pen p=nullpen, filltype filltype=NoFill)
{
  rotatedLabel OL;
  OL.L.init(s,size,align,p,Rotate,filltype);
  return OL;
}

rotatedLabel rotatedLabel(Label L, explicit position position,
                          align align=NoAlign,
                          pen p=nullpen, filltype filltype=NoFill)
{
  rotatedLabel OL;
  OL.L=Label(L,align,p,Rotate,filltype);
  OL.L.position(position);
  return OL;
}

rotatedLabel rotatedLabel(Label L, pair position,
                          align align=NoAlign,
                          pen p=nullpen, filltype filltype=NoFill)
{
  return rotatedLabel(L,(position) position,align,p,filltype);
}

void draw(picture pic=currentpicture, rotatedLabel L, path g, align align=NoAlign,
          pen p=currentpen, arrowbar arrow=None, arrowbar bar=None,
          margin margin=NoMargin, Label legend="", marker marker=nomarker)
{
  Label LL=L.L.copy();
  bool relative=LL.position.relative;
  real position=LL.position.position.x;
  if(LL.defaultposition) {relative=true; position=0.5;}
  if(relative) position=reltime(g,position);
  LL.embed=Rotate(rotate(dir(g,position))*(1,0));
  LL.align.dir=LL.embed(identity())*LL.align.dir;
  align lalign=align.copy();
  lalign.dir=dir(g,position)*align.dir;
  draw(pic, LL, g, lalign, p, arrow, bar, margin, legend, marker);
}
// *...................End rotatedLabel....................*
// *=======================================================*


/*<asyxml><function type="void" signature="finalbounds(picture,pen)"><code></asyxml>*/
void finalbounds(picture pic=currentpicture,pen p=currentpen)
{/*<asyxml></code><documentation>Write the final bounding box of picture 'pic'.
   This routine is useful to determine the right top and left bottom
   point for enlarging manually the bounding box.</documentation></function></asyxml>*/
  pic.add(new void (frame f, transform t, transform, pair m, pair M) {
      // Reduce the bounds by the size of the pen and the margins.
      m += min(p); M -= max(p);
      transform T=inverse(t);
      write("box("+(string)(T*m)+", "+(string)(T*M)+")");
    },true);
}

/*<asyxml><function type="bool" signature="isPrime(int)"><code></asyxml>*/
bool isPrime(int num)
{/*<asyxml></code><documentation></documentation></function></asyxml>*/
  if (num == 2)
    return true;
  else if (num % 2 == 0)
    return false;
  else
    {
      bool prime = true;
      int divisor = 3;
      int upperLimit = ceil(sqrt(num) + 1);
      while (divisor <= upperLimit)
        {
          if (num % divisor == 0)
            prime = false;
          divisor += 2;
        }
      return prime;
    }
}




