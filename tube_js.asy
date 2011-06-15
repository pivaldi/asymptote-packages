// Copyright (c) 2007, author: Jens Schwaiger
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

// INSTALLATION:
// Paste this file in the sub-directory $HOME/.asy

// Code:

import graph3;

// similar to roundedpath for 3D
guide3 roundedguide(guide3 A, real r=0.2){
  guide3 rounded;
  triple before, after, indir, outdir;
  int len=length(A);
  bool guideclosed=cyclic(A);
  if(len<2){return A;};
  if(guideclosed){rounded=point(point(A,0)--point(A,1),r);}
  else {rounded=point(A,0);};
  for(int i=1;i<len;i=i+1){
    before=point(point(A,i)--point(A,i-1),r);
    after=point(point(A,i)--point(A,i+1),r);
    indir=dir(point(A,i-1)--point(A,i),1);
    outdir=dir(point(A,i)--point(A,i+1),1);
    rounded=rounded--before{indir}..{outdir}after;
  }
  if(guideclosed) {
    before=point(point(A,0)--point(A,len-1),r);
    indir=dir(point(A,len-1)--point(A,0),1);
    outdir=dir(point(A,0)--point(A,1),1);
    rounded=rounded--before{indir}..{outdir}cycle;}
  else rounded=rounded--point(A,len);

  return rounded;
};

// returns a triple orthogonal to the triple p
triple orthv(triple p=(0,0,1)){
  if(abs((p.x,p.y))>0)
    {return unit((-p.y,p.x,0));} else {return (1,0,0);};
};
// used in constructin the array of Bishop frames
triple nextnormal(triple p, triple q){
  triple nw=p-(dot(p,q)*q);
  if(abs(nw)<0.001){return p;} else {return unit(nw);}
};

// Bishop frame itself; for closed curves a modification guarantees
// smoothness also at the
// "closing" position of the guide3 g
// tw<>0 means some additional twist (measured in radians)
// for closed g twist should be a multiple of 2pi
/*
  See http://ada.math.uga.edu/research/software/tube/tube.html
*/
triple[][] bframe(guide3 g, int subdiv=20, real tw=0){
  triple[][] bf=new triple[subdiv+1][3];
  real lg=arclength(g);
  for(int i=0;i<subdiv+1;i=i+1){bf[i][0]=dir(g,arctime(g,(i/subdiv)*lg));}
  bf[0][1]=orthv(bf[0][0]);
  bf[0][2]=cross(bf[0][0],bf[0][1]);
  for(int i=1;i<subdiv+1;i=i+1){bf[i][1]=nextnormal(bf[i-1][1],bf[i][0]);
    bf[i][2]=cross(bf[i][0],bf[i][1]);

  };

  if(cyclic(g)){// Modify frame, such that surface closes smoothly
    triple[] startframe=new triple[3];
    triple[] endframe=new triple[3];
    startframe=bf[0]; endframe=bf[subdiv];

    pair tmp=(dot(endframe[1],startframe[1]),-dot(endframe[2],startframe[1]));
    real alpha=angle(unit(tmp));
    for(int i=1;i<subdiv+1;i=i+1){
      bf[i][1]=rotate(-alpha*180/pi*i/subdiv,bf[i][0])*bf[i][1];
      bf[i][2]=rotate(-alpha*180/pi*i/subdiv,bf[i][0])*bf[i][2];
    };
  };
  for(int i=1;i<subdiv+1;i=i+1){
    bf[i][1]=rotate(tw*180/pi*i/subdiv,bf[i][0])*bf[i][1];
    bf[i][2]=rotate(tw*180/pi*i/subdiv,bf[i][0])*bf[i][2];
  };
  return bf;
};

typedef guide crosssec(real);
guide cs0(real s){return scale(0.3)*unitcircle;};

