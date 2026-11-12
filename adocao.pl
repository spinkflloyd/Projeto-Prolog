:- encoding(utf8).

% ============================================================
% 1. FATOS: ANIMAIS
% ============================================================

% animal(Nome, Especie, Porte, FaixaEtaria, Energia)
animal(rex,   cachorro, grande,  adulto,  alta).
animal(mel,   cachorro, medio,   filhote, media).
animal(thor,  cachorro, pequeno, idoso,   baixa).
animal(luna,  gato,     pequeno, adulto,  media).
animal(mimi,  gato,     pequeno, filhote, alta).
animal(bob,   cachorro, medio,   adulto,  alta).
animal(nina,  coelho,   pequeno, adulto,  baixa).
animal(simba, gato,     pequeno, idoso,   baixa).

% Convive bem com crianças
sociavel_criancas(rex).
sociavel_criancas(mel).
sociavel_criancas(luna).
sociavel_criancas(mimi).
sociavel_criancas(bob).
sociavel_criancas(simba).

% Convive bem com outros animais
sociavel_animais(mel).
sociavel_animais(thor).
sociavel_animais(luna).
sociavel_animais(bob).
sociavel_animais(simba).

% Vacinação em dia (bob não está vacinado)
vacinado(rex).
vacinado(mel).
vacinado(thor).
vacinado(luna).
vacinado(mimi).
vacinado(nina).
vacinado(simba).

% raca(Nome, Raca): srd = sem raça definida
raca(rex,   pastor_alemao).
raca(mel,   labrador).
raca(thor,  poodle).
raca(luna,  siames).
raca(mimi,  srd).
raca(bob,   srd).
raca(nina,  mini_lop).
raca(simba, persa).

% ============================================================
% 2. FATOS: INTERESSADOS
% ============================================================

% Dinâmico: o modo interativo cadastra o "visitante" aqui
:- dynamic pessoa/5.

% pessoa(Nome, Moradia, TemCriancas, TemAnimais, Tempo)
pessoa(ana,   apartamento,  nao, nao, pouco).
pessoa(bruno, casa_quintal, sim, sim, muito).
pessoa(carla, casa_pequena, sim, nao, medio).

% ============================================================
% 3. ESCALAS AUXILIARES (para comparar com >=)
% ============================================================

porte_exige(pequeno, 1).
porte_exige(medio,   2).
porte_exige(grande,  3).

espaco_nivel(apartamento,  1).
espaco_nivel(casa_pequena, 2).
espaco_nivel(casa_quintal, 3).

energia_nivel(baixa, 1).
energia_nivel(media, 2).
energia_nivel(alta,  3).

tempo_nivel(pouco, 1).
tempo_nivel(medio, 2).
tempo_nivel(muito, 3).

% ============================================================
% 4. REGRAS
% ============================================================

% 1. O animal cabe na moradia?
cabe_no_espaco(A, P) :-
    animal(A, _, Porte, _, _),
    pessoa(P, Moradia, _, _, _),
    porte_exige(Porte, NivelAnimal),
    espaco_nivel(Moradia, NivelMoradia),
    NivelMoradia >= NivelAnimal.

% 2. A pessoa tem tempo para a energia do animal?
tempo_adequado(A, P) :-
    animal(A, _, _, _, Energia),
    pessoa(P, _, _, _, Tempo),
    energia_nivel(Energia, NivelEnergia),
    tempo_nivel(Tempo, NivelTempo),
    NivelTempo >= NivelEnergia.

% 3. Com crianças em casa, o animal precisa ser sociável com elas
compativel_criancas(_, P) :-
    pessoa(P, _, nao, _, _).
compativel_criancas(A, P) :-
    pessoa(P, _, sim, _, _),
    sociavel_criancas(A).

% 4. Com outros animais em casa, o animal precisa conviver bem com eles
compativel_animais(_, P) :-
    pessoa(P, _, _, nao, _).
compativel_animais(A, P) :-
    pessoa(P, _, _, sim, _),
    sociavel_animais(A).

