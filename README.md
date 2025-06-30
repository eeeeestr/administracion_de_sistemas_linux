# Administración de Sistemas Linux

## Resumen

En este proyecto se desarrolla un script en bash diseñado para automatizar tareas clave de administración de sistemas Linux. Este script permite realizar configuraciones iniciales del sistema, gestionar usuarios y grupos, configurar directorios compartidos, realizar respaldos automáticos, aplicar cuotas de disco, instalar y configurar servicios como Apache y Samba, monitorear servicios críticos, reiniciar automáticamente servicios caídos, habilitar logs centralizados, configurar almacenamiento redundante mediante RAID 1 por software, implementar LVM, generar snapshots automáticos, verificar integridad de archivos y generar reportes del sistema, ya sean generales o por áreas específicas.

Esta herramienta está orientada a facilitar el trabajo del personal técnico, mejorando la eficiencia operativa, reduciendo errores comunes en la configuración manual y fortaleciendo la seguridad e integridad del sistema.

## Introducción

En entornos corporativos, la correcta administración de sistemas Linux es una tarea esencial que impacta directamente en la disponibilidad, seguridad y rendimiento de los servicios. Fedora 42, como distribución moderna y flexible, permite implementar soluciones avanzadas de administración, pero requiere un conocimiento técnico que muchas organizaciones no tienen estandarizado.

Este proyecto consiste en el desarrollo de una solución automatizada, modular y reutilizable mediante scripting en bash, que permite realizar tareas administrativas críticas sin necesidad de intervención manual constante. A través de un menú interactivo, el administrador puede ejecutar configuraciones, instalar servicios, gestionar usuarios, crear backups, implementar redundancia de almacenamiento, controlar el uso del disco y obtener reportes útiles del sistema, todo en un solo flujo controlado.

## Diagnóstico

Aunque Linux es ampliamente adoptado en servidores web, bases de datos, dispositivos de red y plataformas en la nube, muchas organizaciones no cuentan con personal especializado que domine la administración profunda de estos sistemas. Esto genera configuraciones manuales inconsistentes, pérdida de datos, errores de seguridad y caídas de servicio no detectadas a tiempo.

Además, muchas de estas tareas son repetitivas y propensas al error humano. En ese contexto, la automatización surge como una necesidad crítica. Este proyecto responde a esta problemática desarrollando una herramienta que centraliza la gestión, reduce la carga operativa y asegura la coherencia del sistema.

Por otro lado, la aplicación del presente proyecto conlleva a una oportunidad de mejora en las automatizaciones de acciones dentro de linux, teniendo en cuenta un análisis SEPTE con las siguientes variables:

- Social: el presente proyecto productivo ayudaría a tener un personal capacitado, ya que la implementación de automatización de acciones en linux exige que el personal tenga los conocimientos adecuados para manejar estas nuevas tecnologías.

- Económico: el presente proyecto requerirá una inversión inicial para la mejora de automatización de acciones en linux mediante el hardware, software y consultoría a involucrar.

- Tecnológico: el presente proyecto requiere actualizar las librerías y paquetes de Linux para la implementación de automatización de acciones en linux.

- Ecológico: para el presente proyecto los equipos de red y servidores deben ser eficientes energéticamente. Asimismo, sustituir los equipos obsoletos para incluirlos en un plan de reciclaje electrónico.

## Objetivos

1. Automatizar el monitoreo y reinicio de servicios críticos (Apache, Samba, SSH) mediante scripts programados con `cron`, garantizando que se reactiven en menos de 5 minutos tras una falla.

2. Diseñar e implementar un sistema de respaldo automatizado que genere copias diarias de los directorios más importantes y las conserve por al menos 10 días.

3. Generar reportes de sistema en menos de 3 segundos, exportables y comprimibles automáticamente, para mejorar el análisis técnico y la auditoría del servidor.

## Justificación del Proyecto

Este proyecto está orientado a cubrir una necesidad crítica en entornos donde se administran servidores Linux sin una estandarización o capacitación adecuada. Al automatizar las principales tareas administrativas, se logra:

- Reducir la curva de aprendizaje de nuevos administradores.

- Minimizar errores humanos al ejecutar configuraciones complejas.

- Aumentar la disponibilidad de servicios esenciales como servidores web y compartidos.

- Proteger la integridad de los datos mediante backups automatizados y snapshots.

- Garantizar la escalabilidad mediante una solución modular y extensible.

**Beneficiarios directos:** Técnicos de TI, administradores de sistemas, estudiantes de administración de redes y pequeñas empresas.

