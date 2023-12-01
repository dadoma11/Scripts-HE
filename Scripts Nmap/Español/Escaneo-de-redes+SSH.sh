#!/bin/bash

# Directorio temporal y archivos
temp_dir="/tmp"
log_dir="/var/log"
log_file="nmap-script-ssh.log"

# Verificar si el usuario es root
if [ "$EUID" -ne 0 ]; then
    echo "###########################################"
    echo "#                                         #"
    echo "#  ⚠️  Por favor, ejecute este script    #"
    echo "#     como superusuario utilizando 'sudo'. #"
    echo "#                                         #"
    echo "###########################################"
    exit 1
fi


# Función para loggear mensajes
log_message() {
    echo "$(date): $1" >> "$log_dir/$log_file"
}

# Borrado del archivo de logs si existe
if [ -f "$log_dir/$log_file" ]; then
    rm "$log_dir/$log_file"
fi

log_message "Inicio del script"

# Paso 1: Solicitar la dirección de red al usuario
read -p "Ingrese la dirección de red a escanear (ejemplo: 192.168.0.0/24): " red
log_message "Dirección de red ingresada: $red"

# Pedir la ubicación para guardar el archivo hosts.txt
read -p "Ingrese la ubicación para guardar el archivo hosts.txt (ejemplo: /ruta/al/directorio): " hosts_dir
hosts_file="$hosts_dir/hosts.txt"
log_message "Ubicación del archivo hosts.txt: $hosts_file"

# Crear el archivo hosts.txt o limpiar su contenido si ya existe
> "$hosts_file"

# Paso 2: Realizar un escaneo de red completo para averiguar el resto de hosts de esa red
echo "Ejecutando un escaneo de red completo en la red $red..."
log_message "Ejecutando un escaneo de red completo en la red $red..."
nmap -sn "$red" | grep 'Nmap scan report' | awk '{print $5}' | grep -vE "^(192\.168\.0\.[123])" > "$temp_dir/temp_hosts.txt"
log_message "Escaneo de red completado"
log_message "Resultados del escaneo de red:"
nmap -sn "$red" >> "$log_dir/$log_file"  # Resultados del escaneo de red en el log

# Buscar el puerto SSH para cada IP y guardar la información en hosts.txt
echo "Realizando escaneo de puertos para encontrar el puerto SSH (OpenSSH)..."
log_message "Realizando escaneo de puertos para encontrar el puerto SSH (OpenSSH)..."
total=$(wc -l < "$temp_dir/temp_hosts.txt")
completed=0

while IFS= read -r ip; do
    log_message "Escaneando puertos para $ip..."
    echo "Escaneando puertos para $ip..."
    puerto_ssh=$(nmap -sV -p- "$ip" | grep -E 'OpenSSH' | grep -oP '\d{1,5}' | head -1)
    
    if [ -n "$puerto_ssh" ]; then
        echo "$ip:$puerto_ssh" >> "$hosts_file"
        log_message "Encontrado puerto SSH $puerto_ssh para $ip"
        echo "Encontrado puerto SSH $puerto_ssh para $ip"
    fi

    completed=$((completed + 1))
    echo "Progreso: $completed de $total"
    log_message "Progreso: $completed de $total"
done < "$temp_dir/temp_hosts.txt"

rm "$temp_dir/temp_hosts.txt"  # Eliminar el archivo temporal
log_message "Archivo temporal eliminado"

log_message "Fin del script"
echo -e "\nEl archivo hosts.txt se ha generado con éxito en $hosts_file."
