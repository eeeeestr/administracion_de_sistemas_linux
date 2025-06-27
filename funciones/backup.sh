#!/bin/bash

CONFIG_FILE="./config/configuracion.conf"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Error: El archivo de configuración '$CONFIG_FILE' no se encontró."
  exit 1
fi

BACKUP_DIR="/backup/sistema"
PERSONAL_SCRIPT="/usr/local/bin/backup_usuario.sh"
LOG_BACKUP="/var/log/backup_sistema.log"
mkdir -p "$BACKUP_DIR"
touch "$LOG_BACKUP"

# ================================================
# Función principal
# ================================================
function configurar_backup() {
  while true; do
    clear
    echo "========================================"
    echo "         CONFIGURACIÓN DE BACKUPS       "
    echo "========================================"
    echo "1. Configurar backup automático del sistema"
    echo "2. Configurar backup personal por usuario"
    echo "3. Ejecutar backup manual"
    echo "4. Restaurar desde backup"
    echo "5. Ver logs de backup"
    echo "6. Volver al menú principal"
    echo "========================================"
    read -p "Seleccionar una opción [1-6]: " resp

    case $resp in
      1)  # BACKUP AUTOMÁTICO SISTEMA
        echo
        echo "Se programará backup diario de: /etc /home /compartido"
        echo "Destino por defecto: $BACKUP_DIR"
        read -p "¿Continuar? [S/n]: " confirmar
        [[ "$confirmar" =~ ^[Nn]$ ]] && continue

        cat <<EOF > /usr/local/bin/backup_sistema.sh
#!/bin/bash
tar -czf "$BACKUP_DIR/sistema_\$(date +%Y%m%d_%H%M).tar.gz" /etc /home /compartido >> "$LOG_BACKUP" 2>&1
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +10 -delete >> "$LOG_BACKUP" 2>&1
EOF

        chmod +x /usr/local/bin/backup_sistema.sh

        echo "0 2 * * * root /usr/local/bin/backup_sistema.sh" > /etc/cron.d/backup_sistema

        print_success "Backup automático programado diario a las 2:00 AM."
        read -p "Presione ENTER para continuar..." ;;

      2)  # BACKUP PERSONAL POR USUARIO
        cat <<EOF > "$PERSONAL_SCRIPT"
#!/bin/bash
DEST=\$HOME/backup
mkdir -p "\$DEST"
tar -czf "\$DEST/backup_\$(date +%Y%m%d_%H%M).tar.gz" \$HOME 2>/dev/null
find "\$DEST" -name "*.tar.gz" -mtime +7 -delete
EOF

        chmod +x "$PERSONAL_SCRIPT"

        echo "@daily bash $PERSONAL_SCRIPT" | crontab -u "$SUDO_USER" -

        print_success "Script de backup personal instalado en $PERSONAL_SCRIPT."
        print_info "Cada usuario podrá usarlo y se ejecutará a diario."
        read -p "Presione ENTER para continuar..." ;;

      3)  # BACKUP MANUAL
        echo "Seleccione tipo de backup:"
        echo "1. Completo del sistema"
        echo "2. Directorio específico"
        read -p "Opción [1-2]: " tipo

        if [[ "$tipo" == "1" ]]; then
          archivo="$BACKUP_DIR/manual_sistema_$(date +%Y%m%d_%H%M).tar.gz"
          tar -czf "$archivo" /etc /home /compartido
          print_success "Backup manual completo guardado en $archivo"

        elif [[ "$tipo" == "2" ]]; then
          read -p "Ruta del directorio a respaldar: " ruta
          if [[ -d "$ruta" ]]; then
            read -p "Nombre del archivo (sin extensión): " nombre
            archivo="$BACKUP_DIR/${nombre}_$(date +%Y%m%d_%H%M).tar.gz"
            tar -czf "$archivo" "$ruta"
            print_success "Backup de $ruta guardado en $archivo"
          else
            print_error "La ruta especificada no existe."
          fi
        else
          print_error "Opción inválida."
        fi
        read -p "Presione ENTER para continuar..." ;;

      4)  # RESTAURAR
        echo "Archivos disponibles en $BACKUP_DIR:"
        ls -lh "$BACKUP_DIR" | grep .tar.gz
        read -p "Archivo a restaurar (nombre exacto): " archivo
        fullpath="$BACKUP_DIR/$archivo"

        if [[ ! -f "$fullpath" ]]; then
          print_error "Archivo no encontrado."
        else
          echo "¿Dónde desea restaurar?"
          echo "1. Ubicación original (⚠️ cuidado)"
          echo "2. /tmp/restore/"
          echo "3. Ruta personalizada"
          read -p "Opción [1-3]: " destino

          case $destino in
            1) tar -xzf "$fullpath" -C / ;;
            2) mkdir -p /tmp/restore; tar -xzf "$fullpath" -C /tmp/restore ;;
            3)
              read -p "Ingrese ruta personalizada: " ruta
              mkdir -p "$ruta"
              tar -xzf "$fullpath" -C "$ruta"
              ;;
            *) print_error "Opción inválida." ;;
          esac

          print_success "Backup restaurado correctamente."
        fi
        read -p "Presione ENTER para continuar..." ;;

      5)  # VER LOGS
        if [[ -f "$LOG_BACKUP" ]]; then
          tail -n 30 "$LOG_BACKUP"
        else
          print_warning "No hay logs aún."
        fi
        read -p "Presione ENTER para continuar..." ;;

      6) sudo chmod +x ./admin_sistema_linux.sh; sudo ./admin_sistema_linux.sh;exit 0;;

      *) echo "Opción inválida." ; sleep 1 ;;
    esac
  done
}

configurar_backup
