@echo off
setlocal EnableDelayedExpansion
color 9e
mode con cols=60 lines=10
title poker hold'em
REM echo                        poker hold'em
:choix_nombre_IA
cls
echo Commandes utiles
echo.
echo coucher : c suivre : s 
echo doubler : d tapis  : t
echo.
rem debut du jeu, choix du nombre de joueurs

set nombre_bot=-1
set /p nombre_bot=Combien d'IA voulez vous ? : 
if %nombre_bot% lss 0 goto :choix_nombre_IA
if %nombre_bot% gtr 22 (
echo maximum 22 IA
goto :choix_nombre_IA )
set /a nombre_max_joueur=22-%nombre_bot%
:choix_nombre_joueur
set nombre_joueur_reel=0
if %nombre_max_joueur% neq 0 set /p nombre_joueur_reel=Combien de joueurs ? :
REM set nombre_joueur=10
REM set nombre_joueur=2
if %nombre_bot%==0 if %nombre_joueur_reel% leq 0 goto :choix_nombre_joueur
if %nombre_bot% neq 0 if %nombre_joueur_reel% lss 0 goto :choix_nombre_joueur
if %nombre_joueur_reel% gtr !nombre_max_joueur! (
echo maximum !nombre_max_joueur! joueurs
goto :choix_nombre_joueur )
set /a nombre_joueur=!nombre_joueur_reel!+!nombre_bot!
REM for /L %%i in (1,1,!nombre_joueur_reel!) do set surnom%%i=joueur %%i
set /a nombre_bot=!nombre_joueur_reel!+1
for /L %%i in (!nombre_bot!,1,!nombre_joueur!) do set surnom%%i=IA %%i
cls
if %nombre_joueur_reel%==0 goto end_boucle_surnom
set acrem=1
:boucle_surnom
set /p surnom%acrem%=Nom du joueur %acrem% : 
set verif=!surnom%acrem%!
for /f "tokens=1,* delims=[,]" %%A in ('"%comspec% /u /c echo:%verif%|more|find /n /v """') do set /a max2=%%A-4
cls
if %max2% gtr 10 echo Ce nom est trop long : 10 caractŠre max&goto boucle_surnom
if %max2% lss 3 echo Ce nom est trop cour : 3 caractŠre min&goto boucle_surnom
set /a acrem+=1
if !acrem! gtr !nombre_joueur_reel! goto end_boucle_surnom
goto boucle_surnom
:end_boucle_surnom
set /a lines=6+2*!nombre_joueur!
mode con cols=60 lines=!lines!
rem ajouter choix nombre jeton ?
for /L %%i in (1,1,!nombre_joueur!) do set jeton[%%i]=500& set exclut[%%i]=0
rem debut du tour, il faut que tout ce qui est en dessous soit un call  donc en dessous de end
set rotation=0
:tour_jeu
for /L %%i in (1,1,!nombre_joueur!) do set couche[%%i]=0
set /a rotation+=1
call :boucle_rotation
rem attention erreur, premier tour joueur a gauche de grosse blind, puis apres joueur a gauche de dealer
set /a blind_temp=!rotation!-1
call :boucle_blind
set big_blind=!blind_temp!
set /a blind_temp=!big_blind!-1
call :boucle_blind
set small_blind=!blind_temp!
REM echo rot !rotation! small !small_blind! big !big_blind!
REM pause
cls
echo                        Debut du tour
echo.
set pot=0
set compteur=0
REM echo creation du deck
for /L %%i in (1,1,7) do for /L %%j in (0,1,!nombre_joueur!) do set main%%i[%%j]=
set nombre_carte=0
for %%a in (A A A A 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 J J J J Q Q Q Q K K K K) do set /a nombre_carte+=1& set carte[!nombre_carte!]=%%a
REM call :affichage_cartes
rem boucle qui distribue les deux cartes … chaque joueurs
if !nombre_joueur! neq 2 (
for /L %%i in (!small_blind!,1,!nombre_joueur!) do if !exclut[%%i]!==0 set nom_joueur=%%i& call :ajout_carte
set /a small_blind_1=!small_blind!-1
for /L %%i in (1,1,!small_blind_1!) do if !exclut[%%i]!==0 set nom_joueur=%%i& call :ajout_carte)
if !nombre_joueur!==2 ( set nom_joueur=!big_blind!& call :ajout_carte
set nom_joueur=!small_blind!& call :ajout_carte
)
rem on choisi la carte puis la boucle choisi le joueur et on enleve la carte du deck
REM call :affichage_cartes
set flop_max=0
set nombre_mise=0
call :choix_affichage_main
set nombre_exclut=0
for /L %%i in (1,1,!nombre_joueur!) do (
REM echo if !exclut[%%i]!==1 set /a nombre_exclut+=1
if !exclut[%%i]!==1 set /a nombre_exclut+=1
)
set /a petite_blinde=5*(1+!nombre_exclut!)
set /a grosse_blinde=10*(1+!nombre_exclut!)
REM echo !petite_blinde! et !grosse_blinde!
REM pause
set mise_min=!grosse_blinde!
set minimum_mise=!grosse_blinde!
for /L %%i in (1,1,!nombre_joueur!) do set mise[%%i]=0& set deja_jouer[%%i]=0& set couche[%%i]=0
if !jeton[%small_blind%]! lss !petite_blinde! set /a mise[%small_blind%]+=!jeton[%small_blind%]!& set /a jeton[%small_blind%]=0& set /a pot+=!jeton[%small_blind%]!
if !jeton[%big_blind%]! lss !grosse_blinde! set /a mise[%big_blind%]+=!jeton[%big_blind%]!& set /a jeton[%big_blind%]=0& set /a pot+=!jeton[%big_blind%]!
if !jeton[%small_blind%]! geq !petite_blinde! set /a jeton[%small_blind%]-=!petite_blinde!& set /a mise[%small_blind%]+=!petite_blinde!& set /a pot+=!petite_blinde!
if !jeton[%big_blind%]! geq !grosse_blinde! set /a jeton[%big_blind%]-=!grosse_blinde!& set /a mise[%big_blind%]+=!grosse_blinde!& set /a pot+=!grosse_blinde!
set first_round=1
call :mise_complete
set first_round=0
if !nombre_joueur!==2 ( set /a rotation+=1 
if !rotation! gtr 2  set rotation=1
)
call :brule
rem creer les 3 cartes du flop
set nom_joueur=0
for /L %%i in (1,1,3) do set numero_main=main%%i& call :ajout_main_joueur& call :destruction_carte
set flop_max=3
REM set main
REM set flop
REM pause
call :choix_affichage_main
for /L %%i in (1,1,!nombre_joueur!) do set deja_jouer[%%i]=0
call :mise_complete
call :brule
set nom_joueur=0
set numero_main=main4
set flop_max=4
call :ajout_main_joueur
call :destruction_carte
call :choix_affichage_main
for /L %%i in (1,1,!nombre_joueur!) do set deja_jouer[%%i]=0
call :mise_complete
call :brule
set nom_joueur=0
set numero_main=main5
set flop_max=5
call :ajout_main_joueur
call :destruction_carte
REM set main
REM set flop
REM pause
call :choix_affichage_main
for /L %%i in (1,1,!nombre_joueur!) do set deja_jouer[%%i]=0
call :mise_complete
cls
echo river		!main1[0]! !main2[0]! !main3[0]! !main4[0]! !main5[0]!

