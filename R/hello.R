### ---- Hello world ----

# set.seed(26062000)
# od <- as.Date("2014-11-01")
# do <- as.Date("2021-02-05")
# co <- "days"
#
# data <- seq(od,do, co)
#
# n <- length(data)
#
# dane <- data.frame(
#   data = data,
#   cena = round(rnorm(n, 1000,100),2),
#   ilosc = sample(1:n, n, replace = TRUE)
# )
#
# usethis::use_data(dane, compress = "xz")
# # save(x,file="data/dane.rda", compress = "xz")


### ---- Funkcje ----
.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Witamy w pakiecie filtr. Przygotowanym w celu zaliczenia przedmiotu Analiza danych w srodowisku R. ")
}
.filtr <- function(dane, kolumna, dol, gora, flaga, typ) {
  # dane
  if (!"data.frame" %in% class(dane)) stop("\nKlasa danych to nie data frame!")
  if (!all(names(dane) %in% c("data", "ilosc", "cena"))) stop("\nDane w zlym formacie.")
  if (nrow(dane)==0) stop("\nPusty zbior danych")
  # kolumna
  if (length(kolumna)!=1) stop("\nPodaj jedna kolumne")
  if (!kolumna %in% c("ilosc", "cena")) stop("\nNie ma takiej kolumny")
  # gora/dol
  if (length(dol)!=1) stop("\nPodaj tylko jedna wartosc - ograniczenie dolne")
  if (length(gora)!=1) stop("\nPodaj tylko jedna wartosc - ograniczenie gorne")
  if (!is.numeric(c(dol, gora))) stop("\nGora i dol powinny byc liczbami")
  if (dol>gora) stop("\nOgranicznie dolne musi byc mniejsze od ograniczenia gornego")
  if (typ == 2 && any(c(gora, dol) > 1) || any(c(gora, dol) < 0)) stop("\nKwantyle z przedzialu [0,1]")
  # flaga
  if (length(flaga)!= 1) stop("\nFlaga powinna byc pojedyncza wartoscia")
  if (!is.logical(flaga)) stop("\nFlaga nie jest wartoscia logiczna")

  if (typ==2) {
    dol <- quantile(dane[, kolumna],
                    dol)
    gora <- quantile(dane[, kolumna],
                    gora)
  }

  x <- dane

  if (flaga) {
    x$flaga <- 0
    x[(x[,kolumna] >= dol) & (x[,kolumna] <= gora), ]$flaga <- 1
  } else {
    x[(x[,kolumna] >= dol) & (x[,kolumna] <= gora), ] -> x
  }
  rownames(x) <- NULL
  x
}



#' @title Filtrowanie z limitem dolnym i gornym
#'
#' @description Dokonuje selekcji tych rekordow, dla ktorych wskazana kolumna jest miedzy limitem dolnym a limitem gornym
#' @param dane Zbior danych uzytkownika jako data frame
#' @param kolumna Kolumna ktora zostanie wykorzystana do dokonywania selekcji
#' @param limit_dolny Najmniejsza akceptowalna wartosc z danej kolumny
#' @param limit_gorny Najwieksza akceptowalna wartosc z danej kolumny
#' @param flaga  Zmienna logiczna, domyslnie \code{FALSE}.
#' @rdname filtr1
#' @return
#' Funkcja zwraca:
#' \itemize{
#'     \item dla \code{FALSE} zawezona ramke (tylko rekordy spelniajace warunki filtru),
#'     \item dla \code{TRUE} z pelna ramke z dodatkowa kolumna FLAGA (1, gdy wiersz/rekord spelnia krytrium filtru, 0 gdy nie spelnia).
#' }
#' @examples
#' filtr1(dane,"cena", 600, 850)
#' filtr1(dane,"ilosc", 800, 1750, TRUE)
#' @export
filtr1 <- function(dane, kolumna, limit_dolny, limit_gorny, flaga=FALSE) {
  .filtr(dane, kolumna, limit_dolny, limit_gorny, flaga, 1)
}


#' @title Filotrowanie z kwantylem dolnym i gornym
#'
#' @description Oblicza kwantyle rozkladu wartosci ze wskazanej kolumny
#'              (odpowiednio rzedu kwantyl dolny i kwantyl gorny) i dokonuje selekcji
#'              tych wartosci z danej kolumny, ktore sie mieszcza pomiedzy
#' @param dane Zbior danych uzytkownika jako data frame
#' @param kolumna Kolumna ktora zostanie wykorzystana do dokonywania selekcji
#' @param kwantyl_dolny Limit dolny
#' @param kwantyl_gorny Limit gorny
#' @param flaga  Zmienna logiczna, domyslnie \code{FALSE}.
#'
#' @rdname filtr2
#' @return
#' Funkcja zwraca:
#' \itemize{
#'     \item dla \code{FALSE} zawezona ramke (tylko rekordy spelniajace warunki filtru),
#'     \item dla \code{TRUE} z pelna ramke z dodatkowa kolumna FLAGA (1, gdy wiersz/rekord spelnia krytrium filtru, 0 gdy nie spelnia).
#' }
#' @examples
#' filtr2(dane,"cena", 0.15, 0.35)
#' filtr2(dane,"ilosc", 0.25, 0.75, TRUE)
#' @export
filtr2 <- function(dane, kolumna, kwantyl_dolny, kwantyl_gorny, flaga=FALSE) {
  .filtr(dane, kolumna, kwantyl_dolny, kwantyl_gorny, flaga, 2)
}



