
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
-- Relacionando um owner para o grupo
INSERT INTO memberships (group_id, user_id, role)
SELECT g.id,
       (SELECT id FROM users ORDER BY RAND() LIMIT 1) AS user_id,
       'OWNER'
FROM `groups` g;

-- Relacionando um admin para o grupo
INSERT INTO memberships (group_id, user_id, role)
SELECT g.id,
       (SELECT id
        FROM users
        WHERE id NOT IN (SELECT user_id
                         FROM memberships
                         WHERE group_id = g.id
                           AND role = 'OWNER')
        ORDER BY RAND()
        LIMIT 1) AS user_id,
       'ADMIN'
FROM `groups` g;

-- Relacionando membro ao grupo
INSERT INTO memberships (group_id, user_id, role)
SELECT g.id, u.user_id, 'MEMBER'
FROM `groups` g
         JOIN (SELECT u.id AS user_id, g.id AS group_id
               FROM users u
                        CROSS JOIN `groups` g
               WHERE u.id NOT IN (SELECT user_id
                                  FROM memberships
                                  WHERE memberships.group_id = g.id
                                    AND memberships.role IN ('OWNER', 'ADMIN'))
               ORDER BY RAND()) u ON g.id = u.group_id
GROUP BY g.id, u.user_id;

-- Inserindo posts para cada usuário
INSERT INTO posts (content, description, user_id)
SELECT CONCAT(
               '1º Post de <a  href="/users/',
               u.id,
               '">',
               u.name,
               ': ',
               '<h1>Qui placeat nihil qui iure facilis. </h1><p>Lorem ipsum dolor sit amet. Nam dignissimos doloremque <strong>Aut error quo recusandae quam in labore nihil</strong> nam molestias distinctio aut pariatur alias ut atque voluptas. Ea consequatur architecto ex sunt vero <a href="https://www.loremipzum.com" target="_blank">Quo iste sit corporis sint aut rerum assumenda non doloremque consequuntur</a>. In inventore alias <em>Quo velit At expedita praesentium est dolorem voluptatem</em> aut internos sapiente est molestiae quia ab asperiores inventore. </p><h2>Ad deleniti omnis id tempore consequatur sed vitae dicta. </h2><p>Eum inventore nobisqui dolorem sed velit beatae. Ut voluptatum voluptatem <em>Qui ullam eum molestiae dolores et reprehenderit iste</em> est repellat nihil aut fugit voluptas aut debitis pariatur! Hic beatae aliquid <strong>Et dolores ut quibusdam voluptatem et veritatis iusto</strong> non repellendus unde. Eos animi accusantium ea accusamus dignissimosEx veritatis non consequuntur consequatur id saepe obcaecati. </p><h3>Aut quasi sint est velit eius et error consequatur. </h3><p>Sit consequatur sequi non quod corrupti <em>Ea sint 33 sunt distinctio</em> id voluptas fugit qui doloribus labore et itaque numquam. Ut dolor magni et voluptatibus aliaseum eveniet cum dolorum dicta. </p>'
       ),
       'Descrição aleatória',
       u.id
FROM users u;

INSERT INTO posts (content, description, user_id)
SELECT CONCAT(
               '2º Post de <a  href="/users/',
               u.id,
               '">',
               u.name,
               '</a>: ',
               '<p>Lorem ipsum dolor sit amet. Et maxime galisum in galisum deleniti <em>Ut aliquid ut ipsum dolores At repellat quia et asperiores inventore</em>. Est officia sunt qui vero repellendus <strong>Ut quia et nihil quam vel omnis sint sed soluta nulla</strong>. </p><blockquote cite="https://www.loremipzum.com">Id consequatur deleniti et vitae rerum ut voluptates delectus At quidem ducimus et voluptatem quod qui galisum galisum. </blockquote><p>Et galisum rerum <em>Qui earum et quod consequatur ut consectetur temporibus</em> hic saepe soluta est accusantium quae et laborum nobis? Aut ipsum sequi eum reprehenderit consequaturet beatae sed doloribus quia. </p>'
       ),
       'Descrição aleatória',
       u.id
FROM users u;
