DROP DATABASE IF EXISTS at2n2;

CREATE DATABASE at2n2;

USE at2n2;

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


CREATE TABLE tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

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

CREATE TABLE relationships
(
    followed_id INT NOT NULL,
    follower_id INT NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (followed_id, follower_id),
    FOREIGN KEY (followed_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (follower_id) REFERENCES users (id) ON DELETE CASCADE
);

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

CREATE TABLE `groups`
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(255) NOT NULL UNIQUE,
    description TEXT         NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

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

CREATE TRIGGER after_post_insert
    AFTER INSERT
    ON posts
    FOR EACH ROW
BEGIN
    INSERT INTO notifications (notificationable_type, notificationable_id, message, user_id)
    SELECT 'POST',
           NEW.id,
           CONCAT('<strong>', u.name, '</strong> created a new post: <a href="/posts/', NEW.id, '">View Post</a>'),
           r.follower_id
    FROM relationships r
             JOIN users u ON u.id = NEW.user_id
    WHERE r.followed_id = NEW.user_id;
END;

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


CREATE TRIGGER after_comment_on_comment
    AFTER INSERT
    ON comments
    FOR EACH ROW
CREATE TRIGGER after_comment_on_comment
    AFTER INSERT
    ON comments
    FOR EACH ROW
BEGIN
    IF NEW.commentable_type = 'REPLY' THEN
        INSERT INTO notifications (notificationable_type, notificationable_id, message, user_id, created_at)
        SELECT 'COMMENT',
               NEW.commentable_id,
               CONCAT('<strong>', u.name, '</strong> replied to your comment: <a href="/comments/', NEW.commentable_id,
                      '">View Reply</a>'),
               c.user_id,
               NOW()
        FROM comments c
                 JOIN users u ON u.id = NEW.user_id
        WHERE c.id = NEW.commentable_id;
    END IF;
END;
DELIMITER ;

CREATE TABLE reviews
(
    id              INT AUTO_INCREMENT PRIMARY KEY,
    reviewable_type ENUM ('USER', 'POST', 'REPLY') NOT NULL,
    reviewable_id   INT                            NOT NULL,
    eval            ENUM ('POSITIVE', 'NEGATIVE')  NOT NULL,
    user_id         INT                            NOT NULL,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at      DATETIME DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id),
    INDEX (reviewable_type, reviewable_id)
);

DELIMITER $$
CREATE TRIGGER after_review_insert
    AFTER INSERT
    ON reviews
    FOR EACH ROW
BEGIN
    CASE NEW.reviewable_type
        WHEN 'POST'
            THEN INSERT INTO notifications (notificationable_type, notificationable_id, message, user_id, created_at)
                 SELECT 'REVIEW',
                        NEW.reviewable_id,
                        CONCAT('<strong>', u.name, '</strong> reviewed your post as <em>', NEW.eval,
                               '</em>: <a href="/posts/', NEW.reviewable_id, '">View Review</a>'),
                        p.user_id,
                        NOW()
                 FROM posts p
                          JOIN users u ON u.id = NEW.user_id
                 WHERE p.id = NEW.reviewable_id;

        WHEN 'REPLY'
            THEN INSERT INTO notifications (notificationable_type, notificationable_id, message, user_id, created_at)
                 SELECT 'REVIEW',
                        NEW.reviewable_id,
                        CONCAT('<strong>', u.name, '</strong> reviewed your comment as <em>', NEW.eval,
                               '</em>: <a href="/comments/', NEW.reviewable_id, '">View Review</a>'),
                        c.user_id,
                        NOW()
                 FROM comments c
                          JOIN users u ON u.id = NEW.user_id
                 WHERE c.id = NEW.reviewable_id;