// produces a tubelike surface around g; sc ist the radius of the tube
/*
  See http://ada.math.uga.edu/research/software/tube/tube.html
*/
surface spacetube(guide3 g, int nx=20, int ny=12,
                  crosssec cs=cs0,
                  real twist=0, bool cover=false)
{
  triple[][] bf=bframe(g,nx,twist);
  triple[] pt=new triple[];
  real lg=arclength(g);
  for(int i=0;i<nx+1;i=i+1){
    pt[i]=relpoint(g,i/nx);}
  triple[][] surfc=new triple[nx+1][ny+1];
  for(int i=0;i<nx+1;i=i+1)
    for(int j=0;j<ny+1;j=j+1){
      guide rhox=cs((i/nx));
      if(cover){
        if((!cyclic(g))&&(i==0||i==nx)){rhox=(0,0);};};
      pair prhox=relpoint(rhox,j/ny);
      real scxx=prhox.x;
      real scyy=prhox.y;
      surfc[i][j]=pt[i]+scxx*bf[i][1]+
        scyy*bf[i][2];
    };
  return surface(surfc, new bool[][] {});
}

surface spacetube(guide3 g, int nx=20,
                  path cs,
                  real twist=0, bool cover=false)
{
  surface sf;
  // path3 sec=path3(cs,ZXplane);
  triple[][] bf=bframe(g,nx,twist);
  triple[] pt=new triple[];
  real lg=length(g), r=abs(max(cs)-min(cs))/2;
  int n=length(cs);
  path3 tmp1,tmp2;
  for(int i=0;i<nx+1;i=i+1) pt[i]=relpoint(g,i/nx);
  //   triple pt1, pt2;
  //   for(int i=0; i < n-1; ++i) {
  //     real S=straightness(g,i);
  //     if(S < epsilon*r) {
  //       pt1=point(g,i);
  //       pt2=point(g,i+1);
  //       triple[][] bf=bframe(subpath(g,i,i+1),3,twist);
  //       for (int k=0; k < (cyclic(cs) ? n : n-1); ++k) {
  //         path sec=subpath(cs,k,k+1);
  //         tmp1=path3(sec,new triple(pair z){return pt1+z.x*bf[1][1]+z.y*bf[1][2];});
  //         tmp2=path3(sec,new triple(pair z){return pt2+z.x*bf[2][1]+z.y*bf[2][2];});
  //         sf.append(surface(tmp1--reverse(tmp2)--cycle));
//       }
//     }
//   }
  // triple[][] surfc=new triple[nx+1][ny+1];
  path3 tmp1,tmp2;
  for(int i=0; i < nx; ++i) {
    // for(int j=0; j < ny-1; ++j) {
    // if(cover){
    // if((!cyclic(g))&&(i==0||i==nx)){rhox=(0,0);};};
    //       pair prhox=relpoint(rhox,j/ny);
    //       real scxx=prhox.x;
    //       real scyy=prhox.y;
    //       surfc[i][j]=pt[i]+scxx*bf[i][1]+scyy*bf[i][2];
    // surface tmp;
    //     path3 tmp1=shift(pt[i])*align(cross(bf[i][1],bf[i][2]))*sec;
    //     path3 tmp2=shift(pt[i+1])*align(cross(bf[i+1][1],bf[i+1][2]))*sec;
    for (int k=0; k < (cyclic(cs) ? n : n-1); ++k) {
      path sec=subpath(cs,k,k+1);
      tmp1=path3(sec,new triple(pair z){return pt[i]+z.x*bf[i][1]+z.y*bf[i][2];});
      tmp2=path3(sec,new triple(pair z){return pt[i+1]+z.x*bf[i+1][1]+z.y*bf[i+1][2];});
      // tmp=surface();
      // sf.append(surface(subpath(tmp1,k,k+1)--subpath(tmp2,k,k+1)--cycle));
      sf.append(surface(tmp1--reverse(tmp2)--cycle));
    }
    // draw(tmp1);
    // return surface(surfc, new bool[][] {});
  }
  return sf;
}
