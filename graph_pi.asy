// Copyright (c) 2007, Philippe Ivaldi.
// Version: $Id: graph_pi.asy,v 0.0 "2007/01/27 10:35:52" Philippe Ivaldi Exp $
// Last modified: Fri Mar 28 15:57:10 CET 2008

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
//   copier ce fichier dans le sous-répertoire $HOME/.asy
//   Move this file in the sub-directory $HOME/.asy

//CODE:

import graph;
import base_pi;
import markers;
usepackage("mathrsfs");

int None=0, onX=1, onY=2, onXY=3;
// Real functions
typedef real realfunction(real);

struct graphicrules
{// used to comunicate graphicrules to cartesianaxis.
  real xmin,xmax;
  real ymin,ymax;
  bool xcrop,ycrop;
  void set(picture pic=currentpicture){
    xlimits(pic,xmin, xmax, xcrop);
    ylimits(pic,ymin, ymax, ycrop);
 }
};
graphicrules init() {return new graphicrules;}
graphicrules graphicrules = new graphicrules;
void graph_pi_exitfunction(){};

/*ANCgraphicrulesANC*/
void graphicrules(picture pic=currentpicture, real unit=1cm,
                  real xunit=unit != 0 ? unit : 0,
                  real yunit=unit != 0 ? unit : 0,
                  real xmin=-infinity, real xmax=infinity, real ymin=-infinity, real ymax=infinity,
                  bool crop=NoCrop, bool xcrop=crop, bool ycrop=crop)
{
  graphicrules.xmin=xmin;
  graphicrules.xmax=xmax;
  graphicrules.ymin=ymin;
  graphicrules.xmax=xmax;
  graphicrules.ymax=ymax;
  graphicrules.xcrop=xcrop;
  graphicrules.ycrop=ycrop;
  pic.unitsize(x=xunit,y=yunit);
  graphicrules.set(pic);
  graph_pi_exitfunction = new void() {
    graphicrules.set(pic);
  };

}

ticklabel NoZero(string s=defaultformat) {
  return new string(real x) {
    if (x!=0) return format(s,x);
    else return "";
  };
}


ticklabel labelfrac(real ep=1/10^5, real factor=1,
                    string symbol="",
                    bool signin=false, bool symbolin=true,
                    bool displaystyle=false,
                    bool zero=true)
{
  return new string(real x) {
      return texfrac(rational(x/factor), symbol, signin, symbolin, displaystyle, zero);
    };
}

ticklabel labelfrac=labelfrac();

// *=======================================================*
// *....................Graph paper....................*
// *=======================================================*
/*ANCmillimeterpaperANC*/
picture millimeterpaper(picture pic=currentpicture, pair O=(0,0),
                        real xmin=infinity, real xmax=infinity,
                        real ymin=infinity, real ymax=infinity,
                        pen p=.5bp+orange)
{
  picture opic;
  real
    cofx = pic.xunitsize/cm,
    cofy = pic.yunitsize/cm;
  real
    xmin = (xmin == infinity) ? pic.userMin().x*cofx : xmin*cofx,
    xmax = (xmax == infinity) ? pic.userMax().x*cofx : xmax*cofx,
    ymin = (ymin == infinity) ? pic.userMin().y*cofy : ymin*cofy,
    ymax = (ymax == infinity) ? pic.userMax().y*cofy : ymax*cofy;
  path
    ph = (xmin*cm, 0)--(xmax*cm, 0),
    pv = (0, ymin*cm)--(0, ymax*cm);
  real [] step={5, 1, .5, .1};
  pen [] p_={ p, scale(.7)*p, scale(.4)*p, scale(.2)*p};

  for (int j=0; j<4; ++j)
    {
      for (real i=O.y; i <= ymax; i += step[j]) {
        draw(opic, shift(0, i*cm) * ph, p_[j]);
          }
      for (real i=O.y; i >= ymin ; i -= step[j]) {
        draw(opic, shift(0, i*cm) * ph, p_[j]);
      }
      for (real i=O.x; i <= xmax; i += step[j]) {
        draw(opic, shift(i*cm, 0) * pv, p_[j]);
      }
      for (real i=O.x; i >= xmin; i -= step[j]) {
        draw(opic, shift(i*cm, 0) * pv, p_[j]);
      }
    }

  return opic;
}

