/*
 * matrice_calcul.c -- Opérations arithmétiques sur les matrices.
 *
 * FICHIER À COMPLÉTER (exercice 3, étapes 3.a à 3.g).
 */
#include <limits.h>
#include <stddef.h>
#include "matrice_calcul.h"
#include "matrice_alloc.h"

/* ------------------------------------------------------------------
 * FOURNI -- Contrôles communs aux deux opérations.
 * Refuse res NULL ou égal à une entrée (sans rien modifier), met *res
 * à l'état vide, puis vérifie que a et b sont valides.
 * ------------------------------------------------------------------ */
static MatErreur verifier_parametres(const Matrice *a, const Matrice *b,
                                     Matrice *res)
{
    if (res == NULL || res == a || res == b)
        return MAT_ERR_ARGUMENT;
    *res = MATRICE_VIDE;
    if (!mat_est_valide(a) || !mat_est_valide(b))
        return MAT_ERR_ARGUMENT;
    return MAT_OK;
}

/* FOURNI -- Un résultat calculé en long long tient-il dans un int ? */
static int tient_dans_int(long long v)
{
    return v >= INT_MIN && v <= INT_MAX;
}

MatErreur mat_additionner(const Matrice *a, const Matrice *b,
                          Matrice *res)
{
    MatErreur err = verifier_parametres(a, b, res);      /* FOURNI */
    if (err != MAT_OK)
        return err;

    if (a->nb_lignes != b->nb_lignes
        || a->nb_colonnes != b->nb_colonnes)
        return MAT_ERR_DIMENSIONS;

    Matrice r = MATRICE_VIDE;
    err = mat_allouer(&r, a->nb_lignes, a->nb_colonnes);
    if (err != MAT_OK)
        return err;

    /* FOURNI : parcours de tous les coefficients de r. */
    for (int i = 0; i < r.nb_lignes; i++) {
        for (int j = 0; j < r.nb_colonnes; j++) {
            long long s = (long long)a->coef[i][j] + b->coef[i][j];

            if (!tient_dans_int(s)) {                    /* FOURNI */
                mat_detruire(&r);
                return MAT_ERR_DEPASSEMENT;
            }
            r.coef[i][j] = (int)s;
        }
    }

    *res = r;
    return MAT_OK;
}

MatErreur mat_multiplier(const Matrice *a, const Matrice *b,
                         Matrice *res)
{
    MatErreur err = verifier_parametres(a, b, res);      /* FOURNI */
    if (err != MAT_OK)
        return err;

    if (a->nb_colonnes != b->nb_lignes)
        return MAT_ERR_DIMENSIONS;

    Matrice r = MATRICE_VIDE;
    err = mat_allouer(&r, a->nb_lignes, b->nb_colonnes);
    if (err != MAT_OK)
        return err;

    for (int i = 0; i < r.nb_lignes; i++) {              /* FOURNI */
        for (int j = 0; j < r.nb_colonnes; j++) {
            long long s = 0;

            for (int k = 0; k < a->nb_colonnes; k++) {
                long long p = (long long)a->coef[i][k] * b->coef[k][j];
                if ((p > 0 && s > LLONG_MAX - p)
                    || (p < 0 && s < LLONG_MIN - p)) {
                    mat_detruire(&r);
                    return MAT_ERR_DEPASSEMENT;
                }
                s += p;
            }

            if (!tient_dans_int(s)) {                    /* FOURNI */
                mat_detruire(&r);
                return MAT_ERR_DEPASSEMENT;
            }
            r.coef[i][j] = (int)s;
        }
    }

    *res = r;
    return MAT_OK;
}
