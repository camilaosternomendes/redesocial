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


