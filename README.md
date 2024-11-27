# Projeto da Rede Social

Este script SQL cria a estrutura do banco de dados **at2n2**, incluindo tabelas para usuários, mensagens, tags, relacionamentos, notificações, grupos, postagens, comentários e avaliações. Além disso, são definidos gatilhos (triggers) para garantir a integridade dos dados e a lógica de negócio no sistema.

## 1. Criação do Banco de Dados

O primeiro trecho do script elimina o banco de dados **at2n2**, caso já exista, e o recria. Em seguida, a instrução `USE at2n2` seleciona o banco de dados recém-criado para uso.

```javascript
DROP DATABASE IF EXISTS at2n2;
CREATE DATABASE at2n2;
USE at2n2;
```

## 2. Tabelas Criadas

### 2.1. Tabela `users`

Armazena informações sobre os usuários do sistema.

```sql
CREATE TABLE users
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100)        NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    birth_date DATE,
    avatar     VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL
);
```

* **id**: Identificador único do usuário (chave primária).
* **name**: Nome completo do usuário.
* **email**: Endereço de e-mail do usuário (único).
* **birth\_date**: Data de nascimento do usuário.
* **avatar**: URL do avatar do usuário.
* **created\_at**: Data e hora da criação do registro.
* **updated\_at**: Data e hora da última atualização do registro.
* **deleted\_at**: Data e hora da exclusão do registro (soft delete).

### 2.2. Tabela `messages`

Armazena mensagens enviadas entre os usuários.

```sql
CREATE TABLE messages
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    sender_id   INT  NOT NULL,
    receiver_id INT  NOT NULL,
    content     TEXT NOT NULL,
    status      ENUM ('DRAFT', 'SENT', 'RECEIVED', 'READ') DEFAULT 'DRAFT',
    created_at  DATETIME                                   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id),
    INDEX (sender_id, receiver_id)
);
```

* **id**: Identificador único da mensagem.
* **sender\_id**: ID do usuário que enviou a mensagem.
* **receiver\_id**: ID do usuário que recebeu a mensagem.
* **content**: Conteúdo da mensagem.
* **status**: Status da mensagem (rascunho, enviada, recebida ou lida).
* **created\_at**: Data e hora de envio da mensagem.

### 2.3. Tabela `tags`

Armazena as tags atribuídas aos usuários.

```sql
CREATE TABLE tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```
* *id*: Identificador único da tag.
* *name*: Nome da tag.
* *user\_id*: ID do usuário ao qual a tag pertence.
* *created\_at*: Data e hora da criação da tag.

Gatilho before_tag_insert

Este gatilho impede que um usuário tenha mais de 5 tags.

sql
CREATE TRIGGER before_tag_insert
    BEFORE INSERT
    ON tags
    FOR EACH ROW
BEGIN
    DECLARE tag_count INT;

    -- Conta o número de tags associadas ao usuário
    SELECT COUNT(*)
    INTO tag_count
    FROM tags
    WHERE user_id = NEW.user_id;

    -- Verifica se o número de tags já atingiu o limite
    IF tag_count >= 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A user cannot have more than 5 tags';
    END IF;
    END;


### 2.4. Tabela relationships

Armazena os relacionamentos de seguidores entre os usuários.

sql
CREATE TABLE relationships
(
    followed_id INT NOT NULL,
    follower_id INT NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (followed_id, follower_id),
    FOREIGN KEY (followed_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (follower_id) REFERENCES users (id) ON DELETE CASCADE
);


* *followed\_id*: ID do usuário seguido.
* *follower\_id*: ID do usuário que segue.
* *created\_at*: Data e hora do relacionamento.

### 2.5. Tabela notifications

Armazena as notificações para os usuários.

sql
CREATE TABLE notifications
(
    id                    INT AUTO_INCREMENT PRIMARY KEY,
    notificationable_type ENUM ('POST', 'COMMENT', 'REVIEW') NOT NULL,
    notificationable_id   INT                                NOT NULL,
    message               TEXT                               NOT NULL,
    user_id               INT                                NOT NULL,
    created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted_at            DATETIME DEFAULT NULL,
    INDEX (notificationable_type, notificationable_id)
);
* *notificationable\_type*: Tipo do objeto relacionado à notificação (postagem, comentário, avaliação).
* *notificationable\_id*: ID do objeto relacionado à notificação.
* *message*: Mensagem da notificação.
* *user\_id*: ID do usuário que recebeu a notificação.
* *created\_at*: Data e hora da criação da notificação.

### 2.6. Tabela groups

Armazena informações sobre os grupos no sistema.

sql
CREATE TABLE `groups`
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(255) NOT NULL UNIQUE,
    description TEXT         NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


* *id*: Identificador único do grupo.
* *name*: Nome do grupo.
* *description*: Descrição do grupo.
* *created\_at*: Data e hora de criação do grupo.
* *updated\_at*: Data e hora da última atualização do grupo.

### 2.7. Tabela memberships

Armazena as informações sobre a associação de usuários a grupos, incluindo os papéis atribuídos (Owner, Admin, Member).

sql
CREATE TABLE memberships
(
    group_id   INT NOT NULL,
    user_id    INT NOT NULL,
    role       ENUM ('OWNER','ADMIN','MEMBER') DEFAULT 'MEMBER',
    PRIMARY KEY (group_id, user_id),
    created_at DATETIME                        DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME                        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES `groups` (id),
    FOREIGN KEY (user_id) REFERENCES users (id)
);


* *group\_id*: ID do grupo.
* *user\_id*: ID do usuário.
* *role*: Papel do usuário no grupo (Owner, Admin ou Member).
* *created\_at*: Data e hora da associação.
* *updated\_at*: Data e hora da última atualização.

### 2.8. Tabela posts

Armazena as postagens feitas pelos usuários.

sql
CREATE TABLE posts
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    content     LONGTEXT NOT NULL,
    description TEXT     NULL,
    user_id     INT      NOT NULL,
    group_id    INT      NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at  DATETIME DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES `groups` (id) ON DELETE CASCADE
);


