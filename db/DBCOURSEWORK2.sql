-- НАЧАЛО ТРАНЗАКЦИИ
BEGIN;

-- =============================================================
-- 0. ОЧИСТКА (УДАЛЕНИЕ СТАРЫХ ТАБЛИЦ)
-- =============================================================
-- Удаляем табл 
DROP TABLE IF EXISTS PROJECTS_HISTORY CASCADE;

DROP TABLE IF EXISTS WORKERS_CHOICE CASCADE;

DROP TABLE IF EXISTS TASKS CASCADE;

DROP TABLE IF EXISTS SALARY CASCADE;

DROP TABLE IF EXISTS USERS CASCADE;

DROP TABLE IF EXISTS PROJECTS_PURPOSES CASCADE;

DROP TABLE IF EXISTS PROJECTS_TEAM CASCADE;

DROP TABLE IF EXISTS WORKERS CASCADE;

DROP TABLE IF EXISTS POSITIONS CASCADE;

DROP TABLE IF EXISTS PROJECTS CASCADE;

DROP TABLE IF EXISTS PROJECTS_STATUSES CASCADE;

DROP TABLE IF EXISTS ORGANIZATION_REPRESENTATIVES CASCADE;

DROP TABLE IF EXISTS ORGANIZATIONS CASCADE;

DROP TABLE IF EXISTS BILLING_PERIOD CASCADE;

DROP TABLE IF EXISTS TASKS_TYPES CASCADE;

DROP TABLE IF EXISTS TASKS_PRIORITIES CASCADE;

DROP TABLE IF EXISTS TASKS_STATUSES CASCADE;

DROP TABLE IF EXISTS DESTINATION_MODE CASCADE;
DROP TABLE IF EXISTS WORKERS_IN_PROJECTS CASCADE;
DROP TABLE IF EXISTS TASKS_HISTORY CASCADE;
DROP TABLE IF EXISTS PROJECTS_TASKS_HISTORY CASCADE;

-- Если была старая таблица customers, удаляем и её
DROP TABLE IF EXISTS CUSTOMERS CASCADE;
COMMIT;
ROLLBACK;
select * from POSITIONS

-- 1. ОРГАНИЗАЦИИ
CREATE TABLE ORGANIZATIONS (
	ID_ORGANIZATION SERIAL PRIMARY KEY,
	NAME VARCHAR(200) NOT NULL,
	INN VARCHAR(20) NOT NULL,
	KPP VARCHAR(20),
	LEGAL_ADDRESS VARCHAR(300) NOT NULL,
	ACTUAL_ADDRESS VARCHAR(300),
	PHONE_NUMBER VARCHAR(100),
	EMAIL VARCHAR(100)
);

-- 2. ПРЕДСТАВИТЕЛИ ОРГАНИЗАЦИИ
CREATE TABLE ORGANIZATION_REPRESENTATIVES (
	ID_REPRESENTATIVE SERIAL PRIMARY KEY,
	SURNAME VARCHAR(100) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	PATRONYMIC VARCHAR(100),
	EMAIL VARCHAR(100) NOT NULL,
	PHONE_NUMBER VARCHAR(100) NOT NULL,
	ORGANIZATION_ID INT NOT NULL,
	CONSTRAINT FK_REPRESENTATIVE_ORGANIZATION FOREIGN KEY (ORGANIZATION_ID) REFERENCES ORGANIZATIONS (ID_ORGANIZATION)
);

-- 3. СТАТУСЫ ПРОЕКТОВ
CREATE TABLE PROJECTS_STATUSES (
	ID_PROJECTS_STATUSES SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300)
);

-- 4. ПРОЕКТЫ
CREATE TABLE PROJECTS (
	ID_PROJECT SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300) NOT NULL,
	START_DATE DATE NOT NULL,
	END_DATE DATE NOT NULL,
	STATUS_ID INT NOT NULL,
	REPRESENTATIVE_ID INT NOT NULL,
	CONSTRAINT FK_PROJECT_STATUS FOREIGN KEY (STATUS_ID) REFERENCES PROJECTS_STATUSES (ID_PROJECTS_STATUSES),
	CONSTRAINT FK_PROJECT_REPRESENTATIVE FOREIGN KEY (REPRESENTATIVE_ID) REFERENCES ORGANIZATION_REPRESENTATIVES (ID_REPRESENTATIVE)
);

-- 5. ДОЛЖНОСТИ
CREATE TABLE POSITIONS (
	ID_POSITION SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300)
);

-- 6. СОТРУДНИКИ
CREATE TABLE WORKERS (
	ID_WORKER SERIAL PRIMARY KEY,
	SURNAME VARCHAR(100) NOT NULL,
	NAME VARCHAR(100) NOT NULL,
	PATRONYMIC VARCHAR(100),
	EMAIL VARCHAR(100) NOT NULL,
	DATE_OF_EMPLOYMENT DATE NOT NULL,
	POSITION_ID INT NOT NULL,
	CONSTRAINT FK_WORKER_POSITION FOREIGN KEY (POSITION_ID) REFERENCES POSITIONS (ID_POSITION)
);

ALTER TABLE WORKERS ADD COLUMN PHONE_NUMBER VARCHAR(20);

