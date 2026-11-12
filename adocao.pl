% ============================================================
% SISTEMA DE INDICAÇÃO DE ANIMAIS PARA ADOÇÃO
% Disciplina: Lógica para Ciências da Computação
% Linguagem : Prolog (SWI-Prolog)
% Autores   : Nome 1 e Nome 2
%
% Como usar:
%   swipl adocao.pl
%   ?- recomendado(A, ana).
%   ?- exemplos.        % executa todos os exemplos de consulta
% ============================================================

:- encoding(utf8).

% ============================================================
% 1. BASE DE CONHECIMENTO - ANIMAIS
% ============================================================

% animal(Nome, Especie, Porte, FaixaEtaria, Energia)
%   Porte       : pequeno | medio | grande
%   FaixaEtaria : filhote | adulto | idoso
%   Energia     : baixa | media | alta
animal(rex,   cachorro, grande,  adulto,  alta).
animal(mel,   cachorro, medio,   filhote, media).
animal(thor,  cachorro, pequeno, idoso,   baixa).
animal(luna,  gato,     pequeno, adulto,  media).
animal(mimi,  gato,     pequeno, filhote, alta).
animal(bob,   cachorro, medio,   adulto,  alta).
animal(nina,  coelho,   pequeno, adulto,  baixa).
animal(simba, gato,     pequeno, idoso,   baixa).

% sociavel_criancas(Nome): o animal convive bem com crianças
sociavel_criancas(rex).
sociavel_criancas(mel).
sociavel_criancas(luna).
sociavel_criancas(mimi).
sociavel_criancas(bob).
sociavel_criancas(simba).

% sociavel_animais(Nome): o animal convive bem com outros animais
sociavel_animais(mel).
sociavel_animais(thor).
sociavel_animais(luna).
sociavel_animais(bob).
sociavel_animais(simba).

% vacinado(Nome): vacinação em dia (bob ainda não está vacinado)
vacinado(rex).
vacinado(mel).
vacinado(thor).
vacinado(luna).
vacinado(mimi).
vacinado(nina).
vacinado(simba).

% ============================================================
% 2. BASE DE CONHECIMENTO - INTERESSADOS
% ============================================================

% pessoa(Nome, Moradia, TemCriancas, TemAnimais, Tempo)
%   Moradia : apartamento | casa_pequena | casa_quintal
%   Tempo   : pouco | medio | muito
pessoa(ana,   apartamento,  nao, nao, pouco).
pessoa(bruno, casa_quintal, sim, sim, muito).
pessoa(carla, casa_pequena, sim, nao, medio).

% ============================================================
% 3. FATOS AUXILIARES (escalas numéricas para comparação)
% ============================================================

% Espaço que cada porte de animal exige
porte_exige(pequeno, 1).
porte_exige(medio,   2).
porte_exige(grande,  3).

% Espaço que cada tipo de moradia oferece
espaco_nivel(apartamento,  1).
espaco_nivel(casa_pequena, 2).
espaco_nivel(casa_quintal, 3).

% Atenção/exercício que cada nível de energia demanda
energia_nivel(baixa, 1).
energia_nivel(media, 2).
energia_nivel(alta,  3).

% Tempo que cada disponibilidade representa
tempo_nivel(pouco, 1).
tempo_nivel(medio, 2).
tempo_nivel(muito, 3).

% ============================================================
% 4. REGRAS LÓGICAS
% ============================================================

% Regra 1: o animal cabe na moradia da pessoa?
% O espaço da moradia deve ser maior ou igual ao exigido pelo porte.
cabe_no_espaco(A, P) :-
    animal(A, _, Porte, _, _),
    pessoa(P, Moradia, _, _, _),
    porte_exige(Porte, NivelAnimal),
    espaco_nivel(Moradia, NivelMoradia),
    NivelMoradia >= NivelAnimal.

% Regra 2: a pessoa tem tempo suficiente para a energia do animal?
tempo_adequado(A, P) :-
    animal(A, _, _, _, Energia),
    pessoa(P, _, _, _, Tempo),
    energia_nivel(Energia, NivelEnergia),
    tempo_nivel(Tempo, NivelTempo),
    NivelTempo >= NivelEnergia.

% Regra 3: compatibilidade com crianças.
% Sem crianças em casa, qualquer animal serve; com crianças,
% o animal precisa ser sociável com elas.
compativel_criancas(_, P) :-
    pessoa(P, _, nao, _, _).
compativel_criancas(A, P) :-
    pessoa(P, _, sim, _, _),
    sociavel_criancas(A).

% Regra 4: compatibilidade com outros animais.
% Sem animais em casa, qualquer animal serve; com animais,
% o animal precisa conviver bem com eles.
compativel_animais(_, P) :-
    pessoa(P, _, _, nao, _).
compativel_animais(A, P) :-
    pessoa(P, _, _, sim, _),
    sociavel_animais(A).

% Regra 5: recomendação final.
% Combina todas as regras anteriores e exige vacinação em dia.
recomendado(A, P) :-
    cabe_no_espaco(A, P),
    tempo_adequado(A, P),
    compativel_criancas(A, P),
    compativel_animais(A, P),
    vacinado(A).

% Regra 6: recomendação filtrada por espécie.
recomendado_especie(A, P, Especie) :-
    recomendado(A, P),
    animal(A, Especie, _, _, _).

% Regra 7: animais idosos têm prioridade de adoção.
animal_prioritario(A) :-
    animal(A, _, _, idoso, _).

% Regra 8: animais não vacinados precisam de atenção de saúde.
% Usa negação por falha (\+).
precisa_atencao_saude(A) :-
    animal(A, _, _, _, _),
    \+ vacinado(A).

% ============================================================
% 5. PREDICADOS AUXILIARES DE CONSULTA
% ============================================================

% listar_recomendacoes(+Pessoa): imprime todos os animais
% recomendados para a pessoa informada.
listar_recomendacoes(P) :-
    findall(A, recomendado(A, P), Lista),
    format('Recomendados para ~w: ~w~n', [P, Lista]).

% ============================================================
% 6. EXEMPLOS DE CONSULTAS (execute com ?- exemplos.)
% ============================================================

exemplos :-
    nl, writeln('--- Exemplos de consultas ---'), nl,

    writeln('1. Quais animais são recomendados para a Ana?'),
    findall(A1, recomendado(A1, ana), L1),
    format('   Resultado: ~w~n~n', [L1]),

    writeln('2. Quais gatos são recomendados para o Bruno?'),
    findall(A2, recomendado_especie(A2, bruno, gato), L2),
    format('   Resultado: ~w~n~n', [L2]),

    writeln('3. O Rex cabe no apartamento da Ana?'),
    (   cabe_no_espaco(rex, ana)
    ->  writeln('   Resultado: sim')
    ;   writeln('   Resultado: nao')
    ), nl,

    writeln('4. Para quem o Simba é recomendado?'),
    findall(P4, recomendado(simba, P4), L4),
    format('   Resultado: ~w~n~n', [L4]),

    writeln('5. Quais animais têm prioridade de adoção?'),
    findall(A5, animal_prioritario(A5), L5),
    format('   Resultado: ~w~n~n', [L5]),

    writeln('6. Quais animais precisam de atenção de saúde?'),
    findall(A6, precisa_atencao_saude(A6), L6),
    format('   Resultado: ~w~n~n', [L6]),

    writeln('7. O Rex é recomendado para alguém?'),
    findall(P7, recomendado(rex, P7), L7),
    (   L7 == []
    ->  writeln('   Resultado: ninguém')
    ;   format('   Resultado: ~w~n', [L7])
    ), nl.
