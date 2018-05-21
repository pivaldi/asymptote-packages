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


# Récupère le texte qui se trouve entre les balises <body> et </body>
function bodyinner()
{
    cat $1 | awk -v FS="^Z" "/<body>/,/<\/body>/" | sed "s/<\/*body>//g"
}

function createindexhtml()
{
    fic=$1 # Le module .asy qu'il faut transformer en xml puis en html via le fichier module2html.xsl
    RES=$2 # Le répertoire où se trouve le fichier module2html.xsl (doit être un répertoire relatif à celui de $1)
    ficssext=${fic%.*}
    ficssext=`basename $ficssext`

    echo "Création de ${fic}.xml"
# ------------
# * L'entête *
    cat>"${fic}.xml"<<EOF
<?xml version="1.0" ?>
<?xml-stylesheet type="text/xsl" href="${RES}module2html.xsl" ?>
<asy-code title="Asy - ${ficssext}" date="`LANG=EN_US date`" resource="${RES}" filename="${ficssext}">
EOF
# ------------
# * Le corps *
    bodyinner "${fic}.html" >>"${fic}.xml"
    cat>>"${fic}.xml"<<EOF
</asy-code>
EOF

# *................Création du .html.................*
    echo "Création de ${fic}.html dans `dirname $fic`"
    xsltproc "${fic}.xml" > "${fic}.html"
}

# *=======================================================*
# *..................Gestion des modules..................*
# *=======================================================*
# src="/home/pi/.asy/"
src="`pwd`/"
dest="/home/pi/www/local/asymptote/modules/" #Destination des .asy et .asy.html
svn="/home/pi/www/svn/pi-asymptote-packages/" # Destination du répertoire placé sous contrôle de SVN.

[ ! -e $dest ] &&  mkdir $dest
[ ! -e "${dest}../travaux/modules/" ] &&  mkdir -p "${dest}../travaux/modules/"
[ ! -e "${svn}branches" ] &&  mkdir -p "${svn}branches" # Modules en cours de développement
[ ! -e "${svn}tags" ] &&  mkdir "${svn}tags" # Pas encore utilisés
[ ! -e "${svn}trunk" ] &&  mkdir "${svn}trunk" # Modules personnels stables

create_geo=false
for fic in `cat list_geo | grep geo_` ; do
    if [ "$fic" -nt "${dest}../travaux/modules/${fic}.html" ]; then
        create_geo=true
        break
    fi
done

# create_geo=false # !!!!!!!!!! PROVISOIREMENT JE NE METS PAS À JOUR !!!!!!!!!!
if $create_geo; then
# *=======================================================*
# *........Reconstruction paquet geometry.asy.........*
# *=======================================================*
    cat>${src}geometry.asy<<EOF
// geometry.asy

// Copyright (C) 2007
// Author: Philippe IVALDI 2007/09/01

// This program is free software ; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation ; either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY ; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.

// You should have received a copy of the GNU Lesser General Public License
// along with this program ; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

// COMMENTARY:
// An Asymptote geometry module.

// THANKS:
// Special thanks to Olivier Guibé for his help in mathematical issues.

// BUGS:

// CODE:

import math;
import markers;
// *=======================================================*
// *........................HEADER.........................*
`cat ${src}geo_header.asy`
// *........................HEADER.........................*
// *=======================================================*

// *=======================================================*
// *......................COORDINATES......................*
`cat ${src}geo_coordinates.asy`
// *......................COORDINATES......................*
// *=======================================================*

// *=======================================================*
// *.........................BASES.........................*
`cat ${src}geo_bases.asy`
// *.........................BASES.........................*
// *=======================================================*

// *=======================================================*
// *.........................LINES.........................*
`cat ${src}geo_lines.asy`
// *.........................LINES.........................*
// *=======================================================*

// *=======================================================*
// *........................CONICS.........................*
`cat ${src}geo_conics.asy`
// *........................CONICS.........................*
// *=======================================================*

