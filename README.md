# Aplikacja służąca do generowania przebiegów czasowych podstawowego modelu Lotki-Volterry oraz z ograniczeniem środowiska dla ofiar

>Aplikacja okienkowa została stworzona przy pomocy **Shoes 3.3.6** w Ruby.

## Krótka instrukcja obsługi symulatora 
* W oknie aplikacji należy uzupełniać parametry wyłącznie liczbami, a jako separator stosować kropkę
* Najlepiej trzymać się wielkości zbliżonych do pierwotnych parametrów modelu i zmieniać je stopniowo
* Przyciski używać należy od lewej do prawej strony, bez pośpiechu, kolejne przyciski są gotowe do użytku gdy zaczną "podskakiwać"
* Kliknięcie na tło jednego z wykresów skutkuje otworzeniem nowego okna zawierającego odpowiadający symulacji portret fazowy (Niestety bez wyznaczania punktow stacjonarnych!)
* Zwieńczenie symulacji przyciskiem "plot it!" skutkuje nie tylko przedstawieniem wykresów, ale również zapisaniem ich do folderu, dzięki czemu wyniki dla każdego dobranego zestawu parametrów zostaną zachowane w postaci czterech wykresów, po dwa odpowiadające za symulację z ograniczeniem środowiska dla ofiar i bez.
* Wszystkie potrzebne foldery zostały uwzględnione w tym repozytorium, aplikacja wymaga do użytku:
	* instalacji butów 3.3.6 np. stąd: [oficjalne źródło](https://walkabout.mvmanila.com/public/shoes/)
	* zainstalowania gemu "numo-gnuplot" zgodnie z instrukcją w dokumencie, w folderze "sprawozdanie" (to kilka kliknięć)
	* posiadanie zainstalowanego programu gnuplot

## Krótki film, jak to działa
[![example](https://img.youtube.com/vi/kVWY6kIuqqo/0.jpg)](https://www.youtube.com/watch?v=kVWY6kIuqqo "example")


### Wersja bez GUI

>Wersja skryptowa wymagająca jedynie interpretera z pewnymi gemami zawarta jest w folderze MyLotka-Volterra, w pliku small_main_K.rb
