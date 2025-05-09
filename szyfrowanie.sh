#!/bin/bash
# Nazwa skryptu: szyfrowanie.sh
# Opis: szyfrowanie plikow
# Autor: Bartosz Pacyga
# Data: 2025-03-09
# Wersja: 0.3

Wersja="0.3"

#pyta uzytkownika czy plik powinien byc usuniety
czy_usun_plik() {
    local plik=$1

    zenity --question --text="Czy usunac plik: $plik?"
    if [[ $? -eq 0 ]]; then
        rm "$plik"
        zenity --info --text="Usunieto: $plik"
    fi
}

#funkcja prosi urzytkownia o podanie hasla urzywajac zenity, po czym zwraca je do funkcji
podaj_haslo() {
    haslo=$(zenity --password --title="Podaj haslo" \
    --text="Podaj haslo ktore zostanie uzyte do szyfrowania/deszyfrowania") || blad "Nie wybrano hasla."

    echo "$haslo"
}

#funkcja prosi urzytkownika o wybranie algorytmu, po czym zwraca ten algorytm do funkcji 
wybierz_algorytm() {
    echo ...
}

#szyfrowanie pojedynczego pliku
szyfruj() {
    local algorytm=$1
    
    #wybieranie konkretnego pliku przy pomocy zenity
    plik=$(zenity --file-selection --title="Wybierz plik ktory chcesz zaszyfrowac" || blad "Blad przy wybieraniu pliku")
    # Haslo
    haslo=$(zenity --password --title="Haslo do szyfrowania/deszyfrowania") || blad "Nie wprowadzono hasla."
    [[ -z "$haslo" ]] && blad "Haslo nie moze byc puste."
    
    openssl enc -"$algorytm" -in "$plik" -out "${plik}.enc" -pass pass:"$haslo" &&
    zenity --info --text="Zaszyfrowano: ${plik}.enc"

    #dodatkowe usuniecie pliku ktory jest szyfrowany
    czy_usun_plik $plik
}

#deszyfrowanie pojedynczego pliku
deszyfruj() {
    local algorytm=$1

    plik=$(zenity --file-selection --title="Wybierz plik .enc do odszyfrowania" --file-filter="*.enc") || blad "Blad przy wybieraniu pliku"
    # Haslo
    haslo=$(zenity --password --title="Haslo do szyfrowania/deszyfrowania") || blad "Nie wprowadzono hasla."
    [[ -z "$haslo" ]] && blad "Haslo nie moze byc puste."
    
    output="${plik%.enc}"
    openssl enc -d -"$algorytm" -in "$plik" -out "$output" -pass pass:"$haslo" &&
    zenity --info --text="Odszyfrowano: $output"

    #dodatkowe usuniecie pliku ktory deszyfrujemy
    czy_usun_plik $plik
}

