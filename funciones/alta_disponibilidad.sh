#!/bin/bash

CONFIG_FILE="./config/configuracion.conf"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Error: El archivo de configuración '$CONFIG_FILE' no se encontró."
  exit 1
fi

function configurar_alta_disponibilidad() {
  while true; do
    clear
    echo "============================================"
    echo "        CONFIGURACIÓN DE ALTA DISPONIBILIDAD"
    echo "============================================"
    echo "1. Instalar y configurar Apache"
    echo "2. Configurar Samba (compartición de archivos)"
    echo "3. Crear script de monitoreo de servicios"
    echo "4. Configurar RAID 1 con LVM"
    echo "5. Crear snapshot automático"
    echo "6. Script de verificación de integridad"
    echo "7. Volver al menú principal"
    echo "============================================"
    read -p "Seleccionar una opción [1-7]: " op

    case $op in
      1) # Apache
        dnf install -y httpd
        systemctl enable --now httpd
        firewall-cmd --permanent --add-service=http
        firewall-cmd --reload
        echo "<h1>Servidor Activo - $(hostname)</h1>" > /var/www/html/index.html
        print_success "Apache instalado y en ejecución. Prueba accediendo a http://<IP>"
        read -p "Presione ENTER para continuar..." ;;

      2) # Samba
        dnf install -y samba samba-common
        mkdir -p /compartido/general
        chmod 1777 /compartido/general
        cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
        cat <<EOF >> /etc/samba/smb.conf
	[general]
	  path = /compartido/general
	  browseable = yes
	  writable = yes
	  guest ok = yes
	EOF
        systemctl enable --now smb nmb
        firewall-cmd --permanent --add-service=samba
        firewall-cmd --reload
        print_success "Samba configurado y compartiendo /compartido/general"
        read -p "Presione ENTER para continuar..." ;;

      3) # Monitoreo de servicios
        cat <<EOF > /usr/local/bin/monitorear_servicios.sh
	#!/bin/bash
	servicios=("httpd" "smb" "sshd")
	for srv in "\${servicios[@]}"; do
	  if ! systemctl is-active --quiet \$srv; then
	    systemctl restart \$srv
	    echo "\$(date): Servicio \$srv fue reiniciado automáticamente" >> /var/log/servicios_monitoreo.log
	  fi
	done
	EOF
        chmod +x /usr/local/bin/monitorear_servicios.sh
        echo "*/5 * * * * root /usr/local/bin/monitorear_servicios.sh" > /etc/cron.d/monitoreo_servicios
        print_success "Monitoreo automático configurado para reiniciar servicios cada 5 min si se caen."
        read -p "Presione ENTER para continuar..." ;;

      4) # RAID 1 con LVM
        echo
        echo "Discos disponibles:"
        lsblk -o NAME,SIZE,TYPE | grep disk
        read -p "Ingrese los dos discos para RAID 1 (ej: sdb sdc): " d1 d2

        for disk in $d1 $d2; do
          if [[ ! -b /dev/$disk ]]; then
            print_error "Disco /dev/$disk no válido."; return
          fi
        done

        # Crear particiones RAID
        parted /dev/$d1 --script mklabel gpt mkpart primary 0% 100%
        parted /dev/$d2 --script mklabel gpt mkpart primary 0% 100%

        yes | mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/${d1}1 /dev/${d2}1

        echo "DEVICE /dev/${d1}1 /dev/${d2}1" > /etc/mdadm.conf
        mdadm --detail --scan >> /etc/mdadm.conf

        mkfs.ext4 /dev/md0
        mount /dev/md0 /mnt
        echo "/dev/md0 /mnt ext4 defaults 0 0" >> /etc/fstab

        # Crear LVM sobre RAID
        dnf install -y lvm2
        pvcreate /dev/md0
        vgcreate vg_raid /dev/md0
        lvcreate -L 5G -n lv_data vg_raid
        mkfs.ext4 /dev/vg_raid/lv_data
        mkdir -p /datos
        mount /dev/vg_raid/lv_data /datos
        echo "/dev/vg_raid/lv_data /datos ext4 defaults 0 2" >> /etc/fstab

        print_success "RAID 1 con LVM configurado. Punto de montaje en /datos"
        read -p "Presione ENTER para continuar..." ;;

      5) # Snapshot automático
        mkdir -p /var/backups/lvm
        cat <<EOF > /usr/local/bin/snapshot_lvm.sh
	#!/bin/bash
	lvcreate -L 500M -s -n snap_data /dev/vg_raid/lv_data
	mount /dev/vg_raid/snap_data /mnt/snapshot
	sleep 10
	umount /mnt/snapshot
	lvremove -f /dev/vg_raid/snap_data
	EOF
        chmod +x /usr/local/bin/snapshot_lvm.sh
        echo "0 3 * * * root /usr/local/bin/snapshot_lvm.sh" > /etc/cron.d/snapshot_lvm
        print_success "Snapshot automático diario configurado (3:00 AM)"
        read -p "Presione ENTER para continuar..." ;;

      6) # Verificación de integridad
        cat <<EOF > /usr/local/bin/verificar_integridad.sh
	#!/bin/bash
	for dir in /etc /home /datos; do
	  if [ -d "\$dir" ]; then
	    find "\$dir" -type f -exec md5sum {} \; > "/var/log/integridad_\$(basename \$dir).md5"
	  fi
	done
	EOF
        chmod +x /usr/local/bin/verificar_integridad.sh
        echo "30 2 * * * root /usr/local/bin/verificar_integridad.sh" > /etc/cron.d/verificar_integridad
        print_success "Verificación de integridad configurada (2:30 AM)"
        read -p "Presione ENTER para continuar..." ;;

      7) return ;;

      *) print_error "Opción inválida."; sleep 2 ;;
    esac
  done
}

configurar_alta_disponibilidad
