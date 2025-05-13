#!/bin/bash
# Nazwa skryptu: szyfrowanie.sh
# Opis: szyfrowanie plikow
# Autor: Bartosz Pacyga
# Data: 2025-03-10
# Wersja: 0.4

source ./args.sh
# Domyslne wymiary okien zenity --width="$WIDTH" --height="$HEIGHT"
WIDTH=600
HEIGHT=400
WIDTH_ER=600
HEIGHT_ER=400

# Wczytaj z configu jesli istnieje
CONFIG="./config.conf"
if [[ -f "$CONFIG" ]]; then
    source "$CONFIG"
fi

#pyta uzytkownika czy plik powinien byc usuniety
czy_usun_plik() {
    local plik=$1

    zenity --width="$WIDTH" --height="$HEIGHT" --question --text="Czy usunac plik: $plik?"
    if [[ $? -eq 0 ]]; then
        #sprawdza czy plik istnieje i potem go usuwa
        [[ -f "$plik" ]] && rm "$plik"            
        zenity --width="$WIDTH" --height="$HEIGHT" --info --text="Usunieto: $plik"
    fi
}

#funkcja prosi urzytkownia o podanie hasla urzywajac zenity --width="$WIDTH" --height="$HEIGHT", po czym zwraca je do funkcji

# Wczytaj z configu jesli istnieje
CONFIG="./config.conf"
if [[ -f "$CONFIG" ]]; then
    source "$CONFIG"
fi

#pyta uzytkownika czy plik powinien byc usuniety
czy_usun_plik() {
    local plik=$1

    zenity --width="$WIDTH" --height="$HEIGHT" --question --text="Czy usunac plik: $plik?"
    if [[ $? -eq 0 ]]; then
        #sprawdza czy plik istnieje i potem go usuwa
        [[ -f "$plik" ]] && rm "$plik"            
        zenity --width="$WIDTH" --height="$HEIGHT" --info --text="Usunieto: $plik"
    fi
}

#funkcja prosi urzytkownia o podanie hasla urzywajac zenity --width="$WIDTH" --height="$HEIGHT", po czym zwraca je do funkcji
podaj_haslo() {
    local haslo=$(zenity --width="$WIDTH" --height="$HEIGHT" --password --title="Podaj haslo" \
        --text="Podaj haslo ktore zostanie uzyte do szyfrowania/deszyfrowania")

    if [[ $? -ne 0 ]]; then
        blad "Nie wybrano hasla."
        return 1
    fi

    if [[ -z "$haslo" ]]; then
        blad "Haslo nie moze byc puste"
        return 1
    fi

    echo "$haslo"
}


#funkcja prosi urzytkownika o wybranie algorytmu, po czym zwraca ten algorytm do funkcji 
wybierz_algorytm() {
    local algorytm=$(zenity --width="$WIDTH" --height="$HEIGHT" --list --radiolist --column="Wybór" --column="Algorytm" \
        --title="Wybierz algorytm" --text="Wybierz algorytm przy pomocy którego zaszyfrowany będzie plik" --width=500 --height=700 \
        TRUE "aes-256-cbc" \
        FALSE "aes-192-cbc" \
        FALSE "aes-128-cbc" \
        FALSE "aes-256-ctr" \
        FALSE "aes-128-ctr" \
        FALSE "camellis-256-cbc" \
        FALSE "des3")

    if [[ $? -ne 0 ]]; then
        blad "Nie wybrano algorytmu!"
        return 1
    fi

    if [[ -z "$algorytm" ]]; then
        blad "Algorytm nie moze byc pusty."
        return 1
    fi

    echo "$algorytm"
}


#szyfrowanie pojedynczego pliku
szyfruj() {
    # wybieranie pliku
    local plik=$(zenity --width="$WIDTH" --height="$HEIGHT" --file-selection --title="Wybierz plik ktory chcesz zaszyfrowac")
    if [[ $? -ne 0 || -z "$plik" ]]; then
        blad "Nie wybrano pliku do zaszyfrowania"
        return 1
    fi

    # wybor algorytmu
    local algorytm=$(wybierz_algorytm)
    [[ $? -ne 0 || -z "$algorytm" ]] && return 1

    # podanie hasła
    local haslo=$(podaj_haslo)
    [[ $? -ne 0 || -z "$haslo" ]] && return 1

    # szyfrowanie
    openssl enc -"$algorytm" -in "$plik" -out "${plik}.enc" -pass pass:"$haslo" &&
    zenity --width="$WIDTH" --height="$HEIGHT" --info --text="Zaszyfrowano: ${plik}.enc"

    # usuniecie oryginalnego pliku
    czy_usun_plik "$plik" || return 1
}


