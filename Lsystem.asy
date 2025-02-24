// Copyright (c) 2008, Philippe Ivaldi.
// Version: $Id: Lsystem.asy,v 0.0 2008/02/18 12:45:04 Philippe Ivaldi Exp $

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

// Code:

// Rules are explain here:
// http://web.telia.com/~u61105057/Intro.htm
// AND
// http://www.xs4all.nl/~cvdmark/tutor.html

import three;

pen tmppen;
pen stringToPen(string s="red"){
  eval("tmppen="+s,true);
  return tmppen;
}

string Lstart="F";
string[][] Lrule=new string[][]{{"F", "F-F+F+F-F"}};
real La=90;
real Lai=0;
real Llength=1;


struct coloredPath
{
  path g;
  pen p=currentpen;
}

void draw(coloredPath g, pen p=currentpen){draw(g.g,g.p+colorless(p));}

void draw(coloredPath[] gs, pen p=currentpen)
{
  for(coloredPath g : gs) {
    draw(g,p);
  };
}

struct branch
{
  path g;
  int depth=0;
}

path operator cast(branch branch){return branch.g;}

typedef branch[] tree;

path[] operator cast(tree tree)
{
  path[] g;
  for(branch b : tree) g.push(b.g);
  return g;
}

struct Lsystem
{
  string L;
  string Lstart=Lstart;
  string[][] Lrule=Lrule;
  real La=La;
  real Lai=Lai;
  real Llength=Llength;
  int n;
  void iterate(int i=1)
  {
    for (int j=0; j < i; ++j) {
      L=replace(L,Lrule);
      ++n;
    }
  }
  void operator init(string Lstart=Lstart,string[][] Lrule=Lrule,
                     real La=La, real Lai=Lai,
                     real Llength=Llength)
  {
    this.L=Lstart;
    this.Lstart=Lstart;
    this.Lrule=Lrule;
    this.La=La;
    this.Lai=Lai;
    this.Llength=Llength;
  }

  path[] paths()
  {
    path[] g;
    string action;
    pair[] cdirs;
    pair cdir=Llength*dir(Lai);
    pair[] pos;
    pair cpos;
    int ng=0;
    g[0]=(0,0); cpos=(0,0);
    for (int i=0; i < length(this.L); ++i) {
      action=substr(this.L,i,1);
      if(action == "|") {
        cdir=rotate(180)*cdir;
      } else if(action == "'") {
        cdir *= (real)substr(this.L,i+2,find(this.L,")",i+2)-i-2);
      } else if(action == "F") {
        g[ng]=g[ng]--(relpoint(g[ng],1)+cdir);
        cpos += cdir;
      } else  if(action == "f") {
        ++ng;
        g[ng]=(relpoint(g[ng-1],1)+cdir);
        cpos += cdir;
      } else if(action == "G") {
        g[ng]=g[ng]--(relpoint(g[ng],1)+cdir);
      } else if(action == "+") {
        cdir=rotate(-La)*cdir;
      } else if(action == "-") {
        cdir=rotate(La)*cdir;
      } else if(action == "[") {
        pos.push(cpos);
        cdirs.push(cdir);
      } else if(action == "]") {
        ++ng;
        g[ng]=pos.pop();
        cpos=point(g[ng],0);
        cdir=cdirs.pop();
      }
    }
    path[] og;
    for(path gp : g) if(length(gp) > 0) og.push(gp);
    return og;
  }

  coloredPath[] coloredPaths()
  {
    coloredPath[] g;
    pen cp;
    pen[] p;
    string action;
    pair[] cdirs;
    pair cdir=Llength*dir(Lai);
    pair[] pos;
    pair cpos;
    int ng=0;
    g[0]=new coloredPath;
    g[0].g=(0,0); cpos=(0,0);
    for (int i=0; i < length(this.L); ++i) {
      action=substr(this.L,i,1);
      if(action == "|") {
        cdir=rotate(180)*cdir;
      } else if(action == "'") {
        cdir *= (real)substr(this.L,i+2,find(this.L,")",i+2)-i-2);
      } else  if(action == "C") {
        cp=stringToPen(substr(this.L,i+2,find(this.L,")",i+2)-i-2));
        g[ng].p=cp;
      } else if(action == "F") {
        g[ng].g=g[ng].g--(relpoint(g[ng].g,1)+cdir);
        cpos += cdir;
      } else  if(action == "f") {
        ++ng;
        g[ng]=new coloredPath;
        g[ng].g=relpoint(g[ng-1].g,1)+cdir;
        g[ng].p=cp;
        cpos += cdir;
      } else if(action == "G") {
        g[ng].g=g[ng].g--(relpoint(g[ng].g,1)+cdir);
      } else if(action == "+") {
        cdir=rotate(-La)*cdir;
      } else if(action == "-") {
        cdir=rotate(La)*cdir;
      } else if(action == "[") {
        pos.push(cpos);
        p.push(cp);
        cdirs.push(cdir);
      } else if(action == "]") {
        ++ng;
        g[ng]=new coloredPath;
        g[ng].g=pos.pop();
        cp=p.pop();
        g[ng].p=cp;
        cpos=point(g[ng].g,0);
        cdir=cdirs.pop();
      }
    }
    coloredPath[] og;
    for(coloredPath gp : g) if(length(gp.g) > 0) og.push(gp);
    return og;
  }