-- 7. ПОЛЬЗОВАТЕЛИ
CREATE TABLE USERS (
	ID_USER SERIAL PRIMARY KEY,
	LOGIN VARCHAR(100) NOT NULL,
	PASSWORD_HASH VARCHAR(300) NOT NULL,
	PASSWORD_SALT VARCHAR(300) NOT NULL,
	ID_WORKER INT UNIQUE,
	CONSTRAINT FK_USERS_WORKER FOREIGN KEY (ID_WORKER) REFERENCES WORKERS (ID_WORKER)
);
ALTER TABLE USERS 
ADD COLUMN AVATAR BYTEA;
-- 8. КОМАНДЫ ПРОЕКТОВ
CREATE TABLE PROJECTS_TEAM (
	PROJECTS_ID INT NOT NULL,
	WORKERS_ID INT NOT NULL,
	CONSTRAINT PK_PROJECTS_TEAM PRIMARY KEY (PROJECTS_ID, WORKERS_ID),
	CONSTRAINT FK_PROJECTS_TEAM_PROJECT FOREIGN KEY (PROJECTS_ID) REFERENCES PROJECTS (ID_PROJECT),
	CONSTRAINT FK_PROJECTS_TEAM_WORKER FOREIGN KEY (WORKERS_ID) REFERENCES WORKERS (ID_WORKER)
);

-- 9. ЦЕЛИ ПРОЕКТА
CREATE TABLE PROJECTS_PURPOSES (
	ID_PROJECTS_PURPOSES SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300),
	PROJECTS_ID INT NOT NULL,
	WORKER_ID INT NOT NULL,
	CONSTRAINT FK_PROJECTS_PURPOSES_PROJECT FOREIGN KEY (PROJECTS_ID) REFERENCES PROJECTS (ID_PROJECT),
	CONSTRAINT FK_PROJECTS_PURPOSES_WORKER FOREIGN KEY (WORKER_ID) REFERENCES WORKERS (ID_WORKER)
);

-- 10. РАСЧЁТНЫЙ ПЕРИОД
CREATE TABLE BILLING_PERIOD (
	ID_BILLING_PERIOD SERIAL PRIMARY KEY,
	START_DATE DATE NOT NULL,
	END_DATE DATE
);

-- 11. ЗАРПЛАТА
CREATE TABLE SALARY (
	ID_SALARY SERIAL PRIMARY KEY,
	HOUR_SUM DECIMAL(10, 2) NOT NULL,
	PAYOUT_CURRENCY_RATE VARCHAR(100) NOT NULL,
	BASIC_SUM DECIMAL(19, 4) NOT NULL,
	TASKS_COUNT_POINT DECIMAL(10, 2) NOT NULL,
	TOTAL_SALARY DECIMAL(19, 4) NOT NULL,
	WORKER_ID INT NOT NULL,
	BILLING_PERIOD_ID INT NOT NULL,
	CONSTRAINT FK_SALARY_WORKER FOREIGN KEY (WORKER_ID) REFERENCES WORKERS (ID_WORKER),
	CONSTRAINT FK_SALARY_BILLING_PERIOD FOREIGN KEY (BILLING_PERIOD_ID) REFERENCES BILLING_PERIOD (ID_BILLING_PERIOD)
);

-- 12. ТИПЫ ЗАДАЧ
CREATE TABLE TASKS_TYPES (
	ID_TYPE SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300)
);

-- 13. ПРИОРИТЕТЫ ЗАДАЧ
CREATE TABLE TASKS_PRIORITIES (
	ID_TASKS_PRIORITY SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300)
);

-- 14. СТАТУСЫ ЗАДАЧ
CREATE TABLE TASKS_STATUSES (
	ID_STATUS SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300)
);

-- 15. ЗАДАЧИ
CREATE TABLE TASKS (
	ID_TASK SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300) NOT NULL,
	POINTS_OF_TASK INT NOT NULL,
	CREATION_DATE DATE NOT NULL,
	DEADLINE DATE NOT NULL,
	STATUS_ID INT NOT NULL,
	PROJECT_ID INT NOT NULL,
	TASK_TYPE_ID INT NOT NULL,
	TASK_PRIORITY_ID INT NOT NULL,
	CONSTRAINT FK_TASKS_PROJECT FOREIGN KEY (PROJECT_ID) REFERENCES PROJECTS (ID_PROJECT),
	CONSTRAINT FK_TASKS_STATUS FOREIGN KEY (STATUS_ID) REFERENCES TASKS_STATUSES (ID_STATUS),
	CONSTRAINT FK_TASKS_TYPE FOREIGN KEY (TASK_TYPE_ID) REFERENCES TASKS_TYPES (ID_TYPE),
	CONSTRAINT FK_TASKS_PRIORITY FOREIGN KEY (TASK_PRIORITY_ID) REFERENCES TASKS_PRIORITIES (ID_TASKS_PRIORITY)
);
ALTER TABLE TASKS
ALTER COLUMN DESCRIPTION DROP NOT NULL;
-- 16. РЕЖИМ НАЗНАЧЕНИЯ
CREATE TABLE DESTINATION_MODE (
	ID_DESTINATION_MODE SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(300)
);

