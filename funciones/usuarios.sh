#!/bin/bash
CONFIG_FILE="./config/configuracion.conf"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Error: El archivo de configuración '$CONFIG_FILE' no se encontró."
  exit 1
fi



# ==============================================
# Función para gestionar el menù de usuarios
# ==============================================
function gestionar_usuarios(){

echo "========================================"
echo "       GESTIÓN DE USUARIOS Y GRUPOS"
echo "========================================"
echo
echo
echo "1. Crear usuarios masivamente"
echo "2. Crear usuario"
echo "3. Crear grupos"
echo "4. Asignar usuarios a grupos"
echo "5. Modificar usuario existente"
echo "6. Eliminar usuario"
echo "7. Listar usuarios y grupos"
echo "8. Volver al menù principal"
echo
echo
echo "========================================="
read -p "Seleccionar una opcion [1-8]:" eleccionUsuario
echo "-----------------------------------------"
echo
echo

case $eleccionUsuario in

1)# Carga masiva desde CSV
        read -p "Ingrese la ruta del archivo CSV: " archivoCSV
        if [[ ! -f "$archivoCSV" ]]; then
          print_error "El archivo no existe."
        else
		while IFS=, read -r usuario nombre grupo clave; do
		  if id "$usuario" &>/dev/null; then
		    print_warning "El usuario '$usuario' ya existe. Saltando..."
		   
		  else
		  
		    useradd -m -c "$nombre" -G "$grupo" -s /bin/bash "$usuario"
		    echo "$usuario:$clave" | chpasswd
		    chage -d 0 "$usuario"
		    print_success "Usuario '$usuario' creado correctamente."
		  
		  fi
		  
		done < "$archivoCSV"
        
        fi
        
        echo "========================================="
	echo
	read -p "Presione ENTER para continuar..." continuar
;;

2)#Creacion de usuario

	read -p "Nombre de usuario (solo minuscula, sin espacios): " usuario
	read -p "Nombre completo del usuario: " nombre
	read -p "Contraseña (minimo 8 caracteres): " clave; echo
	read -p "Confirmar contraseña:" clave2; echo
	
	if [[ "$clave" != "$clave2" ]]; then
          print_error "Las contraseñas no coinciden."
          continue
        fi

        read -p "¿Crear directorio home? [S/n]: " crearHome
        read -p "¿El usuario debe cambiar contraseña al iniciar sesión? [S/n]: " forzarCambio
        echo "Seleccione grupo principal: "
        echo "1. desarrollo"
        echo "2. marketing"
        echo "3. administradores"
        echo "4. usuarios (por defecto)"
        read -p "Opción [1-4]: " grupoSel

        case $grupoSel in
          1) grupo="desarrollo" ;;
          2) grupo="marketing" ;;
          3) grupo="administradores" ;;
          *) grupo="usuarios" ;;
        esac

        opciones="-c \"$nombre\" -G $grupo -s /bin/bash"
        [[ "$crearHome" =~ ^[Ss]$ ]] && opciones="$opciones -m"

        eval useradd $opciones "$usuario"
        echo "$usuario:$clave" | chpasswd
        [[ "$forzarCambio" =~ ^[Ss]$ ]] && chage -d 0 "$usuario"

        print_success "Usuario '$usuario' creado con éxito."
        read -p "Presione ENTER para continuar..." ;;


3)#Creacion de grupo
	echo
	echo
	echo "Creando grupos: desarrollo, marketing, administradores, backup_users"
	sleep 2
	echo
	for group in desarrollo marketing administradores backup_users; do
		
		if ! getent group "$group" >/dev/null; then
			
			groupadd "$group"
			echo 
			print_success "> Grupo '$group' creado."
			echo
			
		else
			echo
			print_warning " El grupo '$group' ya existe."
			echo
		
		fi
	
	done
	
	echo "%administradores ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/administradores
	chmod 440 /etc/sudoers.d/administradores
	echo "========================================="
	print_success "Grupo 'administradores' tiene acceso sudo completo."
	echo "========================================="
	echo
	read -p "Presione ENTER para continuar..." continuar
	
	
;;

