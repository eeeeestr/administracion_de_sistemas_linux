#!/bin/bash

CONFIG_FILE="./config/configuracion.conf"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Error: El archivo de configuración '$CONFIG_FILE' no se encontró."
  exit 1
fi

# Directorio de exportación
EXPORT_DIR="/tmp/reportes_sistema"
mkdir -p "$EXPORT_DIR"

function generar_reportes(){

  while true; do
    clear
    echo "========================================"
    echo "         GENERACIÓN DE REPORTES"
    echo "========================================"
    echo "1. Reporte completo del sistema"
    echo "2. Reporte de usuarios y grupos"
    echo "3. Reporte de uso de disco"
    echo "4. Reporte de backups"
    echo "5. Reporte de servicios"
    echo "6. Exportar todos los reportes"
    echo "7. Volver al menú principal"
    echo "========================================"
    read -p "Seleccionar una opción [1-7]: " resp
    echo "----------------------------------------"

    case $resp in
      1)
        archivo="$EXPORT_DIR/reporte_sistema.txt"
        echo "======= REPORTE COMPLETO DEL SISTEMA =======" > "$archivo"
        hostnamectl >> "$archivo"
        echo >> "$archivo"
        timedatectl >> "$archivo"
        echo >> "$archivo"
        lscpu >> "$archivo"
        echo >> "$archivo"
        free -h >> "$archivo"
        echo >> "$archivo"
        df -h >> "$archivo"
        print_success "Reporte del sistema generado en $archivo"
        read -p "Presione ENTER para continuar..." ;;
      
      2)
        archivo="$EXPORT_DIR/reporte_usuarios_grupos.txt"
        echo "======= USUARIOS =======" > "$archivo"
        cut -d: -f1 /etc/passwd >> "$archivo"
        echo >> "$archivo"
        echo "======= GRUPOS ========" >> "$archivo"
        cut -d: -f1 /etc/group >> "$archivo"
        print_success "Reporte de usuarios y grupos generado en $archivo"
        read -p "Presione ENTER para continuar..." ;;
      
      3)
        archivo="$EXPORT_DIR/reporte_disco.txt"
        echo "======= USO DE DISCO =======" > "$archivo"
        df -h >> "$archivo"
        echo >> "$archivo"
        du -sh /home/* /compartido/* 2>/dev/null >> "$archivo"
        print_success "Reporte de uso de disco generado en $archivo"
        read -p "Presione ENTER para continuar..." ;;
      
      4)
        archivo="$EXPORT_DIR/reporte_backups.txt"
        echo "======= BACKUPS ENCONTRADOS =======" > "$archivo"
        find /backup -type f -name "*.tar.gz" -exec ls -lh {} \; 2>/dev/null >> "$archivo"
        print_success "Reporte de backups generado en $archivo"
        read -p "Presione ENTER para continuar..." ;;
      
      5)
        archivo="$EXPORT_DIR/reporte_servicios.txt"
        echo "======= ESTADO DE SERVICIOS =======" > "$archivo"
        systemctl status sshd >> "$archivo" 2>&1
        echo >> "$archivo"
        systemctl status firewalld >> "$archivo" 2>&1
        echo >> "$archivo"
        systemctl list-units --type=service --state=running >> "$archivo"
        print_success "Reporte de servicios generado en $archivo"
        read -p "Presione ENTER para continuar..." ;;
      
      6)
        archivoZip="/tmp/reportes_sistema_$(date +%Y%m%d_%H%M).tar.gz"
        tar -czf "$archivoZip" -C /tmp reportes_sistema/
        print_success "Todos los reportes han sido comprimidos en: $archivoZip"
        read -p "Presione ENTER para continuar..." ;;
      
      7)sudo chmod +x ./admin_sistema_linux.sh;
	sudo ./admin_sistema_linux.sh;
	exit 0;;  # Volver al menú principal

      *)
        print_error "Opción inválida. Intente de nuevo."
        sleep 2 ;;
    esac
  done
}

generar_reportes
