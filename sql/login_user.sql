-- テーブルの作成
CREATE TABLE LoginUser (
    UserId INT PRIMARY KEY,
    UserName VARCHAR(50)
);

-- テストユーザーの挿入
INSERT INTO LoginUser (UserId, UserName) VALUES (1, 'TestUser1');
INSERT INTO LoginUser (UserId, UserName) VALUES (2, 'TestUser2');