  tree tree()
  {
    tree g;
    string action;
    pair[] cdirs;
    pair cdir=Llength*dir(Lai);
    int[] pos;
    int ng=0;
    g[0]=new branch;
    g[0].g=(0,0);
    for (int i=0; i < length(this.L); ++i) {
      action=substr(this.L,i,1);
      if(action == "|") {
        cdir=rotate(180)*cdir;
      } else if(action == "'") {
        cdir *= (real)substr(this.L,i+2,find(this.L,")",i+2)-i-2);
      } else if(action == "F") {
        g[ng].g=g[ng].g--(relpoint(g[ng].g,1)+cdir);
      } else if(action == "+") {
        cdir=rotate(-La)*cdir;
      } else if(action == "-") {
        cdir=rotate(La)*cdir;
      } else if(action == "[") {
        pos.push(ng);
        cdirs.push(cdir);
        g[g.length]=new branch;
        g[g.length-1].g=relpoint(g[ng].g,1);
        ng=g.length-1;
      } else if(action == "]") {
        ng=pos.pop();
        ++g[ng].depth;
        cdir=cdirs.pop();
      }
    }
    return g;
  }

  // path[] paths()
  // {
  //   path[] g;
  //   string action;
  //   pair[] cdirs;
  //   pair cdir=Llength*dir(Lai);
  //   int[] pos;
  //   int ng=0;
  //   g[0]=(0,0);
  //   for (int i=0; i < length(this.L); ++i) {
  //     action=substr(this.L,i,1);
  //     if(action == "F") {
  //       g[ng]=g[ng]--(relpoint(g[ng],1)+cdir);
  //     } else if(action == "+") {
  //       cdir=rotate(-La)*cdir;
  //     } else if(action == "-") {
  //       cdir=rotate(La)*cdir;
  //     } else if(action == "[") {
  //       pos.push(ng);
  //       cdirs.push(cdir);
  //       g[g.length]=relpoint(g[ng],1);
  //       ng=g.length-1;
  //     } else if(action == "]") {
  //       ng=pos.pop();
  //       cdir=cdirs.pop();
  //     }
  //   }
  //   return g;
  // }
}

struct branch3
{
  path3 g;
  int depth=0;
}

path3 operator cast(branch3 branch){return branch.g;}

typedef branch3[] tree3;

path3[] operator cast(tree3 tree)
{
  path3[] g;
  for(branch3 b : tree) g.push(b.g);
  return g;
}

struct Lsystem3
{
  string L;
  string Lstart=Lstart;
  string[][] Lrule=Lrule;
  real La=La;
  real Lai=Lai;
  real Llength=Llength;
  int n;
  void iterate(int i=1)
  {
    for (int j=0; j < i; ++j) {
      L=replace(L,Lrule);
      ++n;
    }
  }
  void operator init(string Lstart=Lstart,string[][] Lrule=Lrule,
                     real La=La, real Lai=Lai,
                     real Llength=Llength)
  {
    this.L=Lstart;
    this.Lstart=Lstart;
    this.Lrule=Lrule;
    this.La=La;
    this.Lai=Lai;
    this.Llength=Llength;
  }