for /L %%k in (1,1,!nombre_joueur!) do set pot%%k=0
for /L %%k in (1,1,!nombre_joueur!) do for /L %%j in (1,1,!nombre_joueur!) do (
if !mise[%%j]! neq !pot1! if !mise[%%j]! neq !pot2! if !mise[%%j]! neq !pot3! if !mise[%%j]! neq !pot4! if !mise[%%j]! neq !pot5! if !mise[%%j]! neq !pot6! if !mise[%%j]! neq !pot7! if !mise[%%j]! neq !pot8! if !mise[%%j]! neq !pot9! if !mise[%%j]! neq !pot11! if !mise[%%j]! neq !pot12! if !mise[%%j]! neq !pot13! if !mise[%%j]! neq !pot14! if !mise[%%j]! neq !pot15! if !mise[%%j]! neq !pot16! if !mise[%%j]! neq !pot17! if !mise[%%j]! neq !pot18! if !mise[%%j]! neq !pot19! if !mise[%%j]! neq !pot20! if !mise[%%j]! neq !pot21! if !mise[%%j]! neq !pot22! if !mise[%%j]! gtr !pot%%k! set pot%%k=!mise[%%j]!
)

for /L %%i in (1,1,!nombre_joueur!) do (
set /a nombre_acceptation[%%i]=0
for /L %%k in (1,1,!nombre_joueur!) do set acceptation[%%k][%%i]=0
)
for /L %%k in (!nombre_joueur!,-1,1) do set k=%%k& call :boucle_multi_pot
for /L %%k in (1,1,!nombre_joueur!) do set /a pot%%k=!pot%%k!*!nombre_acceptation[%%k]! 
REM echo set /a pot%%k=!pot%%k!*!nombre_acceptation[%%k]!
for /L %%i in (1,1,6) do set best0[%%i]=0
for /L %%i in (0,1,!nombre_joueur!) do set best1[%%i]=0
set nombre_gagnant=1
echo.
for /L %%i in (1,1,!nombre_joueur!) do if !exclut[%%i]!==0 if !couche[%%i]!==0 set nom_joueur=%%i& call :verification_main
for /L %%i in (1,1,!nombre_joueur!) do if !exclut[%%i]!==0 if !couche[%%i]!==0 set nom_joueur=%%i& call :verif_gagnant& call :changer_cartes
set gagnants=
if !nombre_gagnant! neq 1 set gagnants=!gagnants!!surnom%gagnant[1]%!& for /L %%i in (2,1,!nombre_gagnant!) do set nom_joueur=!gagnant[%%i]!& call :assemblage_nom
if !nombre_gagnant!==1 echo le gagnant de cette manche est !surnom%gagnant[1]%!& set nom_joueur=!gagnant[1]!
if !nombre_gagnant! neq 1 echo Les gagnants de cette manche sont : & echo !gagnants!
echo.
pause>nul
cls
echo jetons restants
echo.
for /L %%k in (1,1,!nombre_joueur!) do set nombre_gagnant[%%k]=0& set nombre_remboursement[%%k]=0& set pot_temp%%k=0&set validation_remboursement[%%k]=1
for /L %%i in (1,1,!nombre_gagnant!) do set nom_joueur=!gagnant[%%i]!& call :repartition_gain
for /L %%i in (1,1,!nombre_gagnant!) do set nom_joueur=!gagnant[%%i]!& call :ajout_gain

for /L %%i in (1,1,!nombre_joueur!) do set nom_joueur=%%i& call :repartition_remboursement
for /L %%i in (1,1,!nombre_joueur!) do set nom_joueur=%%i& call :ajout_remboursement

for /L %%i in (1,1,!nombre_joueur!) do if !exclut[%%i]!==0 echo !surnom%%i! : !jeton[%%i]!& echo.
REM call :affichage_cartes
set compteur=1
for /L %%i in (1,1,!nombre_joueur!) do if !jeton[%%i]!==0 set /a compteur+=1& set exclut[%%i]=1& set mise[%%i]=0
echo.
if !compteur! geq !nombre_joueur! for /L %%i in (1,1,!nombre_joueur!) do if !jeton[%%i]! neq 0 echo !surnom%%i! a gagn‚& pause>nul& exit
pause>nul& goto tour_jeu

:boucle_multi_pot
set /a k1=!k!-1
for /L %%i in (!k1!,-1,1) do set /a pot%%i=!pot%%i!-!pot%k%!
for /L %%i in (1,1,!nombre_joueur!) do if !mise[%%i]! geq !pot%k%! (
REM echo avant %%i et %k% : if !mise[%%i]! geq !pot%k%! set /a mise[%%i]=!mise[%%i]!-!pot%k%!
set /a mise[%%i]=!mise[%%i]!-!pot%k%!
set acceptation[%k%][%%i]=1
set /a nombre_acceptation[%k%]+=1)
goto :eof

