#ifndef FORMATER_H
#define FORMATER_H

enum formater_types 
{
    Char, Int, Double, String, Eop
};
typedef enum formater_types formaterTypes;

extern char *formater(formaterTypes, ...);

#endif  /* FORMATER_H */
