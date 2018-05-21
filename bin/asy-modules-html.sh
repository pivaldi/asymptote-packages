#!/bin/bash

# Copyright (C) 2006
# Author: Philippe IVALDI
#
# This program is free software ; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation ; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY ; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program ; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA



function createstyle()
{
    [ ! -e "${1}style.css" ]  && cat>${1}style.css<<EOF
body {
  color: #f5deb3;
  background-color: #2f4f4f;
  font-weight: bold;
  font-size: 11pt;
}
.inv {
  /* invisible */
  color: #2f4f4f;
}
.builtin {
  /* font-lock-builtin-face */
  color: #b0c4de;
}
.comment {
  /* font-lock-comment-face */
  color: #ff7f24;
}
.comment-delimiter {
  /* font-lock-comment-delimiter-face */
  color: #ff7f24;
}
.constant {
  /* font-lock-constant-face */
  color: #7fffd4;
}
.function-name {
  /* font-lock-function-name-face */
  color: #87cefa;
}
.keyword {
  /* font-lock-keyword-face */
  color: #00ffff;
}
.string {
  /* font-lock-string-face */
  color: #ffa07a;
}
.type {
  /* font-lock-type-face */
  color: #98fb98;
}
.variable-name {
    /* font-lock-variable-name-face */
    color: #eedd82;
}
.documentation {
    color: #eeeeff;
    font-size: 12pt;
}
a {
    color: #c8c8c8;
    background-color: inherit;
    font: inherit;
    text-decoration: underline;
}
a:hover {
    text-decoration: underline;
}
EOF
}

# *=======================================================*
# *..................Gestion des modules..................*
# *=======================================================*
src="/home/pi/.asy/"
dest="/home/pi/www/local/asymptote/modules/" #Destination des .asy et .asy.html
svn="/home/pi/www/svn/asymptote/" # Destination du répertoire placé sous contrôle de SVN.


# [ ! -e $dest ] &&  mkdir $dest
# [ ! -e "${dest}../travaux/modules/" ] &&  mkdir -p "${dest}../travaux/modules/"
# [ ! -e "${svn}branches" ] &&  mkdir -p "${svn}branches" # Modules en cours de développement
# [ ! -e "${svn}tags" ] &&  mkdir "${svn}tags" # Pas encore utilisés
# [ ! -e "${svn}trunk" ] &&  mkdir "${svn}trunk" # Modules personnels stables
createstyle "$dest"

for fic in `cat list-html` ; do
    basefic=`basename $fic`
    ficssext=${basefic%.*}
    module_src="$src""$basefic"
    if [ "${ficssext%_dev}" == "${ficssext}"  ]; then ## Il ne s'agit pas d'un module en cours de developpement.
        ## Copie du fichier dans le répertoire ${svn}trunk
        module_dest="${svn}trunk/${basefic}"
        if [ $module_src -nt $module_dest ]; then
            echo "Copie MODULE dans ${svn}trunk/ : $module_src"
            cp -f $module_src $module_dest
       fi
        module_dest="${dest}${basefic}"
    else ## Il s'agit d'un module en cours de developpement.
        ## Copie du fichier '*_dev' dans le répertoire ${svn}branches
        module_dest="${svn}branches/${basefic}"
        if [ $module_src -nt $module_dest ]; then
            echo "Copie MODULE dans ${svn}branches/ : $module_src"
            cp -f $module_src $module_dest
        fi
        module_dest="${dest}../travaux/modules/${basefic}"
    fi

    if [ $module_src -nt $module_dest ]; then
        echo "Copie MODULE: $module_src"
        cp -f $module_src $module_dest
# "htmlize" le .asy
        emacsclient -e '(htmlize-file "'$module_dest'")' && echo "Conversion en HTML de $module_src"

# ------------------------------------------------
# * Modification du code html généré par htmlize *

