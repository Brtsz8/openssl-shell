#!/bin/bash
# Nazwa skryptu: szyfrowanie.sh
# Opis: szyfrowanie plikow
# Autor: Bartosz Pacyga
# Data: 2025-03-05
# Wersja: 0.2  

czy_usun_plik() {
    local plik=$1

    zenity --question --text="Czy usunac plik: $plik?"
    if [[ $? -eq 0 ]]; then
        rm "$plik"
        zenity --info --text="Usunieto: $plik"
    fi
}

#funckja do szyfrowania pojedynczego pliku
szyfruj() {
    local algorytm=$1
    local haslo=$2

    #wybieranie konkretnego pliku przy pomocy zenity
    plik=$(zenity --file-selection --title="Wybierz plik ktory chcesz zaszyfrowac" || blad "Blad przy wybieraniu pliku")
    openssl enc -"$algorytm" -in "$plik" -out "${plik}.enc" -pass pass:"$haslo" &&
    zenity --info --text="Zaszyfrowano: ${plik}.enc"

    #dodatkowe usuniecie pliku ktory jest szyfrowany
    czy_usun_plik $plik
}

deszyfruj() {
    local algorytm=$1
    local haslo=$2

    plik=$(zenity --file-selection --title="Wybierz plik .enc do odszyfrowania" --file-filter="*.enc") || blad "Blad przy wybieraniu pliku"
    output="${plik%.enc}"
    openssl enc -d -"$algorytm" -in "$plik" -out "$output" -pass pass:"$haslo" &&
    zenity --info --text="Odszyfrowano: $output"

    #dodatkowe usuniecie pliku ktory deszyfrujemy
    czy_usun_plik $plik
}

szyfruj_pliki() {
    local algorytm=$1
    losal haslo=$2

    katalog=$(zenity --file-selection --directory --title="Wybierz katalog ktorego zawartosc ma byc zaszyfrowana") || blad "Blad przy wyborze katalogu"
    #tutaj powinna byc dodana funkcjonalnosc typu szyfrowanie podkatalogow w wybranym katalogu
    for plik in "$katalog"/*; do
        [[ -f "$plik" ]] && openssl enc -"$algorytm" -in "$plik" -out "${plik}.enc" -pass pass:"$haslo"
        czy_usun_plik $plik
    done
}

deszyfruj_pliki() {
    local algorytm=$1
    local haslo=$2
    
    katalog=$(zenity --file-selection --directory --title="Wybierz katalog ktorego zawartosc ma byc zaszyfrowana") || blad "Blad przy wyborze katalogu"
    for plik in "$katalog"/*; do
        output="${plik%.enc}"
        [[ -f "$plik" ]] && openssl enc -d -"$algorytm" -in "$plik" -out "$output" -pass pass:"$haslo"
        czy_usun_plik $plik
    done
}

szyfruj_katalog() {
    local algorytm=$1
    local haslo=$2

    katalog=$(zenity --file-selection --directory --title="Wybierz katalog do szyfrowania") || blad "Blad przy wyborze katalogu"

    nazwa=$(basename "$katalog")
    sciezka=$(dirname "$katalog")
    archiwum="${sciezka}/${nazwa}.tar.gz"
    output="${archiwum}.enc"

    #spakowanie katalogu
    tar czf "$archiwum" -C "$sciezka" "$nazwa" || blad "Nie udalo sie spakowac katalogu"

    #szyfrowanie archiwum
    openssl enc -"$algorytm" -in "$archiwum" -out "$output" -pass pass:"$haslo" || blad "Szyfrowanie archiwum nie powiodlo sie"

    #usniecie archiwum (to powinno byc w sumie w folderze temp - trzeba to zmienic)
    rm "$archiwum"

    zenity --info --text="Zaszyfrowano wybrany katalog jako: $output"
    czy_usun_plik $katalog
}

deszyfruj_katalog() {
    echo "deszyfruje katalog ..."
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
  FALSE "Szyfruj pliki w katalogu" \
  FALSE "Deszyfruj pliki w katalogu" \
  FALSE "Szyfruj katalog" \
  FALSE "Deszyfruj katalog" \
  FALSE "Szyfruj wg wzorca" \
  FALSE "Wyjscie") || blad "Nie wybrano zadnej opcji."

# Algorytm
algorytm=$(zenity --list --radiolist --column="Wybror" --column="Algorytm" \
    --title="Wybierz algorytm" --text="Wybierz algorytm przy pomocy ktorego zaszyfrowany bedzie plik" --width=500 --height=700 \
    TRUE "aes-256-cbc" \
    FALSE "aes-192-cbc" \
    FALSE "aes-128-cbc" \
    FALSE "aes-256-ctr" \
    FALSE "aes-128-ctr" \
    FALSE "camellis-256-cbc" \
    FALSE "des3") || blad "Nie wybrano algorytmu!"
[[ -z "$algorytm" ]] && blad "Algorytm nie moze byc pusty."

# Haslo
haslo=$(zenity --password --title="Haslo do szyfrowania/deszyfrowania") || blad "Nie wprowadzono hasla."
[[ -z "$haslo" ]] && blad "Haslo nie moze byc puste."

# na podstawie wyboru przechodzimy do roznych funkcji
case "$opcja" in
    "Szyfruj plik") szyfruj "$algorytm" "$haslo" ;;
    "Deszyfruj plik") deszyfruj "$algorytm" "$haslo" ;;
    "Szyfruj pliki w katalogu") szyfruj_pliki "$algorytm" "$haslo" ;;
    "Deszyfruj pliki w katalogu") deszyfruj_pliki "$algorytm" "$haslo" ;;
    "Szyfruj katalog") szyfruj_katalog "$algorytm" "$haslo" ;;
    "Deszyfruj katalog") deszyfruj_katalog "$algorytm" "$haslo" ;;
    "Szyfruj wg wzorca") szyfruj_wzorzec "$algorytm" "$haslo" ;;
    "Wyjscie") exit 0 ;;
esac