#deszyfrowanie pojedynczego pliku
deszyfruj() {
    # wybieranie pliku
    local plik=$(zenity --width="$WIDTH" --height="$HEIGHT" --file-selection --title="Wybierz plik ktory chcesz zaszyfrowac")
    if [[ $? -ne 0 || -z "$plik" ]]; then
        blad "Nie wybrano pliku do zaszyfrowania"
        return 1
    fi

    # wybor algorytmu
    local algorytm=$(wybierz_algorytm)
    [[ $? -ne 0 || -z "$algorytm" ]] && return 1

    # podanie hasla
    local haslo=$(podaj_haslo)
    [[ $? -ne 0 || -z "$haslo" ]] && return 1
    
    output="${plik%.enc}"
    openssl enc -d -"$algorytm" -in "$plik" -out "$output" -pass pass:"$haslo" &&
    zenity --width="$WIDTH" --height="$HEIGHT" --info --text="Odszyfrowano: $output"

    #dodatkowe usuniecie pliku ktory deszyfrujemy
    czy_usun_plik $plik || return 1
}

#szyfruje wszystkie pliki w wybranym folderze
szyfruj_pliki() {
    local katalog
    katalog=$(zenity --width="$WIDTH" --height="$HEIGHT" --file-selection --directory --title="Wybierz katalog ktorego zawartosc ma byc zaszyfrowana")
    if [[ $? -ne 0 || -z "$katalog" ]]; then
        blad "Nie wybrano katalogu."
        return 1
    fi
    # wybor algorytmu
    local algorytm=$(wybierz_algorytm)
    [[ $? -ne 0 || -z "$algorytm" ]] && return 1
    
    # podanie hasla
    local haslo=$(podaj_haslo)
    [[ $? -ne 0 || -z "$haslo" ]] && return 1
    
    #tutaj powinna byc dodana funkcjonalnosc typu szyfrowanie podkatalogow w wybranym katalogu
    for plik in "$katalog"/*; do
        [[ -f "$plik" ]] && openssl enc -"$algorytm" -in "$plik" -out "${plik}.enc" -pass pass:"$haslo"
        czy_usun_plik $plik
    done
}

#deszyfruje wszystkie pliki w wybranym folderze
deszyfruj_pliki() {
    local katalog
    katalog=$(zenity --width="$WIDTH" --height="$HEIGHT" --file-selection --directory --title="Wybierz katalog ktorego zawartosc ma byc zaszyfrowana")
    if [[ $? -ne 0 || -z "$katalog" ]]; then
        blad "Nie wybrano katalogu."
        return 1
    fi
    # wybor algorytmu
    local algorytm=$(wybierz_algorytm)
    [[ $? -ne 0 || -z "$algorytm" ]] && return 1
    
    # podanie hasla
    local haslo=$(podaj_haslo)
    [[ $? -ne 0 || -z "$haslo" ]] && return 1

    for plik in "$katalog"/*; do
        output="${plik%.enc}"
        [[ -f "$plik" ]] && openssl enc -d -"$algorytm" -in "$plik" -out "$output" -pass pass:"$haslo"
        czy_usun_plik $plik
    done
}

#szyfruje caly katalog, najpierw pakujac go w jeden plik
szyfruj_katalog() {
    local katalog
    katalog=$(zenity --width="$WIDTH" --height="$HEIGHT" --file-selection --directory --title="Wybierz katalog ktorego zawartosc ma byc zaszyfrowana")
    if [[ $? -ne 0 || -z "$katalog" ]]; then
        blad "Nie wybrano katalogu."
        return 1
    fi
    # wybor algorytmu
    local algorytm=$(wybierz_algorytm)
    [[ $? -ne 0 || -z "$algorytm" ]] && return 1
    
    # podanie hasla
    local haslo=$(podaj_haslo)
    [[ $? -ne 0 || -z "$haslo" ]] && return 1

    nazwa=$(basename "$katalog")
    sciezka=$(dirname "$katalog")
    archiwum=$(mktemp "/tmp/${nazwa}.tar.gz.XXXXXX")
    output="${archiwum}.enc"

    #spakowanie katalogu
    tar czf "$archiwum" -C "$sciezka" "$nazwa" || blad "Nie udalo sie spakowac katalogu"

    #szyfrowanie archiwum
    openssl enc -"$algorytm" -in "$archiwum" -out "$output" -pass pass:"$haslo" || blad "Szyfrowanie archiwum nie powiodlo sie"

    #usniecie archiwum (to powinno byc w sumie w folderze temp - trzeba to zmienic)
    rm "$archiwum"

    zenity --width="$WIDTH" --height="$HEIGHT" --info --text="Zaszyfrowano wybrany katalog jako: $output"
    czy_usun_plik $katalog
}

#deszyfruje caly katalog, po czym rozpakowuje go (bo byl spakowany w funkcji szyfruj katalog)
deszyfruj_katalog() {
    local katalog
    katalog=$(zenity --width="$WIDTH" --height="$HEIGHT" --file-selection --directory --title="Wybierz katalog ktorego zawartosc ma byc zaszyfrowana")
    if [[ $? -ne 0 || -z "$katalog" ]]; then
        blad "Nie wybrano katalogu."
        return 1
    fi
    # wybor algorytmu
    local algorytm=$(wybierz_algorytm)
    [[ $? -ne 0 || -z "$algorytm" ]] && return 1
    
    # podanie hasla
    local haslo=$(podaj_haslo)
    [[ $? -ne 0 || -z "$haslo" ]] && return 1

    #miejsce do ktorego bedzie odszyfrowany i rozpakowany folder
    local sciezka="$(dirname "$katalog")"

    #plik tymczasowy do rozpakowywania 
    local rozszyfrowany=$(mktemp "/tmp/rozszyfrowany.XXXXXX")

    #Deszyfrowanie do pliku tymczasoweg
    if ! openssl enc -d -"$algorytm" -in "$katalog" -out "$rozszyfrowany" -pass pass:"$haslo"; then
        rm -f "rozszyfrowany"
        blad "Blad podczas rozszyfrowania pliku: $katalog"
        return 1
    fi

    #rozpakowanie
    if file "$rozszyfrowany" | grep -q "gzip compressed"; then
        if ! tar -xzf "$rozszyfrowany" -C "$sciezka"; then
            rm -f "rozszyfrowany"
            blad "Blad podczas rozpakowania .tar.gz"
            return 1
        fi
    elif file "$rozszyfrowany" | grep -q "Zip archive"; then
        if ! unzip -q "$rozszyfrowany" -d "$sciezka"; then
            rm -f "rozszyfrowany"
            blad "Blad podczas rozszyfrowania pliku .zip"
        return 1
        fi
    else
        rm -f "$rozszyfrowany"
        blad "Nieznany format archiwum"
        return 1
    fi

    rm -f "$rozszyfrowany"

    zenity --width="$WIDTH" --height="$HEIGHT" --info --text="Katalog zostal odszyfrowany i rozpakowany w:\n$katalog_docelowy"
}

#szyfruje pliki wedlug wzorca
szyfruj_wzorzec() {
    #wybor katalogu i wzorca przy pomocy ktorego beda szukane pliki
    local katalog
    katalog=$(zenity --width="$WIDTH" --height="$HEIGHT" --file-selection --directory --title="Wybierz katalog w ktorym bedzie wyszukiwany wzorzec!")
    if [[ $? -ne 0 || -z "$katalog" ]]; then
        blad "Nie wybrano katalogu."
        return 1
    fi
    local wzorzec
    wzorzec=$(zenity --width="$WIDTH" --height="$HEIGHT" --entry --title="Wzorzec:" --text="Podac wzorzec np. \"*.txt\" lub \"dokument*.pdf\"")
    if [[ $? -ne 0 || -z "$wzorzec" ]]; then
        blad "Nie wybrano wzorca"
        return 1
    fi
    # wybor algorytmu
    local algorytm=$(wybierz_algorytm)
    [[ $? -ne 0 || -z "$algorytm" ]] && return 1
    
    # podanie hasla
    local haslo=$(podaj_haslo)
    [[ $? -ne 0 || -z "$haslo" ]] && return 1

    #szuakanie plikow przy urzyciu find
    local znalezione_pliki=($(find "$katalog" -type f -name "$wzorzec"))

    [[ ${#znalezione_pliki[@]} -eq 0 ]] && blad "Nie znaleziono plikow pasujacych do tego wzorca!"

    for plik in "${znalezione_pliki[@]}"; do
        [[ -f "$plik" ]] && openssl enc -"$algorytm" -in "$plik" -out "${plik}.enc" -pass pass:"$haslo" && czy_usun_plik "$plik"
    done

    zenity --width="$WIDTH" --height="$HEIGHT" --info --text="Zaszyfrowano ${#znalezione_pliki[@]} plikow pasujacych do wzorca: $wzorzec"
}

#deszyfruje plik wedlug wzorca
deszyfruj_wzorzec() {
    #wybor katalogu i wzorca przy pomocy ktorego beda szukane pliki
    local katalog
    katalog=$(zenity --width="$WIDTH" --height="$HEIGHT" --file-selection --directory --title="Wybierz katalog w ktorym bedzie wyszukiwany wzorzec!")
    if [[ $? -ne 0 || -z "$katalog" ]]; then
        blad "Nie wybrano katalogu."
        return 1
    fi
    local wzorzec
    wzorzec=$(zenity --width="$WIDTH" --height="$HEIGHT" --entry --title="Wzorzec:" --text="Podac wzorzec np. \"*.txt\" lub \"dokument*.pdf\"")
    if [[ $? -ne 0 || -z "$wzorzec" ]]; then
        blad "Nie wybrano wzorca"
        return 1
    fi
    # wybor algorytmu
    local algorytm=$(wybierz_algorytm)
    [[ $? -ne 0 || -z "$algorytm" ]] && return 1
    
    # podanie hasla
    local haslo=$(podaj_haslo)
    [[ $? -ne 0 || -z "$haslo" ]] && return 1
    
    #szuakanie plikow przy urzyciu find
    local znalezione_pliki=($(find "$katalog" -type f -name "$wzorzec"))

    [[ ${#znalezione_pliki[@]} -eq 0 ]] && blad "Nie znaleziono plikow pasujacych do tego wzorca!"

    for plik in "${znalezione_pliki[@]}"; do
        plik_deszyfrowany="${plik%.enc}"
        [[ -f "$plik" ]] && openssl enc -d -"$algorytm" -in "$plik" -out "$plik_deszyfrowany" -pass pass:"$haslo" && czy_usun_plik "$plik"
    done

    zenity --width="$WIDTH" --height="$HEIGHT" --info --text="Odszyfrowano ${#znalezione_pliki[@]} plikow pasujacych do wzorac: $wzorzec"
}

# Funkcja wyswietla przekazany do niej blad bledu
blad() {
    zenity --width="$WIDTH_ER" --height="$HEIGHT_ER" --error --text="$1"
    return 1
}

obsluga_argumentow "$@"
#MENU GLOWNE PROGRAMU
#wybor sposobu dzialania programu
while true; do
kategoria=$(zenity --width="$WIDTH" --height="$HEIGHT" --list --radiolist \
  --title="Wybierz tryb:" \
  --column="Wybor" --column="Kategoria" \
  TRUE "Szyfrowanie" \
  FALSE "Deszyfrowanie" \
  FALSE "Wyjscie") || blad "Nie wybrano kategorii." || break

#wybor konkretnej opcji
case "$kategoria" in
  "Szyfrowanie")
    opcja=$(zenity --width="$WIDTH" --height="$HEIGHT" --list --radiolist \
      --title="Szyfrowanie - wybierz operacje" \
      --column="Wybor" --column="Operacja" \
      TRUE "Szyfruj plik" \
      FALSE "Szyfruj pliki w katalogu" \
      FALSE "Szyfruj katalog" \
      FALSE "Szyfruj wg wzorca") || blad "Nie wybrano operacji." || continue
    ;;
  
  "Deszyfrowanie")
    opcja=$(zenity --width="$WIDTH" --height="$HEIGHT" --list --radiolist \
      --title="Deszyfrowanie - wybierz operacje" \
      --column="Wybor" --column="Operacja" \
      TRUE "Deszyfruj plik" \
      FALSE "Deszyfruj pliki w katalogu" \
      FALSE "Deszyfruj katalog" \
      FALSE "Deszyfruj wg wzorca") || blad "Nie wybrano operacji." || continue
    ;;
  
  "Wyjscie")
    break
    ;;
esac

# na podstawie wyboru przechodzimy do roznych funkcji
case "$opcja" in
    "Szyfruj plik") szyfruj ;;
    "Deszyfruj plik") deszyfruj ;;
    "Szyfruj pliki w katalogu") szyfruj_pliki ;;
    "Deszyfruj pliki w katalogu") deszyfruj_pliki ;;
    "Szyfruj katalog") szyfruj_katalog ;;
    "Deszyfruj katalog") deszyfruj_katalog ;;
    "Szyfruj wg wzorca") szyfruj_wzorzec ;;
    "Deszyfruj wg wzorca") deszyfruj_wzorzec ;;
esac
done
trap 'echo "Przerwano. Czyszczenie..."; rm -f "$rozszyfrowany"; exit 1' INT
