-- Consulta 1: Listar todos os usuários e suas tags
SELECT u.id, u.name, GROUP_CONCAT(t.name) AS tags
FROM users u
LEFT JOIN tags t ON u.id = t.user_id
GROUP BY u.id;

-- Consulta 2: Contar o número de postagens por usuário
SELECT u.id, u.name, COUNT(p.id) AS post_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id;

-- Consulta 3: Listar comentários de um post específico
SELECT c.content, u.name AS commenter
FROM comments c
JOIN users u ON c.user_id = u.id
WHERE c.commentable_type = 'POST' AND c.commentable_id = ?;

-- Consulta 4: Listar notificações de um usuário específico
SELECT n.message, n.created_at
FROM notifications n
WHERE n.user_id = ?
ORDER BY n.created_at DESC;

-- Consulta 5: Listar grupos e seus membros
SELECT g.name AS group_name, u.name AS member_name
FROM `groups` g
JOIN memberships m ON g.id = m.group_id
JOIN users u ON m.user_id = u.id;