-- 17. ВЫБОР ЗАДАЧИ СОТРУДНИКОМ
CREATE TABLE WORKERS_CHOICE (
	ID_WORKER_CHOICE SERIAL PRIMARY KEY,
	BONUSES VARCHAR(100) NOT NULL,
	WORKER_ID INT NOT NULL,
	TASK_ID INT NOT NULL,
	DESTINATION_MODE_ID INT NOT NULL,
	CONSTRAINT FK_WORKER_CHOICE_WORKER FOREIGN KEY (WORKER_ID) REFERENCES WORKERS (ID_WORKER),
	CONSTRAINT FK_WORKER_CHOICE_TASK FOREIGN KEY (TASK_ID) REFERENCES TASKS (ID_TASK)
);

-- 18. ИСТОРИЯ ПРОЕКТОВ
CREATE TABLE PROJECTS_HISTORY (
	ID_PROJECT_HISTORY SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	CREATION_DATE DATE NOT NULL,
	END_DATE DATE,
	PROJECT_ID INT NOT NULL,
	CONSTRAINT FK_PROJECT_HISTORY_PROJECT FOREIGN KEY (PROJECT_ID) REFERENCES PROJECTS (ID_PROJECT)
);

-- 19. ИСТОРИЯ ЗАДАЧ
CREATE TABLE TASKS_HISTORY (
	ID_TASK_HISTORY SERIAL PRIMARY KEY,
	NAME VARCHAR(100) NOT NULL,
	CREATION_DATE DATE NOT NULL,
	END_DATE DATE,
	TASK_ID INT NOT NULL,
	CONSTRAINT FK_TASKS_HISTORY_TASK FOREIGN KEY (TASK_ID) REFERENCES TASKS (ID_TASK)
);

-- 20. ИСТОРИЯ ЗАДАЧ И ПРОЕКТОВ
CREATE TABLE PROJECTS_TASKS_HISTORY (
	H_PROJECTS_ID INT NOT NULL,
	H_TASKS_ID INT NOT NULL,
	CONSTRAINT PK_PROJECTS_TASKS_HISTORY PRIMARY KEY (H_PROJECTS_ID, H_TASKS_ID),
	CONSTRAINT FK_HISTORY_TASKS FOREIGN KEY (H_TASKS_ID) REFERENCES TASKS_HISTORY (ID_TASK_HISTORY),
	CONSTRAINT FK_HISTORY_PROJECTS FOREIGN KEY (H_PROJECTS_ID) REFERENCES PROJECTS_HISTORY (ID_PROJECT_HISTORY)
);

-- 21. СОТРУДНИКИ В ПРОЕКТАХ (ИСТОРИЯ)
CREATE TABLE WORKERS_IN_PROJECTS (
	H_PROJECTS_ID INT NOT NULL,
	WORKER_ID INT NOT NULL,
	CONSTRAINT PK_WORKERS_IN_PROJECTS PRIMARY KEY (H_PROJECTS_ID, WORKER_ID),
	CONSTRAINT FK_WIP_HISTORY_PROJECT FOREIGN KEY (H_PROJECTS_ID) REFERENCES PROJECTS_HISTORY (ID_PROJECT_HISTORY),
	CONSTRAINT FK_WIP_WORKER FOREIGN KEY (WORKER_ID) REFERENCES WORKERS (ID_WORKER)
);
-- 1. ОРГАНИЗАЦИИ
INSERT INTO
	ORGANIZATIONS (
		NAME,
		INN,
		KPP,
		LEGAL_ADDRESS,
		ACTUAL_ADDRESS,
		PHONE_NUMBER,
		EMAIL
	)
VALUES
	(
		'ООО "Вектор"',
		'7711223344',
		'770101001',
		'г. Москва, ул. Ленина, 10',
		'г. Москва, ул. Ленина, 10',
		'+74950000001',
		'info@vector.com'
	),
	(
		'ЗАО "Техно"',
		'5022334455',
		'500202002',
		'г. СПб, ул. Пушкина, 5',
		'г. СПб, ул. Пушкина, 5',
		'+78120000002',
		'tech@zao.ru'
	),
	(
		'ИП Сидоров',
		'770011223344',
		NULL,
		'г. Казань, ул. Баумана, 1',
		NULL,
		'+79998887766',
		'sidorov@biz.ru'
	);

-- 2. ПРЕДСТАВИТЕЛИ ОРГАНИЗАЦИИ
INSERT INTO
	ORGANIZATION_REPRESENTATIVES (
		SURNAME,
		NAME,
		PATRONYMIC,
		EMAIL,
		PHONE_NUMBER,
		ORGANIZATION_ID
	)
VALUES
	(
		'Смирнов',
		'Алексей',
		'Директорович',
		'smirnov@vector.com',
		'+79001112233',
		1
	),
	(
		'Иванова',
		'Мария',
		'Сергеевна',
		'maria@vector.com',
		'+79004445566',
		1
	),
	(
		'Петров',
		'Дмитрий',
		'Сисадминов',
		'petrov@zao.ru',
		'+79007778899',
		2
	),
	(
		'Сидоров',
		'Петр',
		'Ильич',
		'peter@biz.ru',
		'+79005556677',
		3
	);

-- 3. СТАТУСЫ ПРОЕКТОВ
INSERT INTO
	PROJECTS_STATUSES (NAME, DESCRIPTION)
VALUES
	('Планируется', 'Проект еще не начат'),
	('В разработке', 'Активная фаза работы'),
	('Тестирование', 'Проверка функционала'),
	('Завершен', 'Проект сдан заказчику'),
	('Заморожен', 'Работы приостановлены');

