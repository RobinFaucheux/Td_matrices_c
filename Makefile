# Makefile -- TD « Stockage de matrices en C »
#
#   make            construit demo_matrices et les trois programmes de test
#   make test       lance test_ex1, test_ex2 et test_ex3
#   make valgrind   passe les tests et quatre scénarios de démo sous valgrind
#   make clean      supprime les objets, les exécutables et les sorties
#
# Les programmes de test sont compilés avec -DMAT_TEST_ALLOC (simulation
# des échecs d'allocation), demo_matrices sans. Un même module donne donc
# deux fichiers objets : module.o (programme) et module_t.o (tests).

CC       = gcc
CFLAGS   = -std=c11 -Wall -Wextra -Wpedantic -g
TESTDEF  = -DMAT_TEST_ALLOC
VALGRIND = valgrind --leak-check=full \
           --errors-for-leak-kinds=definite,indirect,possible \
           --error-exitcode=99 -q

PROGS = demo_matrices test_ex1 test_ex2 test_ex3

OBJ_DEMO  = main.o matrice.o matrice_alloc.o matrice_io.o matrice_calcul.o
OBJ_TEST1 = test_ex1_t.o matrice_t.o matrice_alloc_t.o
OBJ_TEST2 = test_ex2_t.o matrice_t.o matrice_alloc_t.o matrice_io_t.o
OBJ_TEST3 = test_ex3_t.o matrice_t.o matrice_alloc_t.o matrice_calcul_t.o

.PHONY: all test valgrind clean

all: $(PROGS)

# --- Édition de liens --------------------------------------------------
demo_matrices: $(OBJ_DEMO)
	$(CC) $(CFLAGS) $^ -o $@

test_ex1: $(OBJ_TEST1)
	$(CC) $(CFLAGS) $^ -o $@

test_ex2: $(OBJ_TEST2)
	$(CC) $(CFLAGS) $^ -o $@

test_ex3: $(OBJ_TEST3)
	$(CC) $(CFLAGS) $^ -o $@

# --- Compilation séparée : un .c donne un .o ----------------------------
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%_t.o: %.c
	$(CC) $(CFLAGS) $(TESTDEF) -c $< -o $@

# --- Dépendances envers les en-têtes (graphe des inclusions) -----------
# Un .o est recompilé si l'un des .h qu'il inclut (même indirectement)
# a changé.
H_MAT    = matrice.h
H_ALLOC  = matrice_alloc.h $(H_MAT)
H_IO     = matrice_io.h $(H_MAT)
H_CALCUL = matrice_calcul.h $(H_MAT)

matrice.o        matrice_t.o        : $(H_MAT)
matrice_alloc.o  matrice_alloc_t.o  : $(H_ALLOC)
matrice_io.o     matrice_io_t.o     : $(H_IO) $(H_ALLOC)
matrice_calcul.o matrice_calcul_t.o : $(H_CALCUL) $(H_ALLOC)
main.o       : $(H_ALLOC) $(H_IO) $(H_CALCUL)
test_ex1_t.o : $(H_ALLOC)
test_ex2_t.o : $(H_ALLOC) $(H_IO)
test_ex3_t.o : $(H_ALLOC) $(H_CALCUL)

# --- Cibles utilitaires ------------------------------------------------
test: test_ex1 test_ex2 test_ex3
	@for t in $^; do ./$$t || exit 1; echo; done

# Code 99 = fuite ou erreur mémoire ; les scénarios d'erreur de la démo
# renvoient normalement 1, ce qui n'est pas un échec ici.
valgrind: $(PROGS)
	@for t in test_ex1 test_ex2 test_ex3; do \
	    echo "== valgrind ./$$t"; \
	    $(VALGRIND) ./$$t > /dev/null || exit 1; \
	done
	@for s in "add donnees/A.txt donnees/B.txt R.txt" \
	          "mul donnees/A.txt donnees/C.txt R.txt" \
	          "add donnees/A.txt donnees/C.txt R.txt" \
	          "add donnees/A.txt donnees/invalide.txt R.txt"; do \
	    echo "== valgrind ./demo_matrices $$s"; \
	    $(VALGRIND) ./demo_matrices $$s > /dev/null 2>&1; \
	    [ $$? -ne 99 ] || exit 1; \
	done
	@echo "valgrind : aucune fuite ni erreur mémoire."

clean:
	rm -f *.o $(PROGS) test_ex2_sortie.txt R.txt R2.txt
