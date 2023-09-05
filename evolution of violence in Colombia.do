*******************************************************************************
*

clear all

global cd "C:\Users\sebas\Downloads\STATA\Taller3\"
cd "${H}"

use "${H}presence"
*Punto 1
/*Construya una base de datos uniendo el panel CEDE y la base de
presencia de grupos armados de Acemoglu, Robinson y Santos (2013). ¿Cuál
es la unidad de observación de cada tabla? ¿Cu´al es el tipo de uni´on utilizado
en esta operaci´on y la relaci´on entre las bases de datos?
Tenga en cuenta que de la base de presencia de grupos armados solo se van a
utilizar las variables: dumpar 9701, dumguer 9701 y pob2005. Las variables de
la base consolidada ser´an representadas en gr´aficos, mapas y tablas.
*/
//
keep  cod_dane dumpar_9701 dumguer_9701 pob2005
//KEEP ELIMINA  todas las variables que no sean las mencionadas en la  lista.
tempfile presencia_armados
// guardar cambios en los datos para usarlos más tarde en la misma sesión, sin crear archivos intermedios en disco duro
save `presencia_armados'

use "${H}conflicto_y_violencia"
//usamos la base de datos conflicto y violencia
merge m:1 cod_dane using `presencia_armados'
//Aqui unimos  dos conjuntos de datos a traves de la variable en comun.Aqui hacemos una fusión de muchos a uno .
keep if _merge == 3
//aca decimos que mantenga la variable si merge es 3
drop _merge

tostring cod_dane, replace
//aqui convertimos cod:dane  en varlist de numérico a cadena.
replace cod_dane = "0" + cod_dane if length(cod_dane) == 4

gen cod_depto = substr(cod_dane,1,2)
//generamos una variable que se llame coddepto que sera igual a  la subcadena de la cadena ASCII s que comienza en la posición 1 y continúa durante la longitud de 2 caracteres.
order cod_dane cod_depto


save CEDE_presencia, replace
//*REALIZANDO LA OBSERVACIÓN VEMOS COMO EL IDENTIFICADOR ES cod_dane.El tipo de union es muchos a uno.y la relación entre las bases de datos es que el id de la base de conflicto esta definida por cod_dane y anounique cod_dane

**punto 2
//Cree la figura 1 que corresponde al comportamiento de las variables de hect´areas cultivadas de coca y hect´areas de coca erradicadas mediante
//aspersi´on a´erea 
//Note que las variables mostradas en los ejes fueron transformadas con logaritmos. Debido a que el logaritmo del valor 0 no existe, se recomienda que se3sume una unidad a la variable de hect´areas cultivadas de coca y hect´areas de coca erradicadas mediante aspersi´on a´erea antes de la transformaci´on. Entre otras, las siguientes opciones pueden resultar ´utiles para realizar el gr´afico:xtitle, ylabel, scheme, legend y note. ¿Qu´e observa de este gr´afico?

use conflicto_mas_presencia, replace
//usamos la presente base de datos
keep if ano == 2009 | ano == 2015
//eliminamos las variables en donde año no se 2015 o 2009
gen hcoca = log(H_coca + 1)
//teniendo en cuenta el enunciado  cramos las variables siendo iguales a el logaritmo de la variable +1
gen herradicada = log(errad_aerea + 1)

#d;
twoway (scatter hcoca herradicada if ano == 2009)
       (scatter hcoca herradicada if ano == 2015, msymbol(triangle) mcolor(red)), 
	   graphregion(color(white))
	   ylabel(, nogrid angle(0))
	   ytitle(Log de hectáreas cultivadas de coca)
	   xtitle(Log de hectareas  erradicadas de coca mediante asperción aerea)
	   scheme(sj)
	   note(El coeficiente de pendiente de toda la muestra es de 0.76 y el error estándar de 0.05)
	   caption(Fuente: Elaboración del autor con información del panel municipal del CEDE)
	   title(Hectáreas cultivadas vs hectáreas erradicadas)
	   legend(order(1 "2009" 2 "2015") region(lwidth(none)));
		 
 # d cr;
 // En el grafico de dispersión   podemos evidenciar como  no hay relación entre las dos variables, y podemos verlo en un gráfico de dispersión ya que no hay dirección para los valores.Sin embargo, observamos como para 2009 como para 2015  ha medida que se aumenta en la erradicacion con aspersión 
 //aerea mayor es el cultivo de coca, concluyendo que la aspersión aerea no es un buen mecanismo para lograr la erradicación de raiz. //
 