-- 4. ПРОЕКТЫ
INSERT INTO
	PROJECTS (
		NAME,
		DESCRIPTION,
		START_DATE,
		END_DATE,
		STATUS_ID,
		REPRESENTATIVE_ID
	)
VALUES
	(
		'Корпоративный портал',
		'Сайт для сотрудников',
		'2023-09-01',
		'2023-12-31',
		2,
		1
	),
	(
		'Мобильное приложение',
		'Магазин цветов',
		'2023-10-15',
		'2024-02-20',
		2,
		2
	),
	(
		'CRM система',
		'Учет клиентов',
		'2023-08-01',
		'2023-11-01',
		4,
		3
	),
	(
		'Лендинг пейдж',
		'Реклама товара',
		'2023-09-20',
		'2023-09-30',
		4,
		4
	),
	(
		'API склада',
		'Бэкенд учета',
		'2023-11-01',
		'2024-01-01',
		1,
		3
	);

-- 5. ДОЛЖНОСТИ
INSERT INTO
	POSITIONS (NAME, DESCRIPTION)
VALUES
	('Тимлид', 'Руководит командой и проектами'),
	(
		'Backend разработчик',
		'Пишет серверную логику (C#)'
	),
	(
		'Frontend разработчик',
		'Делает красиво (WPF/Web)'
	),
	('Дизайнер', 'Рисует макеты'),
	('Тестировщик', 'Ломает то, что сделали другие');

-- 6. СОТРУДНИКИ
INSERT INTO
	WORKERS (
		SURNAME,
		NAME,
		PATRONYMIC,
		EMAIL,
		DATE_OF_EMPLOYMENT,
		POSITION_ID
	)
VALUES
	(
		'Мяу',
		'Анастасия',
		'Мур',
		'anastasia.meow@company.com',
		'2022-01-10',
		1
	),
	(
		'Котиков',
		'Борис',
		'Барсикович',
		'boris@company.com',
		'2022-05-20',
		2
	),
	(
		'Собакин',
		'Шарик',
		'Бобикович',
		'sharik@company.com',
		'2023-02-15',
		3
	),
	(
		'Птичкина',
		'Елена',
		'Карловна',
		'elena@company.com',
		'2023-06-01',
		4
	),
	(
		'Рыбкина',
		'Ольга',
		'Водолазовна',
		'olga@company.com',
		'2023-08-10',
		5
	);

UPDATE WORKERS
SET
	EMAIL = 'moiaeda75@gmail.com'
WHERE
	ID_WORKER = 1;

UPDATE WORKERS
SET
	EMAIL = 'moiaeda75@gmail.com'
WHERE
	ID_WORKER = 1;

SELECT
	*
FROM
	WORKERS
	-- 7. ПОЛЬЗОВАТЕЛИ 
INSERT INTO
	USERS (LOGIN, PASSWORD_HASH, PASSWORD_SALT, ID_WORKER)
VALUES
	(
		'a',
		'PxrJEXKWcsT6Mw5G196zASCyjQwQRE4gcTWdu0+h9tULjfao9G8jC5gC69qzL3AyS5cSIDjeJVF0jxcvOkZOAQ==',
		'EqFN+oUQQi8tPsDhv/2hYCIIm0J5tbwazcsapYt3UPGHrYQkVfbf/s45yzr7PkemooHiZxLU5RoBLFfFz5gAKQ==',
		1
	);
SELECT
	*
FROM
	USERS
-- 8. ТИПЫ ЗАДАЧ
INSERT INTO
	TASKS_TYPES (NAME, DESCRIPTION)
VALUES
	('Разработка', 'Написание кода'),
	('Дизайн', 'Отрисовка макетов'),
	('Багфикс', 'Исправление ошибок'),
	('Аналитика', 'Сбор требований'),
	('Тест', 'Проверка работоспособности');

-- 9. ПРИОРИТЕТЫ
INSERT INTO
	TASKS_PRIORITIES (NAME, DESCRIPTION)
VALUES
	('Низкий', 'Может подождать'),
	('Средний', 'Обычная задача'),
	('Высокий', 'Нужно сделать скоро'),
	('Критический', 'Всё горит!'),
	('Горящая', 'Спец. статус для балльной системы');

-- 10. СТАТУСЫ ЗАДАЧ
INSERT INTO
	TASKS_STATUSES (NAME, DESCRIPTION)
VALUES
	('К выполнению', 'Задача назначена'),
	('В работе', 'Сотрудник делает'),
	('На проверке', 'Ждет аппрува'),
	('Готово', 'Сделано'),
	('Отменена', 'Не актуально');

-- 11. ЗАДАЧИ
INSERT INTO
	TASKS (
		NAME,
		DESCRIPTION,
		POINTS_OF_TASK,
		CREATION_DATE,
		DEADLINE,
		STATUS_ID,
		PROJECT_ID,
		TASK_TYPE_ID,
		TASK_PRIORITY_ID
	)
VALUES
	(
		'Закупить кирпичи',
		'Нужны красные кирпичи',
		50,
		'2023-11-01',
		'2023-11-05',
		1,
		1,
		1,
		2
	),
	(
		'Сделать макет главной',
		'Красивый дизайн',
		80,
		'2023-11-02',
		'2023-11-10',
		2,
		2,
		2,
		3
	),
	(
		'Исправить баг в логине',
		'Не входит под админом',
		100,
		'2023-11-03',
		'2023-11-04',
		1,
		1,
		3,
		5
	),
	(
		'Написать документацию',
		'Описать API',
		40,
		'2023-11-05',
		'2023-11-15',
		4,
		3,
		4,
		1
	),
	(
		'Собрать сервер',
		'Установить Ubuntu и Docker',
		150,
		'2023-11-01',
		'2023-11-02',
		4,
		4,
		1,
		4
	);

