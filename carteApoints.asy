usepackage("frcursive");
texpreamble("\usepackage{avant}
\renewcommand*\familydefault{\sfdefault}
\usepackage[misc]{ifsym}");

string[] numbers={"", "un", "deux", "trois", "quatre", "cinq",
                  "six", "sept", "huit", "neuf", "dix"};
string[] Numbers={"", "UN", "DEUX", "TROIS", "QUATRE", "CINQ",
                  "SIX", "SEPT", "HUIT", "NEUF", "DIX"};
real sq2=sqrt(2);
picture countbox(int n)
{
  real voffset=0;
  picture pic;
  for (int i=0; i < 10; ++i) {
    if(i == 5) {
      voffset=0.12pt;
      draw(pic,(5+voffset/2,0)--(5+voffset/2,1),linecap(0)+linewidth(4bp));
      draw(pic,(5,0)--(5+voffset,0),linecap(0)+linewidth(2bp));
      draw(pic,(5,1)--(5+voffset,1),linecap(0)+linewidth(2bp));
    }
    draw(pic,shift(i+voffset,0)*unitsquare,miterjoin+linewidth(2bp));
    if(i < n) fill(pic,shift((i+0.5+voffset,0.5))*scale(sq2/4)*unitcircle);
  }
  return shift(-(min(pic)+max(pic))/2)*pic;
}


picture carteApoints(int n)
{
  picture opic, pic;
  size(opic,18cm,0);
  label(pic, scale(n == 1 ? 5 : 6)*graphic("main"+(string)(n < 6 ? n : 5)+"."+settings.outformat));
  if(n > 5)
    label(pic,shift(1.8*(max(pic).x,0))*reflect(N,S)*scale(n-5 == 1 ? 5 : 6)*graphic("main"+(string)(n-5)+"."+settings.outformat));
  add(opic, shift(-(min(pic)+max(pic))/2)*pic);
  layer(opic);

  label(opic, scale(8)*("\textcursive{"+(string)n+"}"),(200,225));
  label(opic, scale(3.5)*("\textcursive{"+numbers[n]+"}"),(200,125));

  label(opic, scale(8)*((string)n),(-200,225));
  label(opic, scale(3)*numbers[n],(-200,125));
  label(opic, scale(3)*Numbers[n],(0,125));

  add(opic,shift((0,-150))*scale(40)*countbox(n));

  picture picc;
  label(picc,scale(10)*("\Cube{"+(string)(n < 6 ? n : 5)+"}"));
  if(n > 5)
    label(picc,scale(10)*("\Cube{"+(string)(n-5)+"}"),(2*max(picc).x,0));
  add(opic,shift((0,225)-(min(picc)+max(picc))/2)*picc);
  return opic;
}
