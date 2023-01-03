#include "Syracuse.h"

int main(int argc, char **argv)
{		 	 
	//Cette partie gère les erreurs d'arguments.
	char* mot = NULL;
	if( argc != 3)
	{
		printf("Veuillez entrer le bon nombre d'argument\n");
		exit(1);
	}
	else
	{
		mot = malloc(strlen(argv[1])*sizeof(char));
		
		if( mot == NULL)
		{
			printf("ERROR ALLOCATION\n");
			exit(0);
		}
		mot = strcpy(mot,argv[1]);
		for(int i=0;i<strlen(mot);i++)
		{
			if(mot[i] > 57 || mot[i] < 48 || strcmp(mot,"0") == 0)
			{
				printf("Veuillez entrer un argument valide\n");
				exit(2);
			}
		}
	}
	ecrireFichier(charToInt(mot),argv[2]);
	return 0;
}
	

//Cette fonction transforme un char nombre en son nombre int correspondant 
int charToInt(char* mot)
{
	int res = 0;
	if(mot==NULL)
	{
		printf("Probleme mot dans chatToInt\n");
		exit(EXIT_FAILURE);
	}
	for(int i=0;i<strlen(mot);i++)
		res = res*10 + charInt(mot[i]); // On multiplie par 10 puis on ajoute le chiffre suivant exemple 120: 0*10 + 1 -> 1*10 + 2 -> 12*10 + 0 -> 120
	return res;
}

//Cette fonction transforme un char chiffre (1-9) en son chiffre int correspondant
int charInt(char mot)
{
	return (int)mot -48;
}

void ecrireFichier(int u0,char* inputnamefile) //fonction pour ecrire le fichier suite
{
	//Declaration variable
	int altimax = u0;
	int dureevol = 0;
	int dureealtitude = 1;
	int un = u0;
	int cmp = 1;
	FILE *fichier = fopen(inputnamefile, "w+");
	
	//Ecriture fichier et calcul suite
	fprintf(fichier,"n un\n");
	fprintf(fichier,"%d %d\n",dureevol,u0);
	while (un != 1)
	{
		if(un%2 == 0) // Pair
		{
			un = un/2;
			dureevol++;
			if(un>=u0) //Ici on compte le nombre d'element pour duree vol altitude. Si en dessous de u0 on remet a 0.
				cmp++;
			else
				cmp=0;
			fprintf(fichier,"%d %d\n",dureevol,un);
		}
		else // Impair
		{
			un = 3*un + 1;
			dureevol++;
			if(un>=u0)//Meme chose que avant.
				cmp++;
			else
				cmp=0;
			if(un>altimax)
				altimax = un;
			fprintf(fichier,"%d %d\n",dureevol,un);
		}
		if(cmp>dureealtitude) // On change dureealtitude si on trouve un nombre d'occurence plus grand
			dureealtitude=cmp;
	}
	fprintf(fichier,"altimax=%d\n",altimax);
	fprintf(fichier,"dureevol=%d\n",dureevol);
	fprintf(fichier,"dureealtitude=%d",dureealtitude);
	fclose(fichier);
}
			
			
			


	
		
		