#szyfruje wszystkie pliki w wybranym folderze
szyfruj_pliki() {
    local algorytm=$1

    katalog=$(zenity --file-selection --directory --title="Wybierz katalog ktorego zawartosc ma byc zaszyfrowana") || blad "Blad przy wyborze katalogu"
    # Haslo
    haslo=$(zenity --password --title="Haslo do szyfrowania/deszyfrowania") || blad "Nie wprowadzono hasla."
    [[ -z "$haslo" ]] && blad "Haslo nie moze byc puste."
    
    #tutaj powinna byc dodana funkcjonalnosc typu szyfrowanie podkatalogow w wybranym katalogu
    for plik in "$katalog"/*; do
        [[ -f "$plik" ]] && openssl enc -"$algorytm" -in "$plik" -out "${plik}.enc" -pass pass:"$haslo"
        czy_usun_plik $plik
    done
}

#deszyfruje wszystkie pliki w wybranym folderze
deszyfruj_pliki() {
    local algorytm=$1
    
    katalog=$(zenity --file-selection --directory --title="Wybierz katalog ktorego zawartosc ma byc zaszyfrowana") || blad "Blad przy wyborze katalogu"
    # Haslo
    haslo=$(zenity --password --title="Haslo do szyfrowania/deszyfrowania") || blad "Nie wprowadzono hasla."
    [[ -z "$haslo" ]] && blad "Haslo nie moze byc puste."

    for plik in "$katalog"/*; do
        output="${plik%.enc}"
        [[ -f "$plik" ]] && openssl enc -d -"$algorytm" -in "$plik" -out "$output" -pass pass:"$haslo"
        czy_usun_plik $plik
    done
}

#szyfruje caly katalog, najpierw pakujac go w jeden plik
szyfruj_katalog() {
    local algorytm=$1

    katalog=$(zenity --file-selection --directory --title="Wybierz katalog do szyfrowania") || blad "Blad przy wyborze katalogu"
    # Haslo
    haslo=$(zenity --password --title="Haslo do szyfrowania/deszyfrowania") || blad "Nie wprowadzono hasla."
    [[ -z "$haslo" ]] && blad "Haslo nie moze byc puste."

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

#deszyfruje caly katalog, po czym rozpakowuje go (bo byl spakowany w funkcji szyfruj katalog)
deszyfruj_katalog() {
    echo "deszyfruje katalog ..."
}

#szyfruje pliki wedlug wzorca
szyfruj_wzorzec() {
    echo "szyfruje wzorzec ..."
}

#deszyfruje plik wedlug wzorca
deszyfruj_wzorzec() {
    echo "deszyfruje wzorzec ..."
}

# Funkcja wyswietla przekazany do niej blad bledu
blad() {
    zenity --error --text="$1"
    ./szyfrowanie.sh    #restartuje program
}

#Sprawdzanie opcji
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        -h|--help)
            echo "Opcje:"
            echo " -h, --help       Wyswietl pomoc"
            echo " -v, --version    Wyswietla weersje programu"
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
#MENU GLOWNE PROGRAMU
#wybor sposobu dzialania programu
kategoria=$(zenity --list --radiolist \
  --title="Wybierz tryb:" \
  --column="Wybor" --column="Kategoria" \
  TRUE "Szyfrowanie" \
  FALSE "Deszyfrowanie" \
  FALSE "Wyjscie") || blad "Nie wybrano kategorii."

haslo=$(podaj_haslo)
echo "Haslo:"
echo $haslo

#wybor konkretnej opcji
case "$kategoria" in
  "Szyfrowanie")
    opcja=$(zenity --list --radiolist \
      --title="Szyfrowanie - wybierz operacje" \
      --column="Wybor" --column="Operacja" \
      TRUE "Szyfruj plik" \
      FALSE "Szyfruj pliki w katalogu" \
      FALSE "Szyfruj katalog" \
      FALSE "Szyfruj wg wzorca") || blad "Nie wybrano operacji."
    ;;
  
  "Deszyfrowanie")
    opcja=$(zenity --list --radiolist \
      --title="Deszyfrowanie - wybierz operacje" \
      --column="Wybor" --column="Operacja" \
      TRUE "Deszyfruj plik" \
      FALSE "Deszyfruj pliki w katalogu" \
      FALSE "Deszyfruj katalog" \
      FALSE "Deszyfruj wg wzorca") || blad "Nie wybrano operacji."
    ;;
  
  "Wyjscie")
    exit 0
    ;;
esac

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


# na podstawie wyboru przechodzimy do roznych funkcji
case "$opcja" in
    "Szyfruj plik") szyfruj "$algorytm" ;;
    "Deszyfruj plik") deszyfruj "$algorytm" ;;
    "Szyfruj pliki w katalogu") szyfruj_pliki "$algorytm" ;;
    "Deszyfruj pliki w katalogu") deszyfruj_pliki "$algorytm" ;;
    "Szyfruj katalog") szyfruj_katalog "$algorytm" ;;
    "Deszyfruj katalog") deszyfruj_katalog "$algorytm" ;;
    "Szyfruj wg wzorca") szyfruj_wzorzec "$algorytm" ;;
    "Deszyfruj wg wzorca") deszyfruj_wzorzec "$algorytm" ;;
esac