**Beneficiarios indirectos:** Usuarios finales de los servicios que dependen de la infraestructura Linux, así como organizaciones que buscan optimizar sus recursos tecnológicos sin grandes inversiones.

## Definición y alcance

Este proyecto consiste en un script principal en bash (admin\_sistema\_linux.sh) que presenta un menú interactivo con acceso a 8 módulos:

1. Configuración inicial del sistema  
2. Gestión de usuarios y grupos  
3. Directorios compartidos  
4. Backups automatizados y manuales  
5. Cuotas de disco por usuario y grupo  
6. Alta disponibilidad (Apache, Samba, RAID, LVM, snapshots)  
7. Reportes del sistema

Cada módulo está implementado como un subscript modular en la carpeta ./funciones/. Además, se incluye un archivo de configuración (./config/configuracion.conf) y un sistema de logging para auditar cada acción.

El proyecto ha sido probado sobre **Fedora 42** y es adaptable a distribuciones similares.

## Productos y entregables

- Script principal interactivo: admin\_sistema\_linux.sh  
- 8 scripts funcionales independientes:  
 - configuracion.sh, usuarios.sh, compartidos.sh, backup.sh, cuotas.sh, alta\_disponibilidad.sh, reportes.sh, y utilidades.sh
- Archivo de configuración con funciones y variables globales: ./config/configuracion.conf  
- Carpeta de logs centralizados: ./logs/sistema.log  
- Carpeta de backups: /backup/sistema  
- Cron jobs configurados automáticamente para backups, snapshots, monitoreo e integridad  
- Directorios compartidos con permisos por grupo  
- RAID 1 con LVM configurado para alta disponibilidad

## Conclusiones

- La automatización de tareas administrativas en Linux mejora significativamente la eficiencia operativa y reduce los riesgos por errores manuales.  
    
- El uso de scripting en bash es una solución efectiva, ligera y accesible para entornos donde no se dispone de herramientas gráficas o comerciales.  
    
- El proyecto demuestra que es posible implementar un sistema de alta disponibilidad, respaldo y control sin depender de herramientas externas, solo con los recursos que proporciona el sistema operativo.

## Recomendaciones

- Extender el proyecto con una interfaz web o vía SSH interactiva para una administración remota más amigable.  
    
- Adaptar el script para que detecte automáticamente la distribución del sistema y cambie `apt`/`dnf` según corresponda.  
    
- Agregar verificación automática de espacio en disco antes de cada respaldo o snapshot.  
  


**Glosario**

- **Bash:** Un intérprete de comandos o shell muy popular en sistemas Linux. Permite ejecutar comandos, scripts y automatizar tareas del sistema. Es una evolución de la shell original de Unix (sh).  
    
- **Backup:** Una copia de seguridad de archivos, configuraciones o sistemas completos, usada para restaurar la información en caso de pérdida, corrupción o fallo del sistema.  
    
- **LVM:** Administrador de volúmenes lógicos que permite una gestión flexible del almacenamiento. Con LVM puedes:  
    
- Redimensionar particiones sin reiniciar.  
- Crear snapshots (copias instantáneas).  
- Agregar discos fácilmente a volúmenes existentes.  
    
- **RAID:** Tecnología que combina varios discos duros en una sola unidad lógica para:  
    
 - Mejorar el rendimiento (RAID 0),  
 - Ofrecer redundancia/fallo seguro (RAID 1, RAID 5, etc.),  
 - O ambas cosas (RAID 10).  
  Puede implementarse a nivel de hardware o software.  
    
- **Sticky bit:** Permiso especial en directorios que permite que solo el propietario de un archivo (o el root) pueda eliminar o renombrar, aunque otros usuarios tengan acceso de escritura al directorio.  
    
- **Hostname:** El nombre del sistema o equipo en la red. Se usa para identificar el equipo entre otros, tanto a nivel local como en redes más grandes. Se puede ver con el comando hostname.  
    
- **Alta disponibilidad:** Conjunto de técnicas y configuraciones que buscan garantizar que un sistema o servicio esté siempre disponible, incluso si ocurre un fallo.


  
## Bibliografía

- (202X),  ¿Qué es un array redundante de discos independientes (RAID)?, Lenovo Colombia. Retribuído de [https://www.lenovo.com/co/es/glosario/raid/](https://www.lenovo.com/co/es/glosario/raid/)   
    
- Mallón X., (2024), ¿Qué es LVM y cómo funciona en Linux?, keepcoding. Retribuido de [https://keepcoding.io/blog/que-es-y-como-funciona-el-lvm-en-linux/](https://keepcoding.io/blog/que-es-y-como-funciona-el-lvm-en-linux/) 

