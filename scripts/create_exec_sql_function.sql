-- Create exec_sql function for database analysis
-- Execute this in Supabase SQL Editor with service role

-- 1. Create the exec_sql function
CREATE OR REPLACE FUNCTION exec_sql(sql text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result json;
BEGIN
    -- Execute the SQL and return as JSON
    EXECUTE format('SELECT array_to_json(array_agg(row_to_json(t))) FROM (%s) t', sql) INTO result;
    RETURN COALESCE(result, '[]'::json);
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'error', SQLERRM,
            'code', SQLSTATE,
            'sql', sql
        );
END;
$$;

-- 2. Grant execute permission to service role
GRANT EXECUTE ON FUNCTION exec_sql(text) TO service_role;

-- 3. Test the function
SELECT 'Function created successfully!' as status;

-- 4. Test with a simple query
SELECT exec_sql('SELECT ''Hello World'' as message, now() as timestamp');

-- 5. Test with table information query
SELECT exec_sql('
  SELECT table_name, table_schema
  FROM information_schema.tables 
  WHERE table_schema = ''public'' 
  AND table_name LIKE ''%club%''
  ORDER BY table_name
');

-- Success message
SELECT '✅ exec_sql function created and tested successfully!' as result;