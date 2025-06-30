#!/bin/bash

#Gestion de cuotas

function configurar_cuotas() {
  while true; do
    clear
    echo "=========================================="
    echo "         CONFIGURACIÓN DE CUOTAS"
    echo "=========================================="
    echo "1. Habilitar cuotas en sistemas de archivos"
    echo "2. Configurar cuotas por usuario"
    echo "3. Configurar cuotas por grupo"
    echo "4. Configurar alertas automáticas"
    echo "5. Volver al menú principal"
    echo "=========================================="
    read -p "Seleccione una opción [1-5]: " op

    case $op in
      1)  # Habilitar cuotas en /home y /compartido
        for punto in /home /compartido; do
          if mount | grep -q " $punto "; then
            sed -i "s|\($punto .*ext4.*defaults\)|\1,usrquota,grpquota|" /etc/fstab
            mount -o remount "$punto"
            quotacheck -cugm "$punto"
            quotaon "$punto"
            print_success "Cuotas habilitadas en $punto"
          else
            print_warning "$punto no está montado."
          fi
        done
        read -p "Presione ENTER para continuar..." ;;
      
      2)  # Configurar cuotas por usuario
        read -p "Nombre del usuario: " usuario
        if ! id "$usuario" &>/dev/null; then
          print_error "El usuario no existe."
          read -p "Presione ENTER para continuar..." ; continue
        fi

        read -p "Límite suave (MB): " suave
        read -p "Límite duro (MB): " duro
        read -p "Período de gracia en días [7]: " gracia
        gracia=${gracia:-7}

        edquota -u "$usuario" <<< "$(echo -e "$usuario\n$((suave * 1024))\t$((duro * 1024))\t0\t0")"
        edquota -t <<< "$(echo -e "grace period:\n$gracia days")"
        print_success "Cuotas asignadas al usuario $usuario"
        read -p "Presione ENTER para continuar..." ;;
      
      3)  # Cuotas por grupo
        read -p "Nombre del grupo: " grupo
        if ! getent group "$grupo" &>/dev/null; then
          print_error "El grupo no existe."
          read -p "Presione ENTER para continuar..." ; continue
        fi

        read -p "Límite suave grupal (GB): " suave
        read -p "Límite duro grupal (GB): " duro

        setquota -g "$grupo" $((suave * 1024 * 1024)) $((duro * 1024 * 1024)) 0 0 /home
        setquota -g "$grupo" $((suave * 1024 * 1024)) $((duro * 1024 * 1024)) 0 0 /compartido
        print_success "Cuotas asignadas al grupo $grupo"
        read -p "Presione ENTER para continuar..." ;;
      
      4)  # Alerta por sobreuso
        cat <<EOF > /usr/local/bin/check_quotas.sh
#!/bin/bash
THRESHOLD_WARN=80
THRESHOLD_CRIT=95
LOG="/var/log/cuotas_alertas.log"
for user in \$(cut -f1 -d: /etc/passwd); do
  uso=\$(quota -u \$user | awk 'NR==3 {if (\$2 != 0 && \$3 != 0) print int(\$2/\$3*100)}')
  if [[ \$uso -ge \$THRESHOLD_CRIT ]]; then
    echo "\$(date): ALERTA CRÍTICA - \$user al \$uso%" >> \$LOG
  elif [[ \$uso -ge \$THRESHOLD_WARN ]]; then
    echo "\$(date): Advertencia - \$user al \$uso%" >> \$LOG
  fi
done
EOF
        chmod +x /usr/local/bin/check_quotas.sh
        echo "0 */6 * * * root /usr/local/bin/check_quotas.sh" > /etc/cron.d/cuotas_monitor
        print_success "Script de monitoreo de cuotas instalado y programado cada 6 horas."
        read -p "Presione ENTER para continuar..." ;;
      
      5) return ;;
      
      *) print_error "Opción inválida."; sleep 1 ;;
    esac
  done
}

configurar_cuotas