// *=======================================================*
// *.....................Axis and grid.....................*
// *=======================================================*
/*ANCgridANC*/
void grid(picture pic=currentpicture,
          real xmin=pic.userMin().x, real xmax=pic.userMax().x,
          real ymin=pic.userMin().y, real ymax=pic.userMax().y,
          real xStep=1, real xstep=.5,
          real yStep=1, real ystep=.5,
          pen pTick=nullpen, pen ptick=grey, bool above=false)
{
  draw(pic,box((xmin,ymin),(xmax,ymax)),invisible);
  xaxis(pic, BottomTop, xmin, xmax,
        Ticks("%",extend=true,Step=xStep,step=xstep,pTick=pTick,ptick=ptick),
        above=above, p=nullpen);
  yaxis(pic, LeftRight, ymin, ymax,
        Ticks("%",extend=true,Step=yStep,step=ystep,pTick=pTick,ptick=ptick),
        above=above, p=nullpen);
}

/*ANCcartesianaxisANC*/
void cartesianaxis(picture pic=currentpicture,
                   Label Lx=Label("$x$",align=2S),
                   Label Ly=Label("$y$",align=2W),
                   real xmin=-infinity, real xmax=infinity,
                   real ymin=-infinity, real ymax=infinity,
                   real extrawidth=1, real extraheight=extrawidth,
                   pen p=currentpen,
                   ticks xticks=Ticks("%",pTick=nullpen, ptick=grey),
                   ticks yticks=Ticks("%",pTick=nullpen, ptick=grey),
                   bool viewxaxis=true,
                   bool viewyaxis=true,
                   bool above=true,
                   arrowbar arrow=Arrow)
{
  graphicrules.set(pic);
  xmin=(xmin == -infinity) ? pic.userMin().x : xmin;
  xmax=(xmax == infinity) ? pic.userMax().x : xmax;
  ymin=(ymin == -infinity) ? pic.userMin().y : ymin;
  ymax=(ymax == infinity) ? pic.userMax().y : ymax;
  extraheight= pic.yunitsize != 0 ? cm*extraheight/(2*pic.yunitsize) : 0;
  extrawidth = pic.xunitsize != 0 ? cm*extrawidth/(2*pic.xunitsize) : 0;
  if (viewxaxis)
    {
        yequals(pic, Lx, 0, xmin-extrawidth, xmax+extrawidth, p, above, arrow=arrow);
        yequals(pic, 0, xmin, xmax, p, xticks, above);
    }
  if (viewyaxis)
    {
      xequals(pic, Ly, 0, ymin-extraheight, ymax+extraheight, p, above, arrow=arrow);
      xequals(pic, 0, ymin, ymax, p, yticks, above);
    }
}

real labelijmargin=1;

/*ANClabeloijANC*/
void labeloij(picture pic=currentpicture,
              Label Lo=Label("$O$",NoFill),
              Label Li=Label("$\overrightarrow{\imath}$",NoFill),
              Label Lj=Label("$\overrightarrow{\jmath}$",NoFill),
              pen p=scale(2)*currentpen,
              pair diro=SW, pair diri=labelijmargin*S, pair dirj=labelijmargin*1.5*W,
              filltype filltype=NoFill, arrowbar arrow=Arrow(2mm),
              marker marker=dot)
{
  if (Lo.filltype==NoFill) Lo.filltype=filltype;
  if (Li.filltype==NoFill) Li.filltype=filltype;
  if (Lj.filltype==NoFill) Lj.filltype=filltype;
  labelx(pic, Lo, 0, diro, p);
  draw(pic, Li, (0,0)--(1,0), diri, p, arrow);
  draw(pic, Lj, (0,0)--(0,1), dirj, p, arrow);
  if(marker != nomarker) draw(pic, (0,0), p, marker);
}

