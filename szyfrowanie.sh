#!/bin/bash
# Nazwa skryptu: szyfrowanie.sh
# Opis: szyfrowanie plikow
# Autor: Bartosz Pacyga
# Data: 2025-03-05
# Wersja: 0.1  

#funckja do szyfrowania pojedynczego pliku
szyfruj_plik() {
    echo "szyfruje plik ..."
}

deszyfruj_plik() {
    echo "deszyfruje plik ..."
}

szyfruj_katalog() {
    echo "szyfruje katalog ..."
}

szyfruj_wzorzec() {
    echo "szyfruje wzorzec ..."
}

# Funkcja bledu
blad() {
    zenity --error --text="$1"
    exit 1
}

# Glowne menu
opcja=$(zenity --list --radiolist \
  --title="Szyfrowanie i deszyfrowanie" \
  --column="Wybor" --column="Operacja" \
  TRUE "Szyfruj plik" \
  FALSE "Deszyfruj plik" \
  FALSE "Szyfruj katalog" \
  FALSE "Szyfruj wg wzorca" \
  FALSE "Wyjscie") || blad "Nie wybrano zadnej opcji."

# Algorytm
algorytm=$(zenity --entry --title="Algorytm" --text="Wprowadz algorytm (np. aes-256-cbc):" --entry-text="aes-256-cbc") || blad "Nie wprowadzono algorytmu."
[[ -z "$algorytm" ]] && blad "Algorytm nie moze byc pusty."

# Haslo
haslo=$(zenity --password --title="Haslo do szyfrowania/deszyfrowania") || blad "Nie wprowadzono hasla."
[[ -z "$haslo" ]] && blad "Haslo nie moze byc puste."

# na podstawie wyboru przechodzimy do roznych funkcji
case "$opcja" in
    "Szyfruj plik") szyfruj_plik "$algorytm" "$haslo" ;;
    "Deszyfruj plik") deszyfruj_plik "$algorytm" "$haslo" ;;
    "Szyfruj katalog") szyfruj_katalog "$algorytm" "$haslo" ;;
    "Szyfruj wg wzorca") szyfruj_wzorzec "$algorytm" "$haslo" ;;
    "Wyjście") exit 0 ;;
esac