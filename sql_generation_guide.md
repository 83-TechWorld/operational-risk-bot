# SQL Query Generation Guide

When asked to generate SQL, follow these strict rules:

## Security Rules (CRITICAL):
1. ALWAYS include user context filter in WHERE clause:
   - ou = '{user_ou}'
   - lre = '{user_lre}'
   - country = '{user_country}'

2. These filters are MANDATORY for every query

## eControls Schema:
Tables:
- users (user_id, username, email, user_ou, user_lre, user_country, is_active)
- controls (control_id, control_ref, control_name, control_description, ou, lre, country, review_status, assigned_to, created_at)
- control_reviews (review_id, control_id, reviewer_id, review_comments, review_status, review_date)

## MyKRI Schema:
Tables:
- users (user_id, username, email, user_ou, user_lre, user_country, is_active)
- kri_indicators (kri_id, kri_ref, kri_name, kri_description, ou, lre, country, status, threshold_value, created_at)
- kri_values (value_id, kri_id, entered_by, kri_value, entry_date, comments)

## SQL Generation Examples:

### Example 1: Count Query
User Query: "How many controls are pending?"
User Context: ou=Finance, lre=US Entity, country=USA

Generated SQL:
SELECT COUNT(*) as count 
FROM controls 
WHERE review_status = 'Pending' 
  AND ou = 'Finance' 
  AND lre = 'US Entity' 
  AND country = 'USA';

### Example 2: List Query
User Query: "Show me all controls"
User Context: ou=Finance, lre=US Entity, country=USA

Generated SQL:
SELECT control_id, control_ref, control_name, review_status, created_at
FROM controls 
WHERE ou = 'Finance' 
  AND lre = 'US Entity' 
  AND country = 'USA'
ORDER BY created_at DESC;

### Example 3: Update Query
User Query: "Update status to Completed for CTRL-2024-001"
User Context: ou=Finance, lre=US Entity, country=USA

Generated SQL:
UPDATE controls 
SET review_status = 'Completed', updated_at = CURRENT_TIMESTAMP
WHERE control_ref = 'CTRL-2024-001' 
  AND ou = 'Finance' 
  AND lre = 'US Entity' 
  AND country = 'USA';

### Example 4: Insert KRI Value
User Query: "Enter value 85 for KRI-2024-001"
User Context: ou=Finance, lre=US Entity, country=USA, user_id=1

Generated SQL:
INSERT INTO kri_values (kri_id, entered_by, kri_value, entry_date, comments)
SELECT kri_id, 1, '85', CURRENT_TIMESTAMP, 'Entered via chatbot'
FROM kri_indicators 
WHERE kri_ref = 'KRI-2024-001' 
  AND ou = 'Finance' 
  AND lre = 'US Entity' 
  AND country = 'USA';

### Example 5: Join Query
User Query: "Show me controls reviewed by john.doe"
User Context: ou=Finance, lre=US Entity, country=USA

Generated SQL:
SELECT c.control_ref, c.control_name, cr.review_status, cr.review_date
FROM controls c
JOIN control_reviews cr ON c.control_id = cr.control_id
JOIN users u ON cr.reviewer_id = u.user_id
WHERE u.username = 'john.doe'
  AND c.ou = 'Finance' 
  AND c.lre = 'US Entity' 
  AND c.country = 'USA'
ORDER BY cr.review_date DESC;

## Response Format:
Return ONLY the SQL query, no explanations or markdown.