***Punto 3
/*(2 puntos) Cree la figura 2, que muestra la tasa de homicidios por 100.000 habitantes en Colombia antes y despu´es del cese al fuego unilateral de la guerrilla.
Para esto, tome datos de dos a˜nos antes (2009 y 2010) y dos a˜nos despu´es del
cese al fuego (2015 y 2016). Recuerde que debe usar el mapa de departamentos
(co dep.shp) para poder proyectar los mapas en Stata. Debe garantizar que las
escalas de las categor´ıas de la leyenda de los mapas sean iguales para poder
comparar los mapas.
Las siguientes opciones pueden resultar de ayuda para realizar el gr´afico: fcolor
y legend. No son las ´unicas que necesitar´ıa usar. En el mapa Antes no especifique
un m´etodo de construcci´on de clases, por defecto Stata crea clases a partir de
cortes naturales y es lo que se muestra en la figura 2. ¿Que cambios observa
en los mapas generados? ¿Cree conveniente tomar los a˜nos 2013 y 2014 como
el periodo .Antes"para el siguiente an´alisis, por qu´e?*/


spshape2dta co_dep, replace
//con esto leemos el archivo co_dep.shp 

clear all

use conflicto_mas_presencia, replace
//usamos la base de datos conficto_mas_presencia
keep if ano == 2009 | ano ==2010 
//elminamos los adtos que no tengan el año igual a 2009 o a 20010
bys cod_dane ano: egen totalhomicidios= sum(homicidios)
//el comando bys es muy similar al comando bysvarlist: pero ordena automáticamente las variables en varlist.
bys cod_dane ano: egen pob_total= sum(pob2005)
collapse totalhomi, by(cod_dane ano pob_total coddepto) 
//convierte el conjunto de datos en la memoria en un conjunto de datos de medias, sumas, medianas, etc.
collapse (sum)totalhomi, by(cod_dane pob_total coddepto)
gen Tasahomicidios_antes=((totalhomicidios/pob_total)*100000)
//creamos una nueva variable que sera la tasa de homicidios antes del cese al fuego la cual equivaldara al total de homicidios /poblacion total sobre 1000.0000 habitantes
collapse (mean)Tasahomicidios_antes, by(coddepto)
gen antes = Tasahomicidios_antes/2
//creamos una nueva variable que es la anterior dividida en 2 

//aqui hacemos lo mismo pero 2 años despues del cese al fuego 
save homicidios_antescese, replace

use conflicto_mas_presencia, replace
keep if ano == 2015 | ano ==2016 
bys coddepto ano: egen totalhomicidios= sum(homicidios)
bys coddepto ano: egen pob_total= sum(pob2005)
collapse totalhomicidios, by( cod_dane coddepto ano pob_total) 
collapse (sum)totalhomicidios, by(coddepto cod_dane pob_total)
gen homicidios_despues=((totalhomicidios/pob_total)*100000)
collapse (mean)homicidios_despues, by(coddepto)
gen despues = homicidios_despues/2


save homi_despues, replace

merge 1:1 coddepto using "tasa_homi_antes"

drop _merge

save tasa_homi_ayd, replace
use co_dep, replace
rename (DPTO_CCDGO DPTO_CNMBR) (coddepto nomdepto)

merge 1:m coddepto using tasa_homi_ayd
drop _merge
keep _ID _CX _CY coddepto nomdepto antes despues

*graph, activate

grmap antes using "co_dep_shp", id(_ID) ///
	clm(c) clb(1.243828 14.38353 28.86996 45.6154 122.9746) ///
	fc(Reds) ///
	title("antes", size(*0.8)) ///
	name("homicidios_antescese", replace)

grmap despues using "co_dep_shp", id(_ID) ///
	clm(c) clb(1.243828 14.38353 28.86996 45.6154 122.9746) ///
	fc(Reds) ///
	title("Después", size(*0.8)) ///
	name("homi_despues", replace)
	
	 graph combine homicidios_antescese homi_despues, ///
	title("Tasa de homicidios en Colombia. Antes y después:", size(*0.8)) ///
	subtitle("Cese al fuego de las FARC") ///
	caption(Fuente: Panel CEDE) ///
	name(Figura_2, replace)
	
/* A traves de los mapas se observa la variación de la tasa de homicidios a traves del tiempo. observamos como luego del cese al fuesgo se redujeron los asesinatos en departamentos en los cuales tenian presencia.Sin embargo vemos como cauca,quindia y risaralda siguen manteniendo esta tasa de homicidios.













    
	



		 
		 

