-- 1. Сверка миграции данных
-- Компания, количество строк, общая сумма. Проверка, 
-- что при переносе ничего не потерялось
SELECT 
    c.company_name AS company,
    COUNT(p.procedure_code) AS procedure_count,
    SUM(p.initial_amount) AS budget
FROM procurement p
JOIN companies c ON p.company_id = c.id
GROUP BY c.company_name
ORDER BY 3 DESC;

-- 2. Закупки c нулевой стоимостью
-- Показывает процедуры, где начальная сумма равна нулю,
-- для выявления скрытых заявок или технических ошибок
SELECT 
    p.procedure_code AS procedure_id,
    c.company_name,
    p.title AS title,
    p.published_at AS published_at
FROM procurement p
JOIN companies c ON p.company_id = c.id
WHERE p.initial_amount = 0.00
ORDER BY p.published_at DESC;

-- 3. Анализ способов закупки
-- Анализ количества денег по разным типам проведения процедур.
-- Помогает увидеть долю неконкурентных закупок
SELECT 
    pm.method_name AS method,
    COUNT(p.procedure_code) AS count_procedure,
    ROUND(COUNT(p.procedure_code) * 100.0 / (SELECT COUNT(*) FROM procurement), 2) AS fraction_by_amount,
    SUM(p.initial_amount) AS budget,
    ROUND(SUM(p.initial_amount) * 100.0 / (SELECT SUM(initial_amount) FROM procurement_flat), 2) AS fraction_by_amount
FROM procurement p
JOIN procurement_methods pm ON p.method_id = pm.id
GROUP BY pm.method_name
ORDER BY budget DESC;

-- 4. Оценка комплеанс-рисков
-- Ищет заявки стоимостью >10млн, где разница между датой публикации
-- и датой окончания меньше 5 дней.
SELECT 
    p.procedure_code,
    c.company_name,
    p.title,
    p.initial_amount AS sum,
    (p.deadline_at - p.published_at) AS sudmission_deadline
FROM procurement p
JOIN companies c ON p.company_id = c.id
WHERE (p.deadline_at - p.published_at) < INTERVAL '5 days'
  AND p.initial_amount > 10000000.00
ORDER BY 5 ASC, 4 DESC;

-- 5. Проверка расходов по ИТ-категориям.
-- Группирует данные по категориям и показывает сумму затрат
SELECT 
    pt.type_name AS name,
    COUNT(p.procedure_code) AS count_procedure,
    SUM(p.initial_amount) AS budget,
    AVG(p.initial_amount) AS average
FROM procurement p
JOIN procurement_types pt ON p.type_id = pt.id
GROUP BY pt.type_name
ORDER BY 3 DESC;