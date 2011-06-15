// Copyright (c) 2007, Philippe Ivaldi.
// Last modified: Mon Dec 31 15:29:19 CET 2007
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


arrowhead EdgeHead()
{
  arrowhead oa;
  oa.head=new path(path g, position position, pen p=currentpen, real size=0,
                   real angle=arrowangle)
    {
      if(size == 0) size=arrowsize(p);
      bool relative=position.relative;
      real position=position.position.x;
      if(relative) position=reltime(g,position);
      path r=subpath(g,position,0.0);
      pair x=point(r,0);
      real t=arctime(r,size);
      pair y=point(r,t);
      path base=y+2*size*I*dir(r,t)--y-2*size*I*dir(r,t);
      path left=rotate(-angle,x)*r;
      real[] T=arrowbasepoints(base,left,r);
      pair denom=point(right,T[1])-y;
      real factor=denom != 0 ? length((point(left,T[0])-y)/denom) : 1;
      path left=rotate(-angle,x)*r;
      real[] T=arrowbasepoints(base,left,r);
      return subpath(left,0,T[0])--y--cycle;
    };
  return oa;
}

arrowhead EdgeHead=EdgeHead();

arrowhead EdgeHookHead(real dir=arrowdir, real barb=arrowbarb)
{
  arrowhead oa;
  oa.head=new path(path g, position position, pen p=currentpen, real size=0,
                   real angle=arrowangle)
    {
      if(size == 0) size=arrowsize(p);
      angle *= arrowhookfactor;
      bool relative=position.relative;
      real position=position.position.x;
      if(relative) position=reltime(g,position);
      path r=subpath(g,position,0);
      pair x=point(r,0);
      real t=arctime(r,size);
      pair y=point(r,t);
      path base=y+2*size*I*dir(r,t)--y-2*size*I*dir(r,t);
      path left=rotate(-angle,x)*r;
      path right=rotate(angle,x)*r;
      real[] T=arrowbasepoints(base,left,right);
      pair denom=point(right,T[1])-y;
      real factor=denom != 0 ? length((point(left,T[0])-y)/denom) : 1;
      path left=rotate(-angle,x)*r;
      path right=rotate(angle*factor,x)*r;
      real[] T=arrowbasepoints(base,left,right);
      left=subpath(left,0,T[0]);
      right=subpath(right,T[1],0);
      pair pl0=point(left,0), pl1=relpoint(left,1);
      pair pr0=relpoint(right,0), pr1=relpoint(right,1);
      pair M=(pl1+pr0)/2;
      pair v=barb*unit(M-pl0);
      pl1=pl1+v; pr0=pr0+v;
      left=pl0{dir(-dir+degrees(M-pl0))}..pl1--M;
      right=M--pr0..pr1{dir(dir+degrees(pr1-M))};
      return left--y--cycle;
    };
  return oa;
}
arrowhead EdgeHookHead=EdgeHookHead();


arrowhead EdgeSimpleHead(real dir=arrowdir, real barb=arrowbarb)
{
  arrowhead oa;
  oa.head=new path(path g, position position, pen p=currentpen, real size=0,
                   real angle=arrowangle)
    {
      if(size == 0) size=arrowsize(p);
      bool relative=position.relative;
      real position=position.position.x;
      if(relative) position=reltime(g,position);
      path r=subpath(g,position,0);
      pair x=point(r,0);
      real t=arctime(r,size);
      pair y=point(r,t);
      path base=y+2*size*I*dir(r,t)--y-2*size*I*dir(r,t);
      path left=rotate(-angle,x)*r;
      path right=rotate(angle,x)*r;
      real[] T=arrowbasepoints(base,left,right);
      pair denom=point(right,T[1])-y;
      real factor=denom != 0 ? length((point(left,T[0])-y)/denom) : 1;
      path left=rotate(-angle,x)*r;
      path right=rotate(angle*factor,x)*r;
      real[] T=arrowbasepoints(base,left,right);
      return subpath(left,T[0],0);
    };
  return oa;
}
arrowhead EdgeSimpleHead=EdgeSimpleHead();


private real position(position position, real size, path g, bool center)
{
  bool relative=position.relative;
  real position=position.position.x;
  if(relative) {
    position *= arclength(g);
    if(center) position += 0.5*size;
    position=arctime(g,position);
  } else if(center)
    position=arctime(g,arclength(subpath(g,0,position))+0.5*size);
  return position;
}

arrowbar EdgeArrows(arrowhead head=EdgeHead,real size=0, real angle=arrowangle,
                    filltype filltype=FillDraw, position position=EndPoint,
                    real space=infinity)
{
  return new bool(picture pic, path g, pen p, margin margin) {
    pair direction;
    real sg=sgn(dot(N,space*I*dir(g,length(g)/2)));
    space = (space == infinity) ? 2*linewidth(p) : space/2;
    if (sg>=0)
      {
        direction=-space*I*dir(g,length(g)/2);
        sg=1;
      }
    else direction=space*I*dir(g,length(g)/2);
    picture tpic;
    tpic.add(new void (frame f, transform t) {
        drawarrow(f,head,t*shift(inverse(t)*(-direction))*g,p,
              size,sg*angle,filltype,position,true,margin,false);
        drawarrow(f,head,t*shift(inverse(t)*direction)*reverse(g),p,
              size,sg*angle,filltype,position,true,margin,false);
      });
    tpic.addPath(g,p);
    real sz=size;
    real gle=angle;
    filltype fl=filltype;
    addArrow(tpic,head,g,p,sz,gle,fl,position(position,size,g,false));
    add(pic,tpic);
    return false;
  };
};

arrowbar EdgeArrows=EdgeArrows();
