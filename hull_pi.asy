// Copyright (c) 2008, Philippe Ivaldi.
// Version: : hull_pi.asy,v 0.1 2008/18/11 Philippe Ivaldi Exp $

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or (at
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
// Graham scan method of computing a hull nodes of a given set of pairs.

// THANKS:

// BUGS:

// INSTALLATION:
// Paste this file in the sub-directory ~/.asy

// Code:

/*<asyxml><function type="path" signature="polygon(pair[])"><code></asyxml>*/
path polygon(pair[] c)
{/*<asyxml></code><documentation>Join the nodes c with segments.</documentation></function></asyxml>*/
  guide g;
  for (int k=0; k < c.length; ++k) 
    g=g--c[k];
  return g--cycle;
}

/*<asyxml><function type="pair" signature="pivot(pair[])"><code></asyxml>*/
pair pivot(pair[] c) {
  /*<asyxml></code><documentation>Return the point with the lowest y-coordinate.
  If there is a tie, the point with the lowest x-coordinate out of the  tie breaking candidates is returned.</documentation></function></asyxml>*/
  real[][] coords;
  for (int i=0; i < c.length; ++i) coords.push(new real[] {c[i].y,c[i].x,i});
  return c[round(sort(coords)[0][2])];
}

/*<asyxml><function type="pair[]" signature=""><code></asyxml>*/
pair[] polarSort(pair[] c, int pivot=-1)
{/*<asyxml></code><documentation>Sort points by the polar angles in ascending order.
   If pivot < 0, use the pair returned by pivot(c) as origin else c[pivot].</documentation></function></asyxml>*/
  int n=c.length;
  if(pivot >= n) abort("polarSort: pivot to large.");
  pair O;
  real[][] polar;
  if(pivot < 0) {
    O=pivot(c);
    for (int i=0; i < n; ++i)
      polar.push(new real[] {degrees(c[i]-O,false),abs(c[i]-O),i});
    polar=sort(polar);
  } else {
    O=c[pivot]; // Origine of the polar coordinates system
    real[][] polp, polm;
    for (int i=0; i < n; ++i) {
      real d;
      if(i != pivot) {
        d=degrees(c[i]-O,false);
        if(d > 180) d=d-360;
        if(d > 0) // 0 <= angle <= 180
          polp.push(new real[] {d,abs(c[i]-O),i});
        else // 180 < angle < 0
          polm.push(new real[] {d,abs(c[i]-O),i});
      }
    }

    // Sort the angles in ascending order;
    polp=sort(polp);
    polm=sort(polm);

    void append(real[][] a, real[][] b, real[][] c)
    {
      polar=copy(a);
      polar.append(b);
      polar.append(c);
    }

    if(polp.length > 0 && polm.length > 0) {
      pair p1=c[round(polp[0][2])],
        p2=c[round(polm[polm.length-1][2])],
        p3=1/3*(O+p1+p2);
      // We must be careful in rotation to join the paths
      if((p2.x-p1.x)*(p3.y-p1.y)-(p2.y-p1.y)*(p3.x-p1.x) > 0)
        append(new real[][]{{0,0,pivot}}, polp, polm);
      else
        append(new real[][]{{0,0,pivot}}, polm, polp);
    } else
      append(new real[][]{{0,0,pivot}}, polp, polm);
  }
  return sequence(new pair(int i){return c[round(polar[i][2])];}, n);
}

/*<asyxml><function type="pair[]" signature="hull(pair[],real,real,real,real,int)"><code></asyxml>*/
pair[] hull(pair[] c, real depthMin=infinity, real depthMax=0,
            real angleMin=360, real angleMax=0, int pivot=-1)
{/*<asyxml></code><documentation>Graham scan method of computing a hull nodes of a given set of points.
With default parameter, return the convex hull.
depthMin and depthMax control the minimum and the maximum depth of cracks from the bounding box of c when it's possible.
angleMin and angleMax control the minimum and the maximum angle (in degrees) defined by three consecutive points when it's possible.
The origin for sorting polar coordinates is the point returned by <html><a href="#pivot(pair[])">pivot(c)</a></html> if pivot < 0 else c[pivot].</documentation></function></asyxml>*/
  pair minb, maxb, center;
  if(depthMax > 0) {
    minb=minbound(c);
    maxb=maxbound(c);
    center=(minb+maxb)/2;
  }
  real dbound(pair M, pair dir)
  {
    return abs(M-minb-realmult(rectify(dir-center),maxb-minb));
  }

  pair[] nodes;
  int n=c.length;

  nodes=polarSort(c,pivot);
  nodes.cyclic=true;

  bool modified;
  do {
    modified=false;
    for (int i=0; i < n; ++i) {
      pair p1=nodes[i], p2=nodes[i+1], p3=nodes[i+2];
      if((p2.x-p1.x)*(p3.y-p1.y)-(p2.y-p1.y)*(p3.x-p1.x) < 0)
        if((depthMax <= 0 || dbound(p2,0.5*(p1+p3)) > depthMax) ||
           (depthMin == infinity || dbound(p2,0.5*(p1+p3)) < depthMin) ||
           (angleMin >=360 || (degrees(p3-p2)-degrees(p1-p2) < angleMin)) ||
           (angleMax <=0 || (degrees(p3-p2)-degrees(p1-p2) > angleMax))) {
          nodes.delete(i+1);
          modified=true;
          break;
        }
    }
  } while(modified);
  return nodes;
}