# Quelques balises utilisées par 'htmlize'.
        CLASSCD="<span class=\"comment-delimiter\">"
        CLASSC="<span class=\"comment\">"
        CLASSD="<span class=\"documentation\">"

        BBDOC="${CLASSCD}\/\*<\/span>${CLASSC}DOC"
        EBDOC="DOC\*\/<\/span>"
        BIDOC="${CLASSCD}\/\*<\/span>${CLASSC}IDOC\(.*\)IDOC\*\/<\/span>"
        BEXA="${CLASSCD}\/\*<\/span>${CLASSC}EXA\(.*\)EXA\*\/<\/span>"
        BANC="${CLASSCD}\/\*<\/span>${CLASSC}ANC\(.*\)ANC\*\/<\/span>"
        BBHTML="<span class=\"comment\">HTML"
        EBHTML="HTML\*\/<\/span>"
        IMPORT="\(<span class=\"builtin\">include<\/span>\) *\([a-zA-Z0-9_]*_dev\);"


# Remplace le feuille de style du document par une extérieure.
# La commande est:
#         cat ${module_dest}.html |\
#  sed -e "/<style type=\"text\/css\">/,/<\/style>/d;s/<\/title>/<\/title>\n    <link href=\"style.css\" rel=\"stylesheet\" type=\"text\/css\">/" > ${module_dest}.html

        COMA="/<style type=\"text\/css\">/,/<\/style>/d;s/<\/title>/<\/title>\n    <link href=\"style.css\" rel=\"stylesheet\" type=\"text\/css\">/"

# Place une ancre dont le nom est compris entre les balises /*ANC et ANC*/
# La commandes est:
#         cat ${module_dest}.html |\
#  sed -e "s/$BANC/<a name=\"\1\"><hr><\/a>/g" > ${module_dest}.html

        COMB="s/$BANC/<a name=\"\1\"><hr><\/a>/g"

# Entre les balises /*IDOC IDOC*/ on place un mot 'MOT' (sans saut de ligne).
# cela sera remplacé par '//View the definition of <a href="#MOT">MOT</a>.'
# La commande est:
#         cat ${module_dest}.html |\
#  sed -e "s/$BIDOC/${CLASSD}\/\/View the definition of <\/span><a href=\"#\1\">\1<\/a>/g" > ${module_dest}.html

        COMC="s/$BIDOC/${CLASSD}\/\/View the definition of <\/span><a href=\"#\1\">\1<\/a>/g"

# Change la couleur des lignes comprises entre les balise /*DOC et DOC*/
# La commandes est:
#         cat ${module_dest}.html |\
#  sed -e "s/${BBDOC}/${CLASSD}\/\*/g;s/${EBDOC}/\*\/<\/span>/g" > ${module_dest}.html

        COMD="s/${BBDOC}/${CLASSD}\/\*/g;s/${EBDOC}/\*\/<\/span>/g"

#         BBDOC="${CLASSCD}\/\*<\/span>${CLASSC}DOC"
#         EBDOC="DOC\*\/<\/span>"
#         # BEXA="${CLASSCD}\/\*<\/span>${CLASSC}EXA(.*?)EXA\*\/<\/span>"
#         BEXA="${CLASSCD}\/\/</span>${CLASSC}EXA<\/span>"
#         RESTRIC="${CLASSCD}\/\*<\/span>${CLASSC}ANC.*?${BEXA}"
#         BANC="${CLASSCD}\/\*<\/span>${CLASSC}ANC(.*)ANC\*\/<\/span>"

#         perl -0777 -pe \
#             's{'$RESTRIC'}
#         {$_=$&;
#             s/'$BANC'/(.*?)'$BBDOC'(.*?)'$EBDOC'(.*?)'$BEXA'/\
# <A\1><\/A>\2<B>\3<\/B>\4<C>blabla \1 blabla<\/C>/gs;$_}segx' ${module_dest}.html \
# > ${module_dest}.html.new && mv ${module_dest}.html.new ${module_dest}.html


# Entre les balise /*EXA et EXA*/ on place une URL.
# l'URL sera remplacée par le code: <a href="URL">Example here</a>
#         cat ${module_dest}.html |\
#  sed -e "s/$BEXA/${CLASSD}\/\/ <\/span><a href=\"#\1\">Example<\/a>/g" > ${module_dest}.html

        COME="s/$BEXA/${CLASSCD}\/\/ <\/span><a href=\"${ficssext}\/index.html#\1\">Example<\/a> --- <a href=\"${basefic}.index.html\">Index<\/a> --- <a href=\"index.html\">List of modules<\/a>/g"

