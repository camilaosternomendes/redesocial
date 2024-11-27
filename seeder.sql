
USE at2n2;

-- Inserindo 10 usuários
INSERT INTO users (name, email, birth_date, avatar, created_at, updated_at)
VALUES ('João Silva', 'joao.silva@example.com', '1990-01-15', 'https://example.com/avatars/joao.jpg', NOW(), NOW()),
       ('Maria Oliveira', 'maria.oliveira@example.com', '1985-07-22', 'https://example.com/avatars/maria.jpg', NOW(),
        NOW()),
       ('Carlos Pereira', 'carlos.pereira@example.com', '1992-03-30', 'https://example.com/avatars/carlos.jpg', NOW(),
        NOW()),
       ('Ana Costa', 'ana.costa@example.com', '1988-10-11', 'https://example.com/avatars/ana.jpg', NOW(), NOW()),
       ('Beatriz Lima', 'beatriz.lima@example.com', '1991-04-18', 'https://example.com/avatars/beatriz.jpg', NOW(),
        NOW()),
       ('Fernanda Santos', 'fernanda.santos@example.com', '1993-08-23', 'https://example.com/avatars/fernanda.jpg',
        NOW(), NOW()),
       ('Rodrigo Fernandes', 'rodrigo.fernandes@example.com', '1993-11-23', 'https://example.com/avatars/fernanda.jpg',
        NOW(), NOW()),
       ('Luiza Martins', 'luiza.martins@example.com', '1990-12-05', 'https://example.com/avatars/luiza.jpg', NOW(),
        NOW()),
       ('Patrícia Almeida', 'patricia.almeida@example.com', '1987-06-10', 'https://example.com/avatars/patricia.jpg',
        NOW(), NOW()),
       ('Pedro Souza', 'pedro.souza@example.com', '1995-05-02', 'https://example.com/avatars/pedro.jpg', NOW(), NOW());

DELIMITER $$

CREATE PROCEDURE add_tags_for_all_users()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE user_id INT;
    DECLARE cur CURSOR FOR
        SELECT id FROM users; -- Pega todos os usuários

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO user_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Adiciona 5 tags para o usuário
        INSERT INTO tags (name, user_id)
        VALUES ('Technology', user_id),
               ('Health', user_id),
               ('Business', user_id),
               ('Music', user_id),
               ('Sports', user_id);

    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

CALL add_tags_for_all_users();

-- Relacionando os usuários
INSERT INTO relationships (followed_id, follower_id)
VALUES (1, 2),
       (1, 3),
       (1, 5),
       (2, 1),
       (2, 4),
       (3, 1),
       (3, 5),
       (4, 1),
       (4, 2),
       (5, 4);

-- Inserindo groups
INSERT INTO `groups` (name, description)
VALUES ('Entusiastas de Tecnologia', 'Um grupo para pessoas apaixonadas por tecnologia e inovação.'),
       ('Amantes de Fitness', 'Um grupo para compartilhar rotinas de treino e dicas de estilo de vida saudável.'),
       ('Clube do Livro', 'Um grupo para amantes de livros discutirem e recomendarem leituras.'),
       ('Cinéfilos', 'Um grupo para discutir filmes, séries e análises.'),
       ('Unidos pelos Games', 'Um grupo para entusiastas de jogos compartilharem dicas e jogarem juntos.'),
       ('Amantes de Música', 'Um grupo para falar sobre gêneros musicais, álbuns e artistas favoritos.'),
       ('Viciados em Viagem', 'Um grupo para compartilhar experiências de viagem e dicas de destinos.'),
       ('Fotógrafos Profissionais', 'Um grupo para fotógrafos exibirem e discutirem seus trabalhos.'),
       ('Apaixonados por Gastronomia', 'Um grupo para compartilhar receitas e discutir comidas de todo o mundo.'),
       ('Empreendedores', 'Um grupo para debater ideias de negócios e fazer networking.');


