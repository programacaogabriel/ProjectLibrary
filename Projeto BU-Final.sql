## Projeto BU -
create database biblioteca_municipal_;

###Tabela de Cadatro
create table Cadastro_Alunos(
id_alunos  integer  NOT NULL AUTO_INCREMENT,
Nome_Aluno varchar(50) not null,
Sobrenome_Aluno varchar(50)not null,
Serie_Escolar varchar(35) not null,
RG varchar(10)not null,
CPF varchar(11)not null,
Telefone varchar(15)not null,
Email varchar(100)not null,
livro_preferido int(100)not null,
primary key(id_alunos)
);

###Tabela para armazenamento
create table Armazenamento_livros(
id_livros  INTEGER NOT NULL AUTO_INCREMENT,
Nome_Livro varchar(100) not null,
Autor_Livro varchar(100) not null,
Quantidade_Copias int(100) not null,
primary key(id_livros)
);

### Tabela para locacao
create table Dados_Locacao_livros(
id_locacao INTEGER NOT NULL AUTO_INCREMENT,
Nome_Aluno_Locador varchar(100) not null,
Nome_Livro_Locado varchar(100) not null,
Quantidade_Livros int (100) not null,
id_livros  integer(11) not null,
id_alunos  integer(11) not null,
primary key(id_locacao)                              
);					
### Verificando 
select * from armazenamento_livros;
select * from cadastro_alunos;
select * from Dados_locacao_livros;
### Adicionar Tabelas ( armazenamento_livros, cadastro_alunos, locacao_livros )
## armazenamento_livros = Livros *
## Cadastro_alunos = Alunos *
## dados_locacao_livros = Locacao * 

###Foreign Key
 alter table cadastro_alunos
 add foreign key(livro_preferido)
 references armazenamento_livros(id_livros);
 
 alter table dados_locacao_livros
 add foreign key(id_alunos) 
 references cadastro_alunos(id_alunos);
 
alter table dados_locacao_livros
add foreign key(id_livros)
references armazenamento_livros(id_livros);
###########################################



##Preferencia de cada Aluno
select Nome_aluno, livro_preferido, Nome_Livro,Autor_Livro,Quantidade_Copias from cadastro_alunos
join armazenamento_livros
on armazenamento_livros.id_livros = cadastro_alunos.livro_preferido
order by Nome_aluno;


###Join com as 3 tabelas
select * from cadastro_alunos
join dados_locacao_livros           								
on cadastro_alunos.id_alunos = dados_locacao_livros.id_alunos
join armazenamento_livros
on armazenamento_livros.id_livros = dados_locacao_livros.id_livros;

###Triggers
create table emprestimo(
id_emprestimo INT NOT NULL AUTO_INCREMENT,
Nome_Aluno varchar(100),
Nome_Livros varchar(100),
Data_locacao Date not null,
Data_devolucao Date not null,
Campo_devolucao varchar(50),
quantidade int(100),
primary key(id_emprestimo)
);
##################################################

### Trigger Para realizar o campo_devolucao
DELIMITER $
CREATE TRIGGER ItensEmprestimo_Insert AFTER INSERT
ON emprestimo
FOR EACH ROW
BEGIN
if new.campo_devolucao = "não" then
 UPDATE armazenamento_livros SET Quantidade_copias = Quantidade_copias - NEW.quantidade
WHERE Nome_Livro = NEW.Nome_Livros and Quantidade_copias >5;
end if;

IF NEW.campo_devolucao = 'sim' THEN
UPDATE armazenamento_livros SET Quantidade_copias = Quantidade_copias + NEW.quantidade
WHERE Nome_Livro = NEW.Nome_Livros and Quantidade_copias <20;
END IF;

END$
DELIMITER $

##Inserir dados da  tabela emprestimo = script_insert_Emprestimo
###Checando a data estipulada de 10 dias para a devolução do livro
select DISTINCT  Nome_aluno,Nome_livros,data_devolucao, adddate(data_locacao,interval 10 day) as Entrega_Prevista from emprestimo ;

###Checando armazenamento de livros
SELECT * FROM biblioteca_municipal_.armazenamento_livros;

###Inserindo o livro para a locacao
INSERT INTO biblioteca_municipal_.emprestimo(Nome_Aluno,Nome_Livros,Data_locacao,Data_devolucao,Campo_devolucao,quantidade) VALUES ('Tamara', 'Nutrição', '2020-12-22', '2020-12-25', 'não', '1');


###Restaurando livro devolvido
INSERT INTO biblioteca_municipal_.emprestimo(Nome_Aluno,Nome_Livros,Data_locacao,Data_devolucao,Campo_devolucao,quantidade) VALUES ('Tamara', 'Nutrição', '2020-12-22', '2020-12-25', 'sim', '1');

###Checando Emprestimo
SELECT * FROM  biblioteca_municipal_.emprestimo;

###Criando tabela para uma procedure automatica
create table emprestimo_procedure(select * from emprestimo)

#### PRocedure para o emprestimo
DELIMITER $$
CREATE PROCEDURE st_input_emprestimo()
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE INSERE_ID_EMPRESTIMO  int default 0;
DECLARE INSERE_NOME_ALUNO varchar(100) default 0;
DECLARE INSERE_Nome_Livros varchar(100)default 0;
DECLARE INSERE_Data_locacao Date default 0;
DECLARE INSERE_Data_devolucao Date default 0;
DECLARE INSERE_Campo_devolucao varchar(50)default 0;
DECLARE INSERE_Quantidade int(100)default 0;

DECLARE cursor1 CURSOR FOR SELECT ID_EMPRESTIMO,NOME_ALUNO,Nome_Livros,Data_locacao,Data_devolucao,Campo_devolucao, Quantidade   from emprestimo;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
 OPEN cursor1;
read_loop: LOOP
IF done THEN
 LEAVE read_loop;
 END IF;
FETCH cursor1 INTO
INSERE_ID_EMPRESTIMO,INSERE_NOME_ALUNO,INSERE_Nome_Livros,INSERE_Data_locacao,INSERE_Data_devolucao,INSERE_Campo_devolucao,INSERE_Quantidade;
insert into emprestimo_procedure
Values(INSERE_ID_EMPRESTIMO,INSERE_NOME_ALUNO,INSERE_Nome_Livros,INSERE_Data_locacao,INSERE_Data_devolucao,INSERE_Campo_devolucao,INSERE_Quantidade);
end loop;
 CLOSE cursor1;
END $$

### Seleciona toda a procedure
select * from emprestimo_procedure;

### Inicia a procedure para rodar a cada 5 minutos
create event chama_procedure ON SCHEDULE EVERY 5 minute
ON COMPLETION NOT PRESERVE DISABLE
do
call st_input_emprestimo

##checando se a tarefa foi criada
show events

## Star na Procedure, seu agendamento.
alter event chama_procedure enable;