real labelIJmargin=1;

/*ANClabeloIJANC*/
void labeloIJ(picture pic=currentpicture,
              Label Lo=Label("$O$",NoFill),
              Label LI=Label("$I$",NoFill),
              Label LJ=Label("$J$",NoFill),
              pair diro=SW, pair dirI=labelIJmargin*S, pair dirJ=labelIJmargin*W,
              pen p=currentpen,
              filltype filltype=NoFill,
              marker marker=dot)
{
  if (Lo.filltype==NoFill) Lo.filltype=filltype;
  if (LI.filltype==NoFill) LI.filltype=filltype;
  if (LJ.filltype==NoFill) LJ.filltype=filltype;
  labelx(pic, LI, 1, dirI, p);
  labely(pic, LJ, 1, dirJ, p);
  labelx(pic, Lo, 0, diro, p);
  if(marker != nomarker) draw(pic, (0,0), p, marker);
}

// *=======================================================*
// *....................Recursivegraph.....................*
// *=======================================================*
typedef void recursiveroutime(picture, real F(real), real, int, int,
                              Label, align, pen, arrowbar, arrowbar,
                              margin, Label, marker);

/*ANCrecursiveoptionANC*/
recursiveroutime recursiveoption(Label L="u",
                                 bool labelbegin=true,
                                 bool labelend=true,
                                 bool labelinner=true,
                                 bool labelalternate=false,
                                 string format="",
                                 int labelplace=onX,
                                 pen px=nullpen,
                                 pen py=nullpen,
                                 bool startonyaxis=false,
                                 arrowbar circuitarrow=None,
                                 marker automarker=marker(cross(4)),
                                 marker xaxismarker=nomarker,
                                 marker yaxismarker=nomarker,
                                 marker xmarker=nomarker,
                                 marker fmarker=nomarker)
{
  return new void(picture pic, real F(real), real u0, int n0, int n,
                  Label L_, align align,
                  pen p, arrowbar arrow, arrowbar bar,
                  margin margin, Label legend, marker marker_)
    {
      real [] u;
      u[n0]=u0;
      for(int i=n0+1;i<n;++i) u[i]=F(u[i-1]);
      guide g= (labelplace==2 || labelplace==3 || startonyaxis) ? nullpath : (u[n0],0);
      bool addlabelautomark;
      for(int i=n0; i < n-1; ++i) {
        g=g--(u[i],u[i+1])--(u[i+1],u[i+1]);
      }
      g = ((labelplace==2 || labelplace==3 || startonyaxis) && u0<0) ? (0,u0)--(u0,u0)--(u0,0)--g : g;
      draw(pic, L_,g, align, p, arrow, bar, margin, legend, marker_);
      if (circuitarrow!=None)
        {
          if (labelplace==2 || labelplace==3 || startonyaxis)
            {
              draw(pic, (0,u[n0])--(u[n0],u[n0]), p, circuitarrow);
              draw(pic, (u[n0],u[n0])--(u[n0],u[n0+1]), p, circuitarrow);
            }
          else
            {
              draw(pic, (u[n0],0)--(u[n0],u[n0+1]), p, circuitarrow);
            }
          draw(pic, (u[n0],u[n0+1])--(u[n0+1],u[n0+1]), p, circuitarrow);
          for(int i=n0+1; i < n-1; ++i) {
            draw(pic, (u[i],u[i])--(u[i],u[i+1]), p, circuitarrow);
            draw(pic, (u[i],u[i+1])--(u[i+1],u[i+1]), p, circuitarrow);
          }
        }
      if (px==nullpen)
        if (labelplace==onX || labelplace==onXY) px=dotted; else px=invisible;
      if (py==nullpen)
        if (labelplace==onY || labelplace==onXY) py=dotted; else py=invisible;
      Label L=L.copy();

      bool Le=(L.s=="");
      bool fe= (format=="");
      bool Lno=(L.s=="%");
      string Ls=L.s;
      for (int i=n0; i<n; ++i)
        {
          addlabelautomark=((i==n0 && labelbegin) || (i!=n0 && labelinner) || (i==n-1 && labelend));
          if (i>n0)
            {
              if (px!=invisible)
                {
                  draw(pic,(u[i],u[i])--(u[i],0),px);
                  if (addlabelautomark) add(pic,automarker.f, (u[i],u[i]));
                }
            }
          if (i>n0)
            {
              if (py!=invisible)
                {
                  if (addlabelautomark) add(pic,automarker.f, (u[i-1],u[i]));
                  draw(pic,(u[i-1],u[i])--(0,u[i]),py);
                }
            }
          if (Le)
            L.s=format(format == "" ? defaultformat : format,u[i]);
          else if (Lno) L.s=""; else
            if (fe) L.s="$" + Ls + "_{" + (string) i + "}$"; else
              L.s="$" + Ls + "_{" + (string) i + "}" + format(format,u[i]) + "$";
          if (labelplace==1 || labelplace==3)
            {//Label on xaxis
              L.position((u[i],0));
              L.align(L.align,S);
              if (labelalternate && i!=n0) {L.align(-L.align.dir);}
              L.s=baseline(L.s,"$p_{1234567890}$");
              if (addlabelautomark) label(pic,L);
              if (xaxismarker==nomarker && addlabelautomark) add(pic,automarker.f, (u[i],0));
            }
          if (labelplace==2 || labelplace==3)
            {//Label on yaxis
              L.position((0,u[i]));
              L.align(L.align,W);
              if (labelalternate && i!=n0) {L.align(-L.align.dir);}
              L.s=baseline(L.s,"$w_{1234567890}$");
              if (addlabelautomark) label(pic,L);
              if (yaxismarker==nomarker && addlabelautomark) add(pic,automarker.f, (0,u[i]));
            }
          add(pic,xaxismarker.f, (u[i],0));
          if (i>n0 || startonyaxis) add(pic,yaxismarker.f, (0,u[i]));
          if (i>n0 || startonyaxis) add(pic,xmarker.f, (u[i],u[i]));
          if (i>n0) add(pic,fmarker.f, (u[i-1],u[i]));
        }
    };
}