# Rends visible le code html compris entre les balises "/*HTML" et "HTML*/"
# La commande est:
#         cat ${ficssext}.asy.html |\
#  sed -e "/$BBHTML/,/$EBHTML/s/&lt;/</g;/$BBHTML/,/$EBHTML/s/&gt;/>/g;s/$BBHTML//g;/$EBHTML/s/$EBHTML/${CLASSCD}\*\/<\/span>/g" > ${ficssext}.asy.html

        COMF="/$BBHTML/,/$EBHTML/s/&lt;/</g;/$BBHTML/,/$EBHTML/s/&gt;/>/g;s/$BBHTML//g;/$EBHTML/s/$EBHTML/${CLASSCD}\*\/<\/span>/g"

# Remplace "include *_dev;" par "include -url vers *_dev;"
# La commande est:
#         cat ${ficssext}.asy.html |\
#  sed -e "s/${IMPORT}/\1 <a href=\"\2.asy\">\2<\/a>;/g" > ${ficssext}.asy.html

        COMG="s/${IMPORT}/\1 <a href=\"\2.asy.html\">\2<\/a>;/g"

# Ces commandes sont remplacées par une seule:
        cat ${module_dest}.html |\
 sed -e "$COMA;$COMB;$COMC;$COMD;$COME;$COMF;$COMG" > ${module_dest}.html.new && mv ${module_dest}.html.new ${module_dest}.html

# Création de l'index des mots pour chaque modules
        cat>${module_dest}.index.html<<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<!-- Created by htmlize-1.21 in css mode. -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Index - `basename ${module_dest}`</title>
<style type="text/css">
<!--
body {
color: #f5deb3;
background-color: #2f4f4f;
font-weight: bold;
font-size: 12pt;
}
.titre {
text-align: center;
padding: 10px;
background-color: #000000;
font-size: 16pt;
}
.key {
color: #c8c8c8;
background-color: inherit;
font-weight: bold;
font-size: 14pt;
text-decoration: none;
}
.key:hover {
text-decoration: underline;
}
a {
color: #c8c8c8;
background-color: inherit;
font: inherit;
text-decoration: underline;
}
a:hover {
text-decoration: underline;
}
-->
</style>
</head>
<body>
<table width="100%"> <tr> <td align ="left">
  <table cellpadding=4><tr><td>
    <a href="../index.html">Monter/Up</a>
      </td><td>
      <a href="http://piprim.tuxfamily.org/index.html">Sommaire/Summary</a>
      </td><td>
      <a href="http://asymptote.sourceforge.net/">Asymptote</a>
    </td></tr></table>
  </td></tr></table>
  <center>
    <table class="titre">
    <tr><td>Index of <a href="`basename ${module_dest}`.html">`basename ${module_dest}`</a> routines</td></tr></table>
  </center>
<hr>
EOF
        grep -e "/\*ANC.*ANC\*/" ${module_dest} | sed "s#/\*ANC\(.*\)ANC\*/#<a class=\"key\" href=\"${basefic}.html\#\1\">\1</a><br>#g" |sort >> ${module_dest}.index.html

        cat>>${module_dest}.index.html<<EOF
<HR>
      <table width="100%"> <tr> <td align ="left">
      <table cellpadding=4><tr><td>
      <a href="../index.html">Monter/Up</a>
      </td><td>
      <a href="http://piprim.tuxfamily.org/index.html">Sommaire/Summary</a>
      </td><td>
      <a href="http://asymptote.sourceforge.net/">Asymptote</a>
      </td></tr></table>
      </td></tr></table>
      <p STYLE="color:#c8c8c8;text-align: right">
      Dernière modification: `date`
      <br>Philippe Ivaldi
      </p>
      <p STYLE="text-align: center">
      <a href="http://validator.w3.org/check?uri=referer">Is this page valid HTML 4.01 strict ?</a>
      </p>
      </body>
      </html>