:repartition_gain
for /L %%k in (1,1,!nombre_joueur!) do if !acceptation[%%k][%nom_joueur%]!==1 set /a nombre_gagnant[%%k]+=1&set validation_remboursement[%%k]=0
goto :eof

:ajout_gain
for /L %%k in (1,1,!nombre_joueur!) do if !acceptation[%%k][%nom_joueur%]!==1 set /a jeton[%nom_joueur%]=!jeton[%nom_joueur%]!+!pot%%k!/!nombre_gagnant[%%k]!
goto :eof

:repartition_remboursement
rem pour chaque joueur, et chaque pot, si le pot peut etre pris et si le joueur peut le prend et si le joueur ne fait pas parti des gagnants alors +1 pretendant pour le pot k
for /L %%k in (1,1,!nombre_joueur!) do (
set eligible[%%k][%nom_joueur%]=0
if !validation_remboursement[%%k]!==1 if !acceptation[%%k][%nom_joueur%]!==1 (
set eligible[%%k][%nom_joueur%]=1
for /L %%i in (1,1,!nombre_joueur!) do if %nom_joueur%==!gagnant[%%i]! set eligible[%%k][%nom_joueur%]=0
if !eligible[%%k][%nom_joueur%]!==1 set /a nombre_remboursement[%%k]+=1 
REM echo pot nø%%k joueur nø%nom_joueur% remboursement:!nombre_remboursement[%%k]! pour le pot de !pot%%k!
))
goto :eof

:ajout_remboursement
for /L %%k in (1,1,!nombre_joueur!) do (
if !nombre_remboursement[%%k]! neq 0 (
if !eligible[%%k][%nom_joueur%]!==1 set /a jeton[%nom_joueur%]=!jeton[%nom_joueur%]!+!pot%%k!/!nombre_remboursement[%%k]!)
)
goto :eof

:assemblage_nom
set gagnants=!gagnants!,!surnom%nom_joueur%!
goto :eof

:verif_gagnant
if !best1[%nom_joueur%]!==!best0[1]! if !best2[%nom_joueur%]!==!best0[2]! if !best3[%nom_joueur%]!==!best0[3]! if !best4[%nom_joueur%]!==!best0[4]! if !best5[%nom_joueur%]!==!best0[5]! if !best6[%nom_joueur%]!==!best0[6]! set /a nombre_gagnant+=1& call :gagnant
if !best1[%nom_joueur%]!==!best0[1]! if !best2[%nom_joueur%]!==!best0[2]! if !best3[%nom_joueur%]!==!best0[3]! if !best4[%nom_joueur%]!==!best0[4]! if !best5[%nom_joueur%]!==!best0[5]! if !best6[%nom_joueur%]! gtr !best0[6]! call :ante_gagnant
if !best1[%nom_joueur%]!==!best0[1]! if !best2[%nom_joueur%]!==!best0[2]! if !best3[%nom_joueur%]!==!best0[3]! if !best4[%nom_joueur%]!==!best0[4]! if !best5[%nom_joueur%]! gtr !best0[5]! call :ante_gagnant
if !best1[%nom_joueur%]!==!best0[1]! if !best2[%nom_joueur%]!==!best0[2]! if !best3[%nom_joueur%]!==!best0[3]! if !best4[%nom_joueur%]! gtr !best0[4]! call :ante_gagnant
if !best1[%nom_joueur%]!==!best0[1]! if !best2[%nom_joueur%]!==!best0[2]! if !best3[%nom_joueur%]! gtr !best0[3]! call :ante_gagnant
if !best1[%nom_joueur%]!==!best0[1]! if !best2[%nom_joueur%]! gtr !best0[2]! call :ante_gagnant
if !best1[%nom_joueur%]! gtr !best0[1]! call :ante_gagnant
goto :eof

:ante_gagnant
set nombre_gagnant=1
for /L %%i in (1,1,!nombre_joueur!) do set gagnant[%%i]=0
:gagnant
for /L %%i in (1,1,6) do set best0[%%i]=!best%%i[%nom_joueur%]!
set gagnant[!nombre_gagnant!]=!nom_joueur!
goto :eof

:changer_cartes
for /L %%j in (1,1,10) do (
if !best2[%nom_joueur%]!==%%j set affichage_carte2=de %%j
if !best3[%nom_joueur%]!==%%j set affichage_carte3=%%j
)
if !best2[%nom_joueur%]!==11 set affichage_carte2=de valet
if !best2[%nom_joueur%]!==12 set affichage_carte2=de reine
if !best2[%nom_joueur%]!==13 set affichage_carte2=de roi
if !best2[%nom_joueur%]!==14 set affichage_carte2=d'as
if !best1[%nom_joueur%]!==5 if !best2[%nom_joueur%]!==14 set affichage_carte2=royale
if !best1[%nom_joueur%]!==9 if !best2[%nom_joueur%]!==14 set affichage_carte2=royale
if !best3[%nom_joueur%]!==11 set affichage_carte3=valet
if !best3[%nom_joueur%]!==12 set affichage_carte3=reine
if !best3[%nom_joueur%]!==13 set affichage_carte3=roi
if !best3[%nom_joueur%]!==14 set affichage_carte3=as


if !best1[%nom_joueur%]!==1 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	carte forte !affichage_carte2!
if !best1[%nom_joueur%]!==2 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	paire !affichage_carte2!
if !best1[%nom_joueur%]!==3 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	paires !affichage_carte2! et !affichage_carte3!
if !best1[%nom_joueur%]!==4 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	brelan !affichage_carte2!
if !best1[%nom_joueur%]!==5 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	suite !affichage_carte2!
if !best1[%nom_joueur%]!==6 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	couleur
if !best1[%nom_joueur%]!==7 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	full !affichage_carte2! et !affichage_carte3!
if !best1[%nom_joueur%]!==8 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	carr‚ !affichage_carte2!
if !best1[%nom_joueur%]!==9 echo !surnom%nom_joueur%!     	!main1[%nom_joueur%]! !main2[%nom_joueur%]!    	quinte-flush !affichage_carte2!
echo.
goto :eof

