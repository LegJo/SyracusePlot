#!/bin/bash

ArgumentError() {														#fonction message d'erreur, d'erreur argument
	echo "Argument error: "
	echo "$1"
	tail +4 ../README | head -n 2
	echo "- you can use ./Syracuse.bash -h for more help"
}
																			#fonction de traçage de graphique avec gnuplot
TracGraphGnuplot() {  													#1er arg = nom fichier, 2eme arg=ylabel, 3eme arg=xlabel, 4eme =min(initial $1), 5eme= max(initial $2)
	gnuplot -persist <<-EOFMarker								
		set term jpeg size 800,600
		set offset 0,0,1,0
		set key top left 
		set output "$1.jpeg"
		set xrange [$4:$5]
		set xlabel "$3"
		set yrange [0:*]
		set ylabel "$2"
		set title "$2 en fonction de $3"
		plot "$1.dat" title "$2" w l  
		replot
		exit
	EOFMarker
}

nombre='^[0-9]+$'																      #expression reguliere d'un nombre entier positif
nombrewozero='^[1-9]([0-9]+)?$'                                     		 						      #expression reguliere d'un nombre entier positif (sans 0 devant, exemple: 010 n'est pas accepté par cette expression reg)

if [ $# -eq 1 ] && [ "$1" == "-h" ] 
then
	tail +4 ../README | head -n 8
	tail +13 ../README | head -n 1
elif [ $# -eq 1 ] && [ "$1" == "-clean" ] 									#option -clean 
then
	if [ -d jpegDir ]
	then 
		rm -r jpegDir
	fi
	if [ -d DossierTemporaireDesSuites ]
	then 
		rm -r DossierTemporaireDesSuites
	fi
	lsfic=`ls ../SyracuseScript`
	for i in $lsfic
	do
		if [ "./$i" != "$0" ]
		then 
			rm $i
		fi
	done 
	echo "Cleaning done"
elif [ $# -ne 2 ]														#verification des parametres d'entrer
then 
	echo "Error Syntaxe"
	if [ $# -lt 2 ]	
	then
		ArgumentError "not enough arguments"			
	else
		ArgumentError "too much arguments"
	fi
elif ! [[ $1 =~ $nombre ]] || ! [[ $2 =~ $nombre ]]       	  				    
then 
	ArgumentError "min or max is not un nombre entier positif"
elif ! [[ $1 =~ $nombrewozero ]] || ! [[ $2 =~ $nombrewozero ]] 
then
	if [ $1 -eq 0 ] || [ $2 -eq 0 ] 											
	then 
		ArgumentError "min or max is equal to 0"
	else
		ArgumentError "min or max have a zero as first digit"
	fi
elif [ $1 -gt $2 ] || [ $1 -eq $2 ] 
then 
	if [ $1 -eq $2 ] 
	then
		ArgumentError "min is equal to max"
	elif [ $1 -gt $2 ] 
	then
		ArgumentError "min is greater than max"
	fi
elif [ `dpkg -l | grep -c gnuplot` -eq 0 ]                                           			    #verification si le package gnuplot est installer sur la machine 
then
	echo "missing gnuplot package. please install gnuplot using :"
	echo "sudo apt install gnuplot"

#Fin de verification des arguments

else
	if [ $(( $2-$1 )) -ge 100000 ]                                                            			   #avertissement pour les appels avec des grand equart entre le min et le max
	then
		echo "difference between max and min is too big (more than 100 000) "
		echo "the process will last more than 10 minutes"
		echo "press Ctrl+C if you want to Cancel it before the end of the timer" ; sleep 4 
		echo "10" ; sleep 1 ; echo "9" ; sleep 1 ; echo "8" ; sleep 1 ; echo "7" ; sleep 1 ; echo "6" ; sleep 1 ; echo "5" ; sleep 1 ; echo "4" ; sleep 1 ; echo "3" ; sleep 1 ; echo "2" ; sleep 1 ; echo "1" ; sleep 1 ; echo "0" 
	fi
	if ! [[ -d jpegDir ]]
	then 
		mkdir jpegDir
	fi
	touch secur.dat ; rm *.dat					                     	  		#suppression des .dat et .jpeg restant des anciennes execs ( secur.dat et .jpeg sont là pour evité un retour de commande si il n'y a rien à supprimer)				
	touch jpegDir/secure.jpeg ; rm jpegDir/*.jpeg
	debut=$(date +%s)												#setup pour le temps d'execution 
	gcc ../SyracuseC/syracuse.c -o ../SyracuseC/Syracuse 			#appel de l'algo c et creation des fichiers suites 
	fichier="DossierTemporaireDesSuites"
	if [ -d $fichier ]
		then
			rm -Rf $fichier
	fi
	mkdir $fichier
	minDureeVol=0 ; maxDureeVol=0 ; moyDureeVol=0 ; somDureeVol=0								#initialisation des variables pour le fichiers Synthese de stats final (les minimums seront reinitialisés à la 1ere valeur correspondante juste en dessous)
	minDureeVolAlti=0 ; maxDureeVolAlti=0 ; moyDureeVolAlti=0 ; somDureeVolAlti=0
	minAlti=0 ; maxAlti=0 ; moyAlti=0 ; somAlti=0
	for i in $(seq $1 1 $2)
	do
		fic="f$i.dat"													#création des fichier .dat contenant les infos des graphics et recuperation des infos pour le fichier synthese-min-max.txt
		(../SyracuseC/Syracuse $i $fic)
		mv $fic $fichier/$fic
		liste=`tail -n -3 $fichier/$fic | cut -d "=" -f2`
		compteur=0
		for j in $liste
		do
			if [ $compteur -eq 0 ]
			then
				echo "$i $j" >> altimax.dat
				if [ $j -lt $minAlti ] || [ $i -eq $1 ] 
				then
					minAlti=$j
				elif [ $j -gt $maxAlti ]
				then
					maxAlti=$j
				fi
				somAlti=$(( somAlti+$j ))
			elif [ $compteur -eq 1 ]
			then
				echo "$i $j" >> dureevol.dat
				if [ $j -lt $minDureeVol ]  || [ $i -eq $1 ]
				then
					minDureeVol=$j
				elif [ $j -gt $maxDureeVol ]
				then
					maxDureeVol=$j
				fi
				somDureeVol=$(( somDureeVol+$j ))
			else
				echo "$i $j" >> dureevolaltitude.dat
				if [ $j -lt $minDureeVolAlti ]  || [ $i -eq $1 ]
				then
					minDureeVolAlti=$j
				elif [ $j -gt $maxDureeVolAlti ]
				then
					maxDureeVolAlti=$j
				fi
				somDureeVolAlti=$(( somDureeVolAlti+$j ))
			fi
			let compteur++
		done	
	done																								#écriture des graphiques
	
	TracGraphGnuplot "altimax" "Altitude Maximum" "U0" $1 $2									#Graphique Altitude Max
	TracGraphGnuplot "dureevol" "Duree De Vol" "U0" $1 $2										#Graphique Duree de vol
	TracGraphGnuplot "dureevolaltitude" "Duree max de vol en altitude" "U0" $1 $2			#Graphique Duree de vol max en Altitude
	
	for m in $(seq $1 1 $2)																			#Graphique de Toutes les suites 
		do
			fic="f$m.dat"
			head -n -3 $fichier/$fic | tail +2 > suite$m.dat
		done
	gnuplot -persist <<-EOFMarker
		set term jpeg size 800,600
		set offset 0,0,1,0
		unset key	
		set output "allsuites.jpeg"
		set xlabel "n"
		set yrange [0:*]
		set ylabel "Un"
		set title "Suites Un"
		plot for [j=$1:$2] 'suite'.j.'.dat' w l linetype 1 linecolor 1
		EOFMarker


	if ! [[ -d jpegDir ]]
	then
		mkdir jpegDir
	fi
	if ! [[ -d jpegDir/Graph-$1-$2 ]]	 	#mv des graphs finaux
	then
		mkdir jpegDir/Graph-$1-$2
	fi	
	mv *.jpeg jpegDir/Graph-$1-$2		
	

	echo "Valeurs entrées en paramètres : Min=$1 Max=$2" > synthese-$1-$2.txt		 #ecriture des statisqtiques de l'execution dans le fichier synthese-min-max.txt 
	
	echo "" >> synthese-$1-$2.txt
	echo "Max Altitude Maximale = $maxAlti" >> synthese-$1-$2.txt					
	echo "Min Altitude Maximale = $minAlti" >> synthese-$1-$2.txt
	moyAlti=$(( $somAlti/$(( $2-$1+1 )) )) 
	echo "Moyenne Altitudes Maximales= $moyAlti" >> synthese-$1-$2.txt
	
	echo "" >> synthese-$1-$2.txt
	echo "Max Durée de Vol = $maxDureeVol" >> synthese-$1-$2.txt
	echo "Min Durée de Vol = $minDureeVol" >> synthese-$1-$2.txt
	moyDureeVol=$(( $somDureeVol/$(( $2-$1+1 )) )) 
	echo "Moyenne Durée de Vol = $moyDureeVol" >> synthese-$1-$2.txt

	echo "" >> synthese-$1-$2.txt
	echo "Max Durée Plus Long Vol en Altitude = $maxDureeVolAlti" >> synthese-$1-$2.txt
	echo "Min Durée Plus Long Vol en Altitude = $minDureeVolAlti" >> synthese-$1-$2.txt
	moyDureeVolAlti=$(( $somDureeVolAlti/$(( $2-$1+1 )) )) 
	echo "Moyenne Durée Plus Long Vol en Altitude = $moyDureeVolAlti" >> synthese-$1-$2.txt
	
	if [ $(( $(date +%s ) - $debut )) -le 1 ]
	then
		echo "Temps d'execution : ≤1 seconde " 
		echo "Temps d'execution : ≤1 seconde " >> synthese-$1-$2.txt
	else
		echo "Temps d'execution : $(( $(date +%s ) - $debut )) secondes " 
		echo "Temps d'execution : $(( $(date +%s ) - $debut )) secondes " >> synthese-$1-$2.txt
	fi
	echo "" >> synthese-$1-$2.txt
	echo "Somme Total Altitudes = $somAlti " >> synthese-$1-$2.txt
	echo "Somme Total Durée de Vol = $somDureeVol " >> synthese-$1-$2.txt	
	echo "Somme Total Durée Plus Long Vol en Altitude = $somDureeVolAlti " >> synthese-$1-$2.txt
	
	#rm suite*.dat						#cleanning
	rm *.dat								
	rm -Rf $fichier
fi


	
