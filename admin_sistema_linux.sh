#!/bin/bash

#Funciones

#Principal
actualizar_sistema(){
 
 sudo dnf update
 sudo dnf upgrade

}


menu_principal(){

clear
echo "========================================="
echo "     ADMINISTRADOR DEL SISTEMA LINUX     "
echo "========================================="
echo ""
echo "1. Configuracion inicial del sistema"
echo "2. Gestion de usuarios y grupos"
echo "3. Configurar directorios compartidos"
echo "4. Sistema de backup"
echo "5. Configurar cuotas de disco"
echo "6. Alta disponibilidad"
echo "7. Generar reportes del sistema"
echo "8. Salir"

echo "========================================="
echo "Selecciones una opcion [1-8]:"
echo "-----------------------------------------"

}


#Secundaria

#actualizar_sistema
while true; do

  menu_principal
  read respuestaOpcion

  case $respuestaOpcion in

    1)sudo chmod +x ./funciones/configuracion.sh; sudo ./funciones/configuracion.sh; exit 0;;
    2)sudo chmod +x ./funciones/usuarios.sh;sudo ./funciones/usuarios.sh;exit 0;;
    3)sudo chmod +x ./funciones/compartidos.sh; sudo ./funciones/compartidos.sh; exit 0;;
    4)sudo chmod +x ./funciones/backup.sh;sudo ./funciones/backup.sh;exit 0;;
    5)sudo chmod +x ./funciones/cuotas.sh; sudo ./funciones/cuotas.sh;exit 0;;
    6)sudo chmod +x ./funciones/alta_disponibilidad.sh; sudo ./funciones/alta_disponibilidad.sh;exit 0;;
    7)sudo chmod +x ./funciones/reportes.sh;sudo ./funciones/reportes.sh;exit 0;;
    8)echo " _   _            __     __                       _ _ ";echo "| \ | | ___  ___  \ \   / /__ _ __ ___   ___  ___| | |";echo "|  \| |/ _ \/ __|  \ \ / / _ \ _  _ \ / _ \/ __| | |";echo "| |\  | (_) \__ \   \ V /  __/ | | | | | (_) \__ \_|_|";echo "|_| \_|\___/|___/    \_/ \___|_| |_| |_|\___/|___(_|_)";echo ; echo ; echo ;exit 0;;

  esac
  echo
  echo
  echo
  echo
  echo "Presione ENTER para continuar..."
  read

done

done