:verification_main
for /L %%i in (1,1,6) do set best%%i[%nom_joueur%]=0
for /L %%i in (1,1,7) do (
set chiffre%%i[%nom_joueur%]=!main%%i[%nom_joueur%]:~0,-1!
set type%%i[%nom_joueur%]=!main%%i[%nom_joueur%]:~-1!
if !chiffre%%i[%nom_joueur%]!==J set chiffre%%i[%nom_joueur%]=11
if !chiffre%%i[%nom_joueur%]!==Q set chiffre%%i[%nom_joueur%]=12
if !chiffre%%i[%nom_joueur%]!==K set chiffre%%i[%nom_joueur%]=13
if !chiffre%%i[%nom_joueur%]!==A set chiffre%%i[%nom_joueur%]=14
if !type%%i[%nom_joueur%]!== set type%%i[%nom_joueur%]=A
if !type%%i[%nom_joueur%]!== set type%%i[%nom_joueur%]=B
if !type%%i[%nom_joueur%]!== set type%%i[%nom_joueur%]=C
if !type%%i[%nom_joueur%]!== set type%%i[%nom_joueur%]=D
REM echo !main%%i[%nom_joueur%]!
)
REM set main1[1]=valet& set main2[1]=valet& set main1[2]=valet& set main2[2]=valet& set chiffre1[3]=14& set chiffre2[3]=14& set chiffre1[2]=14& set chiffre2[2]=14& set chiffre1[1]=14& set chiffre2[1]=14& set chiffre0[1]=3& set chiffre0[2]=2& set chiffre0[3]=14& set chiffre0[4]=3& set chiffre0[5]=2& set type1[1]=C& set type2[1]=D& set type0[1]=B& set type0[2]=B& set type0[3]=B& set type0[4]=B& set type0[5]=B
set paire_sup1[%nom_joueur%]=0& set paire_sup2[%nom_joueur%]=0& set full_sup1[%nom_joueur%]=0& set full_sup2[%nom_joueur%]=0& set carre[%nom_joueur%]=0& set brelan[1][%nom_joueur%]=0
REM set brelan[2][%nom_joueur%]=0& set paire[1][%nom_joueur%]=0& set paire[2][%nom_joueur%]=0& set paire[3][%nom_joueur%]=0
for /L %%j in (1,1,7) do set carte_forte%%j[%nom_joueur%]=0
for /L %%i in (1,1,6) do set best%%i[%nom_joueur%]=0
set gagnant[%nom_joueur%]=0
rem verif si couleur ou suite_couleur
for %%a in (A B C D) do (
set couleur%%a[%nom_joueur%]=0
for /L %%i in (1,1,7) do if !type%%i[%nom_joueur%]!==%%a set /a couleur%%a[%nom_joueur%]+=1
if !couleur%%a[%nom_joueur%]! geq 5 (
rem verif si suite_couleur
for /L %%k in (1,1,5) do for /L %%j in (1,1,7) do if !type%%j[%nom_joueur%]!==%%a if !chiffre%%j[%nom_joueur%]! neq !carte_forte1[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte2[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte3[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte4[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte5[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! gtr !carte_forte%%k[%nom_joueur%]! set carte_forte%%k[%nom_joueur%]=!chiffre%%j[%nom_joueur%]!
if !carte_forte1[%nom_joueur%]!==14  set carte_forte6[%nom_joueur%]=1
for /L %%i in (2,1,6) do set /a suite%%i=!carte_forte%%i[%nom_joueur%]!+1
if !carte_forte1[%nom_joueur%]!==!suite2! if !carte_forte2[%nom_joueur%]!==!suite3! if !carte_forte3[%nom_joueur%]!==!suite4! if !carte_forte4[%nom_joueur%]!==!suite5! set best1[%nom_joueur%]=9& set best2[%nom_joueur%]=!carte_forte1[%nom_joueur%]!& goto :eof
if !carte_forte2[%nom_joueur%]!==!suite3! if !carte_forte3[%nom_joueur%]!==!suite4! if !carte_forte4[%nom_joueur%]!==!suite5! if !carte_forte5[%nom_joueur%]!==!suite6! set best1[%nom_joueur%]=9& set best2[%nom_joueur%]=!carte_forte2[%nom_joueur%]!& goto :eof

rem couleur
set best1[%nom_joueur%]=6& set best2[%nom_joueur%]=!carte_forte1[%nom_joueur%]!& set best3[%nom_joueur%]=!carte_forte2[%nom_joueur%]!& set best4[%nom_joueur%]=!carte_forte3[%nom_joueur%]!& set best5[%nom_joueur%]=!carte_forte4[%nom_joueur%]!& set best6[%nom_joueur%]=!carte_forte5[%nom_joueur%]!& goto :eof)
)

rem verif suite
for /L %%k in (1,1,7) do set k=%%k& call :nombre_carte_forte
REM echo suite possible !carte_forte1[%nom_joueur%]!, !carte_forte2[%nom_joueur%]!, !carte_forte3[%nom_joueur%]!, !carte_forte4[%nom_joueur%]!, !carte_forte5[%nom_joueur%]!, !carte_forte6[%nom_joueur%]!, !carte_forte7[%nom_joueur%]!
if !carte_forte1[%nom_joueur%]!==14  set carte_forte6[%nom_joueur%]=1
for /L %%i in (2,1,8) do set /a suite%%i=!carte_forte%%i[%nom_joueur%]!+1
if !carte_forte1[%nom_joueur%]!==!suite2! if !carte_forte2[%nom_joueur%]!==!suite3! if !carte_forte3[%nom_joueur%]!==!suite4! if !carte_forte4[%nom_joueur%]!==!suite5! set best1[%nom_joueur%]=5& set best2[%nom_joueur%]=!carte_forte1[%nom_joueur%]!& goto :eof
if !carte_forte2[%nom_joueur%]!==!suite3! if !carte_forte3[%nom_joueur%]!==!suite4! if !carte_forte4[%nom_joueur%]!==!suite5! if !carte_forte5[%nom_joueur%]!==!suite6! set best1[%nom_joueur%]=5& set best2[%nom_joueur%]=!carte_forte2[%nom_joueur%]!& goto :eof
if !carte_forte3[%nom_joueur%]!==!suite4! if !carte_forte4[%nom_joueur%]!==!suite5! if !carte_forte5[%nom_joueur%]!==!suite6! if !carte_forte6[%nom_joueur%]!==!suite7! set best1[%nom_joueur%]=5& set best2[%nom_joueur%]=!carte_forte3[%nom_joueur%]!& goto :eof
if !carte_forte4[%nom_joueur%]!==!suite5! if !carte_forte5[%nom_joueur%]!==!suite6! if !carte_forte6[%nom_joueur%]!==!suite7! if !carte_forte7[%nom_joueur%]!==!suite8! set best1[%nom_joueur%]=5& set best2[%nom_joueur%]=!carte_forte4[%nom_joueur%]!& goto :eof
for /L %%j in (1,1,7) do set carte_forte%%j[%nom_joueur%]=0

rem verif si paire ou brelan ou full
set num_paire=0
set num_brelan=0
for /L %%i in (2,1,14) do set numero_carte=%%i& call :verif_multiple
if !num_paire!==1 (
set paire_sup1[%nom_joueur%]=!paire[1][%nom_joueur%]!
for /L %%k in (1,1,3) do set k=%%k& call :nombre_carte_forte
if !num_brelan!==0 set best1[%nom_joueur%]=2& set best2[%nom_joueur%]=!paire_sup1[%nom_joueur%]!& set best3[%nom_joueur%]=!carte_forte1[%nom_joueur%]!& set best4[%nom_joueur%]=!carte_forte2[%nom_joueur%]!& set best5[%nom_joueur%]=!carte_forte3[%nom_joueur%]!& set best6[%nom_joueur%]=0
)

if !num_paire! geq 2 (
for /L %%j in (1,1,3) do if !paire[%%j][%nom_joueur%]! gtr !paire_sup1[%nom_joueur%]! set paire_sup1[%nom_joueur%]=!paire[%%j][%nom_joueur%]!
for /L %%j in (1,1,3) do if !paire[%%j][%nom_joueur%]! neq !paire_sup1[%nom_joueur%]! if !paire[%%j][%nom_joueur%]! gtr !paire_sup2[%nom_joueur%]! set paire_sup2[%nom_joueur%]=!paire[%%j][%nom_joueur%]!
set k=1& call :nombre_carte_forte
if !num_brelan!==0 set best1[%nom_joueur%]=3& set best2[%nom_joueur%]=!paire_sup1[%nom_joueur%]!& set best3[%nom_joueur%]=!paire_sup2[%nom_joueur%]!& set best4[%nom_joueur%]=!carte_forte1[%nom_joueur%]!& set best5[%nom_joueur%]=0& set best6[%nom_joueur%]=0)

if !num_brelan!==1 (
if !num_paire!==0 (
for /l %%k in (1,1,2) do set k=%%k& call :nombre_carte_forte
set best1[%nom_joueur%]=4& set best2[%nom_joueur%]=!brelan[1][%nom_joueur%]!& set best3[%nom_joueur%]=!carte_forte1[%nom_joueur%]!& set best4[%nom_joueur%]=!carte_forte2[%nom_joueur%]!& set best5[%nom_joueur%]=0& set best6[%nom_joueur%]=0
)
if !num_paire! geq 1 (
set full_sup1[%nom_joueur%]=!brelan[1][%nom_joueur%]!
set full_sup2[%nom_joueur%]=!paire_sup1[%nom_joueur%]!
set best1[%nom_joueur%]=7& set best2[%nom_joueur%]=!full_sup1[%nom_joueur%]!& set best3[%nom_joueur%]=!full_sup2[%nom_joueur%]!& set best4[%nom_joueur%]=0& set best5[%nom_joueur%]=0& set best6[%nom_joueur%]=0)
)

if !num_brelan!==2 (
for /L %%j in (1,1,2) do if !brelan[%%j][%nom_joueur%]! gtr !full_sup1[%nom_joueur%]! set full_sup1[%nom_joueur%]=!brelan[%%j][%nom_joueur%]!
for /L %%j in (1,1,2) do if !brelan[%%j][%nom_joueur%]! neq !full_sup1[%nom_joueur%]! if !brelan[%%j][%nom_joueur%]! gtr !full_sup2[%nom_joueur%]! set full_sup2[%nom_joueur%]=!brelan[%%j][%nom_joueur%]!
set best1[%nom_joueur%]=7& set best2[%nom_joueur%]=!full_sup1[%nom_joueur%]!& set best3[%nom_joueur%]=!full_sup2[%nom_joueur%]!& set best4[%nom_joueur%]=0& set best5[%nom_joueur%]=0& set best6[%nom_joueur%]=0
)
if !best1[%nom_joueur%]! leq 1 (
for /L %%k in (1,1,5) do set k=%%k& call :nombre_carte_forte
set best1[%nom_joueur%]=1& set best2[%nom_joueur%]=!carte_forte1[%nom_joueur%]!& set best3[%nom_joueur%]=!carte_forte2[%nom_joueur%]!& set best4[%nom_joueur%]=!carte_forte3[%nom_joueur%]!& set best5[%nom_joueur%]=!carte_forte4[%nom_joueur%]!& set best6[%nom_joueur%]=!carte_forte5[%nom_joueur%]!)
goto :eof

:nombre_carte_forte
for /L %%j in (1,1,7) do if !chiffre%%j[%nom_joueur%]! neq !carre[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !brelan[1][%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !paire_sup1[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !paire_sup2[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte1[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte2[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte3[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte4[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte5[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte6[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! neq !carte_forte7[%nom_joueur%]! if !chiffre%%j[%nom_joueur%]! gtr !carte_forte%k%[%nom_joueur%]! set carte_forte%k%[%nom_joueur%]=!chiffre%%j[%nom_joueur%]!
goto :eof

:verif_multiple
set multiple!numero_carte![%nom_joueur%]=0
for /L %%j in (1,1,7) do if !chiffre%%j[%nom_joueur%]!==!numero_carte! set /a multiple%numero_carte%[%nom_joueur%]+=1
if !multiple%numero_carte%[%nom_joueur%]!==4 (
set carre[%nom_joueur%]=!numero_carte!
set k=1& call :nombre_carte_forte
set best1[!nom_joueur!]=8& set best2[%nom_joueur%]=!numero_carte!& set best3[!nom_joueur!]=!carte_forte1[%nom_joueur%]!& set best4[!nom_joueur!]=0& set best5[!nom_joueur!]=0& set best6[!nom_joueur!]=0
)
if !multiple%numero_carte%[%nom_joueur%]!==2 set /a num_paire+=1& set paire[!num_paire!][!nom_joueur!]=!numero_carte!
if !multiple%numero_carte%[%nom_joueur%]!==3 set /a num_brelan+=1& set brelan[!num_brelan!][!nom_joueur!]=!numero_carte!
goto :eof

:boucle_rotation
if !rotation! gtr !nombre_joueur! set rotation=1
if !exclut[%rotation%]!==0 goto :eof
if !exclut[%rotation%]!==1 set /a rotation+=1
goto :eof

:boucle_blind
if !blind_temp! lss  1 set blind_temp=!nombre_joueur!
if !exclut[%blind_temp%]!==0 goto :eof
if !exclut[%blind_temp%]!==1 set /a blind_temp-=1
goto :eof

:mise_complete
set nom_joueur=0
call :verification_main
REM echo flop !best1[0]!,!best2[0]!,!best3[0]!,!best4[0]!,!best5[0]!,!best6[0]!
REM pause
set compteur=!nombre_joueur!
for /L %%i in (1,1,!nombre_joueur!) do if !exclut[%%i]!==1 set /a compteur-=1
for /L %%i in (1,1,!nombre_joueur!) do if !couche[%%i]!==1 set /a compteur-=1
for /L %%i in (1,1,!nombre_joueur!) do if !couche[%%i]!==0 if !exclut[%%i]!==0 if !jeton[%%i]!==0 set /a compteur-=1
if !compteur!==0 goto :eof
if !compteur!==1 goto :eof
rem attention il me semble que sa buger ici et qu'il fallait metre les boucles en dessous de mise_boucle juste avant goto eof
set premier_tour=0
set /a nombre_mise+=1
for /L %%i in (1,1,!nombre_joueur!) do if couche[%%i]==0 if exclut[%%i]==0 set deja_jouer[%%i]=0
for /L %%i in (!nombre_bot!,1,!nombre_joueur!) do set tour_bot[%%i]=0
call :mise_boucle
cls
goto :eof

:mise_boucle
if !first_round!==0 if !premier_tour!==0 for /L %%i in (!small_blind!,1,!nombre_joueur!) do if !jeton[%%i]! neq 0 set nom_joueur=%%i& call :choix_mise
if !first_round!==1 if !premier_tour!==0 for /L %%i in (!rotation!,1,!nombre_joueur!) do if !jeton[%%i]! neq 0 set nom_joueur=%%i& call :choix_mise
set premier_tour=1
for /L %%i in (1,1,!nombre_joueur!) do if !jeton[%%i]! neq 0 set nom_joueur=%%i& call :choix_mise
for /L %%i in (1,1,!nombre_joueur!) do if !deja_jouer[%%i]! neq 0 if !jeton[%%i]! neq 0 if !exclut[%%i]!==0 if !couche[%%i]!==0 if !mise[%%i]! neq !mise_min! goto mise_boucle
goto :eof

:choix_mise
cls
set compteur=!nombre_joueur!
for /L %%i in (1,1,!nombre_joueur!) do if !exclut[%%i]!==1 set /a compteur-=1
for /L %%i in (1,1,!nombre_joueur!) do if !couche[%%i]!==1 set /a compteur-=1
REM echo if !compteur!==1 goto :eof
REM pause>nul
if !compteur!==1 goto :eof
rem permet de sortir de choix_mise
if !exclut[%nom_joueur%]! neq 0 goto :eof
if !couche[%nom_joueur%]! neq 0 goto :eof
if !mise[%nom_joueur%]!==!mise_min! if !deja_jouer[%nom_joueur%]!==1 goto :eof
if !nombre_mise!==1 echo                        mise pr‚-flop
if !nombre_mise!==2 echo                        mise flop
if !nombre_mise!==3 echo                        mise turn
if !nombre_mise!==4 echo                        mise river
echo.
set deja_jouer[%nom_joueur%]=0
set ancienne_mise[%nom_joueur%]=!mise[%nom_joueur%]!
set /a diff_min_mise=!mise_min!-!mise[%nom_joueur%]!
echo Nombres de jetons
echo restant : !jeton[%nom_joueur%]! , pot : !pot!
if !jeton[%nom_joueur%]! gtr !diff_min_mise! echo d‚j… mis‚ : !mise[%nom_joueur%]! , suivre : !diff_min_mise!
if !jeton[%nom_joueur%]! leq !diff_min_mise! ( echo d‚j… mis‚ : !mise[%nom_joueur%]! , tapis : !jeton[%nom_joueur%]!
set diff_min_mise=!jeton[%nom_joueur%]!)
set nouvelle_mise[%nom_joueur%]=-1

if %nom_joueur% geq %nombre_bot% (
if !tour_bot[%nom_joueur%]!==0 call :verification_main
REM echo joueur %nom_joueur% a !best1[%nom_joueur%]! tour !tour_bot[%nom_joueur%]!
set nouvelle_mise[%nom_joueur%]=0
set /a double_blind=!grosse_blinde!*2
set /a rand=%random%%%4
if !tour_bot[%nom_joueur%]!==0 (
if !flop_max! leq 3 set nouvelle_mise[%nom_joueur%]=s
if !diff_min_mise!==0 if !rand! leq 1 set /a nouvelle_mise[%nom_joueur%]=!petite_blinde!+!petite_blinde!*!rand!
if !best1[%nom_joueur%]! gtr !best1[0]! (
if !rand! leq 2 set /a nouvelle_mise[%nom_joueur%]=!grosse_blinde!+!grosse_blinde!*!rand!
if !diff_min_mise! gtr !grosse_blinde! set nouvelle_mise[%nom_joueur%]=s
if !diff_min_mise! geq !double_blind! if !best1[%nom_joueur%]! leq 2 if !rand! leq 2 set nouvelle_mise[%nom_joueur%]=0)
if !best1[%nom_joueur%]!==4 (
set nouvelle_mise[%nom_joueur%]=d
if !diff_min_mise! gtr 50 set nouvelle_mise[%nom_joueur%]=s
)
if !best1[%nom_joueur%]! geq 5 (
set nouvelle_mise[%nom_joueur%]=d
if !diff_min_mise! leq !double_blind! set /a nouvelle_mise[%nom_joueur%]=!double_blind!+!double_blind!*!rand!)

)
if !tour_bot[%nom_joueur%]! geq 1 (
REM set nouvelle_mise[%nom_joueur%]=s
if !flop_max! leq 3 set nouvelle_mise[%nom_joueur%]=s
if !flop_max! leq 3 if !diff_min_mise! gtr !grosse_blinde! set nouvelle_mise[%nom_joueur%]=0
REM if !rand! leq 1 set nouvelle_mise[%nom_joueur%]=0
if !best1[%nom_joueur%]! gtr !best1[0]! set nouvelle_mise[%nom_joueur%]=s
if !best1[%nom_joueur%]! geq 3 set nouvelle_mise[%nom_joueur%]=s
if !best1[%nom_joueur%]! geq 5 (
set nouvelle_mise[%nom_joueur%]=s
if !tour_bot[%nom_joueur%]!==1 set nouvelle_mise[%nom_joueur%]=d
if !tour_bot[%nom_joueur%]!==1 if !diff_min_mise! leq 40 set /a nouvelle_mise[%nom_joueur%]=40+10*!rand!)
if !rand! leq 1 if !best1[%nom_joueur%]! geq 5 if !best1[%nom_joueur%]! gtr !best1[0]! set nouvelle_mise[%nom_joueur%]=t
if !diff_min_mise! geq !double_blind! if !best1[%nom_joueur%]! leq 2 set nouvelle_mise[%nom_joueur%]=0)

if !best1[%nom_joueur%]! geq 8 (
set /a rand2=%random%%%2
if !rand2!==1 (
set nouvelle_mise[%nom_joueur%]=d
if !diff_min_mise! leq 100 set /a nouvelle_mise[%nom_joueur%]=200+10*!rand!
)
if !rand2!==0 set nouvelle_mise[%nom_joueur%]=t)
if !flop_max! lss 3 if !diff_min_mise! geq !double_blind! set nouvelle_mise[%nom_joueur%]=0
if !flop_max!==5 if !diff_min_mise! geq !grosse_blinde! if !best1[%nom_joueur%]! leq 2 if !best2[%nom_joueur%]! leq 5 set nouvelle_mise[%nom_joueur%]=0
if !best1[%nom_joueur%]!==!best1[0]! if !diff_min_mise! geq !grosse_blinde! if !flop_max!==5 if !best2[%nom_joueur%]!==!best2[0]! if !best2[0]! leq 5 (
if !best1[0]!==5 set nouvelle_mise[%nom_joueur%]=0
if !best1[0]!==6 set nouvelle_mise[%nom_joueur%]=0)
set /a rand2=%random%%%3
if !diff_min_mise! neq 0 if !diff_min_mise! leq !grosse_blinde! if !rand!==2 set /a nouvelle_mise[%nom_joueur%]=!petite_blinde!+!petite_blinde!*!rand2!
if !diff_min_mise! geq !jeton[%nom_joueur%]! if !rand!==3 set nouvelle_mise[%nom_joueur%]=t
REM echo joueur %nom_joueur% a !best1[%nom_joueur%]! et mise !nouvelle_mise[%nom_joueur%]!
if !nouvelle_mise[%nom_joueur%]! neq s if !nouvelle_mise[%nom_joueur%]! neq d if !nouvelle_mise[%nom_joueur%]! gtr !jeton[%nom_joueur%]! set nouvelle_mise[%nom_joueur%]=t
REM echo !nouvelle_mise[%nom_joueur%]!
REM pause>nul
set /a tour_bot[%nom_joueur%]+=1)

if %nom_joueur% lss %nombre_bot% set /p nouvelle_mise[%nom_joueur%]=Mise de !surnom%nom_joueur%! : 
if !nouvelle_mise[%nom_joueur%]!==t set nouvelle_mise[%nom_joueur%]=!jeton[%nom_joueur%]!
if !nouvelle_mise[%nom_joueur%]!==c set nouvelle_mise[%nom_joueur%]=0
if !nouvelle_mise[%nom_joueur%]!==s set nouvelle_mise[%nom_joueur%]=!diff_min_mise!
if !nouvelle_mise[%nom_joueur%]!==d (
set /a nouvelle_mise[%nom_joueur%]=2*!diff_min_mise!
if !nouvelle_mise[%nom_joueur%]! gtr !jeton[%nom_joueur%]! set nouvelle_mise[%nom_joueur%]=!jeton[%nom_joueur%]!
)
if !nouvelle_mise[%nom_joueur%]! lss 0 goto choix_mise
rem modifier 0 pour metre minium 8 si pas encore mis‚ et 8-deja mis‚ sinon et que si 8-deja sup a 0
if !nouvelle_mise[%nom_joueur%]! gtr !jeton[%nom_joueur%]! goto choix_mise
set /a mise_previsionelle[%nom_joueur%]=!ancienne_mise[%nom_joueur%]!+!nouvelle_mise[%nom_joueur%]!
rem si la mise total est inférieur à la mise_min et que la nouvelle mise est differente de 0 (pas couché) et que la mise totale est differente du nbr de jeton max du joueur alors le joueur doit miser +
if !mise_previsionelle[%nom_joueur%]! lss !mise_min! if !nouvelle_mise[%nom_joueur%]! neq 0 if !nouvelle_mise[%nom_joueur%]! neq !jeton[%nom_joueur%]! ( 
echo la mise doit ˆtre au minimum ‚gale a !diff_min_mise!
if !nom_joueur! lss !nombre_bot! pause>nul
goto choix_mise)

if !mise_min! neq !mise_previsionelle[%nom_joueur%]! if !nouvelle_mise[%nom_joueur%]!==0 (
echo !surnom%nom_joueur%! se couche
set couche[%nom_joueur%]=1
set deja_jouer[%nom_joueur%]=1
if !nom_joueur! lss !nombre_bot! pause>nul
cls
goto :eof
)
set /a mise[%nom_joueur%]=!mise_previsionelle[%nom_joueur%]!
if !mise[%nom_joueur%]! gtr !mise_min! set /a mise_min=!mise[%nom_joueur%]!
set /a pot=!pot!+!nouvelle_mise[%nom_joueur%]!
set /a jeton[%nom_joueur%]=!jeton[%nom_joueur%]!-!nouvelle_mise[%nom_joueur%]!
set deja_jouer[%nom_joueur%]=1
goto :eof

:ajout_carte
set numero_main=main1
call :ajout_main_joueur
call :destruction_carte
set numero_main=main2
call :ajout_main_joueur
call :destruction_carte
goto :eof

REM :affichage_cartes
rem affiche toute les cartes
REM echo cartes du deck
REM for /L %%i in (1,1,!nombre_carte!) do echo !carte[%%i]!
REM goto :eof

:choix_affichage_main
set compteur=0
for /L %%i in (1,1,!nombre_joueur_reel!) do if !couche[%%i]!==0 if !exclut[%%i]!==0 if !jeton[%%i]! neq 0 set /a compteur+=1
if !nombre_joueur_reel!==!nombre_joueur! if !compteur! leq 1 goto :eof
if !nombre_joueur_reel! neq !nombre_joueur! if !compteur!==0 goto :eof
set compteur2=0
for /L %%i in (!nombre_bot!,1,!nombre_joueur!) do if !couche[%%i]!==0 if !exclut[%%i]!==0 if !jeton[%%i]! neq 0 set /a compteur2+=1
if !compteur!==1 if !compteur2!==0 goto :eof
:choix_affichage_main_valeur
cls
if !flop_max!==3 echo flop		!main1[0]! !main2[0]! !main3[0]!
if !flop_max!==4 echo turn		!main1[0]! !main2[0]! !main3[0]! !main4[0]!
if !flop_max!==5 echo river		!main1[0]! !main2[0]! !main3[0]! !main4[0]! !main5[0]!
if !flop_max! geq 3 echo.
set /a nom_joueur=-1
for /L %%i in (1,1,!nombre_joueur_reel!) do if !couche[%%i]!==0 if !exclut[%%i]!==0 echo !surnom%%i! (%%i)& echo.
for /L %%i in (!nombre_bot!,1,!nombre_joueur!) do if !couche[%%i]!==0 if !exclut[%%i]!==0 echo restant !surnom%%i!& echo.
if !nombre_joueur_reel! neq 1 set /p nom_joueur=Num‚ro du joueur souhaitant voir sa main (0 si aucun) : 
if !nombre_joueur_reel!==1 set nom_joueur=1
REM set /a nom_joueur=%nom_joueur%
set /a temp=!nom_joueur!-1
set /a temp+=1
if !temp! neq !nom_joueur! goto choix_affichage_main_valeur
if !nom_joueur!==0 goto :eof
if !nom_joueur! lss 0 goto choix_affichage_main_valeur
if !nom_joueur! gtr !nombre_joueur_reel! (
echo il n'y a que !nombre_joueur_reel! joueurs r‚els
pause>nul
REM cls
goto choix_affichage_main_valeur)
if !exclut[%nom_joueur%]! neq 0 goto choix_affichage_main_valeur
if !couche[%nom_joueur%]! neq 0 goto choix_affichage_main_valeur
cls
if !flop_max!==3 echo flop		!main1[0]! !main2[0]! !main3[0]!
if !flop_max!==4 echo turn		!main1[0]! !main2[0]! !main3[0]! !main4[0]!
if !flop_max!==5 echo river		!main1[0]! !main2[0]! !main3[0]! !main4[0]! !main5[0]!
if !flop_max! neq 0 echo.
REM echo !surnom%nom_joueur%! (%nom_joueur%) :!main1[%nom_joueur%]! !main2[%nom_joueur%]!
call :verification_main
call :changer_cartes
pause>Nul
cls
if !nombre_joueur_reel!==1 goto :eof
goto :choix_affichage_main

:ajout_main_joueur
rem permet de stoker la carte dans la main d'un joueur
set /a carte_supprimer=%random%%%nombre_carte%+1
REM echo %carte_supprimer% ou !carte_supprimer!
REM echo ajout de !carte[%carte_supprimer%]! pour joueur !nom_joueur!
set %numero_main%[%nom_joueur%]=!carte[%carte_supprimer%]!
set numero_main_joueur=!numero_main:~-1!
set /a numero_main_joueur+=2
REM echo if %nom_joueur%==0 for /L %%i in (1,1,!nombre_joueur!) do set main%numero_main_joueur%[%%i]=!carte[%carte_supprimer%]!
if %nom_joueur%==0 for /L %%i in (1,1,!nombre_joueur!) do set main%numero_main_joueur%[%%i]=!carte[%carte_supprimer%]!
set /a nombre_carte=!nombre_carte!-1
REM pause>nul
goto :eof
:destruction_carte
rem permet de supprimer une carte de la liste
rem principe : commence à partir de la carte sup et change sa valeur par la suivante jusqu'à la fin-1 pour compenser la carte enlevée
set /a carte_supprimer2=!carte_supprimer!+1
set carte[%carte_supprimer%]=!carte[%carte_supprimer2%]!
if %carte_supprimer% geq %nombre_carte% goto :eof
set /a carte_supprimer+=1
goto destruction_carte

:brule
REM echo une carte brule
set /a carte_supprimer=%random%%%nombre_carte%+1
set /a nombre_carte=!nombre_carte!-1
call :destruction_carte
goto :eof