4)#Asignar usuario a grupo
	read -p "Nombre del usuario: " usuario
        read -p "Nombre del grupo: " grupo
        if id "$usuario" &>/dev/null && getent group "$grupo" &>/dev/null; then
          usermod -aG "$grupo" "$usuario"
          print_success "Usuario '$usuario' añadido al grupo '$grupo'."
        else
          print_error "Usuario o grupo inválido."
        fi
        echo "========================================="
	echo
	read -p "Presione ENTER para continuar..." continuar

;;

5)#Modificacion de usuario existente

	read -p "Ingrese el nombre de usuario a modificar: " nombreUsuarioModificar
	
	if ! id "$nombreUsuarioModificar" &>/dev/null; then
	
		echo "El usuario $nombreUsuarioModificar no existe en el sistema"; sleep 2;
	else
		while true;do
	
			clear
			echo "========================================"
			echo "MODIFICACION DE USUARIO '$nombreUsuarioModificar'"
			echo "========================================"
			echo ""
			echo "¿Que desea modificar?"
			echo "1. Cambiar contraseña"
			echo "2. Cambiar grupo principal"
			echo "3. Agregar a grupo secundario"
			echo "4. Cambiar nombre completo"
			echo "5. Boquear/Desbloquear cuenta"
			echo "6. Cambiar directorio home"
			echo "7. Cancelar operacion"
			echo "-----------------------------------"
			read -p "Opcion [1-7]: " seleccionModificarUsuario
			
			echo "-----------------------------------"
			echo
			echo
			
			case $seleccionModificarUsuario in
				
			    1) passwd "$usuario" ;;
			    2) read -p "Nuevo grupo principal: " grupo; usermod -g "$grupo" "$nombreUsuarioModificar" ;;
			    3) read -p "Grupo secundario: " grupo; usermod -aG "$grupo" "$nombreUsuarioModificar" ;;
			    4) read -p "Nuevo nombre completo: " nombre; usermod -c "$nombre" "$nombreUsuarioModificar" ;;
			    5)
			      read -p "¿Bloquear (L) o Desbloquear (D)? " accion
			      [[ "$accion" =~ ^[Ll]$ ]] && usermod -L "$nombreUsuarioModificar" && print_info "Cuenta bloqueada."
			      [[ "$accion" =~ ^[Dd]$ ]] && usermod -U "$nombreUsuarioModificar" && print_info "Cuenta desbloqueada."
			      ;;
			    6)
			      read -p "Nuevo directorio home: " nuevoHome
			      usermod -d "$nuevoHome" -m "$nombreUsuarioModificar"
			      ;;
			    7) break ;;
			    *) echo "Opción inválida."; sleep 1 ;;
			    
			esac
		done
	fi

;;

6)#Eliminacion de usuario
read -p "Ingrese el nombre del usuario a eliminar: " usuarioEliminar

if ! id "$usuarioEliminar" &>/dev/null; then

	print_error "El usuario '$usuarioEliminar' no existe, intente nuevamente."
else
	
	read -p "¿Eliminar tambien el directorio home? S/n: " eliminarHome
	
	if [[ "$eliminarHome" =~ ^[Ss] ]]; then
	
	  userdel -r "$usuarioEliminar"
	  print_success "Usuario '$usuarioEliminar' y su home eliminados."
	
	else
	
	  userdel "$usuarioEliminar"
	  print_success "Usuario '$usuarioEliminar' eliminado."
	  
	fi
fi
echo "========================================="
echo
read -p "Presione ENTER para continuar..." continuar

;;

7)#Listar usuario y grupo

	echo
	echo "========================================"
	echo "---------> LISTA DE USUARIOS <----------"
	echo "========================================"
	echo
	echo
	cut -d: -f1 /etc/passwd
	
	echo
	echo
	echo
	echo "========================================"
	echo "----------> LISTA DE GRUPOS <-----------"
	echo "========================================"
	echo
	echo
	cut -d: -f1 /etc/group
	echo
	echo
	echo
	echo "========================================"
	echo
	read -p "Presione ENTER para continuar..." continuar
	

;;

8)sudo chmod +x ./admin_sistema_linux.sh; sudo ./admin_sistema_linux.sh;exit 0;;

*)echo "Opcion invalida!!"; sleep 1;;

esac

}



while true;do
  clear
  gestionar_usuarios
  
done

