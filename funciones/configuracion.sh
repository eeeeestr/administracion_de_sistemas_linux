#!/bin/bash
CONFIG_FILE="./config/configuracion.conf"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Error: El archivo de configuración '$CONFIG_FILE' no se encontró."
  exit 1
fi

function configurar_sistema(){
	clear
	
	echo "========================================"
	echo "GESTIÓN DE CONFIGURACION INICIAL DEL SISTEMA"
	echo "========================================"
	echo
	echo "1. Actualizar Hostname del servidor"
	echo "2. Actualizar Zona horaria"
	echo "3. Instalar y habilitar servicios necesarios (htop, tree, rsync, quota, vim, curl/wget)"
	echo "4. Crear estructura de directorio base"
	echo "5. Volver al menù principal"
	echo
	echo "========================================="
	read -p "Seleccionar una opcion [1-5]:" seleccionConfiguracion
	echo "-----------------------------------------"
	
	
	case $seleccionConfiguracion in
		
		1)
		    	read -p "Ingrese el nuevo hostname (ej: servidor-principal): " hostname
			if [[ "$hostname" =~ ^[a-zA-Z0-9-]{1,63}$ && ${#hostname} -le 15 ]]; then
				echo
				echo "========================================="
				
				hostnamectl set-hostname "$hostname"
				print_success "Hostname actualizado a '$hostname'."
				
			else
				print_error "Hostname ingresado inválido. Use solo letras, números y guiones (máx 15 caracteres)."
			fi
			
			echo "========================================="
			echo
			read -p "Presione ENTER para continuar..." continuar
	
		;;
		
		2)	
			clear
			echo "========================================"
			echo "ACTUALIZACION ZONA HORARIA"
			echo "========================================"
			echo
			echo "Seleccione la zona horaria:"
			echo "1. America/Lima"
			echo "2. America/Mexico_City"
			echo "3. America/Buenos_Aires"
			echo "4. Europe/Madrid"
			echo "5. Personalizada"
			echo "6. Cancelar Operacion"
			echo
			echo "========================================="
			read -p "Opción [1-6]: " tz_choice
			local timezone
			case $tz_choice in
				1) timezone="America/Lima" ;;
				2) timezone="America/Mexico_City" ;;
				3) timezone="America/Buenos_Aires" ;;
				4) timezone="Europe/Madrid" ;;
				5) read -p "Ingrese la zona horaria (ej: America/New_York): " timezone ;;
				6) timezone="Error"; return ;;
				*) print_error "Opción inválida." && return ;;
			esac

			if timedatectl set-timezone "$timezone"; then
				print_success "Zona horaria configurada a '$timezone'."
			else
				print_error "No se pudo configurar la zona horaria."
			fi
			
			echo
			echo
			echo "========================================"
			echo
			read -p "Presione ENTER para continuar..." continuar
		
		;;
		
		3) # 2. Instalar paquetes esenciales
			echo
			echo "¿Desea instalar los paquetes adicionales?"
			echo
			
			echo "Los siguientes paquetes se instalaran:"
			echo "- htop (monitor de procesos)"
			echo "- tree (visualizar directorios)"
			echo "- rsync (sincronizacion de archivos)"
			echo "- quota (gestion de cuotas)"
			echo "- vim (editor de texto)"
			echo "- curl/wget (descarga de archivos)"
			echo
			read -p "S/n: " respuestaPaquetes
			
			print_info "Instalando paquetes esenciales: htop, tree, rsync, quota, cron, vim, curl, wget"
				
			if dnf install -y htop tree rsync quota cron vim curl wget --skip-unavailable; then
				print_success "Paquetes esenciales instalados."
			else
				print_error "Fallo al instalar paquetes esenciales."
			fi

			echo "========================================"
			echo
			read -p "Presione ENTER para continuar..." continuar
		
		
		;;
		
		4) # 4. Crear estructura de directorios base
		
			print_info "Creando estructura de directorios..."
			mkdir -p /compartido/{desarrollo,marketing,general}
			mkdir -p /backup/{sistema,usuarios}
			
			print_success "Directorios creados en /compartido/ y /backup/."
			
			echo
			echo
			echo "========================================"
			echo
			read -p "Presione ENTER para continuar..." continuar
		;;
		
		5) sudo chmod +x ./admin_sistema_linux.sh; sudo ./admin_sistema_linux.sh; exit 0;;
		
		*);;
	
	
	esac



}

while true; do

	configurar_sistema 

done

