#!/bin/bash

Wersja="0.4"

#funkcja analizujaca dodatkowe opcje szyfrowanie.sh
obsluga_argumentow() {
    #Sprawdzanie opcji
    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            -h|--help)
                echo "Uzycie: $0"
                echo "Program do szyfrowania i deszyfrowania plikow i katalogow"
                echo "z uzyciem openssl i zenity"
                echo "Opcje:"
                echo " -h, --help       Wyswietl pomoc"
                echo " -v, --version    Wyswietla weersje programu"
                echo ""
                echo "Program oferuje graficzny interfejs do:"
                echo " - szyfrowania/deszyfrowania plikow"
                echo " - szyfrowania/deszyfrowania folderow"
                echo " - wyboru algorytmu szyfrowania"
                echo " - zabezpieczenia szyfrowania przy pommocy hasla"
                echo "Wymagania: openssl, zenity, tar"
                exit 0 
                ;;
            -v|--version)
                echo "$0 - wersja $Wersja"
                exit 0
                ;;
            *)
                echo "Nieznana opcja: $1"
                echo "Uzyj -h lub --help, aby uzyskac pomoc."
                exit 1
                ;;
        esac
        shift
    done
}