-- 12. КОМАНДЫ ПРОЕКТОВ
INSERT INTO
	PROJECTS_TEAM (PROJECTS_ID, WORKERS_ID)
VALUES
	(1, 1),
	(2, 1),
	(1, 2),
	(2, 3),
	(3, 4);

-- ЗАВЕРШЕНИЕ ТРАНЗАКЦИИ
COMMIT;

-- НАЧАЛО ТРАНЗАКЦИИ
BEGIN;

DROP TABLE IF EXISTS WORKERS_CHOICE CASCADE;
DROP TABLE IF EXISTS DESTINATION_MODE CASCADE;
TRUNCATE TABLE 
    USERS, 
    SALARY, 
    PROJECTS_TEAM, 
    PROJECTS_PURPOSES, 
    WORKERS_IN_PROJECTS, 
    PROJECTS_TASKS_HISTORY, 
    TASKS_HISTORY, 
    PROJECTS_HISTORY, 
    TASKS, 
    TASKS_PRIORITIES, 
    TASKS_TYPES, 
    TASKS_STATUSES, 
    WORKERS, 
    POSITIONS, 
    PROJECTS, 
    PROJECTS_STATUSES, 
    ORGANIZATION_REPRESENTATIVES, 
    ORGANIZATIONS,
    BILLING_PERIOD
RESTART IDENTITY CASCADE;
-- 1. ОРГАНИЗАЦИИ
INSERT INTO ORGANIZATIONS (NAME, INN, KPP, LEGAL_ADDRESS, ACTUAL_ADDRESS, PHONE_NUMBER, EMAIL) VALUES
('ООО "Вектор"', '7711223344', '770101001', 'г. Москва, ул. Ленина, 10', 'г. Москва, ул. Ленина, 10', '+74950000001', 'info@vector.com'),
('ЗАО "Техно"', '5022334455', '500202002', 'г. СПб, ул. Пушкина, 5', 'г. СПб, ул. Пушкина, 5', '+78120000002', 'tech@zao.ru'),
('ИП Сидоров', '770011223344', NULL, 'г. Казань, ул. Баумана, 1', NULL, '+79998887766', 'sidorov@biz.ru');

-- 2. ПРЕДСТАВИТЕЛИ 
INSERT INTO ORGANIZATION_REPRESENTATIVES (SURNAME, NAME, PATRONYMIC, EMAIL, PHONE_NUMBER, ORGANIZATION_ID) VALUES
('Смирнов', 'Алексей', 'Директорович', 'smirnov@vector.com', '+79001112233', 1), 
('Иванова', 'Мария', 'Сергеевна', 'maria@vector.com', '+79004445566', 1),      
('Петров', 'Дмитрий', 'Сисадминов', 'petrov@zao.ru', '+79007778899', 2),      
('Сидоров', 'Петр', 'Ильич', 'peter@biz.ru', '+79005556677', 3); 

-- 3. СТАТУСЫ ПРОЕКТОВ
INSERT INTO PROJECTS_STATUSES (NAME, DESCRIPTION) VALUES 
('Планируется', 'Проект еще не начат'),
('В разработке', 'Активная фаза работы'),
('Тестирование', 'Проверка функционала'),
('Завершен', 'Проект сдан заказчику'),
('Заморожен', 'Работы приостановлены');

-- 4. ПРОЕКТЫ
INSERT INTO PROJECTS (NAME, DESCRIPTION, START_DATE, END_DATE, STATUS_ID, REPRESENTATIVE_ID) VALUES
('Корпоративный портал', 'Сайт для сотрудников', '2023-09-01', '2023-12-31', 2, 1), 
('Мобильное приложение', 'Магазин цветов', '2023-10-15', '2024-02-20', 2, 2),        
('CRM система', 'Учет клиентов', '2023-08-01', '2023-11-01', 4, 3),                 
('Лендинг пейдж', 'Реклама товара', '2023-09-20', '2023-09-30', 4, 4),              
('API склада', 'Бэкенд учета', '2023-11-01', '2024-01-01', 1, 3); 

-- 5. ДОЛЖНОСТИ 
INSERT INTO POSITIONS (NAME, DESCRIPTION) VALUES
('Сотрудник', 'Выполняет задачи, отмечает завершённые, просматривает историю. Прав мало.'),
('Админ', 'Управляет проектами и сотрудниками, меняет историю. Нет доступа к ЗП.'),
('Тимлид', 'Управляет своими проектами, видит историю, отвечает за зарплату.');

