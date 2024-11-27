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