recursiveroutime DefaultRecursiveOption=recursiveoption();

struct recursivegraph
{
  real f(real);
  real u0;
  int n0;
  int n;
  recursiveroutime recursiveroutime=DefaultRecursiveOption;
  void draw(picture pic=currentpicture,
            Label L, align align,
            pen p, arrowbar arrow, arrowbar bar,
            margin margin, Label legend, marker marker)
  {recursiveroutime(pic, f, u0, n0, n,
                    L, align,
                    p, arrow, bar,
                    margin, legend, marker);};
};
recursivegraph operator init() {return new recursivegraph;}

recursivegraph recursivegraph(real F(real), real u0, int n0=0, int n)
{
  recursivegraph orec= new recursivegraph;
  orec.f=F;
  orec.u0=u0;
  orec.n0=n0;
  orec.n=n;
  return orec;
}


void draw(picture pic=currentpicture, Label L="", recursivegraph g, recursiveroutime lr=DefaultRecursiveOption,align align=NoAlign,
          pen p=currentpen, arrowbar arrow=None, arrowbar bar=None,
          margin margin=NoMargin, Label legend="", marker marker=nomarker)
{
  g.recursiveroutime=lr;
  g.draw(pic, L, align, p, arrow, bar, margin, legend, marker);
}

guide graph(picture pic=currentpicture, real f(real),
            int n=ngraph, interpolate join=operator --)
{
  return graph(pic, f, a=pic.userMin().x, b=pic.userMax().x, n, join);
}


