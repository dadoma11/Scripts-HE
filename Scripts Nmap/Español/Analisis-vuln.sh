#!/bin/bash

# Función para verificar vulnerabilidades
check_vulnerabilities() {
    clear
    echo "Detección de Exploits Conocidos"
    echo "--------------------------------"

    # Verificar la vulnerabilidad EternalBlue en SMB
    msfconsole -q -x "use auxiliary/scanner/smb/smb_ms17_010; set RHOSTS $ip_address; run; exit"

    # Otras vulnerabilidades a verificar, por ejemplo, Heartbleed en OpenSSL
    msfconsole -q -x "use auxiliary/scanner/ssl/openssl_heartbleed; set RHOSTS $ip_address; run; exit"

    # Añade aquí más verificaciones de vulnerabilidades según sea necesario

    echo "Análisis de vulnerabilidades completado."
    read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
}

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

# Info
echo "Este script realizará la detección de vulnerabilidades conocidas en sistemas y aplicaciones específicas."
echo "Se utilizará Metasploit para verificar la presencia de exploits conocidos."
echo "Recuerda que ejecutar pruebas de vulnerabilidades en sistemas o aplicaciones sin permiso explícito puede ser ilegal y está estrictamente prohibido."
echo "¡Usa este script con responsabilidad y solo en sistemas donde tengas permiso para hacerlo!"
echo ""

# Solicitar la dirección IP del equipo a verificar
read -p "Ingrese la dirección IP del equipo a analizar: " ip_address

# Instalar Metasploit si no está instalado (puede variar dependiendo del sistema)
if ! command -v msfconsole &> /dev/null; then
    echo "Instalando Metasploit..."
    # Comando de instalación de Metasploit (puede variar dependiendo del sistema)
    # Este comando es un ejemplo y puede necesitar ser modificado para tu sistema
    sudo apt-get install metasploit-framework
fi

# Llamada a la función para verificar vulnerabilidades
check_vulnerabilities
