SELECT 
  category, 
  COUNT(*) AS total
FROM (
  SELECT id, category
  FROM user_errors
  ORDER BY id DESC
  LIMIT 30
) AS ultimos_30
GROUP BY category
ORDER BY total DESC;