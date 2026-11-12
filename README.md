# 🐾 Sistema de Indicação de Animais para Adoção (Prolog)

Projeto avaliativo de **Lógica para Ciências da Computação** (UNIVASF).
**Autores:** Gustavo Souza e Luis Soares

## Descrição

Sistema em Prolog que recomenda animais de um abrigo de acordo com o perfil do interessado. A base de conhecimento tem fatos sobre os animais (espécie, porte, faixa etária, energia, sociabilidade, vacinação) e sobre as pessoas (moradia, crianças e outros animais em casa, tempo disponível). As regras lógicas combinam esses fatos para indicar adoções compatíveis.

## Estrutura

```
├── adocao.pl          # código-fonte (fatos, regras e consultas)
├── apresentacao.pdf   # slides da apresentação
└── README.md
```

## Base de conhecimento

- `animal(Nome, Especie, Porte, FaixaEtaria, Energia)`: 8 animais (cachorros, gatos e um coelho)
- `sociavel_criancas/1`, `sociavel_animais/1`, `vacinado/1`
- `pessoa(Nome, Moradia, TemCriancas, TemAnimais, Tempo)`: ana, bruno e carla
- Escalas auxiliares: `porte_exige/2`, `espaco_nivel/2`, `energia_nivel/2`, `tempo_nivel/2`

## Regras

| Regra | O que verifica |
|---|---|
| `cabe_no_espaco(A, P)` | Porte do animal x tamanho da moradia |
| `tempo_adequado(A, P)` | Energia do animal x tempo disponível |
| `compativel_criancas(A, P)` | Se há crianças, o animal precisa ser sociável com elas |
| `compativel_animais(A, P)` | Se há outros animais, o animal precisa conviver bem com eles |
| `recomendado(A, P)` | Combina as quatro anteriores e exige vacinação |
| `recomendado_especie(A, P, E)` | Recomendação filtrada por espécie |
| `animal_prioritario(A)` | Animais idosos |
| `precisa_atencao_saude(A)` | Animais não vacinados |

## Como executar

```bash
swipl adocao.pl
```

Use `;` para ver a próxima solução. O predicado `exemplos.` roda todas as consultas abaixo de uma vez.

## Exemplos de consultas

```prolog
?- recomendado(A, ana).
A = thor ; A = nina ; A = simba.

?- recomendado_especie(A, bruno, gato).
A = luna ; A = simba.

?- cabe_no_espaco(rex, ana).
false.

?- recomendado(simba, P).
P = ana ; P = bruno ; P = carla.

?- animal_prioritario(A).
A = thor ; A = simba.

?- precisa_atencao_saude(A).
A = bob.
```