/*ANCgraphpoint(...)ANC*/
void graphpoint(picture pic=currentpicture,
                Label L="",
                real f(real), real xCoordinate,
                real xmin=0, real ymin=0,
                int draw=onXY,
                pen px=nullpen, pen py=px,
                arrowbar arrow=None, arrowbar bar=None,
                margin marginy=NoMargin, margin marginx=NoMargin,
                bool extend=false, bool extendx=extend, bool extendy=extend,
                Label legendx="", Label legendy="",
                marker markerx=nomarker, marker markery=nomarker)
{/*DOC Mark a point on a curve defined by real f(real). DOC*/
  /*EXAgraphpoint(...)EXA*/
  real xmax,ymax;
  if (extendy) {
    xmin=pic.userMin().x;
    xmax=pic.userMax().x;
  } else xmax=xCoordinate;
  if (extendx) {
    ymin=pic.userMin().y;
    ymax=pic.userMax().y;
  } else ymax=f(xCoordinate);
  px = (px==nullpen) ? currentpen+linetype("6 6") : px;
  py = (py==nullpen) ? currentpen+linetype("6 6") : py;
  L.align(L.align,NE);
  label(pic, L, (xCoordinate,f(xCoordinate)));
  if (draw==onX || draw==onXY)
    draw(pic, (xCoordinate,ymin)--(xCoordinate,ymax),
         p=px, arrow=arrow, bar=bar, margin=marginx, legend=legendx, marker=markerx);
  if (draw==onY || draw==onXY)
    draw(pic, (xmin,ymax)--(xmax,ymax),
         p=py, arrow=arrow, bar=bar, margin=marginy, legend=legendy, marker=markery);
}

// *=======================================================*
// *.....................About tangent.....................*
// *=======================================================*
/*ANCtangentANC*/
path tangent(path g, real x, path b=box(userMin(currentpicture),userMax(currentpicture)))
{//Return the tangent with the maximun size allowed by b (cyclic path)
  if (!cyclic(b)) abort("tangent: path b is not a cyclic path...");
  pair pt=point(g,intersectsv(g,x)[0]);
  real t=intersectp(g,pt);
  real rt=intersectp(reverse(g),pt);
  pair dirr=dir(g,t);
  pair dll=intersectionpointsd(b,pt,shift(pt)*dirr)[0];
  pair dlr=intersectionpointsd(b,pt,shift(pt)*(-dirr))[0];
  return dll--dlr;
}