EOF

    fi

done

# Création de la page index.html pour les modules
cat>${dest}index.html<<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<!-- Created by htmlize-1.21 in css mode. -->
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Asy - Personal packages</title>
    <style type="text/css">
    <!--
      body {
        color: #f5deb3;
        background-color: #2f4f4f;
        font-weight: bold;
        font-size: 12pt;
      }
      .titre {
      text-align: center;
       padding: 10px;
       background-color: #000000;
        font-size: 16pt;
      }
      .key {
        color: #c8c8c8;
        background-color: inherit;
        font-weight: bold;
        font-size: 14pt;
        text-decoration: none;
      }
      }
      .li {
        color: #2f4f4f;
        background-color: #2f4f4f;
        font-weight: bold;
        font-size: 14pt;
        text-decoration: none;
      }
      .li:hover {
        color: #000000;
        text-align: center;
        background-color: #000000;
        text-decoration: none;
      }
      .cell {
        color: #2f4f4f;
        background-color: #2f4f4f;
        font-weight: bold;
        font-size: 14pt;
        text-align: center;
        text-decoration: none;
      }
      .cell:hover {
        color: #FF2222;
        text-align: center;
        background-color: #FF2222;
        text-decoration: none;
      }
      a {
        color: #c8c8c8;
        background-color: inherit;
        font: inherit;
        text-decoration: underline;
      }
      a:hover {
        text-decoration: underline;
      }
    -->
    </style>
  </head>
<body>
<table width="100%"> <tr> <td align ="left">
  <table cellpadding="4"><tr><td>
    <a href="../index.html">Monter/Up</a>
      </td><td>
      <a href="http://piprim.tuxfamily.org/index.html">Sommaire/Summary</a>
      </td><td>
      <a href="http://asymptote.sourceforge.net/">Asymptote</a>
    </td></tr></table>
  </td></tr></table>
  <center>
    <table class="titre">
    <tr><td>Personal packages</td></tr></table>
  </center>
<a href="http://svnweb.tuxfamily.org/listing.php?repname=piprim/asymptote&path=%2Ftrunk%2F&rev=0&sc=0">RSS feed</a>
<hr>
<table cellpadding="4" width="600"><tbody>
<tr STYLE="font-size: 14pt;background-color: #000000;"><th>Name</th><th>Download</th><th>View html</th><th>Examples</th><th>Index</th>
EOF

for fic in `ls ${dest}*.asy` ; do
    basefic=`basename $fic`
    ficssext=${basefic%.*}
    [ ! -e "${fic%.*}" ] &&  mkdir ${fic%.*}
    cat>>${dest}index.html<<EOF
    <tr class="li">
      <td STYLE="text-align:left;font-size: 14pt;background-color: #000000;"><span STYLE="color: #f5deb3;">$basefic</span></td>
      <td><a class="cell" href="http://svnweb.tuxfamily.org/listing.php?repname=piprim/asymptote&path=%2Ftrunk%2F&rev=0&sc=0">.....GO.....</a></td>
      <td><a class="cell" href="${basefic}.html">.....GO.....</a></td>
      <td><a class="cell" href="${ficssext}/index.html">.....GO.....</a></td>
      <td><a class="cell" href="${basefic}.index.html">.....GO.....</a></td>
    </tr>
EOF
done

cat>>${dest}index.html<<EOF
</tbody></table>
<HR>
<table width="100%"> <tr> <td align ="left">
<table cellpadding=4><tr><td>
<a href="../index.html">Monter/Up</a>
</td><td>
<a href="http://piprim.tuxfamily.org/index.html">Sommaire/Summary</a>
</td><td>
<a href="http://asymptote.sourceforge.net/">Asymptote</a>
</td></tr></table>
</td></tr></table>
<p STYLE="color:#c8c8c8;text-align: right">
Dernière modification: `date`
<br><a href="http://sourceforge.net/users/pivaldi/">Philippe Ivaldi</a>
</p>
</body>
</html>
EOF

echo "#Terminé#"