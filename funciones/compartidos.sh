#!/bin/bash
CONFIG_FILE="./config/configuracion.conf"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Error: El archivo de configuración '$CONFIG_FILE' no se encontró."
  exit 1
fi

function configurar_compartidos(){

	clear
	echo "========================================"
	echo "     CONFIGURACION DE ALMACENAMIENTO    "
	echo "========================================"
	echo
	read -p "¿Desea crear una nueva particion para directorios compartidos? [S/n]: " respuestaParticion
	respuestaParticion=${respuestaParticion:-S} # Por defecto 'S'
	
	if [[ "$respuestaParticion" =~ ^[Ss]$ ]]; then
	
		echo "Discos disponibles: "
		
		lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINT | grep "disk"

		echo
		read -p "Seleccione el disco para la partición (ej. /dev/sdb): " disco_seleccionado
		if [[ ! -b "$disco_seleccionado" ]]; then
		    echo "Error: El disco seleccionado no es válido o no existe."
		    return 1
		fi
		
		read -p "Tamaño de la partición en GB [por defecto 2GB]: " tamano_particion
		tamano_particion=${tamano_particion:-2} # Por defecto 2GB

		read -p "¿Usar LVM para gestión avanzada? [S/n]: " usar_lvm
		usar_lvm=${usar_lvm:-S} # Por defecto 'S'
		
		local device_to_mount=""

		if [[ "$usar_lvm" =~ ^[Ss]$ ]]; then
		    echo "Creando partición LVM en $disco_seleccionado..."
		    # Crear una nueva tabla de particiones y una partición primaria para LVM
		    echo "g" | fdisk "$disco_seleccionado" # Crea una nueva tabla de particiones GPT
		    echo "n" | fdisk "$disco_seleccionado" # Nueva partición
		    echo "1" | fdisk "$disco_seleccionado" # Partición número 1
		    echo "" | fdisk "$disco_seleccionado"  # Primer sector por defecto
		    echo "" | fdisk "$disco_seleccionado"  # Último sector por defecto
		    echo "t" | fdisk "$disco_seleccionado" # Cambiar tipo de partición
		    echo "30" | fdisk "$disco_seleccionado" # Tipo de partición Linux LVM (código 30, o 8e en algunas versiones)
		    echo "w" | fdisk "$disco_seleccionado" # Escribir cambios y salir
		    sync
		    partprobe "$disco_seleccionado"

		    local particion_lvm="${disco_seleccionado}1"
		    echo "Creando volumen físico LVM en $particion_lvm..."
		    pvcreate "$particion_lvm"

		    echo "Creando grupo de volúmenes vg_compartido..."
		    vgcreate vg_compartido "$particion_lvm"

		    echo "Creando volumen lógico lv_compartido de ${tamano_particion}GB..."
		    lvcreate -L "${tamano_particion}G" -n lv_compartido vg_compartido
		    device_to_mount="/dev/mapper/vg_compartido-lv_compartido"
		else
		    echo "Creando partición estándar en $disco_seleccionado..."
		    # Crear una nueva tabla de particiones y una partición primaria
		    echo "g" | fdisk "$disco_seleccionado" # Crea una nueva tabla de particiones GPT
		    echo "n" | fdisk "$disco_seleccionado" # Nueva partición
		    echo "1" | fdisk "$disco_seleccionado" # Partición número 1
		    echo "" | fdisk "$disco_seleccionado"  # Primer sector por defecto
		    echo "+${tamano_particion}G" | fdisk "$disco_seleccionado" # Tamaño de la partición
		    echo "w" | fdisk "$disco_seleccionado" # Escribir cambios y salir
		    sync
		    partprobe "$disco_seleccionado"
		    device_to_mount="${disco_seleccionado}1"
		fi

		echo "Formateando $device_to_mount con ext4..."
		mkfs.ext4 "$device_to_mount"

		echo "Creando punto de montaje /compartido/..."
		mkdir -p /compartido

		echo "Montando $device_to_mount en /compartido/..."
		mount "$device_to_mount" /compartido

		echo "Configurando montaje automático en /etc/fstab..."
		echo "$device_to_mount /compartido ext4 defaults 0 2" | tee -a /etc/fstab

		echo "Verificando montaje..."
		mount | grep "/compartido"
		if [[ $? -eq 0 ]]; then
		    echo "Partición creada, formateada y montada exitosamente."
		else
		    echo "Error al montar la partición. Verifique el fstab."
		    return 1
		fi

	else
		echo
		echo "No se creará una nueva partición. Asegúrese de que /compartido ya esté configurado si es necesario."
		echo
	fi
	
	echo
	echo
	echo "========================================"
	echo "       CONFIGURACION DE PERMISOS        "
	echo "========================================"
	echo
	echo
	echo "Configurando permisos para directorios compartidos: "
	echo
	echo "/compartido/desarrollo/ - ¿Quien puede escribir?"
	echo "1. Solo grupo desarrollo"
	echo "2. Grupo desarrollo + administradores"
	echo "3. Todos los usuarios"
	read -p "Opcion [1-3]: " respuestaEscribirDesarrollo
	
	case "$respuestaEscribirDesarrollo" in
	
		1)
		    chown :desarrollo /compartido/desarrollo
		    chmod 2775 /compartido/desarrollo # rwxrwsr-x con SGID
		    echo "Permisos para /compartido/desarrollo: grupo desarrollo (2775)"
		    ;;
		2)
		    # Para permitir que 'desarrollo' y 'administradores' escriban, usaremos ACLs
		    chown :desarrollo /compartido/desarrollo
		    chmod 2775 /compartido/desarrollo # Permisos base
		    setfacl -m g:administradores:rwx /compartido/desarrollo
		    setfacl -m d:g:administradores:rwx /compartido/desarrollo # Permisos por defecto para nuevos archivos/directorios
		    echo "Permisos para /compartido/desarrollo: grupo desarrollo y administradores (ACLs)"
		    ;;
		3)
		    chown :users /compartido/desarrollo # Opcional: Asignar a un grupo genérico si "todos" es el objetivo
		    chmod 1777 /compartido/desarrollo # rwxrwxrwt con sticky bit (aunque se pida en general, por coherencia si se elige "todos")
		    echo "Permisos para /compartido/desarrollo: Todos los usuarios (1777)"
		    ;;
		*)
		    echo "Opción inválida. Se aplicará el valor por defecto: Solo grupo desarrollo (2775)."
		    chown :desarrollo /compartido/desarrollo
		    chmod 2775 /compartido/desarrollo
		    ;;
	esac

	echo
	echo
	echo "/compartido/marketing/ - ¿Quien puede escribir?"
	echo "1. Solo grupo marketing"
	echo "2. Grupo marketing + administradores"
	echo "3. Todos los usuarios"
	read -p "Opcion [1-3]: " respuestaEscribirMarketing

	case "$respuestaEscribirMarketing" in
		1)
		    chown :marketing /compartido/marketing
		    chmod 2775 /compartido/marketing # rwxrwsr-x con SGID
		    echo "Permisos para /compartido/marketing: grupo marketing (2775)"
		    ;;
		2)
		    # Para permitir que 'marketing' y 'administradores' escriban, usaremos ACLs
		    chown :marketing /compartido/marketing
		    chmod 2775 /compartido/marketing # Permisos base
		    setfacl -m g:administradores:rwx /compartido/marketing
		    setfacl -m d:g:administradores:rwx /compartido/marketing
		    echo "Permisos para /compartido/marketing: grupo marketing y administradores (ACLs)"
		    ;;
		3)
		    chown :users /compartido/marketing
		    chmod 1777 /compartido/marketing
		    echo "Permisos para /compartido/marketing: Todos los usuarios (1777)"
		    ;;
		*)
		    echo "Opción inválida. Se aplicará el valor por defecto: Solo grupo marketing (2775)."
		    chown :marketing /compartido/marketing
		    chmod 2775 /compartido/marketing
		    ;;
	esac

	echo
	echo
	read -p "/compartido/general/ - ¿Aplicar sticky bit? [S/n]: " respuestaStickyBit
	respuestaStickyBit=${respuestaStickyBit:-S}
	if [[ "$aplicar_sticky_general" =~ ^[Ss]$ ]]; then
		chown :users /compartido/general # Se recomienda un grupo genérico para "general"
		chmod 1777 /compartido/general # rwxrwxrwt con sticky bit
		echo "(El sticky bit evita que usuarios borren archivos de otros)"
		echo "Permisos para /compartido/general: grupo users, sticky bit aplicado (1777)."
	else
		chown :users /compartido/general
		chmod 0777 /compartido/general # Permisos sin sticky bit si se elige no aplicarlo
		echo "Permisos para /compartido/general: grupo users, sin sticky bit (0777)."
	fi
	
	
	
	
	echo ""
	echo "==================================================="
	echo "Configuración de Directorios Compartidos Completada"
	echo "==================================================="
	echo "Estructura de permisos resultante:"
	echo
	echo "/compartido/desarrollo/   (grupo: desarrollo, permisos: 2775)"
	echo "/compartido/marketing/    (grupo: marketing, permisos: 2775)"
	echo "/compartido/general/      (grupo: users, permisos: 1777)"
			
	

}


configurar_compartidos
echo
echo
echo "========================================"
echo
read -p "Presione ENTER para continuar..." continuar
sudo chmod +x ./admin_sistema_linux.sh
sudo ./admin_sistema_linux.sh
exit 0