/*ANCaddtangentANC*/
void addtangent(picture pic=currentpicture,
                path g,
                pair pt,//Point on the path g
                real size=infinity,//ABSOLUTE size of the tangent line (infinity=maximun size according the size of the pic)
                bool drawright=true,//Draw the tangent at the right
                bool drawleft=true,//... left
                pair v=(infinity,infinity),//A finite value forces the value of the derivative
                pair vr=v,//A finite value forces the value of the derivative at right
                pair vl=v,//A finite value forces the value of the derivative at left
                arrowbar arrow=null,//null=automatic determination
                margin margin=NoMargin,//Useful with size=infinity
                Label legend="",
                pen p=currentpen,
                real dt=2,//Increase this number can help to discern tangent at the right and tgt at the left.
                bool differentiable=true)//Set it "true" maybe useful if you are sure that "g is differentiable" at this point.
{
  arrowbar arrow_=arrow;
  pair dir_r,dir_l;
  if (intersect(g,pt).length<2) abort("addtangent: the point is not on the path.");
  real t=intersectp(g,pt);
  if (!differentiable) {
    path subpa,subpb;
    subpa=subpath(g,0,t-dt/2);
    subpb=subpath(g,t+dt/2,length(g));
    dir_l=(vl.x<infinity || vl.y<infinity) ? dir((0,0)--vl,.5) : dir(subpa,length(subpa));
    dir_r=(vr.x<infinity || vr.y<infinity) ? dir((0,0)--vr,.5) : dir(subpb,0);
  } else {
    if (v.x<infinity || v.y<infinity) dir_r=dir((0,0)--v,.5);
    else if (vr.x<infinity || vr.y<infinity) dir_r=dir((0,0)--vr,.5);
    else if (vl.x<infinity || vl.y<infinity) dir_r=dir((0,0)--vl,.5);
    else dir_r=dir(g,t);
    dir_l=dir_r;
  }
  pair dr_a,dl_a;
  pair dr_b,dl_b;
  dl_a=shift(pt)*(-dir_l);
  dl_b=shift(pt)*dir_l;
  dr_a=shift(pt)*dir_r;
  dr_b=shift(pt)*(-dir_r);
  if (size==infinity) {
    draw(pic,g,invisible);
    dl_a=intersectionpointsd(box(userMin(currentpicture),userMax(currentpicture)),pt,dl_a)[0];
    dl_b=intersectionpointsd(box(userMin(currentpicture),userMax(currentpicture)),pt,dl_b)[0];
    dr_a=intersectionpointsd(box(userMin(currentpicture),userMax(currentpicture)),pt,dr_a)[0];
    dr_b=intersectionpointsd(box(userMin(currentpicture),userMax(currentpicture)),pt,dr_b)[0];
    if (arrow_==null) arrow_=None;
    if (drawright && drawleft) {
      draw(dl_a--dl_b,p=p,arrow=arrow_,margin=margin, legend=legend);
      if (!differentiable) draw(dr_a--dr_b,p=p,arrow=arrow_);
    } else if (drawright) draw(pt--dr_a,p=p,arrow=arrow_,margin=margin, legend=legend);
    else if (drawleft) draw(pt--dl_a,p=p,arrow=arrow_,margin=margin, legend=legend);
  } else {//Fixed size
    dl_a=shift((0,0))*(-size*unit(pic.calculateTransform()*dir_l));
    dl_b=shift((0,0))*(size*unit(pic.calculateTransform()*dir_l));
    dr_a=shift((0,0))*(size*unit(pic.calculateTransform()*dir_r));
    dr_b=shift((0,0))*(-size*unit(pic.calculateTransform()*dir_r));
    picture pict;
    if (drawright && drawleft) {
      if (differentiable) {
        if (arrow_==null) arrow_=Arrows;
        draw(pict,dl_a--dl_b,p,arrow=arrow_,margin=margin, legend=legend);
      } else {
        if (arrow_==null) arrow_=Arrow;
        draw(pict,(0,0)--dl_a,p,arrow=arrow_,margin=margin, legend=legend);
        draw(pict,(0,0)--dr_a,p,arrow=arrow_,margin=margin, legend=legend);
      }
    } else {
      if (arrow_==null) arrow_=Arrow;
      if (drawleft) draw(pict,(0,0)--dl_a,p,arrow=arrow_,margin=margin, legend=legend);
      else if (drawright) draw(pict,(0,0)--dr_a,p,arrow=arrow_,margin=margin, legend=legend);
    }
    add(pic,pict,pt);
  }
}

void addtangent(picture pic=currentpicture,
                path g,
                real x,//x-Coodinate
                real size=infinity,//ABSOLUTE size of the tangent line (infinity=maximun size according the size of the pic)
                bool drawright=true,//Draw the tangent at the right
                bool drawleft=true,//... left
                pair v=(infinity,infinity),//A finite (x OR y) value forces the value of the derivative
                pair vr=v,//A finite value forces the value of the derivative at right
                pair vl=v,//A finite value forces the value of the derivative at left
                arrowbar arrow=null,//null=automatic determination
                margin margin=NoMargin,//Useful with size=infinity
                Label legend="",
                pen p=currentpen,
                real dt=2,//Increase this number can help to discern tangent at the right and tgt at the left.
                bool differentiable=true)//Set it "true" maybe useful if you are sure that "g is differentiable" at this point.
{
  addtangent(pic,g,point(g,intersectsv(g,x)[0]),size,drawright,drawleft,v,vr,vl,arrow,margin,legend,p,dt,differentiable);
}


