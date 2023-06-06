#!/bin/bash
#Este es un script en base al buscador de resolución de máquinas de HackThebox de s4vitar, https://htbmachines.github.io/ 
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

ctrl_c(){
  echo -e "\n\n${redColour}[!]Saliendo...${endColour}\n"
  tput cnorm && exit 1
}



#Ctrl + C
trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"


help_Panel(){
  echo -e "\n${yellowColour}[+]${endColour}${greenColour}Uso:${endColour}" 
  echo -e "\t${purpleColour}u)${endColour}${greenColour}Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${greenColour}Buscar por un nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${greenColour}Mostrar por IP de la máquina${endColour}"
  echo -e "\t${purpleColour}l)${endColour}${greenColour}Obtener link de la resolución de la maquina en Youtube${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${greenColour}Obten el nivel de dificultad de la máquina${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${greenColour}Buscar por sistema operativo${endColour}"  
  echo -e "\t${purpleColour}h)${endColour}${greenColour}Mostrar el panel de ayuda${endColour}\n" 

}

updateFiles(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour} [+]${endColour} ${greenColour} Descargando archivos necesarios... ${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n ${yellowColour} [+]${endColour} ${greenColour} Todos los archivos han sido descargados${endColour} "
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour} [+]${endColour} ${greenColour} Comprobando si hay actualizaciones...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
  
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${greenColour} No se han detectado actualizaciones lo tienes todo al día ;)${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Se han encontrado actualizaciones ${endColour}"
      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "${yellowColour}[+]${endColour} ${greenColour} Los archivos han sido actualizados ${endColour}"
    fi

    
    tput cnorm
  fi
}

searchMachine(){
  machineName="$1"
  machine_checker=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ */ /')
  
  if [ "$machine_checker" ]; then

    name=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ */ /' | grep  "name:" | awk '{print $2}')
    ip=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ */ /' | grep  "ip:" | awk '{print $2}')
    so=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ */ /' | grep  "so:" | awk '{print $2}')
    dific=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ */ /' | grep  "dificultad:" | awk '{print $2}')
    skills=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ */ /' | grep  "skills:" | awk '{print $2}')
    like=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ */ /' | grep  "like:" | awk '{print $2}')
    yt=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ */ /' | grep  "youtube:" | awk '{print $2}')

    #Imprimiendo variables
    echo -e "${yellowColour}[+]${endColour}${grayColour}Listando las propiedades de la máquina${endColour}${blueColour} $name ${endColour}"
    echo -e "${purpleColour}IP:${endColour}${blueColour}$ip${endColour}"
    echo -e "${purpleColour}SO:${endColour}${blueColour}$so${endColour}"
    echo -e "${purpleColour}DIFICULTAD:${endColour}${blueColour}$dific${endColour}"
    echo -e "${purpleColour}SKILLS:${endColour}${blueColour}$skills${endColour}"
    echo -e "${purpleColour}CERTIF:${endColour}${blueColour}$like${endColour}"
    echo -e "${purpleColour}YOUTBE:${endColour}${blueColour}$yt${endColour}"
  else
    echo -e "\n${redColour}[!]La máquina proporcionada no existe${endColour}"

  fi

}

ipMachine(){
  ipAddress=$1
  ip_Checker=$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | tail -n 1 | tr -d "," | tr -d '""' | awk '{print $2}')

  if [ $ip_Checker ]; then

    machineName=$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | tr -d '""' | tr -d "," | awk '{print $NF}')
    echo -e "\n${yellowColour}[+]${endColour}${grayColour}La maquina correspodiente para la IP: ${endColour}${blueColour}$ipAddress${endColour} es ${purpleColour}$machineName${endColour}"
  else
    echo -e "\n${redColour}[!]La IP proporcionada no existe${endColour}"
  fi

}

linkMachine(){
  machineName="$1"
  link_machine=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ *//' | grep  youtube | awk '{print $NF}')

  if [ $link_machine ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour}El enlace de la máquina ${endColour}${blueColour}$machineName${endColour}:${purpleColour}$link_machine${endColour}"
  else
    echo -e "\n${redColour}[!]La máquina proporcionada no existe${endColour}"
  fi
}


dificultMachine(){
  dificultName="$1"
  dificultMaquina=$(cat bundle.js | grep "dificultad: \"$dificultName\"" -B 5 | grep name | awk '{print $NF}' | tr -d '"' | tr -d "," | column )
  if [ "$dificultMaquina" ]; then 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour}Las maquinas de nivel $dificultName son:${endColour}\n${purpleColour}$dificultMaquina${endColour}" 
  else
    echo -e "\n${redColour}[!]Dificultad no valida${endColour}"
  fi
}

sysOperative(){
  os="$1"
  nameSysOperative="$(cat bundle.js | grep "so: \"$os\"" -B 7 | grep "name: " |tr -d "," | awk '{print $NF}' | tr -d '""'| column)"
  if [ "$nameSysOperative" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour}Los nombres de las máquinas con el Sistema Operativo${endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n ${purpleColour}$nameSysOperative:${endColour}"
  else
      echo -e "\n${redColour}[!]No existe ese sistema operativo${endColour}" 
  fi
}

getOSdificultyMachines(){
    dificultName="$1"
    os="$2"
    echo -e "\nFiltrando por dificultad $dificultName y sistema operativo $os"
    get_dificut_os_machine="$(cat bundle.js | grep "so: \"$os\"" -C 5 | grep "dificultad: \"$dificultName\"" -B 5 | grep "name: " | tr -d '""' | tr -d "," | awk '{print $NF}'| column)"
    if [ "$get_dificut_os_machine" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour}Máquinas con dificultad ${endColour}${purpleColour}$dificultName${endColour}${grayColour} y de sistema operativo ${endColour}${purpleColour}$os${endColour}${grayColour} son:${endColour}\n${turquoiseColour}$get_dificut_os_machine${endColour}"
    else
      echo -e "${redColour}[!]No existe esa o ese sistema operativo${endColour}" 
    fi

}


#Indicadores
declare parameter_counter=0

#Declarando chivatos
declare chivato_dificulty=0
declare chivato_os=0


while getopts "m:ul:i:d:o:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    l) machineName="$OPTARG"; let parameter_counter+=4;;
    d) dificultName="$OPTARG"; chivato_dificulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;; 
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  ipMachine $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  linkMachine $machineName
elif [ $parameter_counter -eq 5 ]; then
  dificultMachine $dificultName
elif [ $parameter_counter -eq 6 ]; then
  sysOperative $os
elif [ $chivato_dificulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOSdificultyMachines $dificultName $os
else
  help_Panel
fi