-- 6. СОТРУДНИКИ 
INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID) VALUES
('Мяу', 'Анастасия', 'Мур', 'moiaeda75@gmail.com', '2007-10-30', 4), -- ID 1, TeamLead
('Пук', 'Кристина', 'Попит', 'titiitiiii@mail.ru', '2007-09-20', 5), -- ID 2, Admin
('Смирнов', 'Иван', 'Иванович', 'aniania0000@gmail.com', '2023-01-15', 6), -- ID 3, Worker (Спец. почта)
('Козлов', 'Петр', 'Петрович', 'kozlov@mail.ru', '2023-02-20', 6),    -- ID 4
('Сидорова', 'Анна', 'Михайловна', 'anna@yandex.ru', '2023-03-10', 6), -- ID 5
('Волков', 'Олег', 'Сергеевич', 'oleg@gmail.com', '2023-04-05', 6),    -- ID 6
('Зайцева', 'Ирина', 'Викторовна', 'ira@mail.ru', '2023-05-12', 6),    -- ID 7
('Лисицын', 'Артем', 'Павлович', 'artem@bk.ru', '2023-06-18', 6),      -- ID 8
('Медведев', 'Дмитрий', 'Анатольевич', 'dima@ya.ru', '2023-07-25', 6), -- ID 9
('Белова', 'Ольга', 'Игоревна', 'olga_b@gmail.com', '2023-08-30', 6);  -- ID 10

-- 7. ПОЛЬЗОВАТЕЛИ
INSERT INTO USERS (LOGIN, PASSWORD_HASH, PASSWORD_SALT, ID_WORKER) VALUES
('a', 
 '6lhgSXh7zPzKjIDryMBkmuLm5+Q/0TFqcwBGh85KZgr/RLwGojjkHicKBwOdDAw4/0szzp5TkXFB+q12LIJVbw==', 
 'dYlCyX2SPj8z6KoXNfsJurOzs5aeGy5SOwypyc7HvSpWV/WzdMIFmJP5x/wS25K8ijLBJpz+XKjFTGBkt+7zIg==', 
 12);
-- 8. ПРИОРИТЕТЫ ЗАДАЧ
INSERT INTO TASKS_PRIORITIES (NAME, DESCRIPTION) VALUES
('Обычная', 'Простая задача для всех сотрудников проекта'),
('Горящая', 'Индивидуальная задача, привязанная к сотруднику');

-- 9. ТИПЫ БАЛЛОВ
INSERT INTO TASKS_TYPES (NAME, DESCRIPTION) VALUES
('Базовые', 'Стандартное начисление'),
('Срочные', 'Повышенный коэффициент');

-- 10. СТАТУСЫ ЗАДАЧ
INSERT INTO TASKS_STATUSES (NAME, DESCRIPTION) VALUES
('Выполнена', 'Задача полностью завершена'),
('В процессе', 'Задача взята в работу');

-- 11. ЗАДАЧИ
INSERT INTO TASKS (NAME, DESCRIPTION, POINTS_OF_TASK, CREATION_DATE, DEADLINE, STATUS_ID, PROJECT_ID, TASK_TYPE_ID, TASK_PRIORITY_ID) VALUES
-- Проект 1
('Дизайн главной', 'Отрисовка в Figma', 100, '2023-11-01', '2023-11-10', 2, 1, 1, 1),
('Верстка хедера', 'HTML/CSS', 50, '2023-11-02', '2023-11-11', 2, 1, 1, 1),
('База данных', 'Создание таблиц', 80, '2023-11-03', '2023-11-12', 1, 1, 2, 2),
-- Проект 2
('Анализ ЦА', 'Маркетинг', 60, '2023-11-05', '2023-11-15', 2, 2, 1, 1),
('Прототип', 'Черновик приложения', 90, '2023-11-06', '2023-11-16', 2, 2, 1, 2),
('API авторизации', 'JWT токены', 100, '2023-11-07', '2023-11-17', 2, 2, 2, 2),
-- Проект 3
('Настройка CRM', 'Импорт клиентов', 70, '2023-11-01', '2023-11-20', 1, 3, 1, 1),
('Отчетность', 'Выгрузка в Excel', 80, '2023-11-02', '2023-11-21', 2, 3, 1, 1),
-- Проект 4
('Текст для лендинга', 'Копирайтинг', 50, '2023-11-10', '2023-11-12', 1, 4, 1, 2),
('Поиск картинок', 'Фотосток', 50, '2023-11-11', '2023-11-13', 2, 4, 1, 1),
-- Проект 5
('Логистика', 'Алгоритм путей', 100, '2023-11-01', '2024-01-01', 2, 5, 2, 2),
('Интеграция 1С', 'Обмен данными', 90, '2023-11-05', '2024-01-10', 2, 5, 2, 1);
SELECT FROM TASKS_TYPES;
-- 12. КОМАНДЫ ПРОЕКТОВ
INSERT INTO PROJECTS_TEAM (PROJECTS_ID, WORKERS_ID) VALUES
(1, 1), (1, 3), (1, 4), (1, 5), (1, 6),
(2, 1), (2, 7), (2, 8), (2, 9),
(3, 1), (3, 3), (3, 10), (3, 5),
(4, 4), (4, 6), (4, 8), (4, 10),
(5, 3), (5, 5), (5, 7), (5, 9);
COMMIT;
INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID) 
VALUES ('Админов', 'Админ', 'Админович', 'admin@mail.ru', NOW(), 2);

INSERT INTO USERS (LOGIN, PASSWORD_HASH, PASSWORD_SALT, ID_WORKER) 
VALUES ('q', 'vwCZV/75anj2McA8Ma/yYDxt7U/kilgC0GkraKpK3xJSkLfQ7bz06af6+WB2ycPb0oJFfWl0jcKXdQMGJLuO9A==', 'B5z5XsuH7KtHmW0Kq4sSuTc5cVeR1vrTNb8bXmuCDmsqjxG18vq8i0T1NE4reks+Vb81zE9WIoPIuKcv3QfeUA==', 2);