% 5. Recomendação: junta as regras anteriores e exige vacinação
recomendado(A, P) :-
    cabe_no_espaco(A, P),
    tempo_adequado(A, P),
    compativel_criancas(A, P),
    compativel_animais(A, P),
    vacinado(A).

% 6. Recomendação filtrada por espécie
recomendado_especie(A, P, Especie) :-
    recomendado(A, P),
    animal(A, Especie, _, _, _).

% 7. Animais idosos têm prioridade
animal_prioritario(A) :-
    animal(A, _, _, idoso, _).

% 8. Animais não vacinados precisam de atenção (negação por falha)
precisa_atencao_saude(A) :-
    animal(A, _, _, _, _),
    \+ vacinado(A).

% ============================================================
% 5. CONSULTA AUXILIAR
% ============================================================

% Lista de uma vez os animais recomendados para uma pessoa
listar_recomendacoes(P) :-
    findall(A, recomendado(A, P), Lista),
    format('Recomendados para ~w: ~w~n', [P, Lista]).

% ============================================================
% 6. EXEMPLOS DE CONSULTAS (?- exemplos.)
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

% ============================================================
% 7. MODO INTERATIVO (?- adotar.)
% Faz uma pergunta por vez e usa recomendado/2 com as respostas.
% ============================================================

% Faz as perguntas e mostra os animais indicados
buscar_animal :-
    nl, writeln('--- Busca de animal ---'),
    writeln('Responda digitando o numero da opcao e apertando Enter.'),

    perguntar('1) Qual animal voce procura?',
              [cachorro-'Cachorro', gato-'Gato', coelho-'Coelho',
               qualquer-'Qualquer um'], Especie),

    opcoes_raca(Especie, OpcoesRaca),
    perguntar('2) Tem preferencia de raca?', OpcoesRaca, Raca),

    perguntar('3) Onde voce mora?',
              [apartamento-'Apartamento',
               casa_pequena-'Casa pequena (sem quintal)',
               casa_quintal-'Casa com quintal'], Moradia),

    perguntar('4) Mora com criancas?',
              [sim-'Sim', nao-'Nao'], Criancas),

    perguntar('5) Mora com outros animais?',
              [sim-'Sim', nao-'Nao'], Animais),

    perguntar('6) Quanto tempo livre voce tem para o animal?',
              [pouco-'Pouco', medio-'Medio', muito-'Muito'], Tempo),

    % Cadastra o visitante, consulta as regras e remove o cadastro
    retractall(pessoa(visitante, _, _, _, _)),
    assertz(pessoa(visitante, Moradia, Criancas, Animais, Tempo)),
    resultado_adocao(Especie, Raca),
    retractall(pessoa(visitante, _, _, _, _)).

% Repete a busca enquanto o usuário quiser
adotar :-
    buscar_animal,
    perguntar('Deseja fazer outra busca?',
              [sim-'Sim', nao-'Nao'], Outra),
    (   Outra == sim -> adotar ; writeln('Obrigado e boa adocao!') ).

% Mostra as opções (Valor-Rotulo), lê o número e repete se for inválido
perguntar(Pergunta, Opcoes, Escolha) :-
    nl, writeln(Pergunta),
    mostrar_opcoes(Opcoes, 1),
    write('> '),
    read_line_to_string(user_input, Entrada),
    (   Entrada == end_of_file
    ->  writeln('Entrada encerrada.'), halt
    ;   number_string(N, Entrada),
        integer(N), N >= 1,
        nth1(N, Opcoes, Escolha-_)
    ->  true
    ;   writeln('Opcao invalida, tente novamente.'),
        perguntar(Pergunta, Opcoes, Escolha)
    ).

% Imprime a lista numerada de opções
mostrar_opcoes([], _).
mostrar_opcoes([_-Rotulo|Resto], N) :-
    format('  ~w) ~w~n', [N, Rotulo]),
    N1 is N + 1,
    mostrar_opcoes(Resto, N1).