// *=======================================================*
// *.......................ABSCISSA........................*
`cat ${src}geo_abscissa.asy`
// *.......................ABSCISSA........................*
// *=======================================================*

// *=======================================================*
// *.........................ARCS..........................*
`cat ${src}geo_arcs.asy`
// *.........................ARCS..........................*
// *=======================================================*

// *=======================================================*
// *........................MASSES.........................*
`cat ${src}geo_masses.asy`
// *........................MASSES.........................*
// *=======================================================*

// *=======================================================*
// *.......................TRIANGLES.......................*
`cat ${src}geo_triangles.asy`
// *.......................TRIANGLES.......................*
// *=======================================================*

// *=======================================================*
// *.......................INVERSIONS......................*
`cat ${src}geo_inversions.asy`
// *.......................INVERSIONS......................*
// *=======================================================*

// *=======================================================*
// *........................FOOTER.........................*
`cat ${src}geo_footer.asy`
// *........................FOOTER.........................*
// *=======================================================*
EOF

fi

for fic in `cat list` ; do
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

        if [ `cat official | grep "${basefic}"` ]; then ## Cas spécial de paquets officiels que je maintiens
        module_dest="${dest}../${ficssext}/modules/${basefic}"
        RES="../../../ressources/"
        else ## Il s'agit d'un module perso non officiel
            module_dest="${dest}${basefic}"
            RES="../../ressources/"
        fi
    else ## Il s'agit d'un module en cours de developpement.
        ## Copie du fichier '*_dev' dans le répertoire ${svn}branches
        module_dest="${svn}branches/${basefic}"
        if [ $module_src -nt $module_dest ]; then
            echo "Copie MODULE dans ${svn}branches/ : $module_src"
            cp -f $module_src $module_dest
        fi
        module_dest="${dest}../travaux/modules/${basefic}"
        RES="../../../ressources/"
    fi

    if [ $module_src -nt $module_dest ]; then
    # if [ $module_src -nt $module_dest ] && [ "${ficssext%_dev}" == "${ficssext}"  ]; then
        echo "Copie MODULE: $module_src"
        cp -f $module_src $module_dest
# "htmlize" le .asy
        emacsclient -e '(htmlize-file "'${module_dest}'")' && echo "Conversion en HTML de $module_src"
        # On conserve une copie du .html pour un traitement ultérieure (création des index)
        cp "${module_dest}.html" "${module_dest}.sauv.html"
        createindexhtml "$module_dest" "$RES"

# Supprime les commentaires autour des <hr/> dans le .html généré
        COMA="s§<span class=\"comment-delimiter\">/\*</span><a name\(.*\)><hr /></a><span class=\"comment\">\*/</span>§<a name\1><hr/></a>§g"

# Supprime les commentaires vides
        COMB="s§<span class=\"comment-delimiter\">/\*</span> *<span class=\"comment\">\*/</span>§§g"

# <url href="une adresse"/> est transformé par xsltproc en <url href="une adresse"></url>
# que je transforme en <a href="une adresse">une adresse</a>
        COMC="s§<url *href=\"\(.*\)\" *> *</url>§<br/><a href=\"\1\">\1</a>§g"

# <look href="une adresse#ancre"/> est transformé par xsltproc en <look href="une adresse#ancre"></url>
# que je transforme en "Look at <a href="une adresse#ancre">ancre</a>"
        COMD="s§<look href=\"\(.*\)#\(.*\)\"></look>§<br/>Look at <a href=\"\1#\2\">\2</a>§g"

        sed -e "$COMA;$COMB;$COMC;$COMD" "${module_dest}.html" > "${module_dest}.html.tmp" && mv "${module_dest}.html.tmp" "${module_dest}.html"

# *=======================================================*
# *..Génération de l'index des fonctions, constantes etc..*
# *=======================================================*

        # RES="../../../ressources/"

        out="${module_dest}"
        ficssext=`basename $out`
        ficssext=${ficssext%.*}
        dirout=`dirname "${module_dest}"`
        presentation="${dirout}/presentation"

