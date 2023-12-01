#!/bin/bash

log_file="/var/log/hydra_script.log"
password_file=""
wordlist_file=""
user_list_file=""
username=""
user_list_option=""

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

# Función para limpiar la pantalla
clear_screen() {
    clear
}

# Función para escribir en el archivo de log
log_message() {
    echo "$(date): $1" >> "$log_file"
}

# Función para seleccionar el tipo de usuario (uno o lista)
select_user_option() {
    clear_screen
    echo "Seleccione el tipo de usuario:"
    echo "1. Un solo usuario"
    echo "2. Lista de usuarios"
    read -p "Seleccione una opción: " user_option

    case $user_option in
        1)
            read -p "Ingrese el nombre de usuario: " username
            echo "Usuario $username ingresado."
            ;;
        2)
            read -p "Ingrese la ubicación del archivo con la lista de usuarios: " user_list_file
            echo "Ubicación del archivo con la lista de usuarios guardada."
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
}

# Función para seleccionar el tipo de ataque
select_attack_option() {
    clear_screen
    echo "Seleccione el tipo de ataque:"
    echo "1. Ataque por fuerza bruta"
    echo "2. Otro tipo de ataque"
    read -p "Seleccione una opción: " attack_option

    case $attack_option in
        1)
            attack_service
            ;;
        2)
            echo "Función para otro tipo de ataque"
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
}

# Función para realizar ataque por fuerza bruta a un servicio de la máquina remota
attack_service() {
    select_user_option  
}

# Menú principal
while true; do
    clear_screen
    echo "Menú principal:"
    echo "1. Introducir el fichero donde están las contraseñas almacenadas"
    echo "2. Realizar ataque por fuerza bruta a algún servicio de la máquina remota"
    echo "3. Borrar / cambiar la wordlist del punto 1"
    echo "4. Información del script"
    echo "5. Salir"

    read -p "Seleccione una opción: " main_option

    case $main_option in
        1)
            read -p "Ingrese la ubicación del archivo de contraseñas: " password_file
            echo "Ubicación del archivo de contraseñas guardada."
            ;;
        2)
            attack_service
            ;;
        3)
            echo "Función para borrar / cambiar la wordlist"
            ;;
        4)
            echo "Información del script"
            ;;
        5)
            echo "Saliendo del script..."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
done

# Función para realizar ataque por fuerza bruta a un servicio de la máquina remota
attack_service() {
    clear_screen
    echo "Realizando escaneo de red..."
    # Obtener la red
    network=$(ip route | grep -oP '192\.168\.\d{1,3}\.\d{1,3}/\d{1,2}' | head -1)
    
    nmap -sn $network
    echo "Escaneo de red completo."

    # Menú para seleccionar el servicio a atacar
    echo "Seleccione el servicio a atacar:"
    echo "1. SSH"
    echo "2. FTP"
    echo "3. HTTP"
    echo "4. Volver al menú principal"
    read -p "Seleccione una opción: " service_option

    case $service_option in
        1)
            service="ssh"
            ;;
        2)
            service="ftp"
            ;;
        3)
            service="http"
            ;;
        4)
            show_info
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac

    select_user_option  # Seleccionar el tipo de usuario (uno o lista)

    if [ -n "$username" ]; then
        read -p "Ingrese la dirección IP del servicio: " target_ip
        read -p "Ingrese el puerto del servicio: " target_port
        read -p "Ingrese el nombre del archivo de salida: " output_file

        echo "Ejecutando ataque de fuerza bruta a $service en $target_ip en el puerto $target_port..."
        hydra -l "$username" -P "$password_file" "$target_ip" -s "$target_port" "$service" > "$output_file"
        echo "Ataque completado. Resultados guardados en $output_file."
        read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
        show_info
    elif [ -n "$user_list_file" ]; then
        # Lógica para atacar con lista de usuarios
        echo "Ejecutando ataque de fuerza bruta con lista de usuarios a $service en $target_ip en el puerto $target_port..."
        hydra -L "$user_list_file" -P "$password_file" "$target_ip" -s "$target_port" "$service" > "$output_file"
        echo "Ataque completado. Resultados guardados en $output_file."
        read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
        show_info
    else
        echo "No se proporcionaron usuarios o listas de usuarios."
    fi
}

# Función para leer la opción seleccionada por el usuario
read_option() {
    read -p "Seleccione una opción: " option

    case $option in
        1)
            clear_screen
            read -p "Ingrese la ubicación del fichero de contraseñas: " password_file
            echo "Ubicación del fichero de contraseñas guardada."
            read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
            show_info
            ;;
        2)
            attack_service
            ;;
        3)
            clear_screen
            read -p "Ingrese la nueva ubicación del archivo de wordlist: " wordlist_file
            if [ -f "$wordlist_file" ]; then
                password_file=$wordlist_file
                echo "La nueva wordlist ha sido establecida."
            else
                echo "¡El archivo no existe!"
            fi
            read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
            show_info
            ;;
        4)
            clear_screen
            echo "Información del script:"
            echo "Este script utiliza Hydra para realizar ataques de fuerza bruta."
            read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
            show_info
            ;;
        5)
            clear_screen
            echo "Saliendo del script."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
}



# Bucle del menú principal
while true; do
    clear_screen
    show_info
done