INSERT INTO USERS (LOGIN, PASSWORD_HASH, PASSWORD_SALT, ID_WORKER) 
VALUES ('z', 'wKKnvNawgIaMPFxju4Nmkds8D/vB4M+xkN3x3fHq/ZujY71FXamd3eXMJBP5mEwTowxYhDJDgu1rexGLGuwAYQ==', 'i0lzkW3/kJMLRYco4DjoWSmEXO/YyK+5uZxAy522BU5+jpP7ecQhICKdP7iAGE9dceWCBUhLDquIiQntmhbROw==', 3);

ALTER TABLE TASKS 
ADD COLUMN WORKER_ID INT REFERENCES WORKERS(ID_WORKER);
COMMIT;
TRUNCATE TABLE POSITIONS RESTART IDENTITY CASCADE;
INSERT INTO POSITIONS (NAME, DESCRIPTION) VALUES
('Тимлид', 'Руководит командой и проектами, отвечает за зарплату'),
('Админ', 'Управляет проектами и сотрудниками, меняет историю'),
('Сотрудник', 'Выполняет задачи, отмечает завершённые, просматривает историю');

DELETE FROM POSITIONS;
UPDATE WORKERS SET
    SURNAME = 'Мяу',
    NAME = 'Анастасия',
    PATRONYMIC = 'Мур',
    EMAIL = 'moiaeda75@gmail.com',
    DATE_OF_EMPLOYMENT = '2007-10-30',
    POSITION_ID = 1
WHERE ID_WORKER = 1;

UPDATE WORKERS SET
    SURNAME = 'Пук',
    NAME = 'Кристина',
    PATRONYMIC = 'Попит',
    EMAIL = 'titiitiiii@mail.ru',
    DATE_OF_EMPLOYMENT = '2007-09-20',
    POSITION_ID = 2
WHERE ID_WORKER = 2;

UPDATE WORKERS SET
    SURNAME = 'Смирнов',
    NAME = 'Иван',
    PATRONYMIC = 'Иванович',
    EMAIL = 'aniania0000@gmail.com',
    DATE_OF_EMPLOYMENT = '2023-01-15',
    POSITION_ID = 3
WHERE ID_WORKER = 3;
INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Козлов', 'Петр', 'Петрович', 'kozlov@mail.ru', '2023-02-20', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'kozlov@mail.ru');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Сидорова', 'Анна', 'Михайловна', 'anna@yandex.ru', '2023-03-10', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'anna@yandex.ru');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Волков', 'Олег', 'Сергеевич', 'oleg@gmail.com', '2023-04-05', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'oleg@gmail.com');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Зайцева', 'Ирина', 'Викторовна', 'ira@mail.ru', '2023-05-12', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'ira@mail.ru');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Лисицын', 'Артем', 'Павлович', 'artem@bk.ru', '2023-06-18', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'artem@bk.ru');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Медведев', 'Дмитрий', 'Анатольевич', 'dima@ya.ru', '2023-07-25', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'dima@ya.ru');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Белова', 'Ольга', 'Игоревна', 'olga_b@gmail.com', '2023-08-30', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'olga_b@gmail.com');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Кузнецов', 'Александр', 'Владимирович', 'kuznetsov@mail.ru', '2023-09-15', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'kuznetsov@mail.ru');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Попова', 'Екатерина', 'Александровна', 'popova@yandex.ru', '2023-10-10', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'popova@yandex.ru');

INSERT INTO WORKERS (SURNAME, NAME, PATRONYMIC, EMAIL, DATE_OF_EMPLOYMENT, POSITION_ID)
SELECT 'Васильев', 'Сергей', 'Игоревич', 'vasilev@gmail.com', '2023-11-05', 3
WHERE NOT EXISTS (SELECT 1 FROM WORKERS WHERE EMAIL = 'vasilev@gmail.com');

DELETE FROM WORKERS WHERE ID_WORKER > 13;
UPDATE WORKERS 
SET POSITION_ID = 3 
WHERE ID_WORKER != 2;

UPDATE WORKERS 
SET POSITION_ID = 1 
WHERE ID_WORKER = 1;
SELECT * FROM WORKERS
SELECT * FROM WORKERS WHERE POSITION_ID = 1;
ALTER TABLE WORKERS ADD COLUMN GENDER VARCHAR(20);
ALTER TABLE WORKERS ADD COLUMN AGE INT;
ALTER TABLE PROJECTS ALTER COLUMN DESCRIPTION DROP NOT NULL;
ALTER TABLE TASKS ALTER COLUMN DESCRIPTION DROP NOT NULL;
ALTER TABLE PROJECTS_STATUSES ALTER COLUMN DESCRIPTION DROP NOT NULL;
ALTER TABLE POSITIONS ALTER COLUMN DESCRIPTION DROP NOT NULL;
ALTER TABLE TASKS_TYPES ALTER COLUMN DESCRIPTION DROP NOT NULL;
ALTER TABLE TASKS_PRIORITIES ALTER COLUMN DESCRIPTION DROP NOT NULL;
ALTER TABLE TASKS_STATUSES ALTER COLUMN DESCRIPTION DROP NOT NULL;
ALTER TABLE PROJECTS ADD COLUMN IF NOT EXISTS SYSTEM_CREATION_DATE TIMESTAMP DEFAULT NOW();

