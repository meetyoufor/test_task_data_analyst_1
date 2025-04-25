/*
-----------------------------------------------------------------------------------------------
---------------------------------------- З А Д А Н И Е ----------------------------------------
-----------------------------------------------------------------------------------------------
| Таблица 1 (содержит данные source A):                                                       |
| Date, Campaign, Ad, Impression, Click, Cost                                                 |
-----------------------------------------------------------------------------------------------
| Таблица 2 (содержит данные source B):                                                       |
| DateTime, Campaign, Ad, Impression, Click, Cost                                             |
-----------------------------------------------------------------------------------------------
| Таблица 3 (содержит данные различных source):                                               |
| Date, Source, Campaign, Ad, install, purchase                                               |
-----------------------------------------------------------------------------------------------
| Задача:                                                                                     |
| Написать запрос, который объединил бы все 3 таблицы. Выводил поля за текущий месяц:         |
| Date, Source, Campaign, Ad, SUM(Click), SUM(Cost), SUM(install), SUM(purchase)              |
| Замечания:                                                                                  |
| source в таблице 3 может быть больше 2                                                      |
| пример поля date: '2021-05-01', пример поля datetime '2021-05-01 12:31:47'                  |
| Запрос может содержать UNION/UNION ALL, но не должен являться единственным способом решения |
-----------------------------------------------------------------------------------------------
*/

SELECT
    dates.date,
    sources.source,
    campaigns.campaign,
    campaigns.ad,
    COALESCE(SUM(table1.click), 0) + COALESCE(SUM(table2.click), 0) as total_clicks,
    COALESCE(SUM(table1.cost), 0) + COALESCE(SUM(table2.cost), 0) as total_cost,
    COALESCE(SUM(table3.install), 0) as total_installs,
    COALESCE(SUM(table3.purchase), 0) as total_purchases

FROM (
    SELECT date FROM table1 UNION
    SELECT DATE(datetime) FROM table2 UNION
    SELECT date FROM table3
) AS dates

CROSS JOIN (
    SELECT 'A' AS Source UNION
    SELECT 'B'
) AS sources

CROSS JOIN (
    SELECT campaign, ad FROM table1 UNION
    SELECT campaign, ad FROM table2 UNION
    SELECT campaign, ad FROM table3
) AS campaigns

LEFT JOIN table1 ON
    table1.date = dates.date AND
    sources.source = 'A' AND
    table1.campaign = campaigns.campaign AND
    table1.ad = campaigns.ad
    
LEFT JOIN table2 ON
    DATE(table2.datetime) = dates.date AND
    sources.source = 'B' AND
    table2.campaign = campaigns.campaign AND
    table2.ad = campaigns.ad

LEFT JOIN table3 ON
    table3.date = dates.date AND
    table3.source = sources.source AND
    table3.campaign = campaigns.campaign AND
    table3.ad = campaigns.ad
    
WHERE dates.date >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY dates.date, sources.source, campaigns.campaign, campaigns.ad

HAVING (
    COALESCE(SUM(table1.click), 0) + COALESCE(SUM(table2.click), 0) +
    COALESCE(SUM(table1.cost), 0) + COALESCE(SUM(table2.cost), 0) +
    COALESCE(SUM(table3.install), 0) +
    COALESCE(SUM(table3.purchase), 0)
) > 0
    
ORDER BY dates.date, sources.source;