% Menu de raças da espécie escolhida (ou de todas)
opcoes_raca(Especie, [qualquer-'Sem preferencia'|Racas]) :-
    findall(R-R,
            (   animal(A, E, _, _, _),
                ( Especie == qualquer ; E == Especie ),
                raca(A, R)
            ),
            Pares),
    sort(Pares, Racas).

% O animal atende à espécie e raça pedidas? (qualquer = sem restrição)
filtro_animal(A, Especie, Raca) :-
    ( Especie == qualquer ; animal(A, Especie, _, _, _) ),
    ( Raca == qualquer ; raca(A, Raca) ).

% Mostra os animais indicados; se o filtro não achar nada,
% sugere os demais animais compatíveis com o perfil
resultado_adocao(Especie, Raca) :-
    nl, writeln('--- Resultado ---'),
    findall(A,
            ( recomendado(A, visitante), filtro_animal(A, Especie, Raca) ),
            Lista),
    findall(A, recomendado(A, visitante), Compativeis),
    (   Lista \== []
    ->  writeln('Animais indicados para voce:'),
        mostrar_animais(Lista)
    ;   Compativeis \== []
    ->  writeln('Nenhum animal com essa especie/raca e compativel com seu perfil.'),
        writeln('Mas estes outros animais combinam com voce:'),
        mostrar_animais(Compativeis)
    ;   writeln('Nenhum animal do abrigo e compativel com o seu perfil no momento.')
    ).

% Imprime os dados de cada animal
mostrar_animais([]).
mostrar_animais([A|Resto]) :-
    animal(A, Especie, Porte, Faixa, Energia),
    raca(A, Raca),
    format('  - ~w: ~w, raca ~w, porte ~w, ~w, energia ~w~n',
           [A, Especie, Raca, Porte, Faixa, Energia]),
    mostrar_animais(Resto).

% ============================================================
% 8. MENU PRINCIPAL (?- iniciar.)
% Tela inicial que reúne todas as funções do sistema.
% ============================================================

iniciar :-
    nl, writeln('=== Sistema de Indicacao de Animais para Adocao ==='),
    writeln('Digite o numero da opcao e aperte Enter.'),
    menu.

% Mostra o menu, executa a opção escolhida e volta ao menu
menu :-
    perguntar('MENU - O que voce deseja fazer?',
              [buscar-'Buscar um animal para mim',
               animais-'Ver os animais do abrigo',
               pessoas-'Ver os perfis cadastrados',
               prioritarios-'Ver animais com prioridade de adocao',
               saude-'Ver animais que precisam de atencao de saude',
               exemplos-'Rodar as consultas de exemplo',
               sair-'Sair'], Opcao),
    (   Opcao == sair
    ->  writeln('Ate logo!')
    ;   acao(Opcao),
        pausar,
        menu
    ).

% acao(+Opcao): executa cada item do menu
acao(buscar) :-
    buscar_animal.
acao(animais) :-
    nl, writeln('--- Animais do abrigo ---'),
    findall(A, animal(A, _, _, _, _), Lista),
    mostrar_animais(Lista).
acao(pessoas) :-
    nl, writeln('--- Perfis cadastrados ---'),
    forall(pessoa(P, Moradia, Criancas, Animais, Tempo),
           format('  - ~w: moradia ~w, criancas ~w, outros animais ~w, tempo ~w~n',
                  [P, Moradia, Criancas, Animais, Tempo])).
acao(prioritarios) :-
    nl, writeln('--- Animais com prioridade de adocao (idosos) ---'),
    findall(A, animal_prioritario(A), Lista),
    mostrar_animais(Lista).
acao(saude) :-
    nl, writeln('--- Animais que precisam de atencao de saude ---'),
    findall(A, precisa_atencao_saude(A), Lista),
    (   Lista == []
    ->  writeln('  Nenhum animal precisa de atencao no momento.')
    ;   mostrar_animais(Lista)
    ).
acao(exemplos) :-
    exemplos.

% Espera o usuário apertar Enter antes de voltar ao menu
pausar :-
    nl, write('Pressione Enter para voltar ao menu...'),
    read_line_to_string(user_input, _).