CREATE TABLE IF NOT EXISTS WORKERS_CHOICE (
    ID_WORKER_CHOICE SERIAL PRIMARY KEY,
    WORKER_ID INT NOT NULL,
    TASK_ID INT NOT NULL,
    CHOSEN_DATE TIMESTAMP DEFAULT NOW(),
    CONSTRAINT FK_WC_WORKER FOREIGN KEY (WORKER_ID) REFERENCES WORKERS (ID_WORKER) ON DELETE CASCADE,
    CONSTRAINT FK_WC_TASK FOREIGN KEY (TASK_ID) REFERENCES TASKS (ID_TASK) ON DELETE CASCADE,
    CONSTRAINT UQ_TASK_CHOICE UNIQUE (TASK_ID) 
);
CREATE TABLE IF NOT EXISTS SALARY (
    ID_SALARY SERIAL PRIMARY KEY,
    WORKER_ID INT NOT NULL,
    BASE_SALARY DECIMAL(10,2) DEFAULT 40000,
    TOTAL_POINTS INT DEFAULT 0,             
    FINAL_SALARY DECIMAL(10,2) DEFAULT 0,  
    CALC_DATE DATE DEFAULT CURRENT_DATE,
    CONSTRAINT FK_SALARY_WORKER FOREIGN KEY (WORKER_ID) REFERENCES WORKERS (ID_WORKER)
);

INSERT INTO TASKS_PRIORITIES (NAME, DESCRIPTION)
VALUES ('Горящая', 'Требует немедленного выполнения, повышенные баллы')
ON CONFLICT DO NOTHING;
COMMIT;
select from WORKERS
select * from PROJECTS_STATUSES

ALTER TABLE SALARY 
ADD COLUMN total_points INT DEFAULT 0,
ADD COLUMN base_salary DECIMAL(10,2) DEFAULT 40000,
ADD COLUMN final_salary DECIMAL(10,2) DEFAULT 0,
ADD COLUMN calc_date DATE DEFAULT CURRENT_DATE;

ALTER TABLE SALARY 
DROP COLUMN IF EXISTS hour_sum CASCADE,
DROP COLUMN IF EXISTS payout_currency_rate CASCADE,
DROP COLUMN IF EXISTS basic_sum CASCADE,
DROP COLUMN IF EXISTS tasks_count_point CASCADE,
DROP COLUMN IF EXISTS total_salary CASCADE,
DROP COLUMN IF EXISTS billing_period_id CASCADE;

UPDATE TASKS 
SET status_id = 1 
WHERE status_id IN (2, 3);
UPDATE TASKS_STATUSES 
SET name = 'В процессе', description = 'Задача выполняется' 
WHERE id_status = 1;

UPDATE TASKS_STATUSES 
SET name = 'Выполнена', description = 'Задача полностью завершена' 
WHERE id_status = 4;

UPDATE TASKS_STATUSES 
SET name = 'Проект заморожен', description = 'Проект приостановлен' 
WHERE id_status = 5;
DELETE FROM TASKS_STATUSES 
WHERE id_status IN (2, 3);

UPDATE SALARY 
SET total_points = 0;
UPDATE SALARY 
SET final_salary = base_salary;
UPDATE SALARY SET base_salary = 75000, final_salary = 75000 
WHERE worker_id IN (SELECT id_worker FROM WORKERS WHERE position_id = 1);

UPDATE SALARY SET base_salary = 85000, final_salary = 85000 
WHERE worker_id IN (SELECT id_worker FROM WORKERS WHERE position_id = 2);

UPDATE SALARY SET base_salary = 45000, final_salary = 45000 
WHERE worker_id IN (3, 4, 5); 

UPDATE SALARY SET base_salary = 50000, final_salary = 50000 
WHERE worker_id IN (6, 7, 8); 

UPDATE SALARY SET base_salary = 60000, final_salary = 60000 
WHERE worker_id > 8 AND worker_id IN (SELECT id_worker FROM WORKERS WHERE position_id = 3);

ALTER TABLE PROJECTS ADD COLUMN IF NOT EXISTS system_updated_date TIMESTAMP DEFAULT NOW();

UPDATE PROJECTS 
SET system_updated_date = system_creation_date 
WHERE system_updated_date IS NULL;

select * from WORKERS
-- Создание представления для детального просмотра проектов с именами вместо ID
CREATE OR REPLACE VIEW VIEW_PROJECTS_DETAILS AS
SELECT 
    p.ID_PROJECT AS "Код",
    p.NAME AS "Название проекта",
    ps.NAME AS "Текущий статус",
    rep.SURNAME || ' ' || rep.NAME AS "Представитель заказчика",
    org.NAME AS "Организация",
    p.START_DATE AS "Дата начала",
    p.END_DATE AS "Дедлайн"
FROM PROJECTS p
JOIN PROJECTS_STATUSES ps ON p.STATUS_ID = ps.ID_PROJECTS_STATUSES
JOIN ORGANIZATION_REPRESENTATIVES rep ON p.REPRESENTATIVE_ID = rep.ID_REPRESENTATIVE
JOIN ORGANIZATIONS org ON rep.ORGANIZATION_ID = org.ID_ORGANIZATION;

-- Вызов данных из представления
SELECT * FROM VIEW_PROJECTS_DETAILS;