* *id*: Identificador único da postagem.
* *content*: Conteúdo da postagem.
* *description*: Descrição da postagem.
* *user\_id*: ID do usuário que criou a postagem.
* *group\_id*: ID do grupo ao qual a postagem pertence (se aplicável).
* *created\_at*: Data e hora de criação da postagem.

Gatilho after_post_insert

Este gatilho cria uma notificação para os seguidores de um usuário sempre que ele criar uma postagem.

sql
CREATE TRIGGER after_post_insert
    AFTER INSERT
    ON posts
    FOR EACH ROW
BEGIN
    INSERT INTO notifications (notificationable_type, notificationable_id, message, user_id, created_at)
    SELECT 'POST',
           NEW.id,
           CONCAT('<strong>', u.name, '</strong> created a new post: <a href="/posts/', NEW.id, '">View Post</a>'),
           r.follower_id,
           NOW()
    FROM relationships r
             JOIN users u ON u.id = NEW.user_id
    WHERE r.followed_id = NEW.user_id;
END;


### 2.9. Tabela comments

Armazena os comentários feitos nas postagens ou respostas.

sql
CREATE TABLE comments
(
    id               INT AUTO_INCREMENT PRIMARY KEY,
    commentable_type ENUM ('POST', 'REPLY') NOT NULL,
    commentable_id   INT                    NOT NULL,
    content          LONGTEXT               NOT NULL,
    user_id          INT,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at       DATETIME DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id),
    INDEX (commentable_type, commentable_id)
);


* *id*: Identificador único do comentário.
* *commentable\_type*: Tipo do objeto relacionado ao comentário (postagem ou resposta).
* *commentable\_id*: ID do objeto relacionado ao comentário.
* *content*: Conteúdo do comentário.
* *user\_id*: ID do usuário que fez o comentário.

Gatilho after_comment_insert

Este gatilho gera uma notificação para os seguidores do usuário que recebeu o comentário.

sql
CREATE TRIGGER after_comment_on_post
    AFTER INSERT
    ON comments
    FOR EACH ROW
BEGIN
    IF NEW.commentable_type = 'POST' THEN
        INSERT INTO notifications (notificationable_type, notificationable_id, message, user_id, created_at)
        SELECT 'POST',
               NEW.commentable_id,
               CONCAT('<strong>', u.name, '</strong> commented on your post: <a href="/posts/', NEW.commentable_id,
                      '">View Comment</a>'),
               p.user_id,
               NOW()
        FROM posts p
                 JOIN users u ON u.id = NEW.user_id
        WHERE p.id = NEW.commentable_id;
    END IF;
END;


## Uso

Para rodar o arquivo database.sql no MySQL, siga os passos abaixo:

1. *1. Instalação do SGBD:* Certifique-se de que você tem o MySQL instalado em seu sistema.
2. *2. Acesso ao MySQL:*

* Abra o terminal ou o prompt de comando.
* Digite o seguinte comando para acessar o MySQL:

javascript
mysql -u seu_usuario -p


* Substitua seu_usuario pelo seu nome de usuário do MySQL. Após pressionar Enter, você será solicitado a inserir sua senha.

1. *Execução do Script*:

* Para rodar o arquivo database.sql, utilize o seguinte comando no terminal:

javascript
source / caminho / para / o / database.sql;


* Ou, se estiver usando MySQL, você pode usar:

javascript
\. /caminho/para/o/database.sql


* Certifique-se de substituir /caminho/para/o/database.sql pelo caminho real onde o arquivo está localizado.

1. *Verificação:*

* Após a execução do script, verifique se as tabelas e estruturas foram criadas corretamente usando o comando:

javascript
SHOW TABLES;


1. *Testes:*

* Realize alguns testes para garantir que o banco de dados está funcionando conforme esperado, inserindo dados nas tabelas e consultando-os.

Seguindo esses passos, você conseguirá rodar o arquivo database.sql e configurar o banco de dados corretamente.

## Conclusão

Este script define a estrutura inicial do banco de dados *at2n2*, incluindo tabelas essenciais para o gerenciamento de usuários, mensagens, grupos, postagens, comentários e notificações. Além disso, os gatilhos implementados garantem a consistência dos dados e geram notificações automáticas para interações entre os usuários, proporcionando uma experiência mais dinâmica e interativa.