// *=======================================================*
// *.....................Special marks.....................*
// *=======================================================*
// On picture pic, add to path g the frame f rotated by the direction of path g
// at the begin or the end of the path g.
markroutine dirmarkextremroutine(bool begin=true, bool end=true) {
  return new void(picture pic=currentpicture, frame f, path g) {
    if(!begin && !end) return;
    else {
      real [] pos;
      if (begin){
        add(pic, rotate(degrees(pic.calculateTransform()*dir(g,arctime(g,0))))*f, point(g,0));
      }
      if (end) {
        add(pic, rotate(180+degrees(pic.calculateTransform()*dir(g,length(g))))*f, relpoint(g,1));
      }
    }
  };
}

// A new marker constructor which uses the markroutine dirmarkendroutine.
marker markerextrem(frame f,bool begin=true, bool end=true,bool above=true)
{
  return marker(f=f,markroutine=dirmarkextremroutine(begin=begin,end=end),above=above);
}

real graphmarksize=sqrt(2)*dotsize(currentpen);
real graphmarksize(){return graphmarksize;}
// *=======================================================*
// *................How define a new marker................*
// *=======================================================*
// 1. Definition of a mark as frame.
frame arcpicture(real radius=graphmarksize(), real angle=90, pen p=currentpen)
{
  frame ofr;
  draw(ofr, shift((-radius,0))*arc((0,0),radius,-angle/2,angle/2),p);
  return ofr;
}

// 2. Definition of the marker itself
marker ArcMarkerExtrem(real radius=graphmarksize(), real angle=180,
                       bool begin=true, bool end=true,
                       pen p=currentpen, bool above=true)
{
  return markerextrem(f=arcpicture(radius=radius,angle=angle,p=p),
                      begin=begin,end=end,above=above);
}

// 3. Definition of an alias to use default values.
marker ArcMarkerExtrem=ArcMarkerExtrem();
//End of section 'How define a new marker'


// HookMarkerExtrem
frame hookpicture(real height=graphmarksize(), real width=height/sqrt(2), real angle=90, pen p=currentpen)
{
  // if (!(width<infinity)) width=graphmarksize()/2;
  frame ofr;
  draw(ofr, (0,height)--(0,-height),p);
  draw(ofr, (0,height)--(-width,height),p);
  draw(ofr, (0,-height)--(-width,-height),p);
  return ofr;
}

marker HookMarkerExtrem(real height=graphmarksize(), real width=height/2,
                        bool begin=true, bool end=true,
                        pen p=currentpen, bool above=true)
{
  return markerextrem(f=hookpicture(height=height,width=width,p=p),
                      begin=begin,end=end,above=above);
}

marker HookMarkerExtrem=HookMarkerExtrem();
//// End HookMarkerExtrem

//CircleMarkerExtrem
frame circlepicture(real radius=graphmarksize(), filltype filltype=NoFill, pen p=currentpen)
{
  frame ofr;
  filltype filltype_=filltype;
  path cle=shift((-radius,0))*scale(radius)*unitcircle;
  filltype.fill(ofr,cle,p);
  if (filltype_==NoFill) draw(ofr, cle,p);
  return ofr;
}

marker CircleMarkerExtrem(real radius=graphmarksize(), real angle=90,
                          bool begin=true, bool end=true,
                          pen p=currentpen, filltype filltype=NoFill,
                          bool above=true)
{
  return markerextrem(f=circlepicture(radius=radius,p=p,filltype=filltype),
                      begin=begin,end=end,above=above);
}

marker CircleMarkerExtrem=CircleMarkerExtrem();
// End CircleMarkerExtrem


exitfcn currentexitfunction=atexit();

atexit(new void() {
    graph_pi_exitfunction();
    if(currentexitfunction != null) currentexitfunction();
  });

































































