# ------------
# * L'entête *
        cat>"${out}.xml"<<EOF
<?xml version="1.0" ?>
<?xml-stylesheet type="text/xsl" href="${RES}module-index-sign.xsl" ?>
<asy title="Index of ${ficssext}" date="`LANG=EN_US date`" resource="${RES}" filename="${ficssext}">
<asy-module>
EOF
# <presentation>`[ -e "$presentation" ] && cat "$presentation"`</presentation>

# ------------
# * Le corps *
        bodyinner "${module_dest}.sauv.html" >>"${out}.xml"
        cat>>"${out}.xml"<<EOF
</asy-module>
EOF

# -------------------------------
# * les exemples pour le module *
# le fichier ../modulename contient le nom du module (avec extension) illustré par les figures
        repfig="`dirname $out`/../"
        modulename="${repfig}modulename"
        if [ -e "$modulename" ]; then
            modulename="`cat $modulename`"
            if [ "$modulename" == "`basename $out`" ]; then
                (
                    echo "...Compilation des exmples..."
                    cd $repfig
                    make
                    i=10001
                    echo "...Récupération des exemples..."
                    for fic in `ls *.asy  2>/dev/null | sort` ; do
                        ficssext=${fic%.*}
                        ficssext=`basename $ficssext`
                        printf "${ficssext} "
                        cat>>"${out}.xml"<<EOF
<asy-example number="${i#1}" filename="${ficssext}" \
asyversion="`sed 's/ \[.*\]//g' ${ficssext}.ver`" `cat "${ficssext}.format"`>
EOF
    # ajout des balises <view.../> dans "out.xml"
                        bodyinner $ficssext.asy.html | awk -v FS="^Z" "/<view/,/\/>/" | grep -Eo "<view.*/>" >> "${out}.xml"
                        cat>>"${out}.xml"<<EOF
</asy-example>
EOF
                        i=$[$i+1]
                    done
                    echo
                    echo "...FIN récupération des exemples..."
                    )
            fi
        fi


        cat>>"${out}.xml"<<EOF
</asy>
EOF
        echo "Création de ${out}.sign/type.html"
        xsltproc --stringparam sortmethod ascending --stringparam sortby signature "${out}.xml" > "${out}.index.sign.html"
        xsltproc --stringparam sortmethod ascending --stringparam sortby type "${out}.xml" > "${out}.index.type.html"

        COMA="s§{*<span class=\"comment-delimiter\">/\*</span>§§g"

        COMB="s§<span class=\"comment\">\*/</span>§§g"

        # COME="s§<div class=\"documentation\">§<div class=\"documentation\">   §g"

# <url href="une adresse"/> est transformé par xsltproc en <url href="une adresse"></url>
# que je transforme en <a href="une adresse">une adresse</a>
        COMC="s§<url *href=\"\(.*\)\" *> *</url>§<a href=\"\1\">\1</a>§g"

        COMD="s§<look href=\"\(.*\)#\(.*\)\"></look>§Look at <a href=\"\1#\2\">\2</a>§g"

        COME="/^$/d"

        COMF="s§^ *</pre>§</pre>§g"

        cat "${out}.index.sign.html" | sed "$COMA;$COMB;$COMC;$COMD;$COME;$COMF" > "${out}_tmp" && mv "${out}_tmp" "${out}.index.sign.html"
        cat "${out}.index.type.html" | sed "$COMA;$COMB;$COMC;$COMD;$COME;$COMF" > "${out}_tmp" && mv "${out}_tmp" "${out}.index.type.html"

    fi

done

# Cas particuliers...
# Le module Lsystem.asy va dans le répertoir "lsystem".
[ Lsystem.asy -nt "${dest}../lsystem/Lsystem.asy" ] && cp Lsystem.asy "${dest}../lsystem/"

echo "#Terminé#"
