# 🐾 Indicação de Animais para Adoção

Projeto avaliativo de **Lógica para Ciências da Computação**

**Autores:** Gustavo Souza e Luis Soares

## Descrição

Sistema em Prolog que recomenda animais para adoção de acordo com o perfil do interessado (espécie, raça, moradia, crianças e outros animais em casa e tempo disponível), usando fatos e regras lógicas.

## Arquivos

- `adocao.pl`: código-fonte comentado
- `apresentacao.pdf`: slides do projeto (ainda não foi feito)

## Como executar

```bash
swipl adocao.pl
```

### Modo interativo

O sistema faz uma pergunta por vez (animal, raça, moradia, crianças, outros animais e tempo disponível) e indica os animais compatíveis:

```prolog
?- adotar.
```

Responda digitando o número da opção e apertando Enter.

## Exemplos de consultas

```prolog
?- recomendado(A, ana).
A = thor ; A = nina ; A = simba.

?- recomendado_especie(A, bruno, gato).
A = luna ; A = simba.

?- cabe_no_espaco(rex, ana).
false.

?- animal_prioritario(A).
A = thor ; A = simba.

?- precisa_atencao_saude(A).
A = bob.
```

O predicado `exemplos.` executa todas as consultas de exemplo de uma vez.