  path3[] paths3()
  {
    path3[] g;
    triple endg=(0,0,0);
    string action;
    triple[] udirs, vdirs, kdirs;
    triple udir=Llength*(0,0,1), vdir=Llength*(1,0,0), kdir=cross(udir,vdir);
    triple[] pos;
    int ng=0;
    g[0]=(0,0,0);
    void changedir(real angle, triple axe)
    {
      transform3 T=rotate(angle,axe);
      udir=T*udir;
      vdir=T*vdir;
      kdir=T*kdir;
    }
    for (int i=0; i < length(this.L); ++i) {
      action=substr(this.L,i,1);
      if(action == "'") {
        udir *= (real)substr(this.L,i+2,find(this.L,")",i+2)-i-2);
      } else if(action == "F") {
        endg += udir;
        g[ng]=g[ng]--endg;
      } else if(action == "+") {
        changedir(-La,kdir);
      } else if(action == "-") {
        changedir(La,kdir);
      } else if(action == "&") {
        changedir(-La,vdir);
      } else if(action == "^") {
        changedir(La,vdir);
      } else if(action == "<") {
        changedir(-La,udir);
      } else if(action == ">") {
        changedir(La,udir);
      } else if(action == "|") {
        changedir(180,udir);
      } else if(action == "[") {
        pos.push(endg);
        udirs.push(udir);
        vdirs.push(vdir);
        kdirs.push(kdir);
      } else if(action == "]") {
        ++ng;
        endg=pos.pop();
        g[ng]=endg;
        udir=udirs.pop();
        vdir=vdirs.pop();
        kdir=kdirs.pop();
      }
    }
    return g;
  }

  void drawpaths3(picture pic=currentpicture, pen p=currentpen)
  {
    triple[] g;
    triple cg;
    string action;
    triple[] udirs, vdirs, kdirs;
    triple udir=Llength*(0,0,1), vdir=Llength*(1,0,0), kdir=cross(udir,vdir);
    triple[] pos;
    int ng=0;
    g[0]=(0,0,0);
    void changedir(real angle, triple axe)
    {
      transform3 T=rotate(angle,axe);
      udir=T*udir;
      vdir=T*vdir;
      kdir=T*kdir;
    }
    for (int i=0; i < length(this.L); ++i) {
      action=substr(this.L,i,1);
      if(action == "'") {
        udir *= (real)substr(this.L,i+2,find(this.L,")",i+2)-i-2);
      } else if(action == "F") {
        cg=g[ng]+udir;
        draw(pic,g[ng]--cg,p);
        g[ng]=cg;
      } else if(action == "+") {
        changedir(-La,kdir);
      } else if(action == "-") {
        changedir(La,kdir);
      } else if(action == "&") {
        changedir(-La,vdir);
      } else if(action == "^") {
        changedir(La,vdir);
      } else if(action == "<") {
        changedir(-La,udir);
      } else if(action == ">") {
        changedir(La,udir);
      } else if(action == "|") {
        changedir(180,udir);
      } else if(action == "[") {
        pos.push(g[ng]);
        udirs.push(udir);
        vdirs.push(vdir);
        kdirs.push(kdir);
      } else if(action == "]") {
        ++ng;
        g[ng]=pos.pop();
        udir=udirs.pop();
        vdir=vdirs.pop();
        kdir=kdirs.pop();
      }
    }
  }
  
  tree3 tree3()
  {
    tree3 g;
    string action;
    triple[] udirs, vdirs, kdirs;
    triple udir=Llength*(0,0,1), vdir=Llength*(1,0,0), kdir=cross(udir,vdir);
    int[] pos;
    int ng=0;
    g[0]=new branch3;
    g[0].g=(0,0,0);
    void changedir(real angle, triple axe)
    {
      transform3 T=rotate(angle,axe);
      udir=T*udir;
      vdir=T*vdir;
      kdir=T*kdir;
    }
    for (int i=0; i < length(this.L); ++i) {
      action=substr(this.L,i,1);
      if(action == "'") {
        udir *= (real)substr(this.L,i+2,find(this.L,")",i+2)-i-2);
      } else if(action == "F") {
        g[ng].g=g[ng].g--(relpoint(g[ng].g,1)+udir);
      } else if(action == "+") {
        changedir(-La,kdir);
      } else if(action == "-") {
        changedir(La,kdir);
      } else if(action == "&") {
        changedir(-La,vdir);
      } else if(action == "^") {
        changedir(La,vdir);
      } else if(action == "<") {
        changedir(-La,udir);
      } else if(action == ">") {
        changedir(La,udir);
      } else if(action == "|") {
        changedir(180,udir);
      } else if(action == "[") {
        pos.push(ng);
        udirs.push(udir);
        vdirs.push(vdir);
        kdirs.push(kdir);
        g[g.length]=new branch3;
        g[g.length-1].g=relpoint(g[ng].g,1);
        ng=g.length-1;
      } else if(action == "]") {
        ng=pos.pop();
        ++g[ng].depth;
        udir=udirs.pop();
        vdir=vdirs.pop();
        kdir=kdirs.pop();
      }
    }
    return